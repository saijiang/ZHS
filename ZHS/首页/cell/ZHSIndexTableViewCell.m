//
//  ZHSIndexTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/16.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSIndexTableViewCell.h"
#import "ZHSBooks.h"
#import "ZHSSchoolbag.h"
#import "UIImageView+WebCache.h"
@interface ZHSIndexTableViewCell ()<MMTableCell>
{
    NSMutableArray *_actions;
    NSMutableDictionary *_rowinfo;
}

@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UILabel *jianToulable;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *BGView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *textLables;

@end
@implementation ZHSIndexTableViewCell

- (void)awakeFromNib {
 
    [self.BGView enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = obj;
        view.layer.borderColor = [[TNAppContext currentContext] getColor:@"#ececec"].CGColor;
        view.layer.borderWidth = 1;
        UIImageView *image = view.subviews[0];
        image.layer.borderWidth = 1;
        image.layer.borderColor = [[TNAppContext currentContext] getColor:@"#e3e2e2"].CGColor;
        
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [view addGestureRecognizer:gr];
    }];
}
-(void)handleCellWithRow:(MMRow *)row{
    _actions = row.rowActions;
    _rowinfo = row.rowInfo;
    self.rightView.frame = CGRectMake(kWidth, 0, 35, self.rightView.frame.size.height-1);
    [UIView animateWithDuration:1 animations:^{
        self.rightView.frame = CGRectMake(kWidth-35, 0, 35, self.rightView.frame.size.height-1);
    }];
    
    self.jianToulable.text = row.rowInfo[@"name"];


    [row.rowInfo[@"packages"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        /*
         ZHSSchoolbag *schoolbag = obj;
         ZHSBooks *book = schoolbag.books_list[idx];
         NSString*imageString = [NSString stringWithFormat:@"http://admin.cctvzhs.com%@",book.images[0][@"small"]];
         */
        UIView *bgView = _BGView[idx];
        UIImageView*image = bgView.subviews[0];
        [image sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@",kUrl, obj[@"image_url"] ]] placeholderImage:[UIImage imageNamed:@"ZHS_Def"]];
        ((UILabel *)_textLables[idx]).text = obj[@"name"];
    }];



}
- (void)tap:(UITapGestureRecognizer*)sender {
    NSInteger number =sender.view.tag;
    [self requestSchoolbagWithNumber:number];
}
-(void)requestSchoolbagWithNumber:(NSInteger)number
{
    NSString *path = [NSString stringWithFormat:@"%@/package/%@",kHeaderURL,_rowinfo[@"packages"][number-1][@"id"]];
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            ZHSSchoolbag *schoolbag = [ZHSSchoolbag modelWithJsonDicUseSelfMap:responseObject[@"data"]];
            NSArray *books = responseObject[@"data"][@"books_list"];
            NSMutableArray *booklist = [@[] mutableCopy];
            for (NSDictionary*dic in books) {
                ZHSBooks*book = [ZHSBooks modelWithJsonDicWithoutMap:dic];
                [booklist addObject:book];
            }
            schoolbag.books_list = booklist;
            
            void(^block)(ZHSSchoolbag*) = _actions[0];
            if (block) {
                block(schoolbag);
            }
        }
    }];
    
 
}
- (IBAction)huanyihuan:(id)sender {
    void(^block)() = _actions[1];
    if (block) {
        block();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
