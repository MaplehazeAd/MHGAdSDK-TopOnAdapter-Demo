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

    // 存储 MHGNativeAd 引用 + models（sideband 模式）
    _lastNativeAd = nativeAd;
    _lastModels = [nativeAdModels copy];

    // 将 MHGNativeAdModel 转换为 MHGATNetworkNativeAd
    NSMutableArray<MHGATNetworkNativeAd *> *nativeAdArray = [NSMutableArray arrayWithCapacity:nativeAdModels.count];
    for (MHGNativeAdModel *model in nativeAdModels) {
        MHGATNetworkNativeAd *nativeAdObj = [[MHGATNetworkNativeAd alloc] init];

        // 基础属性映射
        nativeAdObj.title = model.title ?: @"";
        nativeAdObj.mainText = model.description ?: @"";
        nativeAdObj.ctaText = model.actionText ?: @"查看详情";
        nativeAdObj.iconUrl = model.iconURL ?: @"";
        nativeAdObj.imageUrl = model.imageURL ?: @"";
        nativeAdObj.mainImageWidth = (CGFloat)model.imageWidth;
        nativeAdObj.mainImageHeight = (CGFloat)model.imageHeight;
        nativeAdObj.isVideoContents = model.isVideoAd;

        // 创建 MHGNativeAdView 并绑定数据
        MHGNativeAdView *adView = [[MHGNativeAdView alloc] init];
        adView.nativeAdModel = model;
        nativeAdObj.mhgNativeAdView = adView;

        // 保存原始 model 引用
        nativeAdObj.mhgNativeAdModel = model;

        // 强引用 MHGNativeAd，保持 adapter→viewCreator 链路存活（weak 引用问题）
        nativeAdObj.mhgNativeAd = nativeAd;

        // 优惠券模型转换
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

        // 保存原始 model 到 networkNativeAdProduct（兼容 sideband）
        nativeAdObj.networkNativeAdProduct = model;

        [nativeAdArray addObject:nativeAdObj];
    }

    _lastNativeAds = [nativeAdArray copy];

    // 逐个上报 eCPM
    for (NSUInteger i = 0; i < nativeAdModels.count; i++) {
        MHGNativeAdModel *model = nativeAdModels[i];
        MHGATNetworkNativeAd *nativeAdObj = nativeAdArray[i];

        NSInteger ecpm = model.ecpm;
        NSString *priceStr = [NSString stringWithFormat:@"%ld", (long)ecpm];
        if ([priceStr doubleValue] < 0) { priceStr = @"0"; }

        NSDictionary *adExtra = @{
            ATAdSendC2SBidPriceKey: priceStr,
            ATAdSendC2SCurrencyTypeKey: @(ATBiddingCurrencyTypeCNYCents)
        };
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
