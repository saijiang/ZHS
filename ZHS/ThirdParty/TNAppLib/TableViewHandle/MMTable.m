//
//  MMTable.m
//  Mikoto
//
//  Created by xxd on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//

#import "MMTable.h"
#import "MMMacros.h"
#import "NSArray+MMExt.h"
#import <objc/runtime.h>

CGFloat const MMTableDefaultHeightSign = -100.f;

#pragma mark - MMRow (private) && MMSection (private)

@interface MMRow (private)
- (void)setRowIndexPath:(NSIndexPath*)indexPath;
@end

@implementation MMRow (private)
- (void)setRowIndexPath:(NSIndexPath*)indexPath
{
    object_setIvar(self, class_getInstanceVariable([self class], "_indexPath"), indexPath);
}
@end

@interface MMSection (private)
- (void)setSectionNumber:(NSNumber *)section;
- (void)updateRowIndexpath;
@end

@implementation MMSection (private)
- (void)setSectionNumber:(NSNumber *)section
{
    object_setIvar(self, class_getInstanceVariable([self class], "_sectionNumber"), section);
    [self updateRowIndexpath];
}

- (void)updateRowIndexpath
{
    if (self.sectionNumber)
    {
        [self.rows enumerateObjectsUsingBlock:^(MMRow *obj, NSUInteger row, BOOL *stop) {
            [obj setRowIndexPath:[NSIndexPath indexPathForRow:row inSection:self.sectionNumber.integerValue]];
        }];
    }
}
@end


#pragma mark - MMTable
@implementation MMTable
+ (instancetype)tagWithTag:(NSInteger)tag
{
    MMTable *table = [[MMTable alloc] init];
    table.tag = tag;
    table.sections = @[];
    return table;
}

+ (instancetype)table
{
    MMTable *table = [[MMTable alloc] init];
    table.tag = 0;
    table.sections = @[];
    return table;
}

+ (instancetype)tableWithTag:(NSInteger)tag sections:(NSArray *)sections
{
    MMTable* table = [MMTable tagWithTag:tag];
    table.tag = tag;
    table.sections = sections;
    return table;
}

- (NSInteger)numberOfSections
{
    return self.sections.count;
}

- (void)updateSectionIndex
{
    [_sections enumerateObjectsUsingBlock:^(MMSection *obj, NSUInteger section, BOOL *stop) {
        [obj setSectionNumber:@(section)];
    }];
}

#pragma mark sections edit
- (MMSection *)sectionAtIndex:(NSInteger)index
{
    if (MMCheckArrayNotOutofRange(index, _sections))
    {
        return [_sections objectAtIndex:index];
    }
    else
    {
        return nil;
    }
}

- (void)addSection:(MMSection *)section
{
    [section setSectionNumber:@(self.numberOfSections)];
    NSMutableArray* newData = [self.sections? self.sections: @[] mutableCopy];
    [newData addObject:section];
    self.sections = newData;
}

- (void)addSections:(NSArray *)sections
{
    [sections enumerateObjectsUsingBlock:^(MMSection *obj, NSUInteger idx, BOOL *stop) {
        [obj setSectionNumber:@(self.numberOfSections+idx)];
    }];
    NSMutableArray* newData = [self.sections? self.sections: @[] mutableCopy];
    [newData addObjectsFromArray:sections];
    self.sections = newData;
}

- (void)insertSection:(MMSection *)section atIndex:(NSInteger)index
{
    if(MMCheckUsignNumberUnder(index, self.numberOfSections+1))
    {
        NSMutableArray* newData = [self.sections? self.sections: @[] mutableCopy];
        [newData insertObject:section atIndex:index];
        self.sections = newData;
        for (NSInteger i = index; i<_sections.count; i++)
        {
            MMSection *fixSection = _sections[i];
            [fixSection setSectionNumber:@(i)];
        }
    }
}

- (void)removeSection:(MMSection *)section
{
    NSMutableArray* newData = [self.sections? self.sections: @[] mutableCopy];
    [newData removeObject:section];
    self.sections = newData;
    for (NSInteger i = section.sectionNumber.integerValue; i<_sections.count; i++)
    {
        MMSection *fixSection = _sections[i];
        [fixSection setSectionNumber:@(i)];
    }
}

- (void)removeSections:(NSSet *)sections
{
    NSMutableArray* newData = [self.sections? self.sections: @[] mutableCopy];
    [sections enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [newData removeObject:obj];
    }];
    self.sections = newData;
    [self updateSectionIndex];
}

- (void)removeSectionAtIndex:(NSInteger)index
{
    NSMutableArray* newData = [self.sections? self.sections: @[] mutableCopy];
    [newData removeObjectAtIndex:index];
    self.sections = newData;
    for (NSInteger i = index; i<_sections.count; i++)
    {
        MMSection *fixSection = _sections[i];
        [fixSection setSectionNumber:@(i)];
    }
}

- (void)removeSectionsWithIndexSet:(NSIndexSet *)indexes
{
    NSMutableArray* newData = [self.sections? self.sections: @[] mutableCopy];
    [newData removeObjectsAtIndexes:indexes];
    self.sections = newData;
    [self updateSectionIndex];
}

#pragma mark row edit
- (MMRow *)rowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self containsIndexPath:indexPath])
    {
        return ((MMSection *)_sections[indexPath.section]).rows[indexPath.row];
    }
    else
    {
        return nil;
    }
}

- (void)insertRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath
{
    if (MMCheckArrayNotOutofRange(indexPath.section, _sections) && MMCheckUsignNumberUnder(indexPath.row, [_sections[indexPath.section] numberOfRows]+1))    {
        [(MMSection *)_sections[indexPath.section] insertRow:row atIndex:indexPath.row];
    }
    else if (indexPath.section == self.numberOfSections && indexPath.row == 0)
    {
        MMSection *section = [MMSection sectionWithTag:0 rows:@[row]];
        [self addSection:section];
    }
}

- (void)removeRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (MMCheckArrayNotOutofRange(indexPath.section, _sections) && MMCheckUsignNumberUnder(indexPath.row, [_sections[indexPath.section] numberOfRows]))
    {
        [(MMSection *)_sections[indexPath.section] removeRowWithIndexSet:[NSIndexSet indexSetWithIndex:indexPath.row]];
    }
}

- (void)removeRowsWithIndexPaths:(NSSet *)indexPaths
{
    NSMutableDictionary *indexs = [@{} mutableCopy];
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
        if (MMCheckArrayNotOutofRange(indexPath.section, _sections) && MMCheckUsignNumberUnder(indexPath.row, [_sections[indexPath.section] numberOfRows]))
        {
            NSMutableIndexSet *indexSet = indexs[@(indexPath.section)];
            if (indexSet)
            {
                [indexSet addIndex:indexPath.row];
            }
            else
            {
                indexSet = [NSMutableIndexSet indexSetWithIndex:indexPath.row];
                [indexs setObject:indexSet forKey:@(indexPath.section)];
            }
        }
    }];
    
    [indexs enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSIndexSet *indexSet, BOOL *stop) {
        [(MMSection *)_sections[key.integerValue] removeRowWithIndexSet:indexSet];
    }];
}

- (void)removeRow:(MMRow *)row
{
    if ([self containsRow:row])
    {
        [_sections enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(MMSection *obj, NSUInteger idx, BOOL *stop) {
            if ([obj containsRow:row])
            {
                [obj removeRow:row];
                *stop = YES;
            }
        }];
    }
}

- (void)removeRows:(NSSet *)rows
{
    [rows enumerateObjectsUsingBlock:^(MMRow *obj, BOOL *stop) {
       [self removeRow:obj];
    }];
}

#pragma mark contains check
- (BOOL)containsSection:(MMSection *)section
{
    return [_sections containsObject:section];
}

- (BOOL)containsRow:(MMRow *)row
{
    __block BOOL containt = NO;
    [_sections enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(MMSection *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.rows containsObject:row])
        {
            containt = YES;
            *stop = YES;
        }
    }];
    return containt;
}

- (BOOL)containsIndexPath:(NSIndexPath *)indexPath
{
    __block BOOL containt = MMCheckArrayNotOutofRange(indexPath.section, _sections);
    if (containt)
    {
        containt = MMCheckArrayNotOutofRange(indexPath.row, [_sections[indexPath.section] rows]);
    }
    return containt;
}

@end

#pragma mark - MMSection
@implementation MMSection

+ (instancetype)tagWithTag:(NSInteger)tag
{
    MMSection* section = [[MMSection alloc] init];
    section.tag = tag;
    section.rows = @[];
    section.heightForHeader = MMTableDefaultHeightSign;
    section.heightForFooter = MMTableDefaultHeightSign;
    return section;
}

+ (instancetype)section
{
    MMSection* section = [[MMSection alloc] init];
    section.tag = 0;
    section.rows = @[];
    section.heightForHeader = MMTableDefaultHeightSign;
    section.heightForFooter = MMTableDefaultHeightSign;
    return section;
}

+ (instancetype)sectionWithTag:(NSInteger)tag rows:(NSArray *)rows
{
    MMSection* section = [MMSection tagWithTag:tag];
    section.rows = rows;
    return section;
}

- (NSInteger)numberOfRows
{
    return self.rows.count;
}

#pragma mark - row edit
- (MMRow *)rowAtIndex:(NSInteger)index
{
    if (MMCheckArrayNotOutofRange(index, _rows))
    {
        return [_rows objectAtIndex:index];
    }
    else
    {
        return nil;
    }
}

- (void)addRow:(MMRow *)row
{
    if (self.sectionNumber)
    {
        [row setRowIndexPath:[NSIndexPath indexPathForRow:self.numberOfRows inSection:self.sectionNumber.integerValue]];
    }
    NSMutableArray* newData = [self.rows? self.rows: @[] mutableCopy];
    [newData addObject:row];
    self.rows = newData;
}

- (void)addRows:(NSArray *)rows
{
    if (self.sectionNumber)
    {
        [rows enumerateObjectsUsingBlock:^(MMRow *obj, NSUInteger idx, BOOL *stop) {
            [obj setRowIndexPath:[NSIndexPath indexPathForRow:self.numberOfRows+idx inSection:self.sectionNumber.integerValue]];
        }];
    }
    NSMutableArray* newData = [self.rows? self.rows: @[] mutableCopy];
    [newData addObjectsFromArray:rows];
    self.rows = newData;
}

- (void)insertRow:(MMRow *)row atIndex:(NSInteger)index
{
    if(MMCheckUsignNumberUnder(index, self.numberOfRows+1))
    {
        NSMutableArray* newData = [self.rows? self.rows: @[] mutableCopy];
        [newData insertObject:row atIndex:index];
        self.rows = newData;
        if (self.sectionNumber)
        {
            for (NSInteger i = index; i<_rows.count; i++)
            {
                MMRow *row = _rows[i];
                [row setRowIndexPath:[NSIndexPath indexPathForRow:i inSection:self.sectionNumber.integerValue]];
            }
        }
    }
}

- (void)removeRow:(MMRow *)row
{
    NSMutableArray* newData = [self.rows? self.rows: @[] mutableCopy];
    [newData removeObject:row];
    self.rows = newData;
    
    if (self.sectionNumber)
    {
        for (NSInteger i = row.indexPath.row; i<_rows.count; i++)
        {
            MMRow *fixRow = _rows[i];
            [fixRow setRowIndexPath:[NSIndexPath indexPathForRow:i inSection:self.sectionNumber.integerValue]];
        }
    }
}

- (void)removeRows:(NSSet *)rows
{
    NSMutableArray* newData = [self.rows? self.rows: @[] mutableCopy];
    [rows enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [newData removeObject:obj];
    }];
    self.rows = newData;
    [self updateRowIndexpath];
}

- (void)removeRowAtIndex:(NSInteger)index
{
    NSMutableArray* newData = [self.rows? self.rows: @[] mutableCopy];
    [newData removeObjectAtIndex:index];
    self.rows = newData;
    if (self.sectionNumber)
    {
        for (NSInteger i = index; i<_rows.count; i++)
        {
            MMRow *row = _rows[i];
            [row setRowIndexPath:[NSIndexPath indexPathForRow:i inSection:self.sectionNumber.integerValue]];
        }
    }
}

- (void)removeRowWithIndexSet:(NSIndexSet *)indexes
{
    NSMutableArray* newData = [self.rows? self.rows: @[] mutableCopy];
    [newData removeObjectsAtIndexes:indexes];
    self.rows = newData;
    [self updateRowIndexpath];
}

- (BOOL)containsRow:(MMRow *)row
{
    return [_rows containsObject:row];
}

@end

#pragma mark - MMRow
@implementation MMRow
+ (instancetype)tagWithTag:(NSInteger)tag
{
    MMRow* row = [[MMRow alloc] init];
    row.tag = tag;
    row.editingStyle = MMTableViewCellAccessoryTypeAutomatic;
    row.accessoryType = MMTableViewCellAccessoryTypeAutomatic;
    row.allowMenu = NO;
    row.pasteboardUTI = @"com.m_mikoto.default";
    return row;
}

+ (instancetype)rowWithTag:(NSInteger)tag rowInfo:(MMBaseModel *)data reuseIdentifier:(NSString *)identifier
{
    return [self rowWithTag:tag rowInfo:data rowActions:nil reuseIdentifier:identifier];
}

+ (instancetype)rowWithTag:(NSInteger)tag rowInfo:(id)data rowActions:(id)actions reuseIdentifier:(NSString *)identifier
{
    return [self rowWithTag:tag rowInfo:data rowActions:actions height:MMTableDefaultHeightSign reuseIdentifier:identifier];
}

+ (instancetype)rowWithTag:(NSInteger)tag rowInfo:(MMBaseModel *)data height:(CGFloat)height reuseIdentifier:(NSString *)identifier
{
    return [self rowWithTag:tag rowInfo:data rowActions:nil height:height reuseIdentifier:identifier];
}

+ (instancetype)rowWithTag:(NSInteger)tag rowInfo:(id)data rowActions:(id)actions height:(CGFloat)height reuseIdentifier:(NSString *)identifier
{
    MMRow* row = [self tagWithTag:tag];
    row.rowInfo = data;
    row.rowActions = actions;
    row.heightForRow = height;
    row.reuseIdentifier = identifier;
    return row;
}

+ (NSMutableArray *)rowsWithTag:(NSInteger)tag rowsInfo:(NSArray *)datas height:(CGFloat)height reuseIdentifier:(NSString *)identifier
{
    NSMutableArray* rows = [@[] mutableCopy];
    for (id data in datas)
    {
        [rows addObject:[self rowWithTag:tag rowInfo:data height:height reuseIdentifier:identifier]];
    }
    return rows;
}

@end

#pragma mark - MMTableRowGroup

@implementation MMTableRowGroup

+ (instancetype)groupOfRows:(NSSet *)rows
{
    MMTableRowGroup *group = [[self alloc] init];
    group.rows = rows;
    return group;
}

- (void)enumerateRowsUsingBlock:(void (^)(MMRow *, BOOL *))block
{
    [_rows enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if (block)
        {
            block(obj, stop);
        }
    }];
}

- (void)enumerateRowsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(MMRow *, BOOL *))block
{
    [_rows enumerateObjectsWithOptions:opts usingBlock:^(id obj, BOOL *stop) {
        if (block)
        {
            block(obj, stop);
        }
    }];
}

@end

@interface MMTableLimitSelectGroup ()
{
    NSMutableArray *_selectedRows;
}
@end

static char mmtableLimitSelectGroupLimitNumber;

@implementation MMTableLimitSelectGroup

+ (instancetype)groupOfRows:(NSSet *)rows withNumberAllowSelect:(NSUInteger)limit;
{
    MMTableLimitSelectGroup *group = [self groupOfRows:rows];
    objc_setAssociatedObject(group, &mmtableLimitSelectGroupLimitNumber, @(limit), OBJC_ASSOCIATION_ASSIGN);
    return group;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _keepingSelected = NO;
        _minSelectedKeeping = 1;
        _selectedRows = [@[] mutableCopy];
        objc_setAssociatedObject(self, &mmtableLimitSelectGroupLimitNumber, @1, OBJC_ASSOCIATION_ASSIGN);
    }
    return self;
}

#pragma mark setter & getter

- (void)setSelectedRows:(NSMutableArray *)selectedRows
{
    _selectedRows = selectedRows;
}

- (NSMutableArray *)selectedRows
{
    return _selectedRows;
}

- (NSUInteger)allowSelectLimit
{
    return [objc_getAssociatedObject(self, &mmtableLimitSelectGroupLimitNumber) unsignedIntegerValue];
}



@end