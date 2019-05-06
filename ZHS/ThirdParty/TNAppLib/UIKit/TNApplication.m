//
//  TNApplication.m
//  WeZone
//
//  Created by DengQiang on 14-6-30.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import "TNApplication.h"
#import "TNRootViewController.h"
#import "ZHSHomeViewController.h"
#import "AppDelegate.h"

#define kUserDefaultsLastEnterBackgroundTime @"kUserDefaultsLastEnterBackgroundTime"

void TNCrashHandler(NSException *e);

@interface TNApplication ()

@property (nonatomic, strong) UIWebView *phoneCallView;
@property (nonatomic, strong) NSDate *launchTime;
@property (nonatomic, strong) NSDate *lastActiveTime;
@property (nonatomic, strong) NSDate *lastDeactiveTime;
@property (nonatomic, strong) NSNotification *lastKeyboardFrameChangedNotification;

@end

@implementation TNApplication

+ (TNApplication *)sharedApplication
{
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        UIApplication *app = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:app];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:app];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:app];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Application Delegate
- (void)startWithLaunchOptions:(NSDictionary *)launchOptions
{
    self.launchOptions = launchOptions;
    self.launchTime = [NSDate date];
    self.lastActiveTime = self.launchTime;
    self.lastDeactiveTime = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsLastEnterBackgroundTime];
    
    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    delegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    delegate.window.rootViewController = [TNNibUtil loadMainObjectFromNib:@"TNRootViewController"];
    [[TNLogger sharedLogger] start];
    NSSetUncaughtExceptionHandler(&TNCrashHandler);
    
    // appearance
    [[UINavigationBar appearance] setTintColor:kTNTintColor];
    [[UINavigationBar appearance] setBarTintColor:kNaverColr];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"common_naviBar_shadow"]];

//    [[UINavigationBar appearance] setBackgroundColor:kNaverColr];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kTNNavbarTitleColor, NSFontAttributeName:[UIFont italicSystemFontOfSize:17.f]}];
    [[UIBarButtonItem appearanceWhenContainedIn:[TNNavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName: kTNTintColor} forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[TNNavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName: kTNDisabledTintColor} forState:UIControlStateDisabled];
    
//    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
//    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: kNaverColr} forState:UIControlStateSelected];

    
//    [[UIToolbar appearance] setTintColor:kTNNavbarColor];
    [[UITableView appearance] setSectionIndexColor:kTNSectionIndexColor];
    [[UITabBar appearance] setTintColor:kTNTabBarTintColor];
//    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"code"]];
//    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbar_sel_bg"]];
    [[UITextField appearance] setTintColor:[UIColor lightGrayColor]];
    [[UITextView appearance] setTintColor:[UIColor lightGrayColor]];
    
    [delegate.window makeKeyAndVisible];
    
    if (launchOptions.count == 0) {
        self.launchType = TNApplicationLaunchTypeNormal;
    } else if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil) {
        self.launchType = TNApplicationLaunchTypeRemoteNotification;
    } else if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey] != nil) {
        self.launchType = TNApplicationLaunchTypeLocalNotification;
    } else if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey] != nil) {
        self.launchType = TNApplicationLaunchTypeOpenURL;
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    self.lastActiveTime = [NSDate date];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    self.lastDeactiveTime = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastDeactiveTime forKey:kUserDefaultsLastEnterBackgroundTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    __block UIBackgroundTaskIdentifier identifier;
    identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if (identifier != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:identifier];
            identifier = UIBackgroundTaskInvalid;
        }
    }];
    
    double delayInSeconds = 30.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (identifier != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:identifier];
                identifier = UIBackgroundTaskInvalid;
            }
        });
    });
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Application Root
- (TNRootViewController *)appRootViewController
{
    return (TNRootViewController *)[[UIApplication sharedApplication].delegate window].rootViewController;
}

- (id)rootViewController
{
    return [self appRootViewController].rootViewController;
}

- (void)setRootViewController:(UIViewController *)controller animated:(BOOL)animated
{
    [[self appRootViewController] setRootViewController:controller animated:animated];
}

#pragma mark - StatusBar
- (void)setStatusBarHidden:(BOOL)hidden style:(UIStatusBarStyle)style withAnimation:(UIStatusBarAnimation)animation animationDuration:(NSTimeInterval)animationDuration
{
    [[self appRootViewController] setStatusBarHidden:hidden style:style withAnimation:animation animationDuration:animationDuration];
}

- (void)resetStatusBarWithAnimated:(BOOL)animated animationDuration:(NSTimeInterval)animationDuration
{
    [[self appRootViewController] resetStatusBarWithAnimated:animated animationDuration:animationDuration];
}

- (void)refreshStatusBar
{
    [[self appRootViewController] setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - Sidebar
- (void)setLeftSidebarViewController:(UIViewController *)leftSidebarViewController
{
    [[self appRootViewController] setLeftSidebarViewController:leftSidebarViewController];
}

- (void)setLeftSidebarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [[self appRootViewController] setLeftSidebarHidden:hidden animated:animated];
}

- (BOOL)isLeftSidebarHidden
{
    return [self appRootViewController].leftSidebarHidden;
}

- (UIViewController *)leftSidebarViewController
{
    return [[self appRootViewController] leftSidebarViewController];
}

- (void)setRightSidebarViewController:(UIViewController *)rightSidebarViewController
{
    [[self appRootViewController] setRightSidebarViewController:rightSidebarViewController];
}

- (void)setRightSidebarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [[self appRootViewController] setRightSidebarHidden:hidden animated:animated];
}

- (BOOL)isRightSidebarHidden
{
    return [self appRootViewController].rightSidebarHidden;
}

- (UIViewController *)rightSidebarViewController
{
    return [[self appRootViewController] rightSidebarViewController];
}

- (UIViewController *)shownSideViewController
{
    return [[self appRootViewController] shownSideViewController];
}

- (void)showSideViewController:(UIViewController *)viewController fromPosition:(TNSideViewPosition)position
{
    [[self appRootViewController] showSideViewController:viewController fromPosition:position];
}

- (void)hideSideViewController
{
    [[self appRootViewController] hideSideViewController];
}

#pragma mark - Utils
- (BOOL)openURL:(NSURL *)url
{
    return [[UIApplication sharedApplication] openURL:url];
}

- (void)callPhoneNumber:(NSString *)phoneNumber
{
    NSString *phone = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (phone.length == 0) {
        return;
    }
    
    if (self.phoneCallView == nil) {
        self.phoneCallView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [self.phoneCallView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phone]]]];
}

- (TNRetryTaskIdentifier)beginRetryTaskWithBlock:(void (^)(void))block test:(BOOL (^)(void))testingBlock
{
    return 0;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    self.lastKeyboardFrameChangedNotification = notification;
}

- (CGFloat)keyboardTop
{
    return [self.lastKeyboardFrameChangedNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
}

@end

#pragma mark - crash handler
void TNCrashHandler(NSException *e) {
    [[TNLogger sharedLogger] logCrashWithException:e];
}