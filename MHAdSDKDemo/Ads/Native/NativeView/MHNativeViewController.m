//
//  MHNativeViewController.m
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2024/11/21.
//

#import "MHNativeViewController.h"

// TopOn SDK
#import <AnyThinkSDK/ATAdManager.h>
#import <AnyThinkSDK/ATAdManager+Native.h>
#import <AnyThinkSDK/ATNativeADDelegate.h>
#import <AnyThinkSDK/ATNativeAdOffer.h>

// MHGAdSDK
#import <MHGAdSDK/MHGNativeAd.h>
#import <MHGAdSDK/MHGNativeAdModel.h>

// Adapter - 用于透传 MHGNativeAd + models
#import "MHGATNativeDelegate.h"

#import "NativeView.h"
#import "Masonry.h"
#import "MHCommonTableViewCell.h"
#import "MHNativeListAdCell.h"
#import "UIView+toast.h"
#import "MHSoundChecker.h"

@interface MHNativeViewController () <UITableViewDelegate, UITableViewDataSource, MHCommonTableViewCellDelegate, ATNativeADDelegate>

@property (nonatomic, strong) UITableView *nativeTableView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray<MHGNativeAdModel *> *adArray;

@property (nonatomic, copy) NSString *adID;
@property (nonatomic, assign) NSInteger adCount;

@property (nonatomic, assign) BOOL isMuted;
@property (nonatomic, assign) BOOL isAutoPlayMobileNetwork;

// 从 adapter 获取，用于 showInViews: 曝光注册
@property (nonatomic, strong) MHGNativeAd *nativeAd;

@property (nonatomic, assign) BOOL hasAdData;
@property (nonatomic, assign) BOOL isAdSectionVisible;

@end

@implementation MHNativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.hasAdData = NO;
    self.isAdSectionVisible = YES;
    self.title = @"原生信息流广告";

    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonTapped)];
    backButton.accessibilityIdentifier = @"MHNativeViewController_BackButtonItem";
    self.navigationItem.leftBarButtonItem = backButton;

    UIBarButtonItem *showAdButton = [[UIBarButtonItem alloc] initWithTitle:@"隐藏广告"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(showAdSectionButtonTapped)];
    self.navigationItem.rightBarButtonItem = showAdButton;

    self.isMuted = YES;
    self.isAutoPlayMobileNetwork = YES;
    self.adCount = 1;
    [self addTapGestureToDismissKeyboard];
    [self getData];

    [self layoutAllSubviews];
}

- (void)backButtonTapped{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAdSectionButtonTapped {
    self.isAdSectionVisible = !self.isAdSectionVisible;

    NSString *title = self.isAdSectionVisible ? @"隐藏广告" : @"显示广告";
    self.navigationItem.rightBarButtonItem.title = title;

    [self.nativeTableView reloadData];
}

-(void)layoutAllSubviews {

    [self.view addSubview:self.nativeTableView];
    [self.nativeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.width.height.equalTo(self.view);
    }];

    [self.nativeTableView reloadData];

}

- (void)addTapGestureToDismissKeyboard {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    [self.view endEditing:YES];
}

- (void)getData {
    self.adArray = [NSMutableArray array];
    self.dataArray = [NSMutableArray array];

    // TopOn 广告位id
    MHCommonCellModel *idModel = [[MHCommonCellModel alloc] init];
    idModel.cellType = MHCommonCellTypeTextField;
    idModel.title = @"广告位id";
    idModel.content = @"b6a851aa7c0d8d";
    self.adID = idModel.content;
    [self.dataArray addObject:idModel];

    // 静音
    MHCommonCellModel *audioConfigModel = [[MHCommonCellModel alloc] init];
    audioConfigModel.cellType = MHCommonCellTypeSwitch;
    audioConfigModel.title = @"静音";
    audioConfigModel.isSelect = self.isMuted;
    [self.dataArray addObject:audioConfigModel];

    // 移动网络是否自动播放
    MHCommonCellModel *autoPlayConfigModel = [[MHCommonCellModel alloc] init];
    autoPlayConfigModel.cellType = MHCommonCellTypeSwitch;
    autoPlayConfigModel.title = @"移动网络是否自动播放";
    autoPlayConfigModel.isSelect = self.isAutoPlayMobileNetwork;
    [self.dataArray addObject:autoPlayConfigModel];

    MHCommonCellModel *requestModel = [[MHCommonCellModel alloc] init];
    requestModel.cellType = MHCommonCellTypeButton;
    requestModel.title = @"请求并展示原生广告";
    [self.dataArray addObject:requestModel];

    if (self.hasAdData) {
        [self addCloseAdData];
    }
}

- (void)addCloseAdData {
    BOOL hasCloseItem = NO;
    for (MHCommonCellModel *item in self.dataArray) {
        if ([item.title isEqualToString:@"关闭广告"]) {
            hasCloseItem = YES;
            break;
        }
    }

    if (!hasCloseItem) {
        MHCommonCellModel *closeModel = [[MHCommonCellModel alloc] init];
        closeModel.cellType = MHCommonCellTypeButton;
        closeModel.title = @"关闭广告";
        [self.dataArray addObject:closeModel];
    }
}

- (void)removeCloseAdData {
    if (self.dataArray.count > 0) {
        MHCommonCellModel *lastModel = self.dataArray.lastObject;
        if ([lastModel.title isEqualToString:@"关闭广告"]) {
            [self.dataArray removeLastObject];
        }
    }
}

// 通过 TopOn 加载原生广告
- (void)loadNativeAdViaTopOn {
    NSDictionary *extra = @{
        @"MHIsMuted": self.isMuted ? @"1" : @"0",
        @"MHAutoPlayMobileNetwork": self.isAutoPlayMobileNetwork ? @"1" : @"0",
        @"loadCount": @(self.adCount)
    };

    [[ATAdManager sharedManager] loadADWithPlacementID:self.adID
                                                  extra:extra
                                               delegate:self];
}

// 懒加载mainTableView
- (UITableView *)nativeTableView {
    if (!_nativeTableView) {
        _nativeTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _nativeTableView.backgroundColor = [UIColor clearColor];
        _nativeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _nativeTableView.sectionFooterHeight = 0;
        _nativeTableView.delegate = self;
        _nativeTableView.dataSource = self;
        [_nativeTableView registerClass:[MHCommonTableViewCell class] forCellReuseIdentifier:@"MHCommonTableViewCell"];
        [_nativeTableView registerClass:[MHNativeListAdCell class] forCellReuseIdentifier:@"MHNativeListAdCell"];
    }
    return _nativeTableView;
}

- (void)dealloc {
    [self closeAd];
    self.nativeAd = nil;
    NSLog(@"原生广告页面 dealloc");
}

#pragma mark ----- UITableViewDelegate && UITableViewDataSource -----
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"MHMainTableViewCell";
        MHCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[MHCommonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }

        cell.indexPath = indexPath;
        cell.delegate = self;

        MHCommonCellModel *model = self.dataArray[indexPath.row];
        [cell setCell:model];
        return cell;
    } else {
        static NSString *cellIdentifier = @"MHNativeListAdCell";
        MHNativeListAdCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[MHNativeListAdCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.nativeAd = self.nativeAd;
        MHGNativeAdModel *model = self.adArray[indexPath.row];
        [cell setCell:model];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.dataArray.count;
    } else if (section == 1) {
        if (self.isAdSectionVisible && self.hasAdData) {
            return self.adArray.count;
        } else {
            return 0;
        }
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.hasAdData) {
        if (self.isAdSectionVisible) {
            return 2;
        } else {
            return 1;
        }
    } else {
        return 1;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 0) {
        return 60;
    } else {
        CGFloat width = self.view.bounds.size.width;
        CGFloat adViewWidth = width - 16;
        CGFloat adWidth = adViewWidth - 16;
        CGFloat adHeight = adWidth / 16 * 9 + 100;
        return adHeight + 10;
    }


}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{


    if (section == 0) {
        return 50;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"选项";
    } else if (section == 1) {
        return @"广告区域";
    }
    return nil;
}
#pragma mark - MHCommonTableViewCellDelegate
- (void)mhCommonTableViewCellButtonDidClick:(NSIndexPath * _Nullable)indexPath {
    MHCommonCellModel *model = self.dataArray[indexPath.row];
    NSString *title = model.title;
    if ([title isEqualToString:@"请求并展示原生广告"]) {
        MHSoundChecker *checker = [[MHSoundChecker alloc] init];
        [checker checkSilentModeWithCompletion:^(BOOL isMuted) {
            if (isMuted) {
                NSLog(@"设备处于静音模式");
                self.isMuted = YES;
            } else {
                NSLog(@"设备未静音");
            }
            [self loadNativeAdViaTopOn];
        }];


    } else if ([title isEqualToString:@"关闭广告"]) {
        [self closeAd];
    }

}

- (void)closeAd {
    self.hasAdData = NO;
    [self.nativeAd unregisterView];
    self.nativeAd = nil;
    [self removeCloseAdData];
    [self.adArray removeAllObjects];
    [self.nativeTableView reloadData];

    self.isAdSectionVisible = YES;
    NSString *rightTitle = self.isAdSectionVisible ? @"隐藏广告" : @"显示广告";
    self.navigationItem.rightBarButtonItem.title = rightTitle;
}

- (void)mhCommonTableViewCellCheckBoxDidClick:(NSIndexPath * _Nullable)indexPath isSelect:(BOOL)isSelect {

}

- (void)mhCommonTableViewCellSwitchDidClick:(NSIndexPath * _Nullable)indexPath isOpen:(BOOL)isOpen {
    MHCommonCellModel *model = self.dataArray[indexPath.row];
    NSString *title = model.title;
    if ([title isEqualToString:@"静音"]) {
        self.isMuted = isOpen;
        for (MHCommonCellModel *item in self.dataArray) {
            if ([item.title isEqualToString:@"静音"]) {
                item.isSelect = isOpen;
                break;
            }
        }

    } else if ([title isEqualToString:@"移动网络是否自动播放"]) {
        self.isAutoPlayMobileNetwork = isOpen;
        for (MHCommonCellModel *item in self.dataArray) {
            if ([item.title isEqualToString:@"移动网络是否自动播放"]) {
                item.isSelect = isOpen;
                break;
            }
        }
    }
    if (self.hasAdData) {
        self.hasAdData = NO;
        self.nativeAd = nil;
        [self removeCloseAdData];
        [self.adArray removeAllObjects];
    }

    [self.nativeTableView reloadData];
}

- (void)mhCommonTableViewCellTextFieldValueChanged:(NSIndexPath *_Nullable)indexPath text:(NSString *)text {
    self.adID = text;
}

#pragma mark ----- ATNativeADDelegate (TopOn) -----

/// 广告加载成功
- (void)didFinishLoadingADWithPlacementID:(NSString *)placementID {
    NSLog(@"[TopOn] native didFinishLoadingAD");

    // 判断命中的广告源是否为 MHAdSDK
    ATNativeAdOffer *offer = [[ATAdManager sharedManager] getNativeAdOfferWithPlacementID:placementID];
    NSInteger networkFirmID = offer.networkFirmID;
    NSLog(@"[TopOn] native networkFirmID: %ld", (long)networkFirmID);

    // 103947 是taku配置的广告平台id,用来区分那个平台的原生广告
    if (networkFirmID != 103947) {
        NSString *msg = [NSString stringWithFormat:@"当前命中非 MHAdSDK 广告 (firmID=%ld)", (long)networkFirmID];
        [self.view makeToast:msg duration:2.0F position:CSToastPositionTop];
        self.hasAdData = NO;
        return;
    }

    // MHGAdSDK 广告 → sideband 模式
    self.nativeAd = [MHGATNativeDelegate lastLoadedNativeAd];
    NSArray<MHGNativeAdModel *> *models = [MHGATNativeDelegate lastLoadedModels];

    // 清空 adapter 的缓存
    [MHGATNativeDelegate clearCache];

    if (!self.nativeAd || models.count == 0) {
        [self.view makeToast:@"nativeAd 无填充!" duration:2.0F position:CSToastPositionTop];
        self.hasAdData = NO;
        return;
    }

    self.nativeAd.rootController = self;
    self.hasAdData = YES;
    [self.adArray removeAllObjects];

    [self.view makeToast:@"nativeAd 广告已经获取" duration:2.0F position:CSToastPositionBottom];

    for (int i = 0; i < models.count; i++) {
        MHGNativeAdModel *nativeModel = models[i];

        NSLog(@"nativeAdDidLoad nativeAdModel 地址[%d]: %p", i, nativeModel);

        NSInteger nativeEcpm = nativeModel.ecpm;
        NSLog(@"[TopOn] native ecpm: %ld", (long)nativeEcpm);
        NSString *ecpmString = [NSString stringWithFormat:@"当前广告的Ecpm[%d]: %ld", i, (long)nativeEcpm];
        [self.view makeToast:ecpmString duration:2.0F position:CSToastPositionCenter];

        [self addCloseAdData];
        [self.adArray addObject:nativeModel];
    }

    [self.nativeTableView reloadData];
}

/// 广告加载失败
- (void)didFailToLoadADWithPlacementID:(NSString *)placementID error:(NSError *)error {
    self.hasAdData = NO;
    [self.adArray removeAllObjects];
    NSLog(@"[TopOn] native 加载失败: %@", error.localizedDescription);
    NSString *toastMessage = [NSString stringWithFormat:@"nativeAd 广告错误: %@", error.localizedDescription];
    [self.view makeToast:toastMessage duration:2.0F position:CSToastPositionCenter];
}

/// 广告展示
- (void)didShowNativeAdInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"[TopOn] native 广告展示");
}

/// 广告点击
- (void)didClickNativeAdInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"[TopOn] native 广告点击");
}

@end
