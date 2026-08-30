//
//  MHGATNetworkNativeAd.h
//  MHGAdSDK-AnyThinkAdapter
//

#import <AnyThinkSDK/AnyThinkSDK.h>

@class MHGNativeAdModel;
@class MHGNativeAdView;
@class MHGNativeAd;
@class MHGATNativeCouponModel;

NS_ASSUME_NONNULL_BEGIN

/// Bridge class between TopOn and MHGAdSDK native ads.
/// Wraps MHGNativeAdModel + MHGNativeAdView, exposes adapter-layer properties.
@interface MHGATNetworkNativeAd : ATCustomNetworkNativeAd

/// MHGAdSDK native ad model (data)
@property (nonatomic, strong) MHGNativeAdModel *mhgNativeAdModel;

/// MHGAdSDK native ad object (strong ref to keep adapter chain alive)
@property (nonatomic, strong) MHGNativeAd *mhgNativeAd;

/// Pre-created native ad view (for rendering & click registration)
@property (nonatomic, strong) MHGNativeAdView *mhgNativeAdView;

/// Adapter-layer coupon model
@property (nonatomic, strong, nullable) MHGATNativeCouponModel *coupon;

@end

NS_ASSUME_NONNULL_END
