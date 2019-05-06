//
//  ZHSOrderEditAddressViewController.h
//  ZHS
//
//  Created by 邢小迪 on 16/7/12.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZHSLocation : NSObject
/**
 *  国家
 */
@property (nonatomic, copy) NSString *country;
/**
 *  省份
 */
@property (nonatomic, copy) NSString *state;
/**
 *  城市
 */
@property (nonatomic, copy) NSString *city;
/**
 *  街道
 */
@property (nonatomic, copy) NSString *street;
/**
 *  区域，地方
 */
@property (nonatomic, copy) NSString *district;
/**
 *  纬度
 */
@property (nonatomic, assign) double latitude;
/**
 *  经度
 */
@property (nonatomic, assign) double longitude;

@end


@class ZHSAreaPickerView;
@protocol ZHSAreaPickerViewDelegate <NSObject>
@optional
- (void)pickerDidChangeStatus:(ZHSAreaPickerView *)picker;
@end



@interface ZHSAreaPickerView : UIView

@property (nonatomic, weak) id<ZHSAreaPickerViewDelegate> delegate;
@property (nonatomic, strong) ZHSLocation *locate;

+ (instancetype)areaPickerViewWithDelegate:(id<ZHSAreaPickerViewDelegate>)delegate;

/**
 *  显示
 *
 */
- (void)showInView:(UIView *)view;
/**
 *  隐藏
 */
- (void)cancelPicker;
@end



@interface ZHSOrderEditAddressViewController : TNViewController

@end
