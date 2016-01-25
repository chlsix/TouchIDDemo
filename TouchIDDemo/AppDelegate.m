//
//  AppDelegate.m
//  TouchIDDemo
//
//  Created by 陈磊 on 16/1/25.
//  Copyright © 2016年 ShenSu. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:[mainSB instantiateViewControllerWithIdentifier:@"ViewController"]];
    self.window.rootViewController = navc;
    
    //应用启动的时候，指纹验证
    [self applicationWillEnterForeground:application];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

//应用即将进去前台的时候，验证指纹
- (void)applicationWillEnterForeground:(UIApplication *)application {
    //判断是否开启了指纹验证
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"touchOn"] intValue]) {
        //设置一个全屏的半透明view，如果不设置这个view的话指纹alert不会消失
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [[[UIApplication sharedApplication] keyWindow] addSubview:view];
        
        //初始化
        LAContext *context = [LAContext new];
        /** 这个属性用来设置指纹错误后的弹出框的按钮文字
         *  不设置默认文字为“输入密码”
         *  设置@""将不会显示指纹错误后的弹出框
         */
        context.localizedFallbackTitle = @"忘记密码";
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"指纹验证"
                          reply:^(BOOL success, NSError * _Nullable error) {
                              if (success) {
                                  NSLog(@"指纹识别成功");
                                  //在主线程刷新view，不然会有卡顿
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [view removeFromSuperview];
                                  });
                              } else {
                                  if (error.code == kLAErrorUserFallback) {
                                      NSLog(@"Fallback按钮被点击");
                                  } else if (error.code == kLAErrorUserCancel) {
                                      NSLog(@"取消按钮被点击");
                                  } else {
                                      NSLog(@"指纹识别失败");
                                  }
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [view removeFromSuperview];
                                  });
                              }
                          }];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
