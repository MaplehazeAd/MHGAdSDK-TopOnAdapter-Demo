# MHGAdSDK-TopOnAdapter

TopOn (Taku) mediation adapter for MHGAdSDK, supporting Splash, Interstitial, Native Feed, and Rewarded Video ad formats.

Built on the TopOn new architecture (`ATBaseMediationAdapter` + `ATBaseInitAdapter` + `ATAdStatusBridge`), requires TPNiOS >= 6.5.80.

## References

- MHGAdSDK integration guide: MapleHaze SDK Developer Documentation
- TopOn custom ADN configuration: <https://help.takuad.com/docs/CQuN9eZp>

## TopOn Dashboard Configuration

> **Note:** When creating a custom ADN ad source in the TopOn dashboard, you must add `slot_id` (corresponding to the MHGAdSDK placement ID) in the ad source parameters. Otherwise, ad requests will fail.

### 1. Create a Custom ADN Ad Source

![Create Custom ADN](./imgs/0aca84bd377637cae3ed184dd3fa687f.png)

### 2. Waterfall Management

![Waterfall Management](./imgs/7f4f29f59e04bab81bc66b18d10dab99.png)

### 3. Ad Source Parameters

Add `slot_id` in the ad source parameters, with the value set to your MHGAdSDK placement ID:

![Ad Source Parameters](./imgs/36ee78ad227a5657406f8c12b1a47d1f.png)



### 4. Adapter Class Names

| Type                 | Adapter Name               |
| -------------------- | -------------------------- |
| SplashAdapter        | MHGATSplashAdapter         |
| InterstitialAdapter  | MHGATInterstitialAdapter   |
| NativeAdapter        | MHGATNativeAdapter         |
| RewardedVideoAdapter | MHGATRewardedVideoAdapter  |



## SDK Initialization

The TopOn SDK is initialized in AppDelegate. MHGAdSDK initialization is handled automatically by the adapter's `MHGATInitAdapter` — **no manual registration is required**.

```objc
#import <AnyThinkSDK/ATAPI.h>

// TopOn SDK initialization
NSError *error = nil;
[[ATAPI sharedInstance] startWithAppID:@"your_app_id"
                                appKey:@"your_app_key"
                                 error:&error];
```

## Podfile

```ruby
source 'https://cdn.cocoapods.org/'

platform :ios, '13.0'

target 'MHAdSDKDemo' do
  use_frameworks! :linkage => :static

  # MH Ad SDK
  pod 'MHGAdSDK', '~> 1.0.2'

  # TopOn mediation platform
  pod 'TPNiOS', '6.5.80'
  pod 'TPNMediationAdxSmartdigimktCNAdapter', '6.5.77.2.0'

  # MHGAdSDK TopOn custom adapter
  pod 'MHGAdSDK-TopOnAdapter', '~> 1.0.2'
  
  pod 'Google-Mobile-Ads-SDK', '~> 13.5.0'
end
```

## Integration Examples

---

### Splash Ad

> See Demo: `MHSplashViewController`

#### Declare Delegate

```objc
#import <AnyThinkSDK/ATAdManager.h>
#import <AnyThinkSDK/ATAdManager+Splash.h>
#import <AnyThinkSDK/ATSplashDelegate.h>

@interface MHSplashViewController () <ATSplashDelegate>
@end
```

#### Load and Show Ad

```objc
// Load splash ad via TopOn
[[ATAdManager sharedManager] loadADWithPlacementID:self.adID
                                              extra:nil
                                           delegate:self
                                      containerView:nil];
```

#### Implement Delegate Callbacks

```objc
#pragma mark - ATSplashDelegate

/// Load succeeded — show immediately
- (void)didFinishLoadingADWithPlacementID:(NSString *)placementID {
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
    NSLog(@"Splash ad load failed: %@", error);
}

/// Ad shown
- (void)splashDidShowForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSNumber *ecpm = extra[kATADDelegateExtraPublisherRevenueKey];
    NSLog(@"Splash eCPM: %@", ecpm);
}

/// Clicked
- (void)splashDidClickForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Splash ad clicked");
}

/// Closed
- (void)splashDidCloseForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Splash ad closed");
}
```

---

### Interstitial Ad

> See Demo: `MHInterstitialViewController`

#### Declare Delegate

```objc
#import <AnyThinkSDK/ATAdManager.h>
#import <AnyThinkSDK/ATAdManager+Interstitial.h>
#import <AnyThinkSDK/ATInterstitialDelegate.h>

@interface MHInterstitialViewController () <ATInterstitialDelegate>
@end
```

#### Load Ad

```objc
// Pass mute config via extra; adapter reads from localInfoDic
NSDictionary *extra = @{
    @"MHIsMuted": self.videoMuted ? @"1" : @"0"
};

[[ATAdManager sharedManager] loadADWithPlacementID:self.placementID
                                              extra:extra
                                           delegate:self];
```

#### Implement Delegate Callbacks

```objc
#pragma mark - ATInterstitialDelegate

/// Load succeeded — show immediately
- (void)didFinishLoadingADWithPlacementID:(NSString *)placementID {
    [[ATAdManager sharedManager] showInterstitialWithPlacementID:placementID
                                                inViewController:self
                                                        delegate:self];
}

/// Load failed
- (void)didFailToLoadADWithPlacementID:(NSString *)placementID error:(NSError *)error {
    NSLog(@"Interstitial load failed: %@", error);
}

/// Ad shown
- (void)interstitialDidShowForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Interstitial ad shown");
}

/// Clicked
- (void)interstitialDidClickForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Interstitial ad clicked");
}

/// Closed
- (void)interstitialDidCloseForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Interstitial ad closed");
}

/// Show failed
- (void)interstitialFailedToShowForPlacementID:(NSString *)placementID error:(NSError *)error extra:(NSDictionary *)extra {
    NSLog(@"Interstitial show failed: %@", error);
}
```

---

### Native Feed Ad

> See Demo: `MHNativeViewController` → `MHNativeRenderAdDisplayViewController`

Native ads are loaded via TopOn, then rendered using MHGAdSDK's `MHGNativeAdView` with a custom `SelfRenderView` (supporting video/image). The adapter caches the most recent `MHGNativeAd` and `MHGNativeAdModel` array in `MHGATNativeDelegate`. The display VC retrieves them in the load-success callback for rendering.

#### Declare Delegate

```objc
#import <AnyThinkSDK/ATAdManager.h>
#import <AnyThinkSDK/ATAdManager+Native.h>
#import <AnyThinkSDK/ATNativeADDelegate.h>
#import <MHGAdSDK/MHGNativeAd.h>
#import <MHGAdSDK/MHGNativeAdView.h>
#import <MHGAdSDK/MHGNativeAdModel.h>
#import "MHGATNativeDelegate.h"

@interface MHNativeRenderAdDisplayViewController () <ATNativeADDelegate>

@property (nonatomic, strong) MHGNativeAdView *nativeAdView;
@property (nonatomic, strong) SelfRenderView *selfRenderView;
@property (nonatomic, strong) MHGNativeAd *nativeAd;

@end
```

#### Load Ad

```objc
// Pass mute and autoplay config via extra
NSDictionary *extra = @{
    @"MHIsMuted": self.isMuted ? @"1" : @"0",
    @"MHAutoPlayMobileNetwork": self.isAutoPlayMobileNetwork ? @"1" : @"0"
};

[[ATAdManager sharedManager] loadADWithPlacementID:self.placementID
                                              extra:extra
                                           delegate:self];
```

#### Implement Delegate Callbacks

```objc
#pragma mark - ATNativeADDelegate

/// Ad loaded successfully — retrieve cached models from adapter and render
- (void)didFinishLoadingADWithPlacementID:(NSString *)placementID {
    // Retrieve MHGNativeAd and models from adapter cache (sideband pattern)
    self.nativeAd = [MHGATNativeDelegate lastLoadedNativeAd];
    NSArray<MHGNativeAdModel *> *models = [MHGATNativeDelegate lastLoadedModels];
    [MHGATNativeDelegate clearCache];

    if (!self.nativeAd || models.count == 0) {
        NSLog(@"Native ad: no fill");
        return;
    }

    self.nativeAd.rootController = self;

    for (MHGNativeAdModel *nativeModel in models) {
        // 1. Bind model to MHGNativeAdView
        self.nativeAdView.nativeAdModel = nativeModel;

        // 2. Create SelfRenderView and populate with ad data
        self.selfRenderView = [[SelfRenderView alloc] init];
        self.selfRenderView.frame = self.nativeAdView.bounds;
        self.selfRenderView.titleLabel.text = nativeModel.title;
        self.selfRenderView.textLabel.text = nativeModel.description;
        self.selfRenderView.ctaLabel.text = nativeModel.actionText;
        self.selfRenderView.mediaView = [self.nativeAdView getMediaView];
        // Load images via SDWebImage
        [self.selfRenderView.iconImageView sd_setImageWithURL:[NSURL URLWithString:nativeModel.iconURL]];
        [self.selfRenderView.mainImageView sd_setImageWithURL:[NSURL URLWithString:nativeModel.imageURL]];

        // 3. Bind views to SDK via MHGNativePrepareInfo
        MHGNativePrepareInfo *info = [MHGNativePrepareInfo loadPrepareInfo:^(MHGNativePrepareInfo *prepareInfo) {
            prepareInfo.titleLabel = self.selfRenderView.titleLabel;
            prepareInfo.textLabel = self.selfRenderView.textLabel;
            prepareInfo.ctaLabel = self.selfRenderView.ctaLabel;
            prepareInfo.advertiserLabel = self.selfRenderView.advertiserLabel;
            prepareInfo.ratingLabel = self.selfRenderView.ratingLabel;
            prepareInfo.iconImageView = self.selfRenderView.iconImageView;
            prepareInfo.mainImageView = self.selfRenderView.mainImageView;
            prepareInfo.dislikeButton = self.selfRenderView.dislikeButton;
            prepareInfo.mediaView = self.selfRenderView.mediaView;
        }];
        [self.nativeAdView prepareWithNativePrepareInfo:info];

        // 4. Render ad (triggers impression + click tracking)
        [self.nativeAd rendererWithRenderView:self.selfRenderView nativeADView:self.nativeAdView];
    }
}

/// Ad load failed
- (void)didFailToLoadADWithPlacementID:(NSString *)placementID error:(NSError *)error {
    NSLog(@"Native ad load failed: %@", error.localizedDescription);
}

/// Impression tracked
- (void)didShowNativeAdInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Native ad impression tracked");
}

/// Clicked
- (void)didClickNativeAdInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Native ad clicked");
}

/// Video play start
- (void)didStartPlayingVideoInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Native ad video play start");
}

/// Video play finished
- (void)didEndPlayingVideoInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Native ad video play finished");
}
```

---

### Rewarded Video Ad

> See Demo: `MHRewardVideoViewController`

#### Declare Delegate

```objc
#import <AnyThinkSDK/ATAdManager.h>
#import <AnyThinkSDK/ATAdManager+RewardedVideo.h>
#import <AnyThinkSDK/ATRewardedVideoDelegate.h>

@interface MHRewardVideoViewController () <ATRewardedVideoDelegate>
@end
```

#### Load and Show Ad

```objc
// Pass mute config via extra; adapter reads from localInfoDic
NSDictionary *extra = @{
    @"MHIsMuted": self.isMuted ? @"1" : @"0"
};

[[ATAdManager sharedManager] loadADWithPlacementID:self.placementID
                                              extra:extra
                                           delegate:self];
```

#### Implement Delegate Callbacks

```objc
#pragma mark - ATRewardedVideoDelegate

/// Load succeeded — show immediately
- (void)didFinishLoadingADWithPlacementID:(NSString *)placementID {
    [[ATAdManager sharedManager] showRewardedVideoWithPlacementID:placementID
                                                inViewController:self
                                                        delegate:self];
}

/// Load failed
- (void)didFailToLoadADWithPlacementID:(NSString *)placementID error:(NSError *)error {
    NSLog(@"Rewarded video load failed: %@", error);
}

/// Playback started
- (void)rewardedVideoDidStartPlayingForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Rewarded video started playing");
}

/// Playback ended
- (void)rewardedVideoDidEndPlayingForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Rewarded video playback ended");
}

/// Clicked
- (void)rewardedVideoDidClickForPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Rewarded video clicked");
}

/// Closed (rewarded indicates whether the reward should be granted)
- (void)rewardedVideoDidCloseForPlacementID:(NSString *)placementID rewarded:(BOOL)rewarded extra:(NSDictionary *)extra {
    NSLog(@"Rewarded video closed rewarded=%d", rewarded);
}

/// Reward granted
- (void)rewardedVideoDidRewardSuccessForPlacemenID:(NSString *)placementID extra:(NSDictionary *)extra {
    NSLog(@"Rewarded video reward granted");
}

/// Show failed
- (void)rewardedVideoDidFailToPlayForPlacementID:(NSString *)placementID error:(NSError *)error extra:(NSDictionary *)extra {
    NSLog(@"Rewarded video show failed: %@", error);
}
```

## Notes

- `placementID` uses the TopOn dashboard placement ID (not the MHGAdSDK posID)
- MHGAdSDK placement IDs are configured in the TopOn dashboard via the `slot_id` ad source parameter
- MHGAdSDK initialization is handled automatically by `MHGATInitAdapter` — no manual registration needed in AppDelegate
- Native ads use MHGAdSDK's `MHGNativeAdView` + `SelfRenderView` for rendering, with `MHGNativePrepareInfo` to bind asset views
- `[MHGNativeAd rendererWithRenderView:nativeADView:]` triggers impression and click tracking
- For C2S Bidding, the adapter passes the price via `ATAdSendC2SBidPriceKey` (NSString) and `ATAdSendC2SCurrencyTypeKey` (`@(ATBiddingCurrencyTypeCNYCents)`)
- Win/loss notifications (`sendWinNotification:` / `sendLossNotification:`) are handled automatically in each adapter's `didReceiveBidResult:` callback
