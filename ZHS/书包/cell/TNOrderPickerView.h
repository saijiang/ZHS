//
//  TNOrderPickerView.h
//  Tuhu
//
//  Created by DengQiang on 14/11/5.
//  Copyright (c) 2014年 telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TNOrderPickerView;
@protocol TNOrderPickerViewDelegate <NSObject>

- (void)orderPickerView:(TNOrderPickerView *)pickerView didSelectOrderWithName:(NSString *)name code:(NSString *)code;

@end

@interface TNOrderPickerView : UIView
@property (strong,nonatomic) NSString *selectTitle;
@property (weak, nonatomic) id<TNOrderPickerViewDelegate> delegate;

+ (TNOrderPickerView *)viewFromNib;
- (CGSize)contentSize;
-(void)reloadOrderDataWithShopType:(NSMutableArray*)dataAry;

@end
