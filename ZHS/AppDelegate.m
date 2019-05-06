//
//  AppDelegate.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/16.
//  Copyright © 2015年 邢小迪. All rights reserved.
//
#define LAST_RUN_VERSION_KEY        @"last_run_version_of_application"
#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define _IPHONE80_ 80000
#import "AppDelegate.h"
#import "TNApplication.h"
#import "TNFlowUtil.h"
#import "UMSocial.h"
#import <AlipaySDK/AlipaySDK.h>
#import "TNAlipayManager.h"
#import "UMessage.h"
#import "PlayerController.h"
#import "TNWXPayManager.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocialQQHandler.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    self.isCurrentVersion = [self isCurrentVersionJudge];
    // start basic application.
    [[TNApplication sharedApplication] startWithLaunchOptions:launchOptions];
    // start entry
    [TNFlowUtil startApplicationEntry];
    [[TNWXPayManager defaultManager] registerClients];



#pragma mark === 设置友盟分享
    [UMSocialData setAppKey:kUMAppkey];
    
    //如果你要支持不同的屏幕方向，需要这样设置，否则在iPhone只支持一个竖屏方向
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
    
    //设置友盟社会化组件appkey
    [UMSocialConfig showNotInstallPlatforms:nil];

    // 友盟的推送
    //set AppKey and AppSecret
    [UMessage startWithAppkey:kUMAppkey launchOptions:launchOptions];
    //1.3.0版本开始简化初始化过程。如不需要交互式的通知，下面用下面一句话注册通知即可。
    [UMessage registerForRemoteNotifications];
    
    //打开调试log的开关
    [UMSocialData openLog:YES];
    //打开新浪微博的SSO开关
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"3431019455" secret:@"d66f9fd60e35578c0e6f3d63f58f6e8c"RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
//    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];

    [UMSocialWechatHandler setWXAppId:@"wxc35fb65a4617b718" appSecret:@"0b6eb8c41ea551bb337f7a8ff8f5fa20" url:@"http://www.umeng.com/social"];
    
    [UMSocialQQHandler setQQWithAppId:@"1105133050" appKey:@"MovE5WcRDTPrmKUi" url:@"http://www.umeng.com/social"];
    //    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];

    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    if(UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        //register remoteNotification types
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_identifier";
        action1.title=@"Accept";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"action2_identifier";
        action2.title=@"Reject";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;
        
        UIMutableUserNotificationCategory *actionCategory = [[UIMutableUserNotificationCategory alloc] init];
        actionCategory.identifier = @"category1";//这组动作的唯一标示
        [actionCategory setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
        
        NSSet *categories = [NSSet setWithObject:actionCategory];
        
        //如果默认使用角标，文字和声音全部打开，请用下面的方法
        [UMessage registerForRemoteNotifications:categories];
        
        //如果对角标，文字和声音的取舍，请用下面的方法
        //UIRemoteNotificationType types7 = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        //UIUserNotificationType types8 = UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge;
        //[UMessage registerForRemoteNotifications:categories withTypesForIos7:types7 withTypesForIos8:types8];
    }
#endif
        [UMessage setAutoAlert:NO];
    // 设置是否允许SDK自动清空角标（默认开启）
        [UMessage setBadgeClear:YES];
    
        [UMessage setLogEnabled:YES];
    
        [UMessage setChannel:@"App Store"];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
//    douPlayer *play = [PlayerController sharedManager].Player;
//    if ([play isPlaying]) {
//        [(douPlayer*)[PlayerController sharedManager].Player pause];
//    }
//    UIBackgroundTaskIdentifier taskID = [application beginBackgroundTaskWithExpirationHandler:^{
//        [application endBackgroundTask:taskID];
//    }];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UMSocialSnsService  applicationDidBecomeActive];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [UMessage registerDeviceToken:deviceToken];
    MMLog(@"deviceToken =====%@",deviceToken);
    MMLog(@"deviceToken =====%@",[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                   stringByReplacingOccurrencesOfString: @">" withString: @""]
                                  stringByReplacingOccurrencesOfString: @" " withString: @""]);
    self.deviceToken = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                         stringByReplacingOccurrencesOfString: @">" withString: @""]
                        stringByReplacingOccurrencesOfString: @" " withString: @""];

    UIDevice *device = [UIDevice currentDevice];
    NSMutableDictionary *dic = [@{} mutableCopy];
    NSMutableDictionary *prams = [@{} mutableCopy];
    
    [dic setValue:[(AppDelegate*)[UIApplication sharedApplication].delegate deviceToken] forKey:@"device_token"];
    MMLog(@"++++%@",[(AppDelegate*)[UIApplication sharedApplication].delegate deviceToken]);
    [dic setValue:device.systemName forKey:@"device_type"];
    [dic setValue:device.systemVersion forKey:@"os_version"];
    [prams setValue:dic forKey:@"device"];
    NSString *path = [NSString stringWithFormat:@"%@/customer/update",kHeaderURL];
    if ([TNAppContext currentContext].user.token) {
        [[THRequstManager sharedManager] asynPOST:path parameters:prams blockUserInteraction:NO messageDuring:0.5  withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
            
        }];
    }

}
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
        MMLog(@"%@", url);
        //跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给SDK
        if ([url.host isEqualToString:@"safepay"]) {
            [[AlipaySDK defaultService]
             processOrderWithPaymentResult:url
             standbyCallback:^(NSDictionary *resultDic) {
                 //             NSLog(@"result = %@", resultDic);
                 [[TNAlipayManager defaultManager]didReceiveResult:resultDic];
             }];
        }
        if ([[NSString stringWithFormat:@"%@",url] isEqualToString:@"wxc35fb65a4617b718://platformId=wechat"]) {
            return [UMSocialSnsService handleOpenURL:url];
        }
        else if ([url.scheme isEqualToString:@"wxc35fb65a4617b718"]) {
                    return [[TNWXPayManager defaultManager] application:application handleOpenURL:url];
        }
        return YES;
    }
    return result;
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [UMessage didReceiveRemoteNotification:userInfo];
    MMLog(@"收到推送消息内容%@",userInfo);
    
    TNBlockAlertView *blockAlert = [[TNBlockAlertView alloc]initWithTitle:nil
                                                                  message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                                                 delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [blockAlert setBlockForCancel:^{
        
    }];
    [blockAlert setBlockForOk:^{
        [UMessage sendClickReportForRemoteNotification:userInfo];
//        [self tiaozhaun:userInfo];
    }];
    [blockAlert show];
}

//判断当前版本是否第一次在该设备上运行
- (BOOL)isCurrentVersionJudge{
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleShortVersionString"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *lastRunVersion = [defaults objectForKey:LAST_RUN_VERSION_KEY];
    
    if (!lastRunVersion) {
        [defaults setObject:currentVersion forKey:LAST_RUN_VERSION_KEY];
        return YES;
        // App is being run for first time
    }
    else if (![lastRunVersion isEqualToString:currentVersion]) {
        [defaults setObject:currentVersion forKey:LAST_RUN_VERSION_KEY];
        return YES;
        // App has been updated since last run
    }
    return NO;
}

@end
