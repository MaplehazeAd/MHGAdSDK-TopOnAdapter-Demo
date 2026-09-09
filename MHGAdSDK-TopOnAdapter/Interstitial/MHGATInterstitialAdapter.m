//
//  MHGATInterstitialAdapter.m
//  MHGAdSDK-AnyThinkAdapter
//

#import "MHGATInterstitialAdapter.h"
#import "MHGATInterstitialDelegate.h"
#import <MHGAdSDK/MHGInterstitialAd.h>

@interface MHGATInterstitialAdapter ()

@property (nonatomic, strong) MHGATInterstitialDelegate *interstitialDelegate;
@property (nonatomic, strong) MHGInterstitialAd *interstitialAd;

@end

@implementation MHGATInterstitialAdapter

@synthesize adStatusBridge = _adStatusBridge;

- (MHGATInterstitialDelegate *)interstitialDelegate {
    if (!_interstitialDelegate) {
        _interstitialDelegate = [[MHGATInterstitialDelegate alloc] init];
        _interstitialDelegate.adStatusBridge = self.adStatusBridge;
    }
    return _interstitialDelegate;
}

- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    NSDictionary *serverContentDic = argument.serverContentDic;
    NSString *placementID = serverContentDic[@"slot_id"];
    if (!placementID.length) {
        placementID = serverContentDic[@"placement_id"];
    }

    self.interstitialAd = [[MHGInterstitialAd alloc] initWithPlacementID:placementID];
    self.interstitialAd.delegate = self.interstitialDelegate;

    // Muted config
    NSString *muteStr = argument.localInfoDic[@"MHIsMuted"];
    if (muteStr) {
        self.interstitialAd.videoMuted = [muteStr boolValue];
    } else {
        self.interstitialAd.videoMuted = YES;
    }

    [self.interstitialAd loadAd];
}

- (void)showInterstitialInViewController:(UIViewController *)viewController {
    [self.interstitialAd presentFromRootViewController:viewController];
}

- (BOOL)adReadyInterstitialWithInfo:(NSDictionary *)info {
    return self.interstitialAd != nil;
}

- (void)didReceiveBidResult:(ATBidWinLossResult *)result {
    if (result.bidResultType == ATBidWinLossResultTypeWin && self.interstitialAd) {
        NSString * price = result.winPrice;
        [self.interstitialAd sendWinNotification:price];
    } else if (self.interstitialAd) {
        NSString * price = result.secondPrice;
        [self.interstitialAd sendLossNotification:price];
    }
}

@end
