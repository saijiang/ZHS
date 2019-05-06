//
//  NetWorkWatchDogManager.h
//  网络监听程序

//
//  Created by Sean Li on 13-9-5.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
@interface NetworkMonitor : NSObject

+ (NetworkMonitor*)shareInstance;
+ (void)destroyInstance;

- (void) startWatchDog; //@abstract 开始网络看守*@discussion 在程序开始启动的时候调用
- (void) stopWatchDog; //停止网络看守 在程序退出调用*/

- (BOOL) isReachableViaWWAN;//  3g/2g
- (BOOL) isReachableViaWiFi;//  wifi
- (BOOL) isHaveNetWork;
+ (BOOL) isConnectNetWork; //代码内判断网络状况
- (BOOL) isBackGroundRunMode;//是否是背景运行状态

@end
