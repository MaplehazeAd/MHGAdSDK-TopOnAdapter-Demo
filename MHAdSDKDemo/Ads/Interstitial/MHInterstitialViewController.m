//
//  MHInterstitialViewController.m
//  MHGAdSDKDemo
//
//  Created by guojianheng on 2026/5/13.
//

#import "MHInterstitialViewController.h"
#import "MHCommonTableViewCell.h"
#import "Masonry.h"
#import "MHCommonCellModel.h"
#import <AnyThinkSDK/ATAdManager.h>
#import <AnyThinkSDK/ATAdManager+Interstitial.h>
#import <AnyThinkSDK/ATInterstitialDelegate.h>
#import "UIView+toast.h"

@interface MHInterstitialViewController () <UITableViewDelegate, UITableViewDataSource, MHCommonTableViewCellDelegate, ATInterstitialDelegate>

@property (nonatomic, strong) UITableView *interstitialTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) NSString *placementID;
@property (nonatomic, assign) BOOL videoMuted;

@end

@implementation MHInterstitialViewController

- (UITableView *)interstitialTableView {
    if (!_interstitialTableView) {
        _interstitialTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _interstitialTableView.backgroundColor = [UIColor clearColor];
        _interstitialTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _interstitialTableView.sectionFooterHeight = 0;
        _interstitialTableView.delegate = self;
        _interstitialTableView.dataSource = self;
        [_interstitialTableView registerClass:[MHCommonTableViewCell class] forCellReuseIdentifier:@"MHCommonTableViewCell"];
    }
    return _interstitialTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoMuted = YES;
    self.title = @"Interstitial Ad";
    self.view.backgroundColor = [UIColor whiteColor];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonTapped)];
    backButton.accessibilityIdentifier = @"MHInterstitialViewController_BackButtonItem";
    self.navigationItem.leftBarButtonItem = backButton;

    [self addTapGestureToDismissKeyboard];
    [self getData];
    [self layoutAllSubviews];
}

- (void)dealloc {
    NSLog(@"MHInterstitialViewController dealloc");
}

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
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
    self.dataArray = [NSMutableArray array];
    NSMutableArray *configArray = [NSMutableArray array];

    MHCommonCellModel *idModel = [[MHCommonCellModel alloc] init];
    idModel.cellType = MHCommonCellTypeTextField;
    idModel.title = @"Placement id";
    idModel.content = @"n6a93ff39cfea6";
    self.placementID = idModel.content;
    [configArray addObject:idModel];

    MHCommonCellModel *muteConfigModel = [[MHCommonCellModel alloc] init];
    muteConfigModel.cellType = MHCommonCellTypeSwitch;
    muteConfigModel.title = @"Muted";
    muteConfigModel.isSelect = self.videoMuted;
    [configArray addObject:muteConfigModel];
    [self.dataArray addObject:configArray];

    MHCommonCellModel *requestModel = [[MHCommonCellModel alloc] init];
    requestModel.cellType = MHCommonCellTypeButton;
    requestModel.title = @"Load Ad";
    NSArray *buttonArray = @[requestModel];
    [self.dataArray addObject:buttonArray];
}

- (void)layoutAllSubviews {
    [self.view addSubview:self.interstitialTableView];
    [self.interstitialTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.width.bottom.equalTo(self.view);
    }];
    [self.interstitialTableView reloadData];
}

#pragma mark ----- UITableViewDelegate && UITableViewDataSource -----

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MHMainTableViewCell";
    MHCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MHCommonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    cell.indexPath = indexPath;
    cell.delegate = self;

    MHCommonCellModel *model = self.dataArray[indexPath.section][indexPath.row];
    [cell setCell:model];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = self.dataArray[section];
    return sectionArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 4) {
        return 60;
    }
    return 42;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Options";
    } else {
        return @" ";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark ----- MHCommonTableViewCellDelegate -----

- (void)mhCommonTableViewCellButtonDidClick:(NSIndexPath *_Nullable)indexPath {
    // Load interstitial via TopOn; pass mute config via extra
    NSDictionary *extra = @{
        @"MHIsMuted": self.videoMuted ? @"1" : @"0"
    };
    [[ATAdManager sharedManager] loadADWithPlacementID:self.placementID
                                                 extra:extra
                                              delegate:self];
}

- (void)mhCommonTableViewCellCheckBoxDidClick:(NSIndexPath *_Nullable)indexPath isSelect:(BOOL)isSelect {}

- (void)mhCommonTableViewCellSwitchDidClick:(NSIndexPath *_Nullable)indexPath isOpen:(BOOL)isOpen {
    MHCommonCellModel *model = self.dataArray[indexPath.section][indexPath.row];
    NSString *title = model.title;
    if ([title isEqualToString:@"Muted"]) {
        self.videoMuted = isOpen;
    }
}

- (void)mhCommonTableViewCellTextFieldValueChanged:(NSIndexPath *_Nullable)indexPath text:(NSString *)text {
    self.placementID = text;
}

#pragma mark ----- ATInterstitialDelegate -----

/// Load succeeded — show immediately
- (void)didFinishLoadingADWithPlacementID:(NSString *)placementID {
    NSLog(@"Interstitial didFinishLoadingADWithPlacementID: %@", placementID);
    [[ATAdManager sharedManager] showInterstitialWithPlacementID:placementID
                                                inViewController:self
                                                        delegate:self];
}

/// Load failed
- (void)didFailToLoadADWithPlacementID:(NSString *)placementID error:(NSError *)error {
    NSString *errorMsg = [NSString stringWithFormat:@"Interstitial load failed: %ld - %@", (long)error.code, error.localizedDescription];
    [[UIApplication sharedApplication].keyWindow makeToast:errorMsg duration:2.0F position:CSToastPositionCenter];
}

/// Ad shown
- (void)interstitialDidShowForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Interstitial didShow");
    [[UIApplication sharedApplication].keyWindow makeToast:@"Interstitial ad shown" duration:2.0F position:CSToastPositionCenter];
}

/// Clicked
- (void)interstitialDidClickForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Interstitial didClick");
    [[UIApplication sharedApplication].keyWindow makeToast:@"Interstitial ad clicked" duration:2.0F position:CSToastPositionCenter];
}

/// Closed
- (void)interstitialDidCloseForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Interstitial didClose");
    [[UIApplication sharedApplication].keyWindow makeToast:@"Interstitial ad closed" duration:2.0F position:CSToastPositionCenter];
}

/// Show failed
- (void)interstitialFailedToShowForPlacementID:(NSString *)placementID error:(NSError *)error extra:(NSDictionary *)extra {
    NSLog(@"Interstitial failedToShow: %@", error);
    [[UIApplication sharedApplication].keyWindow makeToast:[NSString stringWithFormat:@"Show failed: %@", error.localizedDescription] duration:2.0F position:CSToastPositionCenter];
}

@end
