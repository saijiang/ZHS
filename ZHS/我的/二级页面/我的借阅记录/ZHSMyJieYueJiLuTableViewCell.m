//
//  ZHSMyJieYueJiLuTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/17.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSMyJieYueJiLuTableViewCell.h"
#import "ZHSBorrowLog.h"
#import "ZHSBooks.h"
#import "UIImageView+WebCache.h"
@interface ZHSMyJieYueJiLuTableViewCell()<MMTableCell>
@property (weak, nonatomic) IBOutlet UIImageView *schoolbagImage;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *borrow_start;
@property (weak, nonatomic) IBOutlet UILabel *borrow_end;
@property (weak, nonatomic) IBOutlet UILabel *booksName;

@end
@implementation ZHSMyJieYueJiLuTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.schoolbagImage.layer.borderColor = [[TNAppContext currentContext] getColor:@"#e3e2e2"].CGColor;
    self.schoolbagImage.layer.borderWidth = 2;
}
-(void)handleCellWithRow:(MMRow *)row{
    ZHSBorrowLog *log = row.rowInfo;
    self.name.text = log.schoolbag.title;

    if ([log.status isEqualToString:@"pre-borrow"]) {
        self.statusImage.image = [UIImage imageNamed:@"yiyujie"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate*date= [formatter dateFromString:(NSString*)log.created_at];
        NSDate *date1 = [NSDate dateWithTimeInterval:2*24*60*60 sinceDate:date];
        self.borrow_start.text = [NSString stringWithFormat:@"预借时间：%@", [(NSString*)log.created_at  substringToIndex:10]];
        self.borrow_end.text = [NSString stringWithFormat:@"预借截止：%@", [date1.description substringToIndex:10]];

    }
    if ([log.status isEqualToString:@"finished"]) {
        if (log.return_at) {
            self.statusImage.image = [UIImage imageNamed:@"yiguihuan"];
            self.borrow_start.text = [NSString stringWithFormat:@"借阅时间：%@", [(NSString*)log.borrow_start substringToIndex:10]];
            self.borrow_end.text = [NSString stringWithFormat:@"归还时间：%@", [(NSString*)log.return_at substringToIndex:10]];

        }else{
            self.statusImage.image = [UIImage imageNamed:@"quxiaoyujie"];
            self.borrow_start.text = [NSString stringWithFormat:@"预借时间：%@", [(NSString*)log.created_at substringToIndex:10]];
            self.borrow_end.text = [NSString stringWithFormat:@"取消时间：%@", [(NSString*)log.updated_at substringToIndex:10]];

        }
    }
    if ([log.status isEqualToString:@"borrowed"]) {
        self.statusImage.image = [UIImage imageNamed:@"jieyuezhong"];
        self.borrow_start.text = [NSString stringWithFormat:@"借阅时间：%@", [(NSString*)log.borrow_start substringToIndex:10]];
        self.borrow_end.text = [NSString stringWithFormat:@"借阅截止：%@", [(NSString*)log.borrow_end substringToIndex:10]];

    }
    if ([log.status isEqualToString:@"overdue"]) {
        self.statusImage.image = [UIImage imageNamed:@"yuqiweihuan"];
        self.borrow_start.text = [NSString stringWithFormat:@"借阅时间：%@", [(NSString*)log.borrow_start substringToIndex:10]];
        self.borrow_end.text = [NSString stringWithFormat:@"借阅截止：%@", [(NSString*)log.borrow_end substringToIndex:10]];
        self.borrow_end.textColor = [UIColor redColor];

    }
    /* 遍历拼接书目的名字 */
    __block NSMutableString *shumuStr  = [@"" mutableCopy];
    [log.schoolbag.books_list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZHSBooks *book = obj;
        if (idx == log.schoolbag.books_list.count-1) {
            [shumuStr appendFormat:@"%@",book.title];
        }else
            [shumuStr appendFormat:@"%@、",book.title];
    }];
    self.booksName.text = [NSString stringWithFormat:@"包含绘本：%@",shumuStr];
    ZHSBooks *book = log.schoolbag.books_list[0];
    NSString*imageString = [NSString stringWithFormat:@"http://admin.cctvzhs.com%@",book.images[0][@"small"]];
    [_schoolbagImage sd_setImageWithURL:[NSURL URLWithString:imageString]placeholderImage:[UIImage imageNamed:@"ZHS_Def"]];


}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
