//
//  TNH5ViewController.m
//  Tuhu
//
//  Created by Tuhu on 15/1/26.
//  Copyright (c) 2015年 telenav. All rights reserved.
//

#import "TNH5ViewController.h"
#import "UMSocialSnsService.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocial.h"
#import "UIImage+WebP.h"

@interface TNH5ViewController () <UIWebViewDelegate,UMSocialUIDelegate>
{
    NSString *_bodyStr;
}
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation TNH5ViewController
- (UIStatusBarStyle)preferredStatusBarStyle{return UIStatusBarStyleLightContent;}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLeftBarItemWithImage];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationItem.title = self.titleString;
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
//    self.navigationItem.leftBarButtonItem = backButton;
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [self.webView loadRequest:request];
    if (self.isShare) {
        [self createRightBarItemWithImage:@"common_share"];
    }
}
-(void)clickRightSender:(UIButton *)sender{
//    [UMSocialData defaultData].title =self.titleString ;
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:self.imageShareString];


    [UMSocialData defaultData].extConfig.wechatSessionData.url = self.urlString;
    [UMSocialData defaultData].extConfig.wechatSessionData.title = self.titleString;

    [UMSocialData defaultData].extConfig.wechatTimelineData.url = self.urlString;
    [UMSocialData defaultData].extConfig.qqData.url = self.urlString;
    [UMSocialData defaultData].extConfig.qqData.title = self.titleString;;

    [UMSocialData defaultData].extConfig.qzoneData.url = self.urlString;
    [UMSocialData defaultData].extConfig.qzoneData.title = self.titleString;
    [UMSocialSnsService presentSnsIconSheetView:self appKey:kUMAppkey shareText:[_bodyStr substringToIndex:100] shareImage:nil shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQzone,UMShareToQQ,UMShareToSina,nil] delegate:self];
}
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    //创建UIActivityIndicatorView背底半透明View
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    [view setTag:108];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.3];
    [self.view addSubview:view];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [self.activityIndicator setCenter:view.center];
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [view addSubview:self.activityIndicator];
    [TNToast showLoadingToast];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [TNToast hideLoadingToast];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
    self.titleString = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navigationItem.title = self.titleString;
    _bodyStr = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];

    DLog(@"======webViewDidFinishLoad");
    
}
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
}

- (IBAction)letUsGo:(UIButton *)sender {
}

- (void)back
{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else{
    [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
