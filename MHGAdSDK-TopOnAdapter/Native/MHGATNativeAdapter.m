//
//  MHGATNativeAdapter.m
//  MHGAdSDK-AnyThinkAdapter
//

#import "MHGATNativeAdapter.h"
#import "MHGATNativeDelegate.h"
#import <MHGAdSDK/MHGNativeAd.h>
#import <MHGAdSDK/MHGNativeAdModel.h>

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

    // Create configuration
    MHGNativeAdConfiguration *configuration = [[MHGNativeAdConfiguration alloc] init];
    configuration.placementID = placementID;

    // Muted config
    NSString *muteStr = argument.localInfoDic[@"MHIsMuted"];
    if (muteStr) {
        configuration.isMuted = [muteStr boolValue];
    } else {
        configuration.isMuted = YES;
    }

    // Auto-play config
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

- (void)didReceiveBidResult:(ATBidWinLossResult *)result {
    NSLog(@"[MHGAT] didReceiveBidResult type=%ld winPrice=%@ secondPrice=%@ lossReason=%ld userInfoDic=%@",
          (long)result.bidResultType, result.winPrice, result.secondPrice,
          (long)result.lossReasonType, result.userInfoDic);

    // Only use firstObject — native ads only serve one ad by default
    MHGNativeAdModel *model = [MHGATNativeDelegate lastLoadedModels].firstObject;
    if (!model) {
        return;
    }

    if (result.bidResultType == ATBidWinLossResultTypeWin) {
        [model sendWinNotification:result.winPrice];
    } else {
        [model sendLossNotification:result.secondPrice];
    }
}

@end
