//
//  ZHSCitysViewController.h
//  ZHS
//
//  Created by 邢小迪 on 15/12/24.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^block)(NSDictionary*classDic,NSDictionary *kindergarten_infoDic,NSDictionary*city_infoDic);
@interface ZHSCitysViewController : TNViewController
@property(nonatomic,copy) block myblock;
@end
