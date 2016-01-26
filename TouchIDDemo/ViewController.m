//
//  ViewController.m
//  TouchIDDemo
//
//  Created by 陈磊 on 16/1/25.
//  Copyright © 2016年 ShenSu. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.navigationItem.title = @"指纹解锁";
    [self.touchSwitch setOn:[[[NSUserDefaults standardUserDefaults] valueForKey:@"touchOn"] intValue] animated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchClick:(UISwitch *)sender {
    //初始化
    LAContext *context = [LAContext new];
    /** 这个属性用来设置指纹错误后的弹出框的按钮文字
     *  不设置默认文字为“输入密码”
     *  设置@""将不会显示指纹错误后的弹出框
     */
    context.localizedFallbackTitle = @"忘记密码";
    NSError *error;
    //判断设备支不支持Touch ID
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        NSLog(@"设备支持Touch ID");
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.view addSubview:view];
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"指纹验证"
                          reply:^(BOOL success, NSError * _Nullable error) {
                              if (success) {
                                  //验证成功执行
                                  NSLog(@"指纹识别成功");
                                  //在主线程刷新view，不然会有卡顿
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [view removeFromSuperview];
                                      //保存设置状态
                                      [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d", sender.isOn] forKey:@"touchOn"];
                                  });
                              } else {
                                  if (error.code == kLAErrorUserFallback) {
                                      //Fallback按钮被点击执行
                                      NSLog(@"Fallback按钮被点击");
                                  } else if (error.code == kLAErrorUserCancel) {
                                      //取消按钮被点击执行
                                      NSLog(@"取消按钮被点击");
                                  } else {
                                      //指纹识别失败执行
                                      NSLog(@"指纹识别失败");
                                  }
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [view removeFromSuperview];
                                      [sender setOn:!sender.isOn animated:YES];
                                      [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d", sender.isOn] forKey:@"touchOn"];
                                  });
                              }
                          }];
    } else {
        NSLog(@"设备不支持Touch ID: %@", error);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备不支持Touch ID" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [sender setOn:0 animated:YES];
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d", sender.isOn] forKey:@"touchOn"];
        }];
        [alert addAction:action];
        
    }
}


@end
