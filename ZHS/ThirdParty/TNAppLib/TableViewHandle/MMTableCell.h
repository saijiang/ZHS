//
//  MMTableCellModel.h
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
//  MMTableCell protocol. cell in table view handled with MMTableViewHandle must conforms this protocol
//****************************************************************************************
//

#import <Foundation/Foundation.h>

@class MMRow;
@protocol MMTableCell <NSObject>
/**
 *   load cell's data model , init cell
 */
- (void)handleCellWithRow:(MMRow*)row;

@end
