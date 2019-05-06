//
//  MMTable.h
//  Mikoto
//
//  Created by xxd on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
//  MMTable, MMSection, MMRow. Be used to maintain table view infomation and table cell data in MMTableViewHandle
//****************************************************************************************
//

#import <UIKit/UIKit.h>
#import "MMTag.h"
#import "MMConstants.h"

extern CGFloat const MMTableDefaultHeightSign;

#pragma mark - MMTable
@class MMSection, MMRow;
@interface MMTable : MMTag
@property (readonly, nonatomic)          NSInteger          numberOfSections;
@property (strong, nonatomic)             NSArray*          sections;
/**
 *  Creat a new MMTable instance with tag 0 and no sections,
 *
 *  @return new MMTable
 */
+ (instancetype)table;
+ (instancetype)tableWithTag:(NSInteger)tag sections:(NSArray*)sections;

- (MMSection *)sectionAtIndex:(NSInteger)index;
- (void)addSection:(MMSection *)section;
- (void)addSections:(NSArray *)sections;
- (void)insertSection:(MMSection *)section atIndex:(NSInteger)index;
- (void)removeSection:(MMSection *)section;
- (void)removeSections:(NSSet *)sections;
- (void)removeSectionAtIndex:(NSInteger)index;
- (void)removeSectionsWithIndexSet:(NSIndexSet *)indexes;

- (MMRow *)rowAtIndexPath:(NSIndexPath *)indexPath;
- (void)insertRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath;
- (void)removeRow:(MMRow *)row;
- (void)removeRows:(NSSet *)rows;
- (void)removeRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)removeRowsWithIndexPaths:(NSSet *)indexPaths;

- (BOOL)containsSection:(MMSection *)section;
- (BOOL)containsRow:(MMRow *)row;
- (BOOL)containsIndexPath:(NSIndexPath *)indexPath;


@end

#pragma mark - MMSection
@class MMRow, MMBaseModel;
@interface MMSection : MMTag
/**
 *  index of section, assign when MMSection be added in MMTable.
 */
@property (strong, readonly, nonatomic)     NSNumber*                  sectionNumber;
@property (readonly, nonatomic)               NSInteger                   numberOfRows;
@property (strong, nonatomic)                 NSString*                    sectionIndexTitle;
@property (strong, nonatomic)                 NSString*                    headerTitle;
@property (strong, nonatomic)                 NSString*                    footerTitle;
@property (strong, nonatomic)                 UIView*                      headerView;
@property (strong, nonatomic)                 UIView*                      footerView;
@property (nonatomic)                          CGFloat                       heightForHeader;
@property (nonatomic)                          CGFloat                       heightForFooter;
/**
 *  wrapping some custom information for the section. default is nil.
 */
@property (strong, nonatomic)                id                                sectionInfo;
@property (strong, nonatomic)                NSArray*                     rows;
/**
 *  Creat a new MMSection instance with tag 0 and no rows,
 *
 *  @return new MMSection
 */
+ (instancetype)section;
+ (instancetype)sectionWithTag:(NSInteger)tag rows:(NSArray*)rows;

- (MMRow *)rowAtIndex:(NSInteger)index;
- (void)addRow:(MMRow *)row;
- (void)addRows:(NSArray *)rows;
- (void)insertRow:(MMRow *)row atIndex:(NSInteger)index;
- (void)removeRow:(MMRow *)row;
- (void)removeRows:(NSSet *)rows;
- (void)removeRowAtIndex:(NSInteger)index;
- (void)removeRowWithIndexSet:(NSIndexSet *)indexes;


- (BOOL)containsRow:(MMRow *)row;
@end

typedef enum : NSUInteger {
    MMRowMenuTypeCopy,
    MMRowMenuTypePaste,
    MMRowMenuTypeBoth,
} MMRowMenuType;

typedef enum : NSUInteger {
    MMTableViewCellEditingStyleAutomatic,  //Cell editing style depend on Table setting
    MMTableViewCellEditingStyleNone,        //Cell editing style = UITableViewCellEditingStyleNone
    MMTableViewCellEditingStyleDelete,      //Cell editing style = UITableViewCellEditingStyleDelete
    MMTableViewCellEditingStyleInsert,      //Cell editing style = UITableViewCellEditingStyleInsert
} MMTableViewCellEditingStyle;

typedef enum : NSUInteger {
    MMTableViewCellAccessoryTypeAutomatic,   //Cell accessory type depend on Table setting
    MMTableViewCellAccessoryTypeNone,                   // Cell accessory type = UITableViewCellAccessoryNone
    MMTableViewCellAccessoryTypeDisclosureIndicator,    // Cell accessory type = UITableViewCellAccessoryDisclosureIndicator
    MMTableViewCellAccessoryTypeDetailDisclosureButton, // Cell accessory type = UITableViewCellAccessoryDetailDisclosureButton
    MMTableViewCellAccessoryTypeCheckmark,              // Cell accessory type = UITableViewCellAccessoryCheckmark
    MMTableViewCellAccessoryTypeDetailButton  // Cell accessory type = UITableViewCellAccessoryDetailButton
} MMTableViewCellAccessoryType;


#pragma mark - MMRow
typedef void(^MMRowPasteBlock)(NSData *);

@interface MMRow : MMTag
/**
 *  indexPath of row, assign when MMRow be added in MMTable.
 */
@property (strong, readonly, nonatomic)  NSIndexPath*                       indexPath;
@property (nonatomic)                        BOOL                                  seleted;
/**
 *  Default is MMTableViewCellEditingStyleAutomatic. If MMTableViewCellEditingStyleAutomatic, cell editing style will depends on MMTableViewHandle setting. otherwise -[tableView:editingStyleForRowAtIndexPath:] method will return this setting.
 */
@property (nonatomic) MMTableViewCellEditingStyle editingStyle;
/**
 *  Default is MMTableViewCellAccessoryTypeAutomatic. If MMTableViewCellAccessoryTypeAutomatic, cell.accessoryType will depends on MMTableViewHandle setting. otherwise use this setting.
 */
@property (nonatomic) MMTableViewCellAccessoryType accessoryType;
/**
 *  Default is nil. If set, will use custom view for cell accessory view, ignore accessoryType.
 */
@property (strong, nonatomic) UIView *accessoryView;
/**
 *  If the user tap-holds a certain row in the table view, show editing menu or not. Default NO.
 */
@property (nonatomic)                       BOOL                                   allowMenu;
@property (nonatomic)                       MMRowMenuType                    allowMenuActions;
@property (strong, nonatomic)             NSString*                              pasteboardUTI;   //Default "com.m_mikoto.default". this is used for copy and paste object for pasteboard. public UTI: https://developer.apple.com/library/mac/documentation/MobileCoreServices/Reference/UTTypeRef/index.html#//apple_ref/doc/constant_group/UTI_Composite_Content_Types
@property (strong, nonatomic)             id                                         rowCopyActionObject; // objec coped to pasteboard when long press on cell to edit
@property (copy, nonatomic)               MMRowPasteBlock                    rowPasteActionBlock; // block of paste edit when long press on cell.

@property (nonatomic)                       CGFloat                                heightForRow;
@property (strong, nonatomic)             NSString*                              reuseIdentifier;
/**
 *  wrapping some custom information for the row.
 */
@property (strong, nonatomic)             id                                         rowInfo;
/**
 *  custom actions in cell, such as button or gesture recognizer in cell, maybe you can use NSArray , NSDictionary or a Mode wrapping some blocks
 */
@property (strong, nonatomic)             id                                         rowActions;

+ (instancetype)rowWithTag:(NSInteger)tag rowInfo:(id)data reuseIdentifier:(NSString*)identifier;
+ (instancetype)rowWithTag:(NSInteger)tag rowInfo:(id)data rowActions:(id)actions reuseIdentifier:(NSString *)identifier;
+ (instancetype)rowWithTag:(NSInteger)tag rowInfo:(id)data height:(CGFloat)height reuseIdentifier:(NSString*)identifier;
+ (instancetype)rowWithTag:(NSInteger)tag rowInfo:(id)data rowActions:(id)actions height:(CGFloat)height reuseIdentifier:(NSString *)identifier;
+ (NSMutableArray*)rowsWithTag:(NSInteger)tag rowsInfo:(NSArray*)datas height:(CGFloat)height reuseIdentifier:(NSString*)identifier;

@end

#pragma mark - MMTableRowGroup
@interface MMTableRowGroup : NSObject
/**
 *  MMRow objects of the group.
 */
@property (strong, nonatomic) NSSet *rows;

+ (instancetype)groupOfRows:(NSSet *)rows;

- (void)enumerateRowsUsingBlock:(void (^)(MMRow *row, BOOL *stop))block;
- (void)enumerateRowsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(MMRow *row, BOOL *stop))block;

@end

@interface MMTableLimitSelectGroup : MMTableRowGroup
/**
 *  Defulte 1.  This determine how many rows can be selected in the group.
 */
@property (readonly, nonatomic) NSUInteger          allowSelectLimit;
/**
 *  Defulte NO. If YES, you can not deselect all row of this group
 */
@property (nonatomic) BOOL                  keepingSelected;
/**
 *  Defulte 1. If set keepingSelected YES, this determine how many rows must keeping selected.
 */
@property (nonatomic) NSUInteger          minSelectedKeeping;

+ (instancetype)groupOfRows:(NSSet *)rows withNumberAllowSelect:(NSUInteger)limit;

@end

