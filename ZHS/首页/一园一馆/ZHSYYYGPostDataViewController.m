//
//  ZHSYYYGPostDataViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/2/2.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSYYYGPostDataViewController.h"

@interface ZHSYYYGPostDataViewController ()<UITextFieldDelegate>
{
    NSMutableArray *_imagesID;
}
@property (weak, nonatomic) IBOutlet UITextField *youeryuanCounts;
@property (weak, nonatomic) IBOutlet UITextField *youeryuanAddress;
@property (weak, nonatomic) IBOutlet UITextField *farenName;
@property (weak, nonatomic) IBOutlet UITextField *youeryuanName;
@property (weak, nonatomic) IBOutlet UITextField *farenPhone;
@property (weak, nonatomic) IBOutlet UIImageView *imageOfYingyeZhiZhao;

@property (strong, nonatomic) IBOutlet UIView *jiazhangView;

// 家长推荐

@property (weak, nonatomic) IBOutlet UITextField *JZYouErYuanName;
@property (weak, nonatomic) IBOutlet UITextField *JZYouErYuanAddress;
@property (weak, nonatomic) IBOutlet UITextField *baobaoName;

@property (weak, nonatomic) IBOutlet UITextField *baobaobanji;
@property (weak, nonatomic) IBOutlet UITextField *JZName;

@end

@implementation ZHSYYYGPostDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _imagesID = [@[@""] mutableCopy];
    self.navigationItem.title = self.isFrom;
    [self createLeftBarItemWithImage];
    if ([self.isFrom isEqualToString:@"家长推荐"]) {
        self.jiazhangView.frame = self.view.bounds;
        [self.view addSubview:self.jiazhangView];
    }
}
-(void)reclaimedKeyboard{
    [self.view endEditing:YES];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *s = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.farenPhone) {
        if (s.length == 11) {
            __weak typeof(self) tempSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [tempSelf reclaimedKeyboard];
            });
        }
        if (s.length > 11) {
            return NO;
        }
    }
    return YES;
}
-(void)postImageWith:(UIImage*)image view:(UIImageView*)view
{
    NSString *path = [NSString stringWithFormat:@"%@/photo-upload",kHeaderURL];
    [[THRequstManager sharedManager] asynPOST:path parameters:@{@"file":image} withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            if (view == _imageOfYingyeZhiZhao) {
                [_imagesID replaceObjectAtIndex:0 withObject:responseObject[@"data"][@"id"]] ;
            }
            
            view.image = image;
        }else{
            [TNToast showWithText:@"图片上传失败，请重新上传"];
        }
    }];
}
- (IBAction)postImage:(id)sender {
    __weak typeof(self)tempSelf = self;
    TNBlockActionSheet* mySheet = [[TNBlockActionSheet alloc]initWithTitle:@"上传相片" delegate:nil cancelButtonTitle:@"取消"destructiveButtonTitle:@"拍摄" otherButtonTitles:@"从相册选取", nil];
    [mySheet setBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        [TNFlowUtil startPhotoPickerWithPresentingViewController:tempSelf defaultToFrontCamera:NO animated:YES completion:^(UIImagePickerController *picker, BOOL isCancel, UIImage *image) {
            if (isCancel) {
                [self dismissViewControllerAnimated:YES completion:nil];
                return ;
            }
            [tempSelf postImageWith:image view:tempSelf.imageOfYingyeZhiZhao];
            [tempSelf dismissViewControllerAnimated:YES completion:nil];
        }];
    } atButtonIndex:0];
    [mySheet setBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        [TNFlowUtil startAlbumPickerWithPresentingViewController:tempSelf animated:YES completion:^(UIImagePickerController *picker, BOOL isCancel, UIImage *image) {
            if (isCancel) {
                [self dismissViewControllerAnimated:YES completion:nil];
                return ;
            }
            [tempSelf postImageWith:image view:tempSelf.imageOfYingyeZhiZhao];
            [tempSelf dismissViewControllerAnimated:YES completion:nil];
        }];
    } atButtonIndex:1];
    [mySheet showInView:self.view.window];
}
- (IBAction)tijiaoClick:(id)sender {
    if (self.youeryuanName.text.length && self.youeryuanAddress.text.length&&self.youeryuanCounts.text.length&&self.farenName.text.length&&self.farenPhone.text.length) {
        NSString *path = [NSString stringWithFormat:@"%@/yyyg/apply",kHeaderURL];
        NSMutableDictionary *parms = [@{} mutableCopy];
        [parms setObject:self.youeryuanName.text forKey:@"name"];
        [parms setObject:self.youeryuanAddress.text forKey:@"address"];
        
        [parms setObject:self.youeryuanCounts.text forKey:@"qty_of_children"];
        
        [parms setObject:self.farenName.text forKey:@"name_of_leader"];
        [parms setObject:self.farenPhone.text forKey:@"telephone"];
        
        [parms setObject:_imagesID forKey:@"files"];
        
        __weak typeof(self)tempself = self;
        [[THRequstManager sharedManager] asynPOST:path parameters:parms withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
            if (code == 1) {
                [TNToast showWithText:responseObject[@"message" ]];
                [tempself back];
            }
        }];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)JZTiaojiao:(id)sender {
        if (self.JZYouErYuanName.text.length && self.JZYouErYuanAddress.text.length&&self.baobaobanji.text.length&&self.baobaoName.text.length&&self.JZName.text.length) {
            NSString *path = [NSString stringWithFormat:@"%@/yyyg/apply",kHeaderURL];
            NSMutableDictionary *parms = [@{} mutableCopy];
            [parms setObject:self.JZYouErYuanName.text forKey:@"name"];
            [parms setObject:self.JZYouErYuanAddress.text forKey:@"address"];
            
            [parms setObject:self.baobaobanji.text forKey:@"name_of_class"];
            
            [parms setObject:self.JZName.text forKey:@"name_of_parent"];
            [parms setObject:self.baobaoName.text forKey:@"name_of_baby"];
            
            
            __weak typeof(self)tempself = self;
            [[THRequstManager sharedManager] asynPOST:path parameters:parms withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
                if (code == 1) {
                    [TNToast showWithText:responseObject[@"message" ]];
                    [tempself back];
                }
            }];

        }
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
