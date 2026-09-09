//
//  MHGATNativeDelegate.h
//  MHGAdSDK-AnyThinkAdapter
//

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <MHGAdSDK/MHGNativeAd.h>

@class MHGATNetworkNativeAd;

NS_ASSUME_NONNULL_BEGIN

@interface MHGATNativeDelegate : NSObject <MHGNativeAdDelegete>

@property (nonatomic, strong) ATNativeAdStatusBridge *adStatusBridge;

/// Last loaded MHGNativeAd object (for rendererWithRenderView, etc.)
+ (nullable MHGNativeAd *)lastLoadedNativeAd;

/// Last loaded native ad array (adapter-layer wrappers)
+ (nullable NSArray<MHGATNetworkNativeAd *> *)lastLoadedNativeAds;

/// Last loaded MHGNativeAdModel array (for Demo VC direct rendering)
+ (nullable NSArray<MHGNativeAdModel *> *)lastLoadedModels;

/// Whether ads have been loaded
+ (BOOL)hasLoadedAds;

/// Clear cache
+ (void)clearCache;

@end

NS_ASSUME_NONNULL_END
