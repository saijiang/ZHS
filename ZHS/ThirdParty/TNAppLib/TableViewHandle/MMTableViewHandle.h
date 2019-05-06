//
//  MMTableViewHandle.h
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
//  MMTableViewHandle. Manager TableView.
//  UPDATE 2015-07-08 : fix error that not reset seleced sgin of MMRow model and not check allowKeepingSelected in -[selectedRow:] methods
//  UPDATE 2015-07-08 : add get selected rows and scrollToRow methods
//  UPDATE 2015-07-09 : arrange model methods，add insert muti-rows methods.
//  LAST UPDATE 2015-07-14 : change some methods param type from NSSet to MMTableRowGroup.
//****************************************************************************************
//

#import <UIKit/UIKit.h>
#import "MMHandle.h"
#import "MMTable.h"

@class MMTableViewHandle;
/**
 *  add handle property for UITableView
 */
@interface UITableView (MMTableHandle)
@property (weak, nonatomic) MMTableViewHandle* handle;
@end

#pragma mark - MMTableViewHandleDelegate
@class MMTable, MMSection, MMRow;
@protocol MMTableViewHandleDelegate <NSObject, MMHandleDelegate>

@optional
/**
 *  Responds to cell click, invoked in -[tableView: didSelectRowAtIndexPath:]. If allowKeepSelecting is YES, -[tableView deselectRowAtIndexPath:animated:] will be invoked after this method completed
 *
 *  @param tableHandle  tableViewHandle of tableView
 *  @param cell        cell be clicked
 *  @param indexPath   position of cell in tableView
 */
- (void)tableHandle:(MMTableViewHandle *)tableHandle didSelectCell:(UITableViewCell *)cell forRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath;
/**
 *  Responds to cell click, invoked in -[tableView: didDeselectRowAtIndexPath:].
 *
 *  @param tableHandle tableViewHandle of tableView
 *  @param cell        cell be clicked
 *  @param indexPath   position of cell in tableView
 */
- (void)tableHandle:(MMTableViewHandle *)tableHandle didDeselectCell:(UITableViewCell *)cell forRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath;
/**
 *  Responds to cell delete. Do something after cell delete. MMTableViewHandle delete row methods dont call this method.
 *
 *  @param tableHandle tableViewHandle of tableView
 *  @param cell         deleted cell
 *  @param row         deleted row
 *  @param indexPath   position of cell in tableView
 */
- (void)tableHandle:(MMTableViewHandle *)tableHandle didDeleteCell:(UITableViewCell *)cell forRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath;
/**
 *  Responds to cell accessory button click if accessory type is UITableViewCellAccessoryDetailButton or UITableViewCellAccessoryDetailDisclosureButton
 *
 *  @param tableHandle tableViewHandle of tableView
 *  @param indexPath   position of cell in tableView
 */
- (void)tableHandle:(MMTableViewHandle *)tableHandle accessoryButtonTappedForRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath;
/**
 *  UIScrollViewDelegate method, invoked in -[scrollViewDidScroll:]
 *
 *  @param tableViewHandle tableViewHandle of tableView
 *  @param offset          scroll contentOffset
 */
- (void)tableHandle:(MMTableViewHandle *)tableHandle scrollDidScroll:(CGPoint)offset;
/**
 *  Responds to  UIScrollViewDelegate method, invoked in -[scrollViewDidEndScrollingAnimation:] , -[scrollViewDidEndDecelerating:] or -[scrollViewDidEndDragging:willDecelerate:] when decelerate is NO.
 *
 *  @param tableHandle tableViewHandle of tableView
 *  @param offset      scroll contentOffset when stop
 */
- (void)tableHandle:(MMTableViewHandle *)tableHandle scrollDidStopScroll:(CGPoint)offset;

- (void)tableHandleTableWillScrollToTop:(MMTableViewHandle *)tableHandle;
- (void)tableHandleTableWillScrollToEnd:(MMTableViewHandle *)tableHandle;

@end

#pragma mark - MMTableViewHandle
// block type define
typedef void(^MMTableHandleCellDeleagteBlock)(MMTableViewHandle *tableHandle, MMRow *row, UITableViewCell *cell, NSIndexPath *indexPath);
typedef void(^MMTableHandleScrollDeleagteBlock)(MMTableViewHandle *tableHandle, CGPoint offset);

typedef MMRow *(^MMTableHandleInsertRowBlock)(NSIndexPath *indexPath);
typedef UIView *(^MMTableHandleAccessoryViewBlock)(NSIndexPath *indexPath);

@class MMTableLimitSelectGroup;
@interface MMTableViewHandle : MMHandle<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) id<MMTableViewHandleDelegate> delegate;
@property (strong, nonatomic) UITableView *tableView;
/**
 *  table data model, all infomation of tableView packaged in this model
 */
@property (strong, nonatomic) MMTable *tableModel;
/**
 *  Default YES. If NO, -[tableView:deselectRowAtIndexPath:animated:] will be invoked in -[tableView:didSelectRowAtIndexPath:] after delay some second depend on keepingSelectingDuring.
 */
@property (nonatomic) BOOL allowKeepSelecting;
/**
 *  Default -1. If allowKeepSelecting is No, keepingSelectingDuring will decide howmuch time cell can be keeping selected. If -1, cell will be deseleted immediately and without invoke -[tableView:deselectRowAtIndexPath:animated:] delegate method.
 */
@property (nonatomic) NSTimeInterval keepingSelectingDuring;
/**
 *  Default YES. For this set, row deselected because of not allowKeepSeletcting or in toggle selected rows group, will animate the deselection or not.
 */
@property (nonatomic) BOOL autoDeselectedAnimated;
/**
 *  Default UITableViewCellEditingStyleNone. If Row setting is MMTableViewCellEditingStyleAutomatic, -[tableView:editingStyleForRowAtIndexPath:] method will return this setting.
 */
@property (nonatomic) UITableViewCellEditingStyle cellEditingStyle;
/**
 *  Default nil. If cell editingStyle is UITableViewCellEditingStyleInsert, this block must be implementation and should retrun a valid MMRow instance, otherwise throw an exception.
 */
@property (copy, nonatomic) MMTableHandleInsertRowBlock cellInsertBlock;
/**
 *  Default UITableViewCellAccessoryNone. If row setting is MMTableViewCellAccessoryTypeAutomatic,  cell.accessoryType will use this setting.
 */
@property (nonatomic) UITableViewCellAccessoryType cellAccessoryType;
/**
 *  Default nil. If accessory type of Row is MMTableViewCellAccessoryTypeAutomatic and accessory view of Row is nil, cell.accessoryView will use the retrun view of the block. If set, ignore cellAccessoryType.
 */
@property (copy, nonatomic) MMTableHandleAccessoryViewBlock cellAccessoryViewBlock;
/**
 *  Default NO. If YES, -[tableView:shouldShowMenuForRowAtIndexPath:] will allways retrun YES, otherwise retrun depends on row.
 */
@property (nonatomic) BOOL allowCellEditingMenu;

#pragma mark init
// Factory Init Method
+ (instancetype)handleWithTableView:(UITableView *)tableView withTableModel:(MMTable*)model;
+ (instancetype)handleWithTableView:(UITableView *)tableView;

#pragma mark register cell
/**
 *  Register tableViewCell Nib with identifier. NOTICE: make sure your reuseIdentifier is same as the cell nib file name.
 *
 *  @param identifier reuse identifier
 *
 *  @return setting result.
 */
- (MMResult)registerTableCellNibWithIdentifier:(NSString *)identifier;
/**
 *  Register tableViewCell Class with identifier. NOTICE: make sure your reuseIdentifier is same as the cell class name.
 *
 *  @param identifier reuse identifier
 *
 *  @return setting result.
 */
- (MMResult)registerTableCellClassWithIdentifier:(NSString *)identifier;

#pragma mark reload
- (void)reloadTable;
- (void)reloadTableSection:(NSInteger)section withAbumation:(UITableViewRowAnimation)animation;
- (void)reloadTableSections:(NSIndexSet *)sections withAbumation:(UITableViewRowAnimation)animation;
- (void)reloadTableRowsAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadTableRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

#pragma mark table model
/**
 *  row at index section 0 row 0. Nil if tableModel is nil or no section in tableModel
 */
@property (readonly, nonatomic) MMRow                      *firstRow;
/**
 *  last row of last section. Nil if tableModel is nil or no section in tableModel
 */
@property (readonly, nonatomic) MMRow                      *lastRow;
/**
 *  indexPath of last row. Nil if tableModel is nil or no section in tableModel
 */
@property (readonly, nonatomic) NSIndexPath               *lastIndexPath;

// get number methods, retrun -1 if error
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)index;
- (NSInteger)numberOfTotalRows;

// get model methods  UPDATE 2015-07-09
- (MMSection *)sectionWithIndex:(NSInteger)index;
- (MMRow *)rowWithIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)selectedRows;
- (NSArray *)selectedRowsOfSection:(NSInteger)section;
- (NSArray *)visibleRows;

#pragma mark table opera
// insert methods
- (MMResult)insertRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
- (MMResult)insertRows:(NSArray *)rows aboveIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation; // ADD 2015-07-09
- (MMResult)insertRows:(NSArray *)rows belowIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation; // ADD 2015-07-09
- (MMResult)insterSection:(MMSection *)section atIndex:(NSInteger)index withRowAnimation:(UITableViewRowAnimation)animation;

// replace rows
- (MMResult)replaceRows:(NSArray *)rows forSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

// delete methods, These methods will not call the delegate method -[tableHandle: didDeleteCell: forRow: atIndexPath:]
- (MMResult)deleteRow:(MMRow *)row withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteRows:(MMTableRowGroup *)rows  withRowAnimation:(UITableViewRowAnimation)animation; // this method is not safe if there is invalid value in container
- (MMResult)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteRowsWithIndexPaths:(NSSet *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation; // this method is not safe if there is invalid value in container
- (MMResult)deleteSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation; // this method is not safe if there is invalid value in container

// swap methods
- (MMResult)swapRow:(MMRow *)row withRow:(MMRow *)anotherRow withRowAnimation:(UITableViewRowAnimation)animation;
- (MMResult)swapRowAtIndexPath:(NSIndexPath *)indexPath withIndexPath:(NSIndexPath *)anotherIndexPath withRowAnimation:(UITableViewRowAnimation)animation;
- (MMResult)swapSection:(MMSection *)section withSection:(MMSection *)anotherSection withRowAnimation:(UITableViewRowAnimation)animation;
- (MMResult)swapSectionAtIndex:(NSInteger)index withIndex:(NSInteger)anotherIndex withRowAnimation:(UITableViewRowAnimation)animation;

// move methods
- (MMResult)moveRow:(MMRow *)row toIndexPath:(NSIndexPath *)indexPath;
- (MMResult)moveRowAtIndexPath:(NSIndexPath *)rowIndexPath toIndexPath:(NSIndexPath *)indexPath;
- (MMResult)moveSection:(MMSection *)section toIndex:(NSInteger)index;
- (MMResult)moveSectionAtIndex:(NSInteger)sectionIndex toIndex:(NSInteger)index;

// selecte and deselect methods, These methods will not call the delegate method -[tableHandle: didSelectCell: atIndexPath:] or -[tableHandle: didDeselectCell: atIndexPath:]
- (MMResult)selectedRow:(MMRow *)row animated:(BOOL)animated withScrollPosition:(UITableViewScrollPosition)position;
- (void)selectedRows:(MMTableRowGroup *)rows; // this method is not safe if there is invalid value in container, and defult set animated is NO
- (MMResult)selectedRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated withScrollPosition:(UITableViewScrollPosition)position;
- (void)selectedRowWithIndexPaths:(NSSet *)indexPaths; // this method is not safe if there is invalid value in container, and defult set animated is NO

- (MMResult)deselectRow:(MMRow *)row animated:(BOOL)animated;
- (void)deselectRows:(MMTableRowGroup *)rows animated:(BOOL)animated; // this method is not safe if there is invalid value in container,
- (MMResult)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)deseleteRowsWithIndexPaths:(NSSet *)indexPaths animated:(BOOL)animated; // this method is not safe if there is invalid value in container

// scroll table view
- (MMResult)scrollToRow:(MMRow *)row animated:(BOOL)animated withScrollPosition:(UITableViewScrollPosition)position;
- (MMResult)scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated withScrollPosition:(UITableViewScrollPosition)position;

/**
 *  Enumerate rows of section. NOTICE: dont delete or insert row during enumerate.
 *
 *  @param section    section index.
 *  @param enumerateBlock enumerate block, enumerate stop if set stop YES in block.
 */
- (void)enumerateRowsInSection:(NSInteger)section usingBlock:(void(^)(MMRow *row, NSIndexPath *indexPath, BOOL *stop))enumerateBlock;
/**
 *  Enumerate all rows in table. NOTICE: dont delete or insert row during enumerate.
 *
 *  @param enumerateBlock enumerate block, enumerate stop if set stop YES in block.
 */
- (void)enumerateAllRowsUsingBlock:(void(^)(MMRow *row, NSIndexPath *indexPath, BOOL *stop))enumerateBlock;

#pragma mark foundation methods
/**
 *  Set some rows allow selected or not.
 *
 *  @param allow      allow selected or not.
 *  @param rowGroup MMTableRowGroup object, MMRow objects in it.
 *
 *  @return setting result.
 */
- (MMResult)setAllowSelected:(BOOL)allow forRows:(MMTableRowGroup *)rowGroup;
/**
 *  Set some rows can only selected one or several of them as a multiple-pole switch. NOTICE: a row only can be in one group.
 *
 *  @param group a MMTableLimitSelectGroup object wrap of MMRows and some other settings.
 *
 *  @return setting result.
 */
- (MMResult)addLimitSelectRowsGroup:(MMTableLimitSelectGroup *)group;
/**
 *  Remove multiple-pole switch rows group
 *
 *  @param group a MMTableLimitSelectGroup object wrap of MMRows and some other settings.
 *
 *  @return setting result.
 */
- (MMResult)removeLimitSelectRowsGroup:(MMTableLimitSelectGroup *)group;

#pragma mark callback block
// Callback Block
@property (copy, nonatomic) MMTableHandleCellDeleagteBlock cellDidSelectedBlock;
@property (copy, nonatomic) MMTableHandleCellDeleagteBlock cellDidDeselectedBlock;
@property (copy, nonatomic) MMTableHandleCellDeleagteBlock cellDidDeletedBlock;
@property (copy, nonatomic) MMTableHandleCellDeleagteBlock accessoryTappedBlock;
@property (copy, nonatomic) MMTableHandleScrollDeleagteBlock scrollDidScrollBlock;
@property (copy, nonatomic) MMTableHandleScrollDeleagteBlock scrollStopScrollBlock;
@end


