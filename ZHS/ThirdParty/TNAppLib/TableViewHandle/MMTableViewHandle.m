//
//  MMTableViewHandle.m
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//

#import "MMTableViewHandle.h"
#import "MMTable.h"
#import "MMTableCell.h"
#import "MMMacros.h"
#import "NSArray+MMExt.h"
#import "NSTimer+MMExt.h"
#import <objc/runtime.h>

#define TableCheck(_return_)  do{  if (!_tableView) return _return_; } while (0)
#define ModelCheck(_return_) do{  if (!_tableModel) return _return_; } while (0)

#pragma mark - UITableView(MMTableHandle)
@implementation UITableView (MMTableHandle)

static char mmtableHanleProptySign;

- (void)setHandle:(MMTableViewHandle *)handle
{
    objc_setAssociatedObject(self, &mmtableHanleProptySign, handle, OBJC_ASSOCIATION_ASSIGN);
}

- (MMTableViewHandle *)handle
{
    return objc_getAssociatedObject(self, &mmtableHanleProptySign);
}

@end

#pragma mark - MMTableLimitSelectGroup
@interface MMTableLimitSelectGroup (MMTableHandle)

@property (readwrite, nonatomic) NSMutableArray *selectedRows;

@end

#pragma mark - MMTableViewHandle
@interface MMTableViewHandle ()
{
    NSMutableSet *_notAllowSelectedRows; // record indexPaths of not allow click cells
    NSMutableSet *_limitSelectRowsGroups;// record indexPaths of a multiple-pole switch cells  group
    CGFloat _lastOffsetY; // record last offset when table view scrolling
    NSMutableDictionary *_deselectedTimers;
}

@end

@implementation MMTableViewHandle
@dynamic delegate;

+ (instancetype)handleWithTableView:(UITableView*)tableView withTableModel:(MMTable*)model
{
    MMTableViewHandle* handle = [[MMTableViewHandle alloc] init];
    handle.tableView = tableView;
    handle.tableModel = model;
    return handle;
}

+ (instancetype)handleWithTableView:(UITableView *)tableView
{
    return [self handleWithTableView:tableView withTableModel:nil];
}

- (instancetype)init
{
    if (self = [super init])
    {
        _allowKeepSelecting = YES;
        _keepingSelectingDuring = -1;
        _autoDeselectedAnimated = YES;
        _cellEditingStyle =UITableViewCellEditingStyleNone;
        _cellAccessoryType = UITableViewCellAccessoryNone;
        _allowCellEditingMenu = NO;
        _notAllowSelectedRows = [NSMutableSet set];
        _limitSelectRowsGroups = [NSMutableSet set];
        _deselectedTimers = [@{} mutableCopy];
    }
    return self;
}

- (void)dealloc
{
    if (_tableView)
    {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
        _tableView.handle = nil;
    }
}

#pragma mark - Property Setter & Getter
- (void)setTableView:(UITableView *)tableView
{
    if (_tableView)
    {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
        _tableView.handle = nil;
    }
    _tableView = tableView;
    if (_tableView)
    {
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.handle = self;
    }
}

- (void)setKeepingSelectingDuring:(NSTimeInterval)keepingSelectingDuring
{
    if (keepingSelectingDuring == -1)
    {
        _keepingSelectingDuring = -1;
    }
    else
    {
        _keepingSelectingDuring = MAX(keepingSelectingDuring, 0);
    }
}

- (MMRow *)firstRow
{
    ModelCheck(nil);
    return [self rowWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (MMRow *)lastRow
{
    ModelCheck(nil);
    return _tableModel.sections.lastObject?((MMSection *)_tableModel.sections.lastObject).rows.lastObject:nil;
}

- (NSIndexPath *)lastIndexPath
{
    ModelCheck(nil);
    return self.lastRow?self.lastRow.indexPath:nil;
}

#pragma mark - Table Operation
- (void)reloadTable
{
    TableCheck();
    [_tableView reloadData];
}

- (void)reloadTableSection:(NSInteger)section withAbumation:(UITableViewRowAnimation)animation
{
    [self reloadTableSections:[NSIndexSet indexSetWithIndex:section] withAbumation:animation];
}

- (void)reloadTableSections:(NSIndexSet*)sections withAbumation:(UITableViewRowAnimation)animation
{
    TableCheck();
    [_tableView reloadSections:sections withRowAnimation:animation];
}

- (void)reloadTableRowsAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation
{
    [self reloadTableRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)reloadTableRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck();
    [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

#pragma mark insert
/**
 *  Inserts row in the table view at the indexPath, with an option to animate the insertion.
 *
 *  @param row       the MMRow object will be inserted in table
 *  @param indexPath target indexPath, representing a row index and section index that together identify a row in the table view
 *  @param animation A constant that either specifies the kind of animation to perform when inserting the cell or requests no animation.
 *
 *  @return setting result.
 */
- (MMResult)insertRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if (!row || !indexPath)  return MMResultInvalidValue;
    if ((MMCheckArrayNotOutofRange(indexPath.section, _tableModel.sections) && MMCheckUsignNumberUnder(indexPath.row, [_tableModel.sections[indexPath.section] numberOfRows]+1)) || (indexPath.section == _tableModel.numberOfSections && indexPath.row == 0))
    {
        [_tableModel insertRow:row atIndexPath:indexPath];
        [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
        return MMResultSuccess;
    }
    return MMResultOutOfRange;
}
/**
 *  Inserts consecutive rows in the table view above the indexPath, with an option to animate the insertion.
 *
 *  @param rows      an array of MMRow object that will be inserted in table.
 *  @param indexPath target indexPath that all rows insert above it.
 *  @param animation A constant that either specifies the kind of animation to perform when inserting the cell or requests no animation.
 *
 *  @return setting result.
 */
- (MMResult)insertRows:(NSArray *)rows aboveIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if (!rows || rows.count == 0 || !indexPath)  return MMResultInvalidValue;
    if ([_tableModel containsIndexPath:indexPath])
    {
        [rows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MMRow *row, NSUInteger idx, BOOL *stop) {
            [_tableModel insertRow:row atIndexPath:indexPath];
        }];
        [_tableView insertRowsAtIndexPaths:[rows valueForKey:@"indexPath"] withRowAnimation:animation];
        return MMResultSuccess;
    }
    return MMResultOutOfRange;
}
/**
 *  Inserts consecutive rows in the table view below the indexPath, with an option to animate the insertion.
 *
 *  @param rows      an array of MMRow object that will be inserted in table.
 *  @param indexPath target indexPath that all rows insert below it.
 *  @param animation A constant that either specifies the kind of animation to perform when inserting the cell or requests no animation.
 *
 *  @return setting result.
 */
- (MMResult)insertRows:(NSArray *)rows belowIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if (!rows || rows.count == 0 || !indexPath)  return MMResultInvalidValue;
    if ([_tableModel containsIndexPath:indexPath])
    {
        [rows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MMRow *row, NSUInteger idx, BOOL *stop) {
            [_tableModel insertRow:row atIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
        }];
        [_tableView insertRowsAtIndexPaths:[rows valueForKey:@"indexPath"] withRowAnimation:animation];
        return MMResultSuccess;
    }
    return MMResultOutOfRange;
}
/**
 *  Inserts one sections in the table view, with an option to animate the insertion.
 *
 *  @param section   the MMSection object will be insert in table
 *  @param index     An index set that specifies the sections to insert in the table view.
 *  @param animation A constant that indicates how the insertion is to be animated
 *
 *  @return setting result.
 */
- (MMResult)insterSection:(MMSection *)section atIndex:(NSInteger)index withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if (!section) return MMResultInvalidValue;
    if (MMCheckUsignNumberUnder(index, _tableModel.numberOfSections+1))
    {
        [_tableModel insertSection:section atIndex:index];
        [_tableView insertSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:animation];
        return MMResultSuccess;
    }
    return MMResultOutOfRange;
}

#pragma mark replace
/**
 *  Replace rows of section
 *
 *  @param rows    rows model, MMRow object in array.
 *  @param section section be reseted.
 *
 *  @return setting result.
 */
- (MMResult)replaceRows:(NSArray*)rows forSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)animation
{
    if (!rows || !_tableModel)
    {
        return MMResultNotFound;
    }
    else if (!MMCheckUsignNumberUnder(section, _tableModel.numberOfSections))
    {
        return MMResultOutOfRange;
    }
    else
    {
        ((MMSection*)_tableModel.sections[section]).rows = rows;
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
        return MMResultSuccess;
    }
}

#pragma mark delete
- (MMResult)deleteRow:(MMRow *)row withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if ([_tableModel containsRow:row])
    {
        [self _checkAndInvalidateDeselectTimers:row.indexPath];
        [_tableModel removeRow:row];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:row.indexPath] withRowAnimation:animation];
        return MMResultSuccess;
    }
    else
    {
        return MMResultNotFound;
    }
}

- (void)deleteRows:(MMTableRowGroup *)rows withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck();
    ModelCheck();
    NSMutableArray *indexPaths = [@[] mutableCopy];
    [rows enumerateRowsUsingBlock:^(MMRow *row, BOOL *stop) {
        [indexPaths addObject:row.indexPath];
        [self _checkAndInvalidateDeselectTimers:row.indexPath];
    }];
    [_tableModel removeRows:rows.rows];
    [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}


- (MMResult)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if ([_tableModel containsIndexPath:indexPath])
    {
        [self _checkAndInvalidateDeselectTimers:indexPath];
        [_tableModel removeRowAtIndexPath:indexPath];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
        return MMResultSuccess;
    }
    else
    {
        return MMResultNotFound;
    }
}

- (void)deleteRowsWithIndexPaths:(NSSet *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck();
    ModelCheck();
    if (!_allowKeepSelecting && _keepingSelectingDuring != -1)
    {
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
            [self _checkAndInvalidateDeselectTimers:indexPath];
        }];
    }
    [_tableModel removeRowsWithIndexPaths:indexPaths];
    [_tableView deleteRowsAtIndexPaths:indexPaths.allObjects withRowAnimation:animation];
}

- (MMResult)deleteSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if (section >=0 && section < _tableModel.numberOfSections)
    {
        if (!_allowKeepSelecting && _keepingSelectingDuring != -1)
        {
            [[_tableModel sectionAtIndex:section].rows enumerateObjectsUsingBlock:^(MMRow *row, NSUInteger idx, BOOL *stop) {
                [self _checkAndInvalidateDeselectTimers:row.indexPath];
            }];
        }
        [_tableModel removeSectionAtIndex:section];
        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
        return MMResultSuccess;
    }
    else
    {
        return MMResultNotFound;
    }
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck();
    ModelCheck();
    if (!_allowKeepSelecting && _keepingSelectingDuring != -1)
    {
        [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [[_tableModel sectionAtIndex:idx].rows enumerateObjectsUsingBlock:^(MMRow *row, NSUInteger idx, BOOL *stop) {
                [self _checkAndInvalidateDeselectTimers:row.indexPath];
            }];
        }];
    }
    [_tableModel removeSectionsWithIndexSet:sections];
    [_tableView deleteSections:sections withRowAnimation:animation];
}

#pragma mark swip
- (MMResult)swapRow:(MMRow *)row withRow:(MMRow *)anotherRow withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if (row == anotherRow) return MMResultInvalidValue;
    if ([_tableModel containsRow:row] && [_tableModel containsRow:anotherRow])
    {
        NSIndexPath *indexPath = row.indexPath;
        NSIndexPath *anotherIndexPath = anotherRow.indexPath;
        [self _swapDeselectTimer:indexPath another:anotherIndexPath];
        [_tableModel removeRow:row];
        [_tableModel removeRow:anotherRow];
        if (indexPath.row > anotherIndexPath.row)
        {
            [_tableModel insertRow:row atIndexPath:anotherIndexPath];
            [_tableModel insertRow:anotherRow atIndexPath:indexPath];
        }
        else
        {
            [_tableModel insertRow:anotherRow atIndexPath:indexPath];
            [_tableModel insertRow:row atIndexPath:anotherIndexPath];
        }
        [self reloadTableRowsAtIndexPaths:@[indexPath, anotherIndexPath] withRowAnimation:animation];
        return MMResultSuccess;
    }
    else
    {
        return MMResultNotFound;
    }
}

- (MMResult)swapRowAtIndexPath:(NSIndexPath *)indexPath withIndexPath:(NSIndexPath *)anotherIndexPath withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if (indexPath == anotherIndexPath) return MMResultInvalidValue;
    if ([_tableModel containsIndexPath:indexPath] && [_tableModel containsIndexPath:anotherIndexPath])
    {
        MMRow *row = [self rowWithIndexPath:indexPath];
        MMRow *anotherRow = [self rowWithIndexPath:anotherIndexPath];
        [self _swapDeselectTimer:indexPath another:anotherIndexPath];
        [_tableModel removeRow:row];
        [_tableModel removeRow:anotherRow];
        if (indexPath.row > anotherIndexPath.row)
        {
            [_tableModel insertRow:row atIndexPath:anotherIndexPath];
            [_tableModel insertRow:anotherRow atIndexPath:indexPath];
        }
        else
        {
            [_tableModel insertRow:anotherRow atIndexPath:indexPath];
            [_tableModel insertRow:row atIndexPath:anotherIndexPath];
        }
        [self reloadTableRowsAtIndexPaths:@[indexPath, anotherIndexPath] withRowAnimation:animation];
        return MMResultSuccess;
    }
    else
    {
        return MMResultOutOfRange;
    }
}

- (MMResult)swapSection:(MMSection *)section withSection:(MMSection *)anotherSection withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if (section == anotherSection) return MMResultInvalidValue;
    if ([_tableModel containsSection:section] && [_tableModel containsSection:anotherSection])
    {
        NSInteger index = section.sectionNumber.integerValue;
        NSInteger anotherIndex = anotherSection.sectionNumber.integerValue;
        [_tableModel removeSection:section];
        [_tableModel removeSection:anotherSection];
        if (index > anotherIndex)
        {
            [_tableModel insertSection:section atIndex:anotherIndex];
            [_tableModel insertSection:anotherSection atIndex:index];
        }
        NSMutableIndexSet *sections = [NSMutableIndexSet indexSet];
        [sections addIndex:index];
        [sections addIndex:anotherIndex];
        [self reloadTableSections:sections withAbumation:animation];
        return MMResultSuccess;
    }
    else
    {
        return MMResultNotFound;
    }
}

- (MMResult)swapSectionAtIndex:(NSInteger)index withIndex:(NSInteger)anotherIndex withRowAnimation:(UITableViewRowAnimation)animation
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if (index == anotherIndex) return MMResultInvalidValue;
    if (MMCheckUsignNumberUnder(index, _tableModel.numberOfSections) && MMCheckUsignNumberUnder(anotherIndex, _tableModel.numberOfSections))
    {
        MMSection *section = [self sectionWithIndex:index];
        MMSection *anotherSection = [self sectionWithIndex:anotherIndex];
        [_tableModel removeSection:section];
        [_tableModel removeSection:anotherSection];
        if (index > anotherIndex)
        {
            [_tableModel insertSection:section atIndex:anotherIndex];
            [_tableModel insertSection:anotherSection atIndex:index];
        }
        NSMutableIndexSet *sections = [NSMutableIndexSet indexSet];
        [sections addIndex:index];
        [sections addIndex:anotherIndex];
        [self reloadTableSections:sections withAbumation:animation];
        return MMResultSuccess;
    }
    else
    {
        return MMResultOutOfRange;
    }
    
}

#pragma mark move
- (MMResult)moveRow:(MMRow *)row toIndexPath:(NSIndexPath *)indexPath
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if ([_tableModel containsRow:row])
    {
        NSIndexPath *rowIndexPath = row.indexPath;
        if (MMCheckUsignNumberUnder(indexPath.row, [_tableModel.sections[indexPath.section] numberOfRows]+(rowIndexPath.section == indexPath.section?0:1)))
        {
            [_tableModel removeRow:row];
            [_tableModel insertRow:row atIndexPath:indexPath];
            [self reloadTable];
            return MMResultSuccess;
        }
        else
        {
            return MMResultOutOfRange;
        }
    }
    else
    {
        return MMResultNotFound;
    }
}

- (MMResult)moveRowAtIndexPath:(NSIndexPath *)rowIndexPath toIndexPath:(NSIndexPath *)indexPath
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if ([_tableModel containsIndexPath:rowIndexPath])
    {
        MMRow *row = [self rowWithIndexPath:rowIndexPath];
        if (MMCheckUsignNumberUnder(indexPath.row, [_tableModel.sections[indexPath.section] numberOfRows]+(rowIndexPath.section == indexPath.section?0:1)))
        {
            [_tableModel removeRow:row];
            [_tableModel insertRow:row atIndexPath:indexPath];
            [self reloadTable];
            return MMResultSuccess;
        }
        else
        {
            return MMResultOutOfRange;
        }
    }
    else
    {
        return MMResultOutOfRange;
    }
    
}

- (MMResult)moveSection:(MMSection *)section toIndex:(NSInteger)index
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if ([_tableModel containsSection:section])
    {
        if (MMCheckUsignNumberUnder(index, _tableModel.numberOfSections))
        {
            [_tableModel removeSection:section];
            [_tableModel insertSection:section atIndex:index];
            [self reloadTable];
            return MMResultSuccess;
        }
        else
        {
            return MMResultOutOfRange;
        }
    }
    else
    {
        return MMResultNotFound;
    }
}

- (MMResult)moveSectionAtIndex:(NSInteger)sectionIndex toIndex:(NSInteger)index
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if (MMCheckUsignNumberUnder(sectionIndex, _tableModel.numberOfSections))
    {
        MMSection *section = [self sectionWithIndex:sectionIndex];
        if (MMCheckUsignNumberUnder(index, _tableModel.numberOfSections))
        {
            [_tableModel removeSection:section];
            [_tableModel insertSection:section atIndex:index];
            [self reloadTable];
            return MMResultSuccess;
        }
        else
        {
            return MMResultOutOfRange;
        }
    }
    else
    {
        return MMResultOutOfRange;
    }
}

#pragma mark selecte
- (MMResult)selectedRow:(MMRow *)row animated:(BOOL)animated withScrollPosition:(UITableViewScrollPosition)position
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if ([_tableModel containsRow:row])
    {
        [_tableView selectRowAtIndexPath:row.indexPath animated:animated scrollPosition:position];
        row.seleted = YES;
        [self _checkRowSelection:row];
        return MMResultSuccess;
    }
    else
    {
        return MMResultNotFound;
    }
}

- (void)selectedRows:(MMTableRowGroup *)rows
{
    TableCheck();
    ModelCheck();
    [rows enumerateRowsWithOptions:NSEnumerationConcurrent usingBlock:^(MMRow *row, BOOL *stop) {
        if ([row isKindOfClass:[MMRow class]])
        {
            [_tableView selectRowAtIndexPath:row.indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            row.seleted = YES;
            [self _checkRowSelection:row];
        }
    }];
}

- (MMResult)selectedRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated withScrollPosition:(UITableViewScrollPosition)position
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if ([_tableModel containsIndexPath:indexPath])
    {
        [_tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:position];
        MMRow *selectedRow = [_tableModel rowAtIndexPath:indexPath];
        selectedRow.seleted = YES;
        [self _checkRowSelection:selectedRow];
        return MMResultSuccess;
    }
    else
    {
        return MMResultNotFound;
    }
}

- (void)selectedRowWithIndexPaths:(NSSet *)indexPaths
{
    TableCheck();
    ModelCheck();
    [indexPaths enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
        if ([indexPath isKindOfClass:[NSIndexPath class]])
        {
            [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            MMRow *selectedRow = [_tableModel rowAtIndexPath:indexPath];
            selectedRow.seleted = YES;
            [self _checkRowSelection:selectedRow];
        }
    }];
}

#pragma mark deselect
- (MMResult)deselectRow:(MMRow *)row animated:(BOOL)animated
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if ([_tableModel containsRow:row])
    {
        [_tableView deselectRowAtIndexPath:row.indexPath animated:animated];
        row.seleted = NO;
        return MMResultSuccess;
    }
    else
    {
        return MMResultNotFound;
    }
}

- (void)deselectRows:(MMTableRowGroup *)rows animated:(BOOL)animated
{
    TableCheck();
    ModelCheck();
    [rows enumerateRowsWithOptions:NSEnumerationConcurrent usingBlock:^(MMRow *row, BOOL *stop) {
        if ([row isKindOfClass:[MMRow class]])
        {
            [_tableView deselectRowAtIndexPath:row.indexPath animated:animated];
            row.seleted = NO;
        }
    }];
}

- (MMResult)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if ([_tableModel containsIndexPath:indexPath])
    {
        [_tableView deselectRowAtIndexPath:indexPath animated:animated];
        [_tableModel rowAtIndexPath:indexPath].seleted = NO;
        return MMResultSuccess;
    }
    else
    {
        return MMResultNotFound;
    }
}

- (void)deseleteRowsWithIndexPaths:(NSSet *)indexPaths animated:(BOOL)animated
{
    TableCheck();
    ModelCheck();
    [indexPaths enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
        if ([indexPath isKindOfClass:[NSIndexPath class]])
        {
            [_tableView deselectRowAtIndexPath:indexPath animated:animated];
            [_tableModel rowAtIndexPath:indexPath].seleted = NO;
        }
    }];
}

#pragma mark scroll
- (MMResult)scrollToRow:(MMRow *)row animated:(BOOL)animated withScrollPosition:(UITableViewScrollPosition)position
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if ([_tableModel containsRow:row])
    {
        [_tableView scrollToRowAtIndexPath:row.indexPath atScrollPosition:position animated:animated];
        return MMResultSuccess;
    }
    else
    {
        return MMResultNotFound;
    }
}

- (MMResult)scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated withScrollPosition:(UITableViewScrollPosition)position
{
    TableCheck(MMResultAssignError);
    ModelCheck(MMResultAssignError);
    if ([_tableModel containsIndexPath:indexPath])
    {
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:position animated:animated];
        return MMResultSuccess;
    }
    else
    {
        return MMResultNotFound;
    }
}


#pragma mark - Data Operation
/**
 *  MMSection model for the index.
 *
 *  @param index section index.
 *
 *  @return The MMSection model for the index. Nil if table model not contains this section index.
 */
- (MMSection *)sectionWithIndex:(NSInteger)index
{
    if (_tableModel && MMCheckUsignNumberUnder(index, _tableModel.numberOfSections))
    {
        return _tableModel.sections[index];
    }
    else
    {
        return nil;
    }
}
/**
 *  MMRow model for the indexPath
 *
 *  @param indexPath indexPath of the row which you want
 *
 *  @return The MMRow model for the indexPath. Nil if table model not cantains this indexPath.
 */
- (MMRow *)rowWithIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (_tableModel && MMCheckUsignNumberUnder(section, _tableModel.numberOfSections) && MMCheckUsignNumberUnder(row, [_tableModel.sections[section] numberOfRows]))
    {
        return ((MMSection*)_tableModel.sections[section]).rows[row];
    }
    return nil;
}

/**
 *  MMRow modles which is selected in table.
 *
 *  @return NSArray with MMRow in it. Nil if tableModel is nil or no row in tableModel. Empty array if none selected.
 */
- (NSArray *)selectedRows
{
    TableCheck(nil);
    if (!self.firstRow) return nil;
    if (!_tableView.allowsSelection) return nil;
    if (_tableView.allowsMultipleSelection)
    {
        return [[_tableView indexPathsForSelectedRows] arrayTransformObjectWithBlock:^id(NSIndexPath *indexPath, NSInteger index, BOOL *stop) {
            return [self rowWithIndexPath:indexPath];
        }];
    }
    else
    {
        NSIndexPath* indexPath = [_tableView indexPathForSelectedRow];
        return indexPath ? @[[self rowWithIndexPath:indexPath]] : @[];
    }
}
/**
 *  MMRow modles which is selected in a section.
 *
 *  @param section section index
 *
 *  @return NSArray of MMRow. Nil if tableModel is nil or no section in tableModel. Empty array if none selected in the section.
 */
- (NSArray *)selectedRowsOfSection:(NSInteger)section
{
    TableCheck(nil);
    if (!self.firstRow || !_tableView.allowsSelection || !MMCheckUsignNumberUnder(section, _tableModel.numberOfSections)) return nil;
    NSMutableArray *selectedRows = [@[] mutableCopy];
    [[self sectionWithIndex:section].rows enumerateObjectsUsingBlock:^(MMRow *row, NSUInteger idx, BOOL *stop) {
        if (row.seleted)
        {
            [selectedRows addObject:row];
        }
    }];
    return selectedRows;
}
/**
 *  Returns an array of index paths each identifying a visible row in the table view
 *
 *  @return NSArray of MMRow. Nil if tableModel is nil or no row in tableModel. Empty array if none visible row.
 */
- (NSArray *)visibleRows
{
    TableCheck(nil);
    if (!self.firstRow) return nil;
    return [[_tableView indexPathsForVisibleRows] arrayTransformObjectWithBlock:^id(NSIndexPath *indexPath, NSInteger index, BOOL *stop) {
        return [self rowWithIndexPath:indexPath];
    }];
}

#pragma mark get number
- (NSInteger)numberOfSections
{
    TableCheck(-1);
    ModelCheck(-1);
    return _tableModel.numberOfSections;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)index
{
    TableCheck(-1);
    ModelCheck(-1);
    return MMCheckArrayNotOutofRange(index, _tableModel.sections)?[self sectionWithIndex:index].numberOfRows:-1;
}

- (NSInteger)numberOfTotalRows
{
    TableCheck(-1);
    ModelCheck(-1);
    __block NSInteger total = 0;
    [_tableModel.sections enumerateObjectsUsingBlock:^(MMSection *section, NSUInteger idx, BOOL *stop) {
        total += section.numberOfRows;
    }];
    return total;
}

#pragma mark enumerate Methods

- (void)enumerateRowsInSection:(NSInteger)section usingBlock:(void(^)(MMRow *row, NSIndexPath *indexPath, BOOL *stop))enumerateBlock
{
    ModelCheck();
    if (MMCheckArrayNotOutofRange(section, _tableModel.sections))
    {
        MMSection *enumerateSection = [self sectionWithIndex:section];
        [enumerateSection.rows enumerateObjectsUsingBlock:^(MMRow *row, NSUInteger idx, BOOL *stop) {
            if (enumerateBlock) {
                enumerateBlock(row, [NSIndexPath indexPathForRow:idx inSection:section], stop);
            }
        }];
    }
}

- (void)enumerateAllRowsUsingBlock:(void(^)(MMRow *row, NSIndexPath *indexPath, BOOL *stop))enumerateBlock
{
    ModelCheck();
    for (MMSection *section in _tableModel.sections)
    {
        __block BOOL enumerateStop = NO;
        [section.rows enumerateObjectsUsingBlock:^(MMRow *row, NSUInteger idx, BOOL *stop) {
            if (enumerateBlock) {
                enumerateBlock(row, row.indexPath, stop);
                enumerateStop = *stop;
            }
        }];
        if (enumerateStop)
        {
            break;
        }
    }
}

#pragma mark - Function Methods

- (MMResult)registerTableCellNibWithIdentifier:(NSString *)identifier
{
    TableCheck(MMResultAssignError);
    UINib* cellNib = [UINib nibWithNibName:identifier bundle:[NSBundle mainBundle]];
    if (!cellNib)
    {
        return MMResultInvalidValue;
    }
    else
    {
        [_tableView registerNib:cellNib forCellReuseIdentifier:identifier];
        return MMResultSuccess;
    }
}

- (MMResult)registerTableCellClassWithIdentifier:(NSString *)identifier
{
    TableCheck(MMResultAssignError);
    Class cellclass = NSClassFromString(identifier);
    if (!cellclass)
    {
        return MMResultInvalidValue;
    }
    else
    {
        [_tableView registerClass:cellclass forCellReuseIdentifier:identifier];
        return MMResultSuccess;
    }
}

- (MMResult)setAllowSelected:(BOOL)allow forRows:(MMTableRowGroup *)rowGroup;
{
    if (!rowGroup.rows)
    {
        return MMResultAssignTypeError;
    }
    if (allow)
    {
        [_notAllowSelectedRows minusSet:rowGroup.rows];
    }
    else
    {
        [_notAllowSelectedRows unionSet:rowGroup.rows];
    }
    return MMResultSuccess;
}

- (MMResult)addLimitSelectRowsGroup:(MMTableLimitSelectGroup *)group;
{
    if (!group || ![group isKindOfClass:[MMTableLimitSelectGroup class]])
    {
        return MMResultInvalidValue;
    }
    __block BOOL intersects = NO;
    [_limitSelectRowsGroups enumerateObjectsUsingBlock:^(MMTableLimitSelectGroup *obj, BOOL *stop) {
        if ([group.rows intersectsSet:obj.rows])
        {
            intersects = YES;
            *stop = YES;
        }
    }];
    if (intersects)
    {
        return MMResultInvalidValue;
    }
    else
    {
        [_limitSelectRowsGroups addObject:group];
        return MMResultSuccess;
    }
}

- (MMResult)removeLimitSelectRowsGroup:(MMTableLimitSelectGroup *)group
{
    if (!group || ![group isKindOfClass:[MMTableLimitSelectGroup class]])
    {
        return MMResultInvalidValue;
    }
    BOOL find = [_limitSelectRowsGroups containsObject:group];
    if (find)
    {
        [_limitSelectRowsGroups removeObject:group];
        return MMResultSuccess;
    }
    else
    {
        return MMResultNotFound;
    }
}

#pragma mark - Private Utils

- (BOOL)_checkDelegate:(SEL)sel { return self.delegate && [self.delegate respondsToSelector:sel]; }

- (void)_checkRowSelection:(MMRow *)row
{
    if (!_allowKeepSelecting)
    {
        if (_keepingSelectingDuring != -1)
        {
            _deselectedTimers[row.indexPath] = [NSTimer scheduledTimerWithTimeInterval:_keepingSelectingDuring forLoopBlock:^(NSTimer *timer) {
                [_tableView deselectRowAtIndexPath:row.indexPath animated:_autoDeselectedAnimated];
                [self tableView:_tableView didDeselectRowAtIndexPath:row.indexPath];
            } userInfo:nil repeats:NO];
        }
        else
        {
            [_tableView deselectRowAtIndexPath:row.indexPath animated:_autoDeselectedAnimated];
            row.seleted = NO;
        }
    }
    else
    {
        [_limitSelectRowsGroups enumerateObjectsUsingBlock:^(MMTableLimitSelectGroup* group, BOOL *stop) {
            if ([group.rows containsObject:row])
            {
                [group.rows enumerateObjectsUsingBlock:^(MMRow *obj, BOOL *stop) {
                    if (obj.seleted && obj != row && ![group.selectedRows containsObject:obj])
                    {
                        [group.selectedRows addObject:obj];
                    }
                }];
                
                if (group.selectedRows.count >= group.allowSelectLimit)
                {
                    NSInteger deselectCount = group.selectedRows.count - group.allowSelectLimit;
                    while (deselectCount >= 0)
                    {
                        MMRow *deselectRow = group.selectedRows[0];
                        [_tableView deselectRowAtIndexPath:deselectRow.indexPath animated:_autoDeselectedAnimated];
                        [self tableView:_tableView didDeselectRowAtIndexPath:deselectRow.indexPath];
                        [group.selectedRows removeObjectAtIndex:0];
                        
                        deselectCount--;
                    }
                    [group.selectedRows addObject:row];
                }
                else
                {
                    [group.selectedRows addObject:row];
                }
                *stop = YES;
            }
        }];
    }
}

- (void)_checkAndInvalidateDeselectTimers:(NSIndexPath *)indexPath
{
    NSTimer *timer = _deselectedTimers[indexPath];
    if (timer)
    {
        [timer invalidate];
        [_deselectedTimers removeObjectForKey:indexPath];
    }
}

- (void)_swapDeselectTimer:(NSIndexPath *)indexPath another:(NSIndexPath *)anotherIndexPath
{
    id temp = _deselectedTimers[indexPath];
    _deselectedTimers[indexPath] = _deselectedTimers[anotherIndexPath];
    _deselectedTimers[anotherIndexPath] = temp;
}

- (UITableViewCellAccessoryType)_getCellAccessoryForIndexPath:(NSIndexPath *)indexPath
{
    ModelCheck(UITableViewCellAccessoryNone);
    switch ([_tableModel rowAtIndexPath:indexPath].accessoryType)
    {
        case MMTableViewCellAccessoryTypeAutomatic:
        {
            return _cellAccessoryType;
        }
        case MMTableViewCellAccessoryTypeNone:
            return UITableViewCellAccessoryNone;
        case MMTableViewCellAccessoryTypeCheckmark:
            return UITableViewCellAccessoryCheckmark;
        case MMTableViewCellAccessoryTypeDetailButton:
            return UITableViewCellAccessoryDetailButton;
        case MMTableViewCellAccessoryTypeDetailDisclosureButton:
            return UITableViewCellAccessoryDetailDisclosureButton;
        case MMTableViewCellAccessoryTypeDisclosureIndicator:
            return UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (UIView *)_getCellAccessoryViewForIndexPath:(NSIndexPath *)indexPath
{
    ModelCheck(nil);
    if ([_tableModel rowAtIndexPath:indexPath].accessoryType == MMTableViewCellAccessoryTypeAutomatic)
    {
        if ([_tableModel rowAtIndexPath:indexPath].accessoryView)
        {
            return [_tableModel rowAtIndexPath:indexPath].accessoryView;
        }
        else if (_cellAccessoryViewBlock)
        {
            return _cellAccessoryViewBlock(indexPath);
        }
    }
    return nil;
}

#pragma mark - UITableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    ModelCheck(0);
    return _tableModel.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ModelCheck(0);
    return ((MMSection*)_tableModel.sections[section]).numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ModelCheck(nil);

    MMSection *section = _tableModel.sections[indexPath.section];
    MMRow *row = section.rows[indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:row.reuseIdentifier forIndexPath:indexPath];
    cell.accessoryType = [self _getCellAccessoryForIndexPath:indexPath];
    cell.accessoryView = [self _getCellAccessoryViewForIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(MMTableCell)])
    {
        if (row.seleted)
        {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        [cell performSelector:@selector(handleCellWithRow:) withObject:row];
    }
    else
    {
        NSAssert(NO, @"tableView handle with MMTableViewHandle use cell without conforms to protocol <MMTableCell>");
    }
    return cell;
}

#pragma mark editing
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ModelCheck(UITableViewCellEditingStyleNone);
    switch ([_tableModel rowAtIndexPath:indexPath].editingStyle)
    {
        case MMTableViewCellEditingStyleAutomatic:
        {
            return _cellEditingStyle;
        }
        case MMTableViewCellEditingStyleNone:
            return UITableViewCellEditingStyleNone;
        case MMTableViewCellEditingStyleDelete:
            return UITableViewCellEditingStyleDelete;
        case MMTableViewCellEditingStyleInsert:
            return UITableViewCellEditingStyleInsert;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ModelCheck();
    switch (editingStyle)
    {
        case UITableViewCellEditingStyleDelete:
        {
            MMRow *deletedRow = [_tableModel rowAtIndexPath:indexPath];
            UITableViewCell * deletedCell = [_tableView cellForRowAtIndexPath:indexPath];
            [self _checkAndInvalidateDeselectTimers:indexPath];
            [_tableModel removeRowAtIndexPath:indexPath];
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            if (_cellDidDeletedBlock)
            {
                _cellDidDeletedBlock(self, deletedRow, deletedCell, indexPath);
            }
            if ([self _checkDelegate:@selector(tableHandle:didDeleteCell:forRow:atIndexPath:)])
            {
                [self.delegate tableHandle:self didDeleteCell:deletedCell forRow:deletedRow atIndexPath:indexPath];
            }
            break;
        }
        case UITableViewCellEditingStyleInsert:
        {
            MMRow *insertRow = _cellInsertBlock?_cellInsertBlock(indexPath):nil;
            if (insertRow && [insertRow isKindOfClass:[MMRow class]])
            {
                [_tableModel insertRow:insertRow atIndexPath:indexPath];
                [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                NSAssert(NO, @"MMTableViewHandle Error: cant get valid row from cellInsertBlock when cell edting type is UITableViewCellEditingStyleInsert.");
            }
            break;
        }
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ModelCheck(NO);
    return _allowCellEditingMenu || [_tableModel rowAtIndexPath:indexPath].allowMenu;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    ModelCheck(NO);
    switch ([_tableModel rowAtIndexPath:indexPath].allowMenuActions)
    {
        case MMRowMenuTypeCopy:
            return [NSStringFromSelector(action) isEqualToString:@"copy:"];
        case MMRowMenuTypePaste:
            return [NSStringFromSelector(action) isEqualToString:@"paste:"];
        case MMRowMenuTypeBoth:
            return [NSStringFromSelector(action) isEqualToString:@"copy:"] || [NSStringFromSelector(action) isEqualToString:@"paste:"];
    }
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    ModelCheck();
    MMRow *row = [_tableModel rowAtIndexPath:indexPath];
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    if ([NSStringFromSelector(action) isEqualToString:@"copy:"] && row.rowCopyActionObject)
    {
        NSData *copyData = nil;
        if ([row.rowCopyActionObject isKindOfClass:[NSString class]])
        {
            copyData = [row.rowCopyActionObject dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if ([row.rowCopyActionObject isKindOfClass:[NSArray class]] || [row.rowCopyActionObject isKindOfClass:[NSDictionary class]])
        {
            copyData = [NSJSONSerialization dataWithJSONObject:row.rowCopyActionObject options:NSJSONWritingPrettyPrinted error:nil];
        }
        else if ([row.rowCopyActionObject isKindOfClass:[NSNumber class]])
        {
            copyData = [[NSString stringWithFormat:@"%@", row.rowCopyActionObject] dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if ([row.rowCopyActionObject isKindOfClass:[NSURL class]])
        {
            copyData = [NSData dataWithContentsOfURL:row.rowCopyActionObject];
        }
        else if ([row.rowCopyActionObject isKindOfClass:[UIImage class]])
        {
            copyData = UIImageJPEGRepresentation(row.rowCopyActionObject, 1.0);
        }
        else if ([row.rowCopyActionObject isKindOfClass:[NSData class]])
        {
            copyData = row.rowCopyActionObject;
        }
        if (copyData)
        {
            [pasteboard setData:copyData forPasteboardType:row.pasteboardUTI];
        }
    }
    else if ([NSStringFromSelector(action) isEqualToString:@"paste:"] && row.rowPasteActionBlock)
    {
        row.rowPasteActionBlock([pasteboard dataForPasteboardType:row.pasteboardUTI]);
        [self reloadTableRowsAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ModelCheck(UITableViewAutomaticDimension);
    CGFloat height = [((MMSection*)_tableModel.sections[indexPath.section]).rows[indexPath.row] heightForRow];
    if (height == MMTableDefaultHeightSign)
    {
        height = UITableViewAutomaticDimension;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    ModelCheck(UITableViewAutomaticDimension);
    CGFloat height = ((MMSection*)_tableModel.sections[section]).heightForHeader;
    if (height == MMTableDefaultHeightSign)
    {
        height = UITableViewAutomaticDimension;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    ModelCheck(UITableViewAutomaticDimension);
    CGFloat height = ((MMSection*)_tableModel.sections[section]).heightForFooter;
    if (height == MMTableDefaultHeightSign)
    {
        height = UITableViewAutomaticDimension;
    }
    return height;
}

#pragma mark header and footer
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ModelCheck(nil);
    return ((MMSection*)_tableModel.sections[section]).headerTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    ModelCheck(nil);
    return ((MMSection*)_tableModel.sections[section]).footerTitle;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ModelCheck(nil);
    return ((MMSection*)_tableModel.sections[section]).headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    ModelCheck(nil);
    return ((MMSection*)_tableModel.sections[section]).footerView;
}

#pragma mark section index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    ModelCheck(nil);
    return [[_tableModel.sections valueForKey:@"sectionIndexTitle"] arrayWithCleanNSNullValue];
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

#pragma mark selection
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_notAllowSelectedRows containsObject:[self rowWithIndexPath:indexPath]])
    {
        return nil;
    }
    else
    {
        return indexPath;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block BOOL find = NO;
    MMRow *deselectRow = [self rowWithIndexPath:indexPath];
    [_limitSelectRowsGroups enumerateObjectsUsingBlock:^(MMTableLimitSelectGroup *group, BOOL *stop) {
        if ([group.rows containsObject:deselectRow])
        {
            [group.rows enumerateObjectsUsingBlock:^(MMRow *row, BOOL *stop) {
                if (row.seleted && ![group.selectedRows containsObject:row])
                {
                    [group.selectedRows addObject:row];
                }
            }];
            
            if (group.keepingSelected && group.selectedRows.count <= group.minSelectedKeeping)
            {
                find = YES;
            }
            else
            {
                [group.selectedRows removeObject:deselectRow];
            }
            *stop = YES;
        }
    }];
    if (find)
    {
        return nil;
    }
    else
    {
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMRow *selectedRow = [_tableModel rowAtIndexPath:indexPath];
    selectedRow.seleted = YES;
    if (_cellDidSelectedBlock)
    {
        _cellDidSelectedBlock(self, [_tableModel rowAtIndexPath:indexPath], [tableView cellForRowAtIndexPath:indexPath], indexPath);
    }
    if ([self _checkDelegate:@selector(tableHandle:didSelectCell:forRow:atIndexPath:)])
    {
        [self.delegate tableHandle:self didSelectCell:[tableView cellForRowAtIndexPath:indexPath] forRow:[_tableModel rowAtIndexPath:indexPath] atIndexPath:indexPath];
    }
    [self _checkRowSelection:selectedRow];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableModel rowAtIndexPath:indexPath].seleted = NO;
    if (_cellDidDeselectedBlock)
    {
        _cellDidDeselectedBlock(self, [_tableModel rowAtIndexPath:indexPath], [tableView cellForRowAtIndexPath:indexPath], indexPath);
    }
    if ([self _checkDelegate:@selector(tableHandle:didDeselectCell:forRow:atIndexPath:)])
    {
        [self.delegate tableHandle:self didDeselectCell:[tableView cellForRowAtIndexPath:indexPath] forRow:[_tableModel rowAtIndexPath:indexPath] atIndexPath:indexPath];
    }
    [self _checkAndInvalidateDeselectTimers:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (_accessoryTappedBlock)
    {
        _accessoryTappedBlock(self, [_tableModel rowAtIndexPath:indexPath], [tableView cellForRowAtIndexPath:indexPath], indexPath);
    }
    if([self _checkDelegate:@selector(tableHandle:accessoryButtonTappedForRow:atIndexPath:)])
    {
        [self.delegate tableHandle:self accessoryButtonTappedForRow:[_tableModel rowAtIndexPath:indexPath] atIndexPath:indexPath];
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_scrollDidScrollBlock)
    {
        _scrollDidScrollBlock(self, scrollView.contentOffset);
    }
    if ([self _checkDelegate:@selector(tableHandle:scrollDidScroll:)])
    {
        [self.delegate tableHandle:self scrollDidScroll:scrollView.contentOffset];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_scrollStopScrollBlock)
    {
        _scrollStopScrollBlock(self, scrollView.contentOffset);
    }
    if ([self _checkDelegate:@selector(tableHandle:scrollDidStopScroll:)])
    {
        [self.delegate tableHandle:self scrollDidStopScroll:scrollView.contentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        if (_scrollStopScrollBlock)
        {
            _scrollStopScrollBlock(self, scrollView.contentOffset);
        }
        if ([self _checkDelegate:@selector(tableHandle:scrollDidStopScroll:)])
        {
            [self.delegate tableHandle:self scrollDidStopScroll:scrollView.contentOffset];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_scrollStopScrollBlock)
    {
        _scrollStopScrollBlock(self, scrollView.contentOffset);
    }
    if ([self _checkDelegate:@selector(tableHandle:scrollDidStopScroll:)])
    {
        [self.delegate tableHandle:self scrollDidStopScroll:scrollView.contentOffset];
    }
}

@end

