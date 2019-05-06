//
//  NetWorkWatchDogManager
//  网络监听程序
//
//  Created by Sean Li on 13-9-5.
//

#import "NetworkMonitor.h"
#define ON_NETWORK_STATUS_CHANGED               @"network_status_changed"

static NetworkMonitor*  monitor = nil;
@interface NetworkMonitor()

@property(nonatomic,strong)Reachability* reachabilityDetector;
@property(nonatomic,assign)NetworkStatus  networkStatus;

@end

@implementation NetworkMonitor

+(NetworkMonitor *) shareInstance
{
    @synchronized(self){
        if (nil == monitor) {
            monitor = [[NetworkMonitor alloc] init];
        }
    }
    return monitor;
}

+(void)destroyInstance
{
    if (nil != monitor) {
        [monitor stopWatchDog];
        monitor = nil;
    }
}

-(id)init
{
    self = [super init];
    if (self) {
        //网络状态变更通知处理
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(rechabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];

        self.networkStatus = [self.reachabilityDetector currentReachabilityStatus];
    }
    return self;
}

/**开始网络看守在程序开始启动的时候调用*/
-(void) startWatchDog
{
    [self.reachabilityDetector startNotifier];
    _networkStatus = [self.reachabilityDetector currentReachabilityStatus];
}

/*** 停止网络看守* 在程序退出调用*/
-(void) stopWatchDog
{
    [self.reachabilityDetector stopNotifier];
}


#pragma mark 网络状态检查
- (void)refrushCurrentNetworkStatus:(Reachability*)currentReach
{
    if ([currentReach isKindOfClass:[Reachability class]])
    {
        NetworkStatus netStatus = [currentReach currentReachabilityStatus];
        [[NSNotificationCenter defaultCenter] postNotificationName:ON_NETWORK_STATUS_CHANGED
                                                            object:[[NSNumber alloc] initWithInt:netStatus]
                                                          userInfo:nil];
    }
}

- (void)rechabilityChanged:(NSNotification*)notification
{
    Reachability *currentReach = [notification object];
    [self refrushCurrentNetworkStatus:currentReach];
}

// 提示框统一控制
-(void)sendAlertMsgViewWithMsg:(NSString*)msg
{
     //不是背景模式的时候，给一个提示
    if (![self isBackGroundRunMode]) {
        //为了防止多次提示网络问题，这里设置存储一个时间
        NSDate* latestAlertRecordDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"networkLatestAlertDate"];
        if ( ([latestAlertRecordDate timeIntervalSince1970]+ 1.5*60) < [[NSDate date] timeIntervalSince1970]) {
            return;
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"networkLatestAlertDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //[CommonUtils AlertWithTitle:@"提示" Msg:msg];
         }
    }
}

#pragma mark 是什么网络
- (BOOL) isReachableViaWWAN
{
    return  self.networkStatus == ReachableViaWWAN ? YES : NO;
}

- (BOOL) isReachableViaWiFi
{
    return  self.networkStatus == ReachableViaWiFi ? YES : NO;
}

- (BOOL) isHaveNetWork
{
    BOOL haveNetWork =  self.networkStatus == NotReachable ? NO: YES;
    if (!haveNetWork) {
        [self sendAlertMsgViewWithMsg:@"网络连接断开，请检你的网络"];
    }
    return haveNetWork;
}

+ (BOOL) isConnectNetWork {
    BOOL haveNetWork =  [self.class shareInstance].networkStatus == NotReachable ? NO: YES;
    return haveNetWork;
}

//是否是背景运行状态
-(BOOL)isBackGroundRunMode
{
  return  [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
}
#pragma mark - getter
-(Reachability*) reachabilityDetector
{
    if (nil == _reachabilityDetector) {
        _reachabilityDetector = [Reachability reachabilityForInternetConnection];
    }
    return _reachabilityDetector;
}

-(NetworkStatus)networkStatus
{
    _networkStatus = [self.reachabilityDetector currentReachabilityStatus];
    return _networkStatus;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
