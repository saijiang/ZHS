//
//  TNBlockImagePickerViewController.h
//  TNAppLib
//
//  Created by kiri on 2013-11-18.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNBlockImagePickerViewController : UIImagePickerController

@property (nonatomic, copy) void (^completion)(TNBlockImagePickerViewController *picker, BOOL isCancel, NSDictionary *mediaInfo);

@end