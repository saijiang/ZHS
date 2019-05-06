//
//  MMMacros.h
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
//  Macros and Debug setting for MMLib
//****************************************************************************************
//

#ifndef MMMacros_h
#define MMMacros_h

// UIColor
#define UIColorWithCode(_code_)    [UIColor colorWithRed:((float)((_code_ & 0xFF0000) >> 16))/255.0 \
                                                                       green:((float)((_code_ & 0x00FF00) >> 8))/255.0 \
                                                                         blue:((float)(_code_ & 0x0000FF))/255.0 \
                                                                        alpha:1]
#define UIColorWithCodeAlpha(_code_,al)    [UIColor colorWithRed:((float)((_code_ & 0xFF0000) >> 16))/255.0 \
                                        green:((float)((_code_ & 0x00FF00) >> 8))/255.0 \
                                        blue:((float)(_code_ & 0x0000FF))/255.0 \
                                        alpha:al]
#define UIColorWithRGB(_red_, _green_, _blue_)                      UIColorWithRGBA(_red_, _green_, _blue_, 1)
#define UIColorWithRGBA(_red_, _green_, _blue_, _alpha_)        [UIColor colorWithRed:_red_/255.f green:_green_/255.f blue:_blue_/255.f alpha:_alpha_]

#define UIColor_Clear  [UIColor clearColor]

// LogRect/Size/Point
#define NSLogRect(rect)            NSLog(@"%s x:%.4f, y:%.4f, w:%.4f, h:%.4f", #rect, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define NSLogSize(size)             NSLog(@"%s w:%.4f, h:%.4f", #size, size.width, size.height)
#define NSLogPoint(point)          NSLog(@"%s x:%.4f, y:%.4f", #point, point.x, point.y)

// Log
#ifdef DEBUG
#define MMLog(fmt, ...)   do { \
                                    fprintf(stderr, "-------------------------- MMLOG --------------------------\n"); \
                                    static NSDateFormatter* formatter; \
                                    static dispatch_once_t predicate; \
                                    dispatch_once(&predicate, ^{ \
                                        formatter = [[NSDateFormatter alloc] init]; \
                                        formatter.dateFormat = @"YYYY-MM-dd hh:mm:ss.SSS"; \
                                    }); \
                                    fprintf(stderr, "[%s] <%s:%s inLine:%d>\n ", [formatter stringFromDate:[NSDate date]].UTF8String, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __FUNCTION__, __LINE__); \
                                    fprintf(stderr, "%s\n", [NSString stringWithFormat:(fmt), ##__VA_ARGS__].UTF8String); \
                                } while (0)
#define Mark              MMLog(@"- MARK -");
#else
#define MMLog(fmt, ...)
#define Mark
#endif

//Utils
#define MMCheckNumberInRange(__index_, __first_, __end_) (__index_ >= __first_ && __index_ < __end_)
#define MMCheckUsignNumberUnder(__index_, __limit_) MMCheckNumberInRange(__index_, 0, __limit_)
#define MMCheckArrayNotOutofRange(__index_, __container_) MMCheckUsignNumberUnder(__index_, __container_.count)

#define ScreenBounds   [UIScreen mainScreen].bounds
#define ScreenWidth     [UIScreen mainScreen].bounds.size.width
#define ScreenHeight    [UIScreen mainScreen].bounds.size.height
#define ScreenScale     [UIScreen mainScreen].scale

#endif
