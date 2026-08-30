//
//  MHSplashViewController.m
//  MHGAdSDKDemo
//
//  Created by Jianheng on 2024/11/25.
//

#import "MHSplashViewController.h"
#import <AnyThinkSDK/ATAdManager.h>
#import <AnyThinkSDK/ATAdManager+Splash.h>
#import <AnyThinkSDK/ATSplashDelegate.h>
#import "Masonry.h"
#import "MHCommonTableViewCell.h"
#import "UIView+toast.h"

@interface MHSplashViewController () <UITableViewDelegate, UITableViewDataSource, MHCommonTableViewCellDelegate, ATSplashDelegate>

@property (nonatomic, strong) UITableView *splashTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) NSString *adID;

@end

@implementation MHSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Splash Ad";
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonTapped)];
    backButton.accessibilityIdentifier = @"MHSplashViewController_BackButtonItem";
    self.navigationItem.leftBarButtonItem = backButton;

    [self addTapGestureToDismissKeyboard];
    [self getData];
    [self layoutAllSubviews];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)layoutAllSubviews {
    [self.view addSubview:self.splashTableView];
    [self.splashTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.width.height.equalTo(self.view);
    }];
    [self.splashTableView reloadData];
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
    idModel.title = @"Placement Id";
    idModel.content = @"n6a87b0db53431";
    self.adID = idModel.content;
    [configArray addObject:idModel];

    [self.dataArray addObject:configArray];

    MHCommonCellModel *requestModel = [[MHCommonCellModel alloc] init];
    requestModel.cellType = MHCommonCellTypeButton;
    requestModel.title = @"Load and display ad";
    NSArray *buttonArray = @[requestModel];
    [self.dataArray addObject:buttonArray];
}

- (UITableView *)splashTableView {
    if (!_splashTableView) {
        _splashTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _splashTableView.backgroundColor = [UIColor clearColor];
        _splashTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _splashTableView.sectionFooterHeight = 0;
        _splashTableView.delegate = self;
        _splashTableView.dataSource = self;
        [_splashTableView registerClass:[MHCommonTableViewCell class] forCellReuseIdentifier:@"MHCommonTableViewCell"];
    }
    return _splashTableView;
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

#pragma mark - MHCommonTableViewCellDelegate

- (void)mhCommonTableViewCellButtonDidClick:(NSIndexPath *_Nullable)indexPath {
    // Load splash ad via TopOn
    [[ATAdManager sharedManager] loadADWithPlacementID:self.adID
                                                 extra:nil
                                              delegate:self
                                         containerView:nil];
}

- (void)mhCommonTableViewCellCheckBoxDidClick:(NSIndexPath *_Nullable)indexPath isSelect:(BOOL)isSelect {}

- (void)mhCommonTableViewCellSwitchDidClick:(NSIndexPath *_Nullable)indexPath isOpen:(BOOL)isOpen {}

- (void)mhCommonTableViewCellTextFieldValueChanged:(NSIndexPath *_Nullable)indexPath text:(NSString *)text {
    self.adID = text;
}

#pragma mark - ATSplashDelegate

/// Load succeeded — show immediately
- (void)didFinishLoadingADWithPlacementID:(NSString *)placementID {
    NSLog(@"SplashViewController didFinishLoadingADWithPlacementID: %@", placementID);

    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    [[ATAdManager sharedManager] showSplashWithPlacementID:placementID
                                                    config:nil
                                                    window:window
                                          inViewController:self
                                                     extra:nil
                                                  delegate:self];
}

/// Load failed
- (void)didFailToLoadADWithPlacementID:(NSString *)placementID error:(NSError *)error {
    NSString *errorMsg = [NSString stringWithFormat:@"Splash load failed: %ld - %@", (long)error.code, error.localizedDescription];
    [self.view makeToast:errorMsg duration:2.0F position:CSToastPositionCenter];
}

/// Ad shown
- (void)splashDidShowForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSNumber *ecpm = extra[kATADDelegateExtraPublisherRevenueKey];
    NSLog(@"SplashViewController splashDidShow eCPM: %@", ecpm);
    NSString *ecpmString = [NSString stringWithFormat:@"current ecpm: %@", ecpm];
    [[UIApplication sharedApplication].keyWindow makeToast:ecpmString duration:2.0F position:CSToastPositionCenter];
}

/// Clicked
- (void)splashDidClickForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"SplashViewController splashDidClick");
}

/// Closed
- (void)splashDidCloseForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"SplashViewController splashDidClose");
}

@end
