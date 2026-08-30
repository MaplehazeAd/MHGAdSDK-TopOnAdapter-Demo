//
//  MHGATRewardedVideoAdapter.m
//  MHGAdSDK-AnyThinkAdapter
//

#import "MHGATRewardedVideoAdapter.h"
#import "MHGATRewardedVideoDelegate.h"
#import <MHGAdSDK/MHGRewardedVideoAd.h>

@interface MHGATRewardedVideoAdapter ()

@property (nonatomic, strong) MHGATRewardedVideoDelegate *rvDelegate;
@property (nonatomic, strong) MHGRewardedVideoAd *rewardedVideoAd;

@end

@implementation MHGATRewardedVideoAdapter

@synthesize adStatusBridge = _adStatusBridge;

- (MHGATRewardedVideoDelegate *)rvDelegate {
    if (!_rvDelegate) {
        _rvDelegate = [[MHGATRewardedVideoDelegate alloc] init];
        _rvDelegate.adStatusBridge = self.adStatusBridge;
    }
    return _rvDelegate;
}

- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    NSDictionary *serverContentDic = argument.serverContentDic;
    NSString *placementID = serverContentDic[@"slot_id"];
    if (!placementID.length) {
        placementID = serverContentDic[@"placement_id"];
    }

    self.rewardedVideoAd = [[MHGRewardedVideoAd alloc] initWithPlacementID:placementID];
    self.rewardedVideoAd.delegate = self.rvDelegate;

    // 静音配置
    NSString *muteStr = argument.localInfoDic[@"MHIsMuted"];
    if (muteStr) {
        self.rewardedVideoAd.isMuted = [muteStr boolValue];
    } else {
        self.rewardedVideoAd.isMuted = YES;
    }

    [self.rewardedVideoAd loadAd];
}

- (void)showRewardedVideoInViewController:(UIViewController *)viewController {
    [self.rewardedVideoAd showAdFromRootViewController:viewController];
}

- (BOOL)adReadyRewardedWithInfo:(NSDictionary *)info {
    return self.rewardedVideoAd != nil;
}

- (void)didReceiveBidResult:(ATBidWinLossResult *)result {
    if (result.bidResultType == ATBidWinLossResultTypeWin && self.rewardedVideoAd) {
        NSInteger price = result.winPrice ? [result.winPrice integerValue] : 0;
        [self.rewardedVideoAd sendWinNotification:price];
    } else if (self.rewardedVideoAd) {
        NSInteger price = result.secondPrice ? [result.secondPrice integerValue] : 0;
        [self.rewardedVideoAd sendLossNotification:price];
    }
}

@end
