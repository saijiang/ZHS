//
//  TNUtils.m
//  Tuhu
//
//  Created by 邢小迪 on 15/5/4.
//  Copyright (c) 2015年 telenav. All rights reserved.
//

#import "TNUtils.h"
#import "SCGIFImageView.h"
#import "TNSegueTarget.h"
#import "TNFlowUtil.h"


@implementation TNUtils
+ (void)customSegueToTarget:(TNSegueTarget *)target inNavigation:(UINavigationController *)navigation
{
    if (!target || !navigation) return;
    Class targetClass = NSClassFromString(target.targetName); // 获取跳转目标类
    if (!targetClass) return;
    id targetVC = [[targetClass alloc] init]; // 初始化目标控制器对象
    if (targetVC)
    {
        // 特殊条件判断
        
        // 保养和轮胎 需求默认车型
//        if ((targetClass == NSClassFromString(@"TNMaintainVC") || targetClass == NSClassFromString(@"TNTireListViewController")) && ![TNAppContext currentContext].car)
//        {
//            TNCarSelectBrandAndInfoListVC * carListVC = [[TNCarSelectBrandAndInfoListVC alloc]init];
//            carListVC.selectBrandPushType = targetClass == NSClassFromString(@"TNMaintainVC")? TNCarSelectBrandPushTypeNextLevel : TNCarSelectBrandPushTypeSegue ;
//            carListVC.segueTarget = target;
//            [navigation pushViewController:carListVC animated:YES];
//        }
//        else if (targetClass == NSClassFromString(@"TNMaintainVC") && ((![TNAppContext currentContext].car.displacement || ![TNAppContext currentContext].car.displacement.length) && [TNAppContext currentContext].car.hasDisplacement))
//        {
//            TNCarSelectDisplacementAndYearVC *carListVC = [[TNCarSelectDisplacementAndYearVC alloc]init];
//            carListVC.car = [TNAppContext currentContext].car;
//            carListVC.segueTarget = target;
//            carListVC.selectLevel = 0;
//            [navigation pushViewController:carListVC animated:YES];
//        }
//        else if (targetClass == NSClassFromString(@"TNTireListViewController") && (![TNAppContext currentContext].car.currentTire || ![TNAppContext currentContext].car.currentTire.length))
//        {
//            TNPickTireViewController *vc = [[TNPickTireViewController alloc]initWithNibName:@"TNPickTireViewController" bundle:[NSBundle mainBundle]];
//            [navigation pushViewController:vc animated:YES];
//        }
//        // 首页，发现， 门店， 我， 4个导航栏根页面
//        else if (targetClass == NSClassFromString(@"TNHomeVC"))
//        {
//            [(UITabBarController *)[TNApplication sharedApplication].rootViewController setSelectedIndex:0];
//            [navigation popToRootViewControllerAnimated:YES];
//        }
//        else if (targetClass == NSClassFromString(@"DiscoverTNVC"))
//        {
//            [(UITabBarController *)[TNApplication sharedApplication].rootViewController setSelectedIndex:1];
//            [navigation popToRootViewControllerAnimated:YES];
//        }
//        else if (targetClass == NSClassFromString(@"TNShopListViewController"))
//        {
//            [(UITabBarController *)[TNApplication sharedApplication].rootViewController setSelectedIndex:2];
//            [navigation popToRootViewControllerAnimated:YES];
//        }
//        else if (targetClass == NSClassFromString(@"TNPersonCenterVC"))
//        {
//            [(UITabBarController *)[TNApplication sharedApplication].rootViewController setSelectedIndex:3];
//            [navigation popToRootViewControllerAnimated:YES];
//        }
        // 一般情况
//        else
//        {
            // 格式化 属性列表， 将 模型对象 类的属性， 从 数据源 (字符串，字典等) 格式化为对象，  并赋值给控制器
            [MMUtils setValuesWithDictionary:[self formatterJsonDataToModel:target.targetParams] forObject:targetVC];
            // 判断是否需要登录
        
                [TNFlowUtil presentLoginWithCompletion:^(UIViewController *vc) {
                    [vc dismissViewControllerAnimated:YES completion:^{
                        [navigation pushViewController:targetVC animated:YES];
                    }];
                } presentingViewController:navigation animated:YES];
            }
            else
            {
                [navigation pushViewController:targetVC animated:YES];
            }
    
//    }
}


#pragma mark - pravite methods
/**
 *  将属性列表字典 格式化 ， 将字典中某些字段的数据 格式化为 模型对象，  规则：  "key<className>" : "vaule" ,  value 为 字典@{} 或者 数组@[@{}, @{}]
 *
 *  @param source 数据源
 *
 *  @return 格式化后的数据
 */
+ (id)formatterJsonDataToModel:(id)source
{
    if ([source isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary *newDic = [@{} mutableCopy];
        if (source)
        {
            NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[^<^>]+<[^<^>]+\\b>$"]; // 正则表达式， 判断  属性名<类名> 格式
            [source enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSNull class]]) return;
                if ([regex evaluateWithObject:key])
                {
                    NSString * fixKey = [key componentsSeparatedByString:@"<"][0];
                    NSString * className = [[key componentsSeparatedByString:@"<"][1] stringByReplacingOccurrencesOfString:@">" withString:@""];
                    if ([obj isKindOfClass:[NSDictionary class]])
                    {
                        [newDic setObject:[MMUtils creatObjectWithJsonDic:[self formatterJsonDataToModel:obj] forClass:NSClassFromString(className)] forKey:fixKey];
                    }
                    if ([obj isKindOfClass:[NSArray class]])
                    {
                        [newDic setObject:[(NSArray *)obj arrayTransformObjectWithBlock:^id(NSDictionary *dataDic, NSInteger index, BOOL *stop) {
                            return [MMUtils creatObjectWithJsonDic:[self formatterJsonDataToModel:dataDic] forClass:NSClassFromString(className)];
                        }] forKey:fixKey];
                    }
                }
                else
                {
                    [newDic setObject:[self formatterJsonDataToModel:obj] forKey:key];
                }
            }];
        }
        return [NSDictionary dictionaryWithDictionary:newDic];
    }
    else if ([source isKindOfClass:[NSArray class]])
    {
        return [source arrayTransformObjectWithBlock:^id(id obj, NSInteger index, BOOL *stop) {
            return [self formatterJsonDataToModel:obj];
        }];
    }
    else
    {
        return source;
    }
}

@end

@implementation UIScrollView (TNRefresh)

- (void)addTNGIFHeaderWithBlock:(void (^)())block
{
    [self addGifHeaderWithRefreshingBlock:block];
    SCGIFImageView* gif = [[SCGIFImageView alloc] initWithGIFFile:[[NSBundle mainBundle] pathForResource:@"loading-hu-red.gif" ofType:nil]];
    NSArray* frames = [gif.GIF_frames valueForKey:@"data"];
    NSMutableArray* images = [@[] mutableCopy];
    [frames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [images addObject:[UIImage imageWithData:obj scale:3]];
    }];
    [self.gifHeader setImages:images forState:MJRefreshHeaderStateIdle];
    [self.gifHeader setImages:images forState:MJRefreshHeaderStatePulling];
    [self.gifHeader setImages:images forState:MJRefreshHeaderStateRefreshing];
    self.gifHeader.updatedTimeHidden = YES;
    self.gifHeader.stateHidden = YES;
}

- (void)addTNGIFFooterWithBlock:(void (^)())block
{
    [self addGifFooterWithRefreshingBlock:block];
    SCGIFImageView* gif = [[SCGIFImageView alloc] initWithGIFFile:[[NSBundle mainBundle] pathForResource:@"loading-hu-red.gif" ofType:nil]];
    NSArray* frames = [gif.GIF_frames valueForKey:@"data"];
    NSMutableArray* images = [@[] mutableCopy];
    [frames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [images addObject:[UIImage imageWithData:obj scale:3]];
    }];
    self.gifFooter.refreshingImages = images;
    self.gifFooter.stateHidden = YES;
}

- (void)addTNGifHeaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action{
    [self addGifFooterWithRefreshingTarget:target refreshingAction:@selector(action)];
    SCGIFImageView* gif = [[SCGIFImageView alloc] initWithGIFFile:[[NSBundle mainBundle] pathForResource:@"loading-hu-red.gif" ofType:nil]];
    NSArray* frames = [gif.GIF_frames valueForKey:@"data"];
    NSMutableArray* images = [@[] mutableCopy];
    [frames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [images addObject:[UIImage imageWithData:obj scale:3]];
    }];
    [self.gifHeader setImages:images forState:MJRefreshHeaderStateIdle];
    [self.gifHeader setImages:images forState:MJRefreshHeaderStatePulling];
    [self.gifHeader setImages:images forState:MJRefreshHeaderStateRefreshing];
    self.gifHeader.updatedTimeHidden = YES;
    self.gifHeader.stateHidden = YES;
}

- (void)addTNGifFooterWithRefreshingTarget:(id)target refreshingAction:(SEL)action{
    [self addGifFooterWithRefreshingTarget:target refreshingAction:@selector(action)];
    SCGIFImageView* gif = [[SCGIFImageView alloc] initWithGIFFile:[[NSBundle mainBundle] pathForResource:@"loading-hu-red.gif" ofType:nil]];
    NSArray* frames = [gif.GIF_frames valueForKey:@"data"];
    NSMutableArray* images = [@[] mutableCopy];
    [frames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [images addObject:[UIImage imageWithData:obj scale:3]];
    }];
    self.gifFooter.refreshingImages = images;
    self.gifFooter.stateHidden = YES;
}
- (void)addPPHeaderWithBlock:(void (^)())block{
    [self addLegendHeaderWithRefreshingBlock:block];
    self.header.updatedTimeHidden = NO;
}
- (void)addPPFooterWithBlock:(void (^)())block{
    [self addLegendFooterWithRefreshingBlock:block];
}
@end