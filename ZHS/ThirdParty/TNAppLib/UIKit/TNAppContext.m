//
//  TNAppContext.m
//  Tuhu
//
//  Created by DengQiang on 14/10/23.
//  Copyright (c) 2014年 telenav. All rights reserved.
//

#import "TNAppContext.h"
#import "Reachability.h"


#define kUserDefaultCurrentCar  @"kUserDefaultCurrentCar"
#define kUserDefaultCurrentUser @"kUserDefaultCurrentUser"
#define kUserDefaultCarList  @"kUserDefaultCarList"
#define kUserDefaultCitys  @"kUserDefaultCitys"


@interface TNAppContext ()

@property (nonatomic, strong) NSMutableArray *carsCache;
@property (nonatomic, strong) NSMutableArray *citysCache;



@end

@implementation TNAppContext

+ (instancetype)currentContext
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSData *temp = [ud objectForKey:kUserDefaultCurrentCar];
        if (temp) {
            
        }
        temp = [ud objectForKey:kUserDefaultCurrentUser];
        if (temp) {
            self.user = [NSKeyedUnarchiver unarchiveObjectWithData:temp];
        }
        temp = [ud objectForKey:kUserDefaultCarList];
        if (temp) {
            self.carsCache = [[NSKeyedUnarchiver unarchiveObjectWithData:temp] mutableCopy];
        }
        if (self.carsCache == nil) {
            self.carsCache = [NSMutableArray array];
        }
        
        temp = [ud objectForKey:kUserDefaultCitys];
        if (temp) {
            self.citysCache = [[NSKeyedUnarchiver unarchiveObjectWithData:temp] mutableCopy];
        }
        if (self.citysCache == nil) {
            self.citysCache = [NSMutableArray array];
        }
    }
    return self;
}
- (void)setUser:(TNUser *)user
{
    if (_user != user) {
        _user = user;
        
        [self saveUser];
    }
}

- (void)logout
{
    self.user = nil;
}

- (void)saveObject:(id)obj forKey:(NSString *)key
{
    if (obj) {
        [[NSUserDefaults standardUserDefaults] setObject:[obj isKindOfClass:[NSString class]] ? obj : [NSKeyedArchiver archivedDataWithRootObject:obj] forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)schoolbagMode{
    return self.user.school_info[@"mode"];
}

- (void)saveUser
{
    [self saveObject:self.user forKey:kUserDefaultCurrentUser];
}
- (NSArray *)cars
{
    return self.carsCache;
}


-(void)setCitys:(NSMutableArray *)citys{
    if (_citysCache != citys) {
        [citys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"name"] isEqualToString:@"北京市"] || [obj[@"name"] isEqualToString:@"天津市"]|| [obj[@"name"] isEqualToString:@"重庆市"]|| [obj[@"name"] isEqualToString:@"上海市"]) {
                NSArray *cirysAry = obj[@"sub_info"];
                NSDictionary*shidic = @{@"id":obj[@"id"],@"name":obj[@"name"],@"type_id":@"2",@"type":@"市",@"sub_info":cirysAry};
                [obj setObject:@[shidic] forKey:@"sub_info"];
            }
        }];
        _citysCache = citys;
        [self saveObject:_citysCache forKey:kUserDefaultCitys];
    }
    
}
- (NSArray *)citys
{
    return self.citysCache;
}



    

- (UIColor *)getColor:(NSString *)hexColor{
    
    NSMutableString *color = [NSMutableString stringWithString:hexColor];
    // 转换成标准16进制数
    [color replaceCharactersInRange:[color rangeOfString:@"#" ] withString:@"0x"];
    // 十六进制字符串转成整形。
    long colorLong = strtoul([color cStringUsingEncoding:NSUTF8StringEncoding], 0, 16);
    // 通过位与方法获取三色值
    int R = (colorLong & 0xFF0000 )>>16;
    int G = (colorLong & 0x00FF00 )>>8;
    int B =  colorLong & 0x0000FF;
    
    //string转color
    UIColor *wordColor = [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0];
    return wordColor;
}

+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize

{
  
    UIImage *newimage;
  
        if (nil == image) {
      
              newimage = nil;
       
          }
        else{
        
              CGSize oldsize = image.size;
       
             CGRect rect;
      
               if (asize.width/asize.height > oldsize.width/oldsize.height) {
        
                       rect.size.width = asize.height*oldsize.width/oldsize.height;
         
                   rect.size.height = asize.height;
          
                       rect.origin.x = (asize.width - rect.size.width)/2;
      
                        rect.origin.y = 0;
           
                    }
    
             else{
         
                   rect.size.width = asize.width;
        
                      rect.size.height = asize.width*oldsize.height/oldsize.width;
    
                    rect.origin.x = 0;
          
                      rect.origin.y = (asize.height - rect.size.height)/2;
          
                 }
    
                UIGraphicsBeginImageContext(asize);
   
               CGContextRef context = UIGraphicsGetCurrentContext();
        
               CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        
                UIRectFill(CGRectMake(0, 0, asize.width, asize.height));
        
               [image drawInRect:rect];
       
                newimage = UIGraphicsGetImageFromCurrentImageContext();
        
               UIGraphicsEndImageContext();
        
            }
    
       return newimage;
   
}
// 验证是否为手机号
- (BOOL)validateMobile:(NSString *)mobileNum
{
    
    
    
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     */
    
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,185,186
     */
    
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     * 中国电信：China Telecom
     * 133,1349,153,180,189
     */
    
    //    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    //    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    NSString *C11 = @"^1([3-9])\\d{9}$";
    NSPredicate *regextest11 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",C11];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        //        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES)
        || ([regextest11 evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
- (NSString *)formateDate:(NSString *)dateString
{
    
    @try {
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSDate * nowDate = [NSDate date];
        
        /////  将需要转换的时间转换成 NSDate 对象
        NSDate * needFormatDate = [dateFormatter dateFromString:dateString];
        /////  取当前时间和转换时间两个日期对象的时间间隔
        /////  这里的NSTimeInterval 并不是对象，是基本型，其实是double类型，是由c定义的:  typedef double NSTimeInterval;
        NSTimeInterval time = [nowDate timeIntervalSinceDate:needFormatDate];
        
        //// 再然后，把间隔的秒数折算成天数和小时数：
        
        NSString *dateStr = @"";
        
        if (time<=60) {  //// 1分钟以内的
            dateStr = @"刚刚";
        }else if(time<=60*60){  ////  一个小时以内的
            
            int mins = time/60;
            dateStr = [NSString stringWithFormat:@"%d分钟前",mins];
            
        }else if(time<=60*60*24){   //// 在两天内的
            int mins = time/60/60;
            dateStr = [NSString stringWithFormat:@"%d小时前",mins];

//            [dateFormatter setDateFormat:@"YYYY/MM/dd"];
//            NSString * need_yMd = [dateFormatter stringFromDate:needFormatDate];
//            NSString *now_yMd = [dateFormatter stringFromDate:nowDate];
//            
//            [dateFormatter setDateFormat:@"HH:mm"];
//            if ([need_yMd isEqualToString:now_yMd]) {
//                //// 在同一天
//                dateStr = [NSString stringWithFormat:@"今天 %@",[dateFormatter stringFromDate:needFormatDate]];
//            }else{
//                ////  昨天
//                dateStr = [NSString stringWithFormat:@"昨天 %@",[dateFormatter stringFromDate:needFormatDate]];
//            }
        }else if(time<=60*60*24*3){   //// 在3天内的
            int mins = time/60/60/24;
            dateStr = [NSString stringWithFormat:@"%d天前",mins];
        }else {
            
            [dateFormatter setDateFormat:@"yyyy"];
            NSString * yearStr = [dateFormatter stringFromDate:needFormatDate];
            NSString *nowYear = [dateFormatter stringFromDate:nowDate];
            
            if ([yearStr isEqualToString:nowYear]) {
                ////  在同一年
                [dateFormatter setDateFormat:@"MM月dd日"];
                dateStr = [dateFormatter stringFromDate:needFormatDate];
            }else{
                [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                dateStr = [dateFormatter stringFromDate:needFormatDate];
            }
        }
        
        return dateStr;
    }
    @catch (NSException *exception) {
        return @"";
    }
    
    
}
- (CGFloat)heightFordetailText:(NSString *)text andWidth:(CGFloat)width andFontOfSize:(CGFloat)size
{
    //设置计算文本时字体的大小,以什么标准来计算
    NSDictionary *attrbute = @{NSFontAttributeName:[UIFont systemFontOfSize:size]};
    return  [text boundingRectWithSize:CGSizeMake(width, 10000) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:attrbute context:nil].size.height;
}
- (MMNetwork)returnNetwork{
    // 1.检测wifi状态
    Reachability *wifi = [Reachability reachabilityForLocalWiFi];
    
    // 2.检测手机是否能上网络(WIFI\3G\2.5G)
    Reachability *conn = [Reachability reachabilityForInternetConnection];
    
    // 3.判断网络状态
    if ([wifi currentReachabilityStatus] != NotReachable) { // 有wifi
        DLog(@"有wifi");
        return MMNetworkWifi;
        
    } else if ([conn currentReachabilityStatus] != NotReachable) { // 没有使用wifi, 使用手机自带网络进行上网
        DLog(@"使用手机自带网络进行上网");
        return MMNetwork3GOr4G;
        
    } else { // 没有网络
        
        DLog(@"没有网络");
//        [TNToast showWithText:@"网络貌似不给力~请检查网络"];
        return MMNetworkNull;
    }
}
@end
