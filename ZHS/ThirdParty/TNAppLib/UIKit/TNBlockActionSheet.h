//
//  TNBlockActionSheet.h
//  TNAppLib
//
//  Created by kiri on 2013-10-17.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TNActionSheetBlock)(UIActionSheet *actionSheet, NSInteger buttonIndex);

/*! An action sheet delegate by block */
@interface TNBlockActionSheet : UIActionSheet

- (TNActionSheetBlock)blockAtButtonIndex:(NSInteger)buttonIndex;
- (void)setBlock:(TNActionSheetBlock)block atButtonIndex:(NSInteger)buttonIndex;

@end
