//
//  TNBlockAlertView.h
//  TNAppLib
//
//  Created by kiri on 2013-10-16.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TNAlertViewBlock)(void);

/*! An alert view delegate by block */
@interface TNBlockAlertView : UIAlertView

- (TNAlertViewBlock)blockForOk;
- (void)setBlockForOk:(TNAlertViewBlock)blockForOk;

- (TNAlertViewBlock)blockForCancel;
- (void)setBlockForCancel:(TNAlertViewBlock)blockForCancel;

- (TNAlertViewBlock)blockAtButtonIndex:(NSInteger)buttonIndex;
- (void)setBlock:(TNAlertViewBlock)block atButtonIndex:(NSInteger)buttonIndex;


@end
