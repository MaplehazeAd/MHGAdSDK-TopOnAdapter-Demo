//
//  MHGATNativeAdapter.m
//  MHGAdSDK-AnyThinkAdapter
//

#import "MHGATNativeAdapter.h"
#import "MHGATNativeDelegate.h"
#import <MHGAdSDK/MHGNativeAd.h>

@interface MHGATNativeAdapter ()

@property (nonatomic, strong) MHGATNativeDelegate *nativeDelegate;
@property (nonatomic, strong) MHGNativeAd *nativeAd;

@end

@implementation MHGATNativeAdapter

@synthesize adStatusBridge = _adStatusBridge;

- (MHGATNativeDelegate *)nativeDelegate {
    if (!_nativeDelegate) {
        _nativeDelegate = [[MHGATNativeDelegate alloc] init];
        _nativeDelegate.adStatusBridge = self.adStatusBridge;
    }
    return _nativeDelegate;
}

- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    NSDictionary *serverContentDic = argument.serverContentDic;
    NSString *placementID = serverContentDic[@"slot_id"];
    if (!placementID.length) {
        placementID = serverContentDic[@"placement_id"];
    }

    // 创建 Configuration
    MHGNativeAdConfiguration *configuration = [[MHGNativeAdConfiguration alloc] init];
    configuration.placementID = placementID;

    // 静音配置
    NSString *muteStr = argument.localInfoDic[@"MHIsMuted"];
    if (muteStr) {
        configuration.isMuted = [muteStr boolValue];
    } else {
        configuration.isMuted = YES;
    }

    // 自动播放配置
    NSString *autoPlayStr = argument.localInfoDic[@"MHAutoPlayMobileNetwork"];
    if (autoPlayStr) {
        configuration.isVideoAutoPlayWithMobileNetwork = [autoPlayStr boolValue];
    } else {
        configuration.isVideoAutoPlayWithMobileNetwork = NO;
    }

    self.nativeAd = [[MHGNativeAd alloc] initWithConfiguration:configuration];
    self.nativeAd.delegate = self.nativeDelegate;

    [self.nativeAd loadAd];
}

@end
