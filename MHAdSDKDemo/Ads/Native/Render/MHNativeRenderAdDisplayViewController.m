//
//  MHNativeRenderAdDisplayViewController.m
//  MHGAdSDKDemo
//
//  Created by Jianheng on 2026/1/9.
//

#import "MHNativeRenderAdDisplayViewController.h"
#import <AnyThinkSDK/ATAdManager.h>
#import <AnyThinkSDK/ATAdManager+Native.h>
#import <AnyThinkSDK/ATNativeADDelegate.h>
#import <MHGAdSDK/MHGNativeAd.h>
#import <MHGAdSDK/MHGNativeAdView.h>
#import <MHGAdSDK/MHGNativeAdModel.h>
#import "MHGATNativeDelegate.h"
#import "UIView+toast.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"
#import "SelfRenderView.h"

@interface MHNativeRenderAdDisplayViewController () <ATNativeADDelegate>

@property (nonatomic, strong) NSMutableArray *adArray;
@property (nonatomic, strong) MHGNativeAdView *nativeAdView;
@property (nonatomic, strong) SelfRenderView *selfRenderView;
@property (nonatomic, strong) MHGNativeAd *nativeAd;

@end

@implementation MHNativeRenderAdDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareSystemUI];
    [self layoutAllSubViews];
    [self loadAd];
}

#pragma mark - UI

- (void)prepareSystemUI {
    self.title = @"Display";
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonTapped)];
    backButton.accessibilityIdentifier = @"MHNativeViewController_BackButtonItem";
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)layoutAllSubViews {
    self.nativeAdView = [[MHGNativeAdView alloc] init];
    [self.view addSubview:self.nativeAdView];
    [self.nativeAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(400);
    }];
}

#pragma mark - LoadAd

- (void)loadAd {
    // Load native ad via TopOn; pass mute and autoplay config via extra
    NSDictionary *extra = @{
        @"MHIsMuted": self.isMuted ? @"1" : @"0",
        @"MHAutoPlayMobileNetwork": self.isAutoPlayMobileNetwork ? @"1" : @"0"
    };
    [[ATAdManager sharedManager] loadADWithPlacementID:self.placementID
                                                 extra:extra
                                              delegate:self];
}

#pragma mark - ATNativeADDelegate

/// Load succeeded — retrieve cached models from adapter and render
- (void)didFinishLoadingADWithPlacementID:(NSString *)placementID {
    // Retrieve MHGNativeAd and models from adapter cache (sideband pattern)
    self.nativeAd = [MHGATNativeDelegate lastLoadedNativeAd];
    NSArray<MHGNativeAdModel *> *models = [MHGATNativeDelegate lastLoadedModels];
    [MHGATNativeDelegate clearCache];

    if (!self.nativeAd || models.count == 0) {
        [self.view makeToast:@"Native ad: no fill" duration:2.0F position:CSToastPositionTop];
        return;
    }

    self.nativeAd.rootController = self;
    [self.view makeToast:@"Native ad loaded!" duration:2.0F position:CSToastPositionBottom];

    for (int i = 0; i < models.count; i++) {
        MHGNativeAdModel *nativeModel = models[i];
        NSLog(@"nativeAdDidLoad nativeAdModel[%d]: %p", i, nativeModel);

        // ----- Ecpm -----
        NSInteger nativeEcpm = nativeModel.ecpm;
        NSString *ecpmString = [NSString stringWithFormat:@"current ad ecpm[%d]: %ld", i, (long)nativeEcpm];
        [self.view makeToast:ecpmString duration:2.0F position:CSToastPositionCenter];

        // Send win notification
        if (nativeEcpm != -1) {
            [nativeModel sendWinNotification:nativeEcpm];
        }

        [self.adArray addObject:nativeModel];

        // ----- Set Ad -----
        // 1. Bind nativeAdModel to nativeAdView
        self.nativeAdView.nativeAdModel = nativeModel;

        // ----- Create SelfRenderView -----
        // 2. Render view
        self.selfRenderView = [[SelfRenderView alloc] init];
        self.selfRenderView.frame = self.nativeAdView.bounds;
        self.selfRenderView.titleLabel.text = nativeModel.title;
        self.selfRenderView.textLabel.text = nativeModel.description;
        self.selfRenderView.ctaLabel.text = nativeModel.actionText;
        self.selfRenderView.mediaView = [self.nativeAdView getMediaView];
        [self.selfRenderView.iconImageView sd_setImageWithURL:[NSURL URLWithString:nativeModel.iconURL]];
        [self.selfRenderView.mainImageView sd_setImageWithURL:[NSURL URLWithString:nativeModel.imageURL]];

        // ----- Bind Data -----
        // 3. Bind views to SDK
        MHGNativePrepareInfo *info = [MHGNativePrepareInfo loadPrepareInfo:^(MHGNativePrepareInfo *prepareInfo) {
            prepareInfo.textLabel = self.selfRenderView.textLabel;
            prepareInfo.advertiserLabel = self.selfRenderView.advertiserLabel;
            prepareInfo.titleLabel = self.selfRenderView.titleLabel;
            prepareInfo.ratingLabel = self.selfRenderView.ratingLabel;
            prepareInfo.iconImageView = self.selfRenderView.iconImageView;
            prepareInfo.mainImageView = self.selfRenderView.mainImageView;
            prepareInfo.ctaLabel = self.selfRenderView.ctaLabel;
            prepareInfo.dislikeButton = self.selfRenderView.dislikeButton;
            prepareInfo.mediaView = self.selfRenderView.mediaView;
        }];
        [self.nativeAdView prepareWithNativePrepareInfo:info];

        // ----- Render -----
        // 4. Render ad
        [self.nativeAd rendererWithRenderView:self.selfRenderView nativeADView:self.nativeAdView];
    }
}

/// Load failed
- (void)didFailToLoadADWithPlacementID:(NSString *)placementID error:(NSError *)error {
    [self.adArray removeAllObjects];
    NSLog(@"Native ad load failed, code: %ld, reason: %@", (long)error.code, error.localizedDescription);
    NSString *toastMessage = [NSString stringWithFormat:@"Native ad load failed, code: %ld - %@", (long)error.code, error.localizedDescription];
    [self.view makeToast:toastMessage duration:2.0F position:CSToastPositionCenter];
}

/// Native ad impression tracked
- (void)didShowNativeAdInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Native ad didShow");
    [self.view makeToast:@"Native ad impression tracked" duration:2.0F position:CSToastPositionCenter];
}

/// Native ad clicked
- (void)didClickNativeAdInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Native ad didClick");
    [self.view makeToast:@"Native ad clicked!" duration:2.0F position:CSToastPositionCenter];
}

/// Video play start
- (void)didStartPlayingVideoInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Native ad video play start");
}

/// Video play finished
- (void)didEndPlayingVideoInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Native ad video play finished");
}

@end
