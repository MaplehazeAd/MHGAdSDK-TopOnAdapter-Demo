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

/// 最近一次加载的 MHGNativeAd 对象（用于 rendererWithRenderView 等）
+ (nullable MHGNativeAd *)lastLoadedNativeAd;

/// 最近一次加载的广告数组（adapter 层 wrapper）
+ (nullable NSArray<MHGATNetworkNativeAd *> *)lastLoadedNativeAds;

/// 最近一次加载的 MHGNativeAdModel 数组（供 Demo VC 直接渲染）
+ (nullable NSArray<MHGNativeAdModel *> *)lastLoadedModels;

/// 是否有已加载的广告
+ (BOOL)hasLoadedAds;

/// 清空缓存
+ (void)clearCache;

@end

NS_ASSUME_NONNULL_END
