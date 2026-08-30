//
//  MHGATNetworkNativeAd.m
//  MHGAdSDK-AnyThinkAdapter
//

#import "MHGATNetworkNativeAd.h"
#import <MHGAdSDK/MHGNativeAdView.h>
#import <MHGAdSDK/MHGNativeAdModel.h>
#import <MHGAdSDK/MHGNativeAd.h>

@implementation MHGATNetworkNativeAd

- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews
                   withContainer:(UIView *)container
                registerArgument:(nullable ATNativeRegisterArgument *)registerArgument {
    if (!self.mhgNativeAdView) {
        return;
    }
    // 委托 MHGAdSDK 内部注册点击追踪
    [self.mhgNativeAdView registerClickableViewArray:clickableViews];
}

@end
