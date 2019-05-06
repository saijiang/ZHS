//
//  ZHSOrderEditAddressViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/7/12.
//  Copyright © 2016年 邢小迪. All rights reserved.
//
#define kDuration 0.25
#define kColumn 3
#define CitiesKey @"cities"
#define StateKey @"state"
#define CityKey @"city"
#define AreasKey @"areas"

#import "ZHSOrderEditAddressViewController.h"
#import "ZHSMyCenterOrderViewController.h"


typedef enum : NSUInteger {
    ZHSAreaTypeProvinces = 0,
    ZHSAreaTypeCitys,
    ZHSAreaTypeAreas
} ZHSAreaType;


@implementation ZHSLocation
@synthesize country = _country;
@synthesize state = _state;
@synthesize city = _city;
@synthesize street = _street;
@synthesize district = _district;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@end



@interface ZHSAreaPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
/**
 *  省份
 */
@property (nonatomic, strong) NSArray *provinces;
/**
 *  城市
 */
@property (nonatomic, strong) NSArray *cities;
/**
 *  地区
 */
@property (nonatomic, strong) NSArray *areas;

@end
@implementation ZHSAreaPickerView
/**
 *  数据的懒加载
 *
 */
- (NSArray *)provinces
{
    if (_provinces == nil) {
        _provinces = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area" ofType:@"plist"]];
    }
    
    return _provinces;
}

- (ZHSLocation *)locate
{
    if (_locate == nil) {
        _locate = [[ZHSLocation alloc] init];
    }
    
    return _locate;
}

+ (instancetype)areaPickerViewWithDelegate:(id<ZHSAreaPickerViewDelegate>)delegate
{
    return [[self alloc] initWithDelegate:delegate];
}
- (instancetype)initWithDelegate:(id<ZHSAreaPickerViewDelegate>)delegate
{
    
    if (self = [super init]) {
        // 从xib中加载视图
        self = [[[NSBundle mainBundle] loadNibNamed:@"ZHSAreaPickerView" owner:nil options:nil] lastObject];
        self.delegate = delegate;
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        
        // 初始化数据，默认加载第一条
        // 第一级
        self.cities = [self.provinces[0] valueForKey:CitiesKey];
        self.locate.state = [self.provinces[0] valueForKey:StateKey];
        // 第二级
        self.locate.city = [self.cities[0] objectForKey:CityKey];
        self.areas = [self.cities[0] objectForKey:AreasKey];
        // 第三级
        if (self.areas.count > 0) {
            self.locate.district = self.areas[0];
        } else{
            self.locate.district = @"";
        }
        
        for (int i = 0; i < kColumn; i++) {
            [self pickerView:self.pickerView didSelectRow:0 inComponent:i];
        }
        
    }
    
    return self;
    
}
#pragma mark - 显示AreaPickerView
- (void)showInView:(UIView *)view
{
    self.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, view.frame.size.height);
    [view addSubview:self];
    
    // 0.3秒后改变areaPicker的frame
    [UIView animateWithDuration:kDuration animations:^{
        self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
}
- (IBAction)cancel:(id)sender {
    [self cancelPicker];
}
- (IBAction)ok:(id)sender {
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(pickerDidChangeStatus:)]) {
        [self.delegate pickerDidChangeStatus:self];
    }
}
#pragma mark - 取消AreaPickerView
- (void)cancelPicker
{
    [UIView animateWithDuration:kDuration animations:^{
        self.frame = CGRectMake(0, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.pickerView.delegate  = nil;
        self.pickerView.dataSource = nil;
    }];
}
#pragma mark -UIPickerViewDataSource数据源方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return kColumn;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case ZHSAreaTypeProvinces:
            return self.provinces.count;
            break;
        case ZHSAreaTypeCitys:
            return self.cities.count;
            break;
        case ZHSAreaTypeAreas:
            return self.areas.count;
            break;
            
        default:
            return 0;
            break;
    }
}
#pragma mark - UIPickerViewDelegate代理方法
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case ZHSAreaTypeProvinces:
            return [self.provinces[row] objectForKey:StateKey];
            break;
        case ZHSAreaTypeCitys:
            return [self.cities[row] objectForKey:CityKey];
            break;
        case ZHSAreaTypeAreas:
            if (self.areas.count > 0) {
                return self.areas[row];
                break;
            }
        default:
            return @"";
            break;
    }
}

/**
 *  选中某列某行
 *
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case ZHSAreaTypeProvinces: // 选中第一列
            // 修改cities数据
            self.cities = [self.provinces[row] objectForKey:CitiesKey];
            // 刷新第二列
            [self.pickerView reloadComponent:1];
            // 默认选中第二列的第一行
            [self.pickerView selectRow:0 inComponent:1 animated:YES];
            
            // 刷新第三列
            [self reloadAreaComponentWithRow:0];
            
            self.locate.state = [[self.provinces objectAtIndex:row] objectForKey:StateKey];
            break;
            
        case ZHSAreaTypeCitys: // 选中第二列
            [self reloadAreaComponentWithRow:row];
            break;
        case ZHSAreaTypeAreas: // 选中第三列
            if ([self.areas count] > 0) {
                self.locate.district = [self.areas objectAtIndex:row];
            } else{
                self.locate.district = @"";
            }
            break;
            
        default:
            break;
    }
//    // 通知代理
//    if ([self.delegate respondsToSelector:@selector(pickerDidChangeStatus:)]) {
//        [self.delegate pickerDidChangeStatus:self];
//    }
    
}

- (void)reloadAreaComponentWithRow:(NSInteger)row
{
    self.areas = [self.cities[row] objectForKey:AreasKey];
    [self.pickerView reloadComponent:ZHSAreaTypeAreas];
    [self.pickerView selectRow:0 inComponent:ZHSAreaTypeAreas animated:YES];
    
    self.locate.city = [[self.cities objectAtIndex:row] objectForKey:CityKey];
    
    if ([self.areas count] > 0) {
        self.locate.district = [self.areas objectAtIndex:0];
    } else{
        self.locate.district = @"";
    }
}
@end




@interface ZHSOrderEditAddressViewController ()<ZHSAreaPickerViewDelegate>
@property (nonatomic, strong) ZHSAreaPickerView *areaPickerView;
@property (weak, nonatomic) IBOutlet UILabel *addressLable;

@end

@implementation ZHSOrderEditAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"编辑收货地址";
    [self createRightBarItemWithTitle:@"保存"];
}
-(void)reclaimedKeyboard{
    [self.view endEditing:YES];
}
-(void)cancelLocatePicker
{
    [self.areaPickerView cancelPicker];
    self.areaPickerView.delegate = nil;
    self.areaPickerView = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)tapAreas:(id)sender {
    [self reclaimedKeyboard];
    // 1, 先清空AreaPickerView
    [self cancelLocatePicker];
    // 2，再初始化AreaPickerView
    self.areaPickerView = [ZHSAreaPickerView areaPickerViewWithDelegate:self];
    // 3，显示
    [self.areaPickerView showInView:self.view];
}
#pragma mark - KJAreaPickerViewDelegate的代理
- (void)pickerDidChangeStatus:(ZHSAreaPickerView *)picker
{
    NSString *areas = [NSString stringWithFormat:@"%@ %@ %@",picker.locate.state,picker.locate.city,picker.locate.district];
    MMLog(@"========%@",areas);
    self.addressLable.text = areas;
    [self cancelLocatePicker];
    
}
-(void)clickRightSender:(UIButton *)sender{
    [self.navigationController pushViewController:[ZHSMyCenterOrderViewController new] animated:YES];
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
