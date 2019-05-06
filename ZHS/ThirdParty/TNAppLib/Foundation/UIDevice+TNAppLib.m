//
//  UIDevice+TNAppLib.m
//  TNAppLib
//
//  Created by kiri on 2013-11-08.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "UIDevice+TNAppLib.h"
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "TNNumberUtil.h"

@implementation UIDevice (TNAppLib)

- (int)majorSystemVersion
{
    return [[[self.systemVersion componentsSeparatedByString:@"."] firstObject] intValue];
}

- (NSString *)macAddress
{
	int mib[6];
	size_t len;
	char *buf;
	unsigned char *ptr;
	struct if_msghdr *ifm;
	struct sockaddr_dl *sdl;
	
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
	
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1/n");
		return NULL;
	}
	
	if ((buf = malloc(len)) == NULL) {
		printf("Could not allocate memory. error!/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 2");
        free(buf);
		return NULL;
	}
	
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	free(buf);
	return [outstring uppercaseString];
}

- (NSString *)machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithUTF8String:systemInfo.machine];
}

- (NSString *)fullModel
{
    NSString *platform = self.machineName;
    NSDictionary *commonNamesDictionary = @{@"i386": @"iPhone Simulator",
                                            @"x86_64": @"iPad Simulator",
                                            
                                            @"iPhone1,1": @"iPhone",
                                            @"iPhone1,2": @"iPhone 3G",
                                            @"iPhone2,1": @"iPhone 3GS",
                                            @"iPhone3,1": @"iPhone 4",
                                            @"iPhone3,2": @"iPhone 4(Rev A)",
                                            @"iPhone3,3": @"iPhone 4(CDMA)",
                                            @"iPhone4,1": @"iPhone 4S",
                                            @"iPhone5,1": @"iPhone 5(GSM)",
                                            @"iPhone5,2": @"iPhone 5(GSM+CDMA)",
                                            @"iPhone5,3": @"iPhone 5C(GSM)",
                                            @"iPhone5,4": @"iPhone 5C(GSM+CDMA)",
                                            @"iPhone6,1": @"iPhone 5S(GSM)",
                                            @"iPhone6,2": @"iPhone 5S(GSM+CDMA)",
                                            
                                            @"iPad1,1": @"iPad",
                                            @"iPad2,1": @"iPad 2(WiFi)",
                                            @"iPad2,2": @"iPad 2(GSM)",
                                            @"iPad2,3": @"iPad 2(CDMA)",
                                            @"iPad2,4": @"iPad 2(WiFi Rev A)",
                                            @"iPad2,5": @"iPad Mini(WiFi)",
                                            @"iPad2,6": @"iPad Mini(GSM)",
                                            @"iPad2,7": @"iPad Mini(GSM+CDMA)",
                                            @"iPad3,1": @"iPad 3(WiFi)",
                                            @"iPad3,2": @"iPad 3(GSM+CDMA)",
                                            @"iPad3,3": @"iPad 3(GSM)",
                                            @"iPad3,4": @"iPad 4(WiFi)",
                                            @"iPad3,5": @"iPad 4(GSM)",
                                            @"iPad3,6": @"iPad 4(GSM+CDMA)",
                                            
                                            @"iPod1,1": @"iPod Touch", /* 1st Gen */
                                            @"iPod2,1": @"iPod Touch 2",
                                            @"iPod3,1": @"iPod Touch 3",
                                            @"iPod4,1": @"iPod Touch 4",
                                            @"iPod5,1": @"iPod Touch 5"};
    NSString *result = [commonNamesDictionary objectForKey:platform];
    if (result == nil) {
        result = @"Unknown";
    }
    return result;
}

- (NSString *)carrierName
{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    if (carrier.carrierName.length > 0) {
        return carrier.carrierName;
    } else {
        return @"UNKNOWN_CARRIER";
    }
}

+ (BOOL)isIphone4
{
    static BOOL isIphone4 = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isIphone4 = [TNNumberUtil float:[UIScreen mainScreen].bounds.size.height isEqual:480.f];
    });
    return isIphone4;
}

+ (BOOL)isIphone5
{
    static BOOL isIphone5 = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isIphone5 = [TNNumberUtil float:[UIScreen mainScreen].bounds.size.height isEqual:568.f];
    });
    return isIphone5;
}
+ (BOOL)isIphone6
{
    static BOOL isIphone6 = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isIphone6 = [TNNumberUtil float:[UIScreen mainScreen].bounds.size.height isEqual:667.f];
    });
    return isIphone6;
}
+ (BOOL)isIphone6P
{
    static BOOL isIphone6P = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isIphone6P = [TNNumberUtil float:[UIScreen mainScreen].bounds.size.height isEqual:736.f];
    });
    return isIphone6P;
}
@end
