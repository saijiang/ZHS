//
//  ZHSOnlyBookDetailViewController.h
//  ZHS
//
//  Created by 邢小迪 on 16/5/14.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZHSSchoolbag;
@interface ZHSOnlyBookDetailViewController : TNViewController
@property(nullable,nonatomic,strong)ZHSSchoolbag *schoolbag;
@property(nonatomic,copy,nullable)NSString *cancelCollection;

@end
