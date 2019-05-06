//
//  ZHSMyInfoViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/2/19.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSMyInfoViewController.h"
#import "ZHSMyInfoXingQuViewController.h"
#import "TNUser.h"
#import "UIImageView+WebCache.h"
#import "ZHSFindYourTeacherViewController.h"
#import "ZHSMoreViewController.h"


@interface ZHSMyInfoViewController ()
{
    NSNumber *_imageID;
    UIImage *_image;
}
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *xingquaihaoL;
@property (weak, nonatomic) IBOutlet UILabel *youeryuanL;

@property (weak, nonatomic) IBOutlet UITextField *userNameL;
@property (weak, nonatomic) IBOutlet UITextField *baobaoname;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *baobaoAge;
@property (weak, nonatomic) IBOutlet UILabel *baobaoSex;








@property (strong, nonatomic) IBOutlet UIView *datePickerContantView;
@property (weak, nonatomic)   IBOutlet UIButton *cancel;
@property (weak, nonatomic)  IBOutlet UIButton *Yes;
@property (weak, nonatomic) IBOutlet UIDatePicker *datepiker;

@end

@implementation ZHSMyInfoViewController
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NSArray *xingqu = [TNAppContext currentContext].user.interests;
    NSMutableString *strL = [@"" mutableCopy];
    [xingqu enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [strL appendString:[NSString stringWithFormat:@"%@  ",obj[@"name"]]];
    }];
    self.xingquaihaoL.text = strL ;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"个人信息";
    self.userImage.layer.cornerRadius = 30;
    self.userImage.layer.masksToBounds = YES;
    [self createRightBarItemWithTitle:@"完成"];
    TNUser *user = [TNAppContext currentContext].user;
    self.youeryuanL.text =[NSString stringWithFormat:@"%@%@",user.school_info[@"name"],user.school_class_info[@"name"]];
    self.userNameL.text = user.name;
    self.baobaoname.text = user.baby[@"name"];
    self.baobaoAge.text = [NSString stringWithFormat:@"%@", user.baby[@"birthday"]];
    if ([user.baby[@"gender"]  isEqual: @"female"]) {
        self.baobaoSex.text =@"小公主";
    }
    if ([user.baby[@"gender"]  isEqual: @"male"]) {
        self.baobaoSex.text =@"小王子";
    }
    [self.userImage sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@",kUrl,user.avatar[@"small"]]] placeholderImage:[UIImage imageNamed:@"chengzhang"]];

    self.datePickerContantView.frame = CGRectMake(0, kHight, kWidth, 240);
    [self.view addSubview:self.datePickerContantView];
}
- (IBAction)xingquClick:(id)sender {
    ZHSMyInfoXingQuViewController *vc = [ZHSMyInfoXingQuViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark ===== postImage
-(void)postImageWithImage:(UIImage *)image{
    NSString *path = [NSString stringWithFormat:@"%@/customer/update",kHeaderURL];
    [[THRequstManager sharedManager] asynPOST:path parameters:@{@"file":image} withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            _imageID = responseObject[@"data"][@"id"] ;
            self.userImage.image = image;
        }else{
            [TNToast showWithText:@"图片上传失败，请重新上传"];
        }
    }];

}
#pragma mark ===== 点击上传图片

- (IBAction)tapImage:(id)sender {
    [self reclaimedKeyboard];
    __weak typeof(self)tempSelf = self;
    TNBlockActionSheet* mySheet = [[TNBlockActionSheet alloc]initWithTitle:@"上传用户图像" delegate:nil cancelButtonTitle:@"取消"destructiveButtonTitle:@"拍摄" otherButtonTitles:@"从相册选取", nil];
    [mySheet setBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        [TNFlowUtil startPhotoPickerWithPresentingViewController:tempSelf defaultToFrontCamera:NO animated:YES completion:^(UIImagePickerController *picker, BOOL isCancel, UIImage *image) {
            if (isCancel) {
                [self dismissViewControllerAnimated:YES completion:nil];
                return ;
            }
            [tempSelf postImageWithImage:image];
//            _image = image;
//            _userImage.image = image;
            [tempSelf dismissViewControllerAnimated:YES completion:nil];
        }];
    } atButtonIndex:0];
    [mySheet setBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        [TNFlowUtil startAlbumPickerWithPresentingViewController:tempSelf animated:YES completion:^(UIImagePickerController *picker, BOOL isCancel, UIImage *image) {
            if (isCancel) {
                [self dismissViewControllerAnimated:YES completion:nil];
                return ;
            }
            [tempSelf postImageWithImage:image];
//            _image = image;
//            _userImage.image = image;

            [tempSelf dismissViewControllerAnimated:YES completion:nil];
        }];
    } atButtonIndex:1];
    [mySheet showInView:self.view.window];

}
- (IBAction)tapSex:(id)sender {
    [self reclaimedKeyboard];
    __weak typeof(self)tempSelf = self;

    TNBlockActionSheet* mySheet = [[TNBlockActionSheet alloc]initWithTitle:@"选择宝宝性别" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"小公主" otherButtonTitles:@"小王子", nil];
    [mySheet setBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        tempSelf.baobaoSex.text = @"小公主";
    } atButtonIndex:0];
    [mySheet setBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        tempSelf.baobaoSex.text = @"小王子";
        
    } atButtonIndex:1];
    [mySheet showInView:self.view.window];
}
#pragma mark ======选择宝宝出生时间
- (IBAction)cancle:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.datePickerContantView.frame = CGRectMake(0, kHight, kWidth, 240);
    }];
}
- (IBAction)xuanzeshijain:(id)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.datePickerContantView.frame = CGRectMake(0, kHight-240, kWidth, 240);
        self.datePickerContantView.hidden = NO;
    }];
}
- (IBAction)yes:(UIButton *)sender{
    NSDate *date = self.datepiker.date;
    DLog(@"time is %@",date);
    DLog(@"time is %f",date.timeIntervalSince1970);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat : @"YYYY-MM-dd"];
    NSString *dateString = [formatter stringFromDate:date];
    self.baobaoAge.text = [NSString stringWithFormat:@"%@",dateString];
    
    [self cancle:nil];
}
-(void)clickRightSender:(UIButton *)sender{
    __weak typeof(self)tempSelf = self;
    NSMutableDictionary *prams = [@{} mutableCopy];
    NSMutableDictionary *prams1 = [@{} mutableCopy];
    
    if (self.userNameL.text.length) {
        [prams setValue:self.userNameL.text forKey:@"name"];
    }
    if (self.baobaoname.text.length) {
        [prams1 setObject:self.baobaoname.text forKey:@"name"];
    }
    if (self.baobaoAge.text.length) {
        [prams1 setObject:self.baobaoAge.text forKey:@"birthday"];
    }
    if (self.baobaoSex.text.length) {
        if ([self.baobaoSex.text isEqualToString:@"小王子"]) {
            [prams1 setObject:@"male" forKey:@"gender"];
        }
        if ([self.baobaoSex.text isEqualToString:@"小公主"]) {
            [prams1 setObject:@"female" forKey:@"gender"];
        }
    }
    if (_imageID.integerValue) {
        [prams setObject:@{@"id":_imageID }forKey:@"avatar"];
    }
//    if (_image) {
//        [prams setObject:_image forKey:@"file"];
//    }
    [prams setObject:prams1 forKey:@"baby"];
    /*
     @{
     @"baby": @{@"name":tempSelf.name.text,@"age":@(tempSelf.age.text.integerValue),@"gender":sex?@"female":@"male"},
     @"school_class_id":_school_class_id
     */
    [[THRequstManager sharedManager] asynPOST:[NSString stringWithFormat:@"%@/customer/update",kHeaderURL] parameters:prams withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code==1) {
            TNUser *user = [TNUser modelWithJsonDicWithoutMap:responseObject[@"data"]];
            user.interests = responseObject[@"data"][@"interests"];
            user.token = [TNAppContext currentContext].user.token;
            user.ID = [TNAppContext currentContext].user.ID;
            [TNAppContext currentContext].user = user;
            [[TNAppContext currentContext] saveUser];
            [tempSelf back];
        }
    }];

}

- (IBAction)tapYoueryuan:(id)sender {
    ZHSFindYourTeacherViewController *vc = [ZHSFindYourTeacherViewController new];
    vc.isCanBack = YES;
    [self.navigationController pushViewController:vc animated:YES];

}
- (IBAction)setting:(id)sender {
    [self.navigationController pushViewController:[ZHSMoreViewController new] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)reclaimedKeyboard{
    [self.view endEditing:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
