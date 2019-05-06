//
//  TNDataUtil.m
//  TNAppLib
//
//  Created by Frank on 13-11-25.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNDataUtil.h"
#import "NSString+TNAppLib.h"

#define DATE_FORRMATTER @"yyyy-MM-dd HH:mm"
#define FULL_MINITE (60)
#define FULL_HOUR (60 * 60)
#define FULL_DAY (60 * 60 * 24)
#define FULL_MONTH (60 * 60 * 24 * 30)
#define FULL_YEAR (60 * 60 * 24 * 365)

@implementation TNDataUtil

+ (BOOL)isValidEmail:(NSString *)inputString
{
    if (inputString== nil || [inputString length] == 0) {
        return NO;
    }
    NSString *stricterFilterString = @"^[a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+(\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$";//@"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2-4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    
    BOOL returnValue = [emailTest evaluateWithObject:inputString];
    
    return returnValue;
}

+ (BOOL)isValidPassword:(NSString *)password
{
    if(password == nil)
    {
        return NO;
    }
    
    NSString *stricterFilterString = @"(^[A-Z0-9a-z,./<>?;:'{}`~!@#$%^&*_+=|\"-]{6,16}$)"; // password must contain A-Z0-9a-z,./<>?;:'{}`~!@#$%^&*_+=|\"- only, and its length must between 6~16
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    
    BOOL ret = [emailTest evaluateWithObject:password];
    
    return ret;
}

+ (BOOL)isValidPhone:(NSString *)phone
{
    NSString* regex = @"^1[0-9]{10}$";
	NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	return [pred evaluateWithObject:phone];
}

+(int) getUnifyNickLength:(NSString*)inputString
{
    NSUInteger stringLen = [inputString length];
    if (stringLen == 0)
    {
        return 0;
    }
    
    int realLen = 0;
    NSRange range = NSMakeRange(0, 1);
    while (range.location < stringLen) {
        NSString *sub = [inputString substringWithRange:range];
        NSUInteger bytes = [[sub dataUsingEncoding:NSUTF8StringEncoding] length];
        if (bytes >= 2)
        {
            realLen += 2;
        }
        else
        {
            realLen += 1;
        }
        
        range.location += 1;
    }
    
    return realLen;
}


+ (NSString *)generateUnifyFileName:(NSString *)extension
{
    NSString *uuidStr = [NSString UUIDString];
    if (extension != nil)
    {
        uuidStr = [uuidStr stringByAppendingPathExtension:extension];
    }
    return uuidStr;
}

+ (NSString*)timeStringForMomentFromDate:(NSDate*) date
{
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [NSLocale currentLocale];
    
    if(hasAMPM)
    {
        fmt.dateFormat = @"M月d日 ahh:mm";
        NSString *result = [fmt stringFromDate:date];
        NSRange amRange = [result.lowercaseString rangeOfString:@"am"];
        NSRange pmRange = [result.lowercaseString rangeOfString:@"pm"];
        if(amRange.location != NSNotFound || pmRange.location != NSNotFound)
        {
            fmt.dateFormat = @"M月d日 hh:mm a";
            result = [fmt stringFromDate:date];
        }
        return result;
        
    }else{
        fmt.dateFormat = @"M月d日 HH:mm";
        return [fmt stringFromDate:date];
    }
}

+ (NSString*) timeTillNow:(NSDate*) date
{
    return [self timeTillNow:date isShortFormat:NO];
}

+ (NSString*)timeTillNow:(NSDate*) date isShortFormat:(BOOL)isShortFormat
{
    NSDate *now = [NSDate date];
    long timeInterval = [now timeIntervalSinceDate:date];
    //    long timeLong = timeInterval;
    if(date == nil)
    {
        return @"未知时间";
    }
    else if (timeInterval < FULL_MINITE)
    {
        return @"刚刚";
    }
    else if (timeInterval < FULL_HOUR)
    {
        return [NSString stringWithFormat:@"%ld分钟前", timeInterval/ FULL_MINITE];
    }
    else if (timeInterval >= FULL_HOUR && timeInterval < FULL_DAY)
    {
        return [NSString stringWithFormat:@"%ld小时前", timeInterval/FULL_HOUR];
    }
    else if (timeInterval >= FULL_DAY && timeInterval < FULL_MONTH)
    {
        return [NSString stringWithFormat:@"%ld天前", timeInterval/FULL_DAY];
    }
    else if (timeInterval >= FULL_MONTH && timeInterval < FULL_YEAR)
    {
        return [NSString stringWithFormat:@"%ld月前", timeInterval/FULL_MONTH];
    }
	else
    {
		return [NSString stringWithFormat:@"%ld年前", timeInterval/FULL_YEAR];
	}
}

+ (long long)currentTimeMillis
{
    return [[NSDate date] timeIntervalSince1970] * 1000L;
}

+(NSDate*) dateFromString:(NSString*) dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_FORRMATTER];
    NSDate *returnValue = [dateFormatter dateFromString:dateString];
    
    return returnValue;
}

+(NSDate*) dateFromTimeStamp:(long long) secondsSince1970
{
    return [NSDate dateWithTimeIntervalSince1970:secondsSince1970];
}

+(long long) dateToTimeStampSeconds:(NSDate*) date
{
    return [date timeIntervalSince1970];
}

+(NSString*) dateToString:(NSDate*) date format:(NSString*) format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    //    [dateFormatter setAMSymbol:NSLocalizedString(@"AM", nil)];
    //    [dateFormatter setPMSymbol:NSLocalizedString(@"PM", nil)];
    
    NSString *returnValue = [dateFormatter stringFromDate:date];

    return returnValue;
}

+(NSString*) dateToString:(NSDate*) date
{
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:DATE_FORRMATTER];
    //
    //    NSString *returnValue = [dateFormatter stringFromDate:date];
    //    [dateFormatter release];
    //    return returnValue;
    return [TNDataUtil dateToString:date format:DATE_FORRMATTER];
}

+(NSString*) formatBizHourString:(NSString*) bizHour
{
    NSString* result = [bizHour stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray* bizHourByDay = [result componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* bizHourString = nil;
    
    if (bizHourByDay.count > 1)
    {
        // biz hour for different week days
        bizHourString = (NSString*)[bizHourByDay objectAtIndex:1];
    }
    else
    {
        // only biz hour
        bizHourString = (NSString*)[bizHourByDay objectAtIndex:0];
    }
    
    NSArray* beginEndTime = [bizHourString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
    if (beginEndTime.count > 1)
    {
        NSString* timeBegin = [TNDataUtil formatAmPmTime:(NSString*)[beginEndTime objectAtIndex:0]];
        NSString* timeEnd = [TNDataUtil formatAmPmTime:(NSString*)[beginEndTime objectAtIndex:1]];
        
        if (bizHourByDay.count > 1)
        {
            result = [NSString stringWithFormat:@"%@ %@-%@", (NSString*)[bizHourByDay objectAtIndex:0], timeBegin, timeEnd];
        }
        else
        {
            result = [NSString stringWithFormat:@"%@-%@", timeBegin, timeEnd];
        }
    }
    
    return result;
}

+(NSString*) formatAmPmTime:(NSString*)time
{
    NSString* result = time;
    
    NSString* hourWithoutAmPm = nil;
    if ([time rangeOfString:@"AM"].location != NSNotFound)
    {
        hourWithoutAmPm = [time stringByReplacingOccurrencesOfString:@"AM" withString:@""];
        NSArray* hourMin = [time componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
        if (hourMin.count > 1)
        {
            NSString* timePrefix = nil;
            NSInteger hour = [[hourMin objectAtIndex:0]intValue];
            if (hour >= 0 && hour <= 3)
            {
                timePrefix = NSLocalizedString(@"MORNING", nil);
            }
            else
            {
                timePrefix = NSLocalizedString(@"AM", nil);
            }
            result = [NSString stringWithFormat:@"%@%@", timePrefix, hourWithoutAmPm];
        }
    }
    else if ([time rangeOfString:@"PM"].location != NSNotFound)
    {
        hourWithoutAmPm = [time stringByReplacingOccurrencesOfString:@"PM" withString:@""];
        NSArray* hourMin = [time componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
        if (hourMin.count > 1)
        {
            NSString* timePrefix = nil;
            NSInteger hour = [[hourMin objectAtIndex:0]intValue];
            NSInteger min = [[hourMin objectAtIndex:1]intValue];
            if ((hour >= 0 && hour <= 5) || (hour == 12 && min > 0))
            {
                timePrefix = NSLocalizedString(@"PM", nil);
            }
            else
            {
                timePrefix = NSLocalizedString(@"EVENING", nil);
            }
            result = [NSString stringWithFormat:@"%@%@", timePrefix, hourWithoutAmPm];
        }
    }
    
    return result;
}

+ (BOOL)isEqualWithNumber:(NSNumber *)number1 number:(NSNumber *)number2
{
    if(!number1 || !number2)
    {
        return NO;
    }
    
    return [number1 isEqualToNumber:number2];
}

+ (NSString*)formatPhoneNumber:(NSString*)phoneNum
{
    NSMutableString* str = [NSMutableString stringWithString:phoneNum];
    
    //NSRange range = NSMakeRange(0, [str length]);
    
    [str replaceOccurrencesOfString:@"(" withString:@"" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@")" withString:@"" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"-" withString:@"" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"+86" withString:@"" options:0 range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, [str length])];
    return [str stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (NSNumber *)stringToNumber:(NSString *)str
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [numberFormatter numberFromString:str];
    return number;
}

+ (NSString*)intToChinese:(NSUInteger)num
{
    if (num == 0)
    {
        return @"零";
    }
    
    
    NSArray *unit = @[@"",@"十",@"百",@"千",@"万",@"十",@"百",@"千",@"亿",@"十",@"百",@"千"];
    NSArray *numChinese = @[@"零",@"一", @"二", @"三", @"四", @"五", @"六", @"七" , @"八", @"九"];
    
    NSString *numString = [NSString stringWithFormat:@"%@", @(num)];
    if (numString.length <= 14)
    {
        NSMutableString *resultString = [NSMutableString new];
        for (int i = 0; i < numString.length; i ++)
        {
            BOOL is4UnitP = i % 4 == 0;

            NSUInteger numIndex = (num /(NSUInteger)pow(10, i)) % 10;
            if (is4UnitP)
            {
                [resultString insertString:unit[i] atIndex:0];//汉字数字每4位单位进一，此时必须显示单位。

                if ([numChinese[numIndex] isEqualToString:@"零"])//末位 “零” 不显示
                {
                    continue;
                }
            }
            else
            {
                if (![numChinese[numIndex] isEqualToString:@"零"])//只要不是“零”就应该显示单位。
                {
                    [resultString insertString:unit[i] atIndex:0];
                }
                else
                {
                    if (resultString.length > 0 && [[resultString substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"零"])//过滤掉重复的“零”
                    {
                        continue;
                    }
                }
                
            }
            
            if (i == numString.length - 1 && [unit[i] isEqualToString:@"十"] && [numChinese[numIndex] isEqualToString:@"一"])//首位单位为（十x）时，"一"不显示
            {
                continue;
            }
       
            [resultString insertString:numChinese[numIndex] atIndex:0];
        }
        return resultString;
    }
    else
    {
        return numString;
    }
}

@end
