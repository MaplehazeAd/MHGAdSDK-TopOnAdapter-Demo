//
//  MHGATNativeDelegate.m
//  MHGAdSDK-AnyThinkAdapter
//

#import "MHGATNativeDelegate.h"
#import "MHGATNetworkNativeAd.h"
#import "MHGATNativeCouponModel.h"
#import <MHGAdSDK/MHGNativeAdModel.h>
#import <MHGAdSDK/MHGNativeAdView.h>
#import <MHGAdSDK/MHGNativeAdCouponModel.h>

static MHGNativeAd *_lastNativeAd = nil;
static NSArray<MHGATNetworkNativeAd *> *_lastNativeAds = nil;
static NSArray<MHGNativeAdModel *> *_lastModels = nil;

@implementation MHGATNativeDelegate

+ (nullable MHGNativeAd *)lastLoadedNativeAd {
    return _lastNativeAd;
}

+ (nullable NSArray<MHGATNetworkNativeAd *> *)lastLoadedNativeAds {
    return _lastNativeAds;
}

+ (nullable NSArray<MHGNativeAdModel *> *)lastLoadedModels {
    return _lastModels;
}

+ (BOOL)hasLoadedAds {
    return _lastNativeAds.count > 0;
}

+ (void)clearCache {
    _lastNativeAd = nil;
    _lastNativeAds = nil;
    _lastModels = nil;
}

#pragma mark - MHGNativeAdDelegete

- (void)nativeAdDidLoad:(MHGNativeAd *)nativeAd
            placementID:(NSString *)placementID
         nativeAdModels:(NSArray<MHGNativeAdModel *> *)nativeAdModels {
    NSLog(@"[MHGAT] %@ count=%lu", NSStringFromSelector(_cmd), (unsigned long)nativeAdModels.count);

    if (nativeAdModels.count == 0) {
        NSError *error = [NSError errorWithDomain:@"MHGNativeAd"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey: @"No fill"}];
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        return;
    }

    // Store MHGNativeAd reference + models (sideband pattern)
    _lastNativeAd = nativeAd;
    _lastModels = [nativeAdModels copy];

    // Convert MHGNativeAdModel to MHGATNetworkNativeAd
    NSMutableArray<MHGATNetworkNativeAd *> *nativeAdArray = [NSMutableArray arrayWithCapacity:nativeAdModels.count];
    for (MHGNativeAdModel *model in nativeAdModels) {
        MHGATNetworkNativeAd *nativeAdObj = [[MHGATNetworkNativeAd alloc] init];

        // Basic property mapping
        nativeAdObj.title = model.title ?: @"";
        nativeAdObj.mainText = model.description ?: @"";
        nativeAdObj.ctaText = model.actionText ?: @"Learn More";
        nativeAdObj.iconUrl = model.iconURL ?: @"";
        nativeAdObj.imageUrl = model.imageURL ?: @"";
        nativeAdObj.mainImageWidth = (CGFloat)model.imageWidth;
        nativeAdObj.mainImageHeight = (CGFloat)model.imageHeight;
        nativeAdObj.isVideoContents = model.isVideoAd;

        // Create MHGNativeAdView and bind data
        MHGNativeAdView *adView = [[MHGNativeAdView alloc] init];
        adView.nativeAdModel = model;
        nativeAdObj.mhgNativeAdView = adView;

        // Keep original model reference
        nativeAdObj.mhgNativeAdModel = model;

        // Strong reference to MHGNativeAd to keep adapter->viewCreator chain alive (weak ref issue)
        nativeAdObj.mhgNativeAd = nativeAd;

        // Coupon model conversion
        MHGNativeAdCouponModel *mhgCoupon = model.coupon;
        if (mhgCoupon) {
            MHGATNativeCouponModel *coupon = [[MHGATNativeCouponModel alloc] init];
            coupon.couponType = mhgCoupon.couponType;
            coupon.couponValue = mhgCoupon.couponValue;
            coupon.couponThreshold = mhgCoupon.couponThreshold;
            coupon.couponTime = mhgCoupon.couponTime;
            coupon.couponSource = mhgCoupon.couponSource;
            coupon.couponDisclaimer = mhgCoupon.couponDisclaimer;
            coupon.couponDescription = mhgCoupon.couponDescription;
            nativeAdObj.coupon = coupon;
        }

        // Store original model in networkNativeAdProduct (sideband compat)
        nativeAdObj.networkNativeAdProduct = model;

        [nativeAdArray addObject:nativeAdObj];
    }

    // Report each model's eCPM to TopOn individually
    for (NSUInteger i = 0; i < nativeAdModels.count; i++) {
        MHGNativeAdModel *model = nativeAdModels[i];
        MHGATNetworkNativeAd *nativeAdObj = nativeAdArray[i];

        NSString *ecpm = [model ecpm];
        if ([ecpm doubleValue] <= 0) {
            ecpm = @"0";
        }

        NSDictionary *adExtra = @{
            ATAdSendC2SBidPriceKey: ecpm,
            ATAdSendC2SCurrencyTypeKey: @(ATBiddingCurrencyTypeCNYCents),
            ATAdSendC2SBidInfoKey: @{@"modelIndex": @(i)}
        };
        NSLog(@"[MHGAT] report model[%lu] ecpm=%@ isVideo=%d", (unsigned long)i, ecpm, model.isVideoAd);
        [self.adStatusBridge atOnNativeAdLoadedArray:@[nativeAdObj] adExtra:adExtra];
    }
}

- (void)nativeAdLoadFailed:(MHGNativeAd *)nativeAd
               placementID:(NSString *)placementID
                 errorCode:(NSInteger)errorCode
              errorMessage:(NSString *)errorMessage {
    NSLog(@"[MHGAT] %@ errorCode=%ld msg=%@", NSStringFromSelector(_cmd), (long)errorCode, errorMessage);
    NSError *error = [NSError errorWithDomain:@"MHGNativeAd"
                                         code:errorCode
                                     userInfo:@{NSLocalizedDescriptionKey: errorMessage ?: @"unknown"}];
    [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
}

- (void)nativeAdDidAppear:(MHGNativeAd *)nativeAd
              placementID:(NSString *)placementID
                   adView:(MHGNativeAdView *)adView
            nativeAdModel:(MHGNativeAdModel *)nativeAdModel {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdShow:nil];
}

- (void)nativeAdDidClick:(MHGNativeAd *)nativeAd
             placementID:(NSString *)placementID
                  adView:(MHGNativeAdView *)adView
           nativeAdModel:(MHGNativeAdModel *)nativeAdModel {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdClick:nil];
}

- (void)nativeAdPlayStart:(MHGNativeAd *)nativeAd
              placementID:(NSString *)placementID
                   adView:(MHGNativeAdView *)adView
            nativeAdModel:(MHGNativeAdModel *)nativeAdModel {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdVideoStart:nil];
}

- (void)nativeAdPlayFinish:(MHGNativeAd *)nativeAd
               placementID:(NSString *)placementID
                    adView:(MHGNativeAdView *)adView
             nativeAdModel:(MHGNativeAdModel *)nativeAdModel {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdVideoEnd:nil];
}

- (void)nativeAdDetailViewDidAppear:(MHGNativeAd *)nativeAd
                        placementID:(NSString *)placementID
                             adView:(MHGNativeAdView *)adView
                      nativeAdModel:(MHGNativeAdModel *)nativeAdModel {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdDetailWillShow:nil];
}

- (void)nativeAdDetailViewDidClose:(MHGNativeAd *)nativeAd
                       placementID:(NSString *)placementID
                            adView:(MHGNativeAdView *)adView
                     nativeAdModel:(MHGNativeAdModel *)nativeAdModel {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdDetailClosed:nil];
}

@end
