//
//  TNMacros.h
//  TNAppLib
//
//  Created by kiri on 2013-5-9.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#ifndef TNAppLib_TNAppLibMacros_h
#define TNAppLib_TNAppLibMacros_h

////////////////////////////////////////////////////////////////////////////////////////////////
#define TNHasOption(opts, opt) (((opts) & (opt)) == (opt))

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Animation

#define TNAnimateDurationShort 0.25
#define TNAnimateDurationNormal 0.35
#define TNAnimateDurationLong 1.0
// 是否是单本书模式
#define kIsBookMode [[TNAppContext currentContext].schoolbagMode isEqualToString:@"book"]
////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - ColorDefines

#define RGB(r, g, b) [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]
#define ARGB(a, r, g, b) [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:(a)/255.f]

#define kTNFont(pt) [UIFont fontWithName:@"HelveticaNeue-Light" size:(pt)]
#define kTNBoldFont(pt) [UIFont fontWithName:@"HelveticaNeue-Bold" size:(pt)]

//#define kTNNavbarColor [UIColor colorWithRed:0 green:169/255.f blue:247/255.f alpha:1.f]
// 60 100 140, 83% above white.
//#define kTNNavbarColor RGB(20, 53, 88)
#define kTNTintColor [UIColor whiteColor]
#define kTNDisabledTintColor [UIColor colorWithWhite:1.f alpha:.5f]
#define kNaverColr RGB(103, 199, 56)

#define kTNTextColor0 RGB(51, 51, 51)
#define kTNTextColor1 RGB(102, 102, 102)
#define kTNTextColor2 RGB(136, 136, 136)
#define kTNTextColor3 RGB(153, 153, 153)

#define kTNTabBarTintColor [UIColor whiteColor]
#define kTNSectionIndexColor RGB(180, 190, 200)
#define kTNLoginBackgroundColor RGB(230, 243, 230)
#define kTNNavbarTitleColor [UIColor whiteColor]

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Release

#define TNFree(__PTR) do{ if(__PTR){ free(__PTR); __PTR = NULL;} } while(0)
#define TNCFRelease(__REF) do{ if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } } while(0)

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Float comparision

#define kVerySmallValue (0.000001)

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Cache

#define kURLCacheMemoryMaxSize (20 * 1024 * 1024)
#define kURLCacheDiskMaxSize (50 * 1024 * 1024)
#define kURLCacheDiskPath   @"URLCache"

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Thread

#define TNAssertMainThread()  do { \
                NSString *desc = [NSString stringWithFormat:@"%s must invoke in main thread!", __FUNCTION__]; \
                NSAssert([NSThread isMainThread], desc); \
            } while (0)

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Block
typedef void (^BasicBlock)(void);

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - TNLocalizedString

#define TNLStr(key) [[NSBundle mainBundle] localizedStringForKey:(key) value:(key) table:@"InfoPlist"]

#endif
