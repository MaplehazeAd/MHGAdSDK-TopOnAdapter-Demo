//
//  MHGATRewardedVideoDelegate.m
//  MHGAdSDK-AnyThinkAdapter
//

#import "MHGATRewardedVideoDelegate.h"

@implementation MHGATRewardedVideoDelegate

- (void)rewardedVideoAdVideoDidLoad:(MHGRewardedVideoAd *)rewardedVideoAd
                        placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    NSInteger ecpm = [rewardedVideoAd ecpm];
    NSLog(@"[MHGAT] ecpm=%ld", (long)ecpm);

    NSString *priceStr = [NSString stringWithFormat:@"%ld", (long)ecpm];
    if ([priceStr doubleValue] < 0) { priceStr = @"0"; }

    NSDictionary *extra = @{
        ATAdSendC2SBidPriceKey: priceStr,
        ATAdSendC2SCurrencyTypeKey: @(ATBiddingCurrencyTypeCNYCents)
    };
    [self.adStatusBridge atOnRewardedAdLoadedExtra:extra];
}

- (void)rewardedVideoAdVideoLoadFailed:(MHGRewardedVideoAd *)rewardedVideoAd
                           placementID:(NSString *)placementID
                             errorCode:(NSInteger)errorCode
                          errorMessage:(NSString *)errorMessage {
    NSLog(@"[MHGAT] %@ errorCode=%ld msg=%@", NSStringFromSelector(_cmd), (long)errorCode, errorMessage);
    NSError *error = [NSError errorWithDomain:@"MHGRewardedVideoAd"
                                         code:errorCode
                                     userInfo:@{NSLocalizedDescriptionKey: errorMessage ?: @"unknown"}];
    [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
}

- (void)rewardedVideoAdWillAppear:(MHGRewardedVideoAd *)rewardedVideoAd
                      placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
}

- (void)rewardedVideoAdDidAppear:(MHGRewardedVideoAd *)rewardedVideoAd
                     placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdShow:nil];
}

- (void)rewardedVideoAdDidDisappear:(MHGRewardedVideoAd *)rewardedVideoAd
                        placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdClosed:nil];
}

- (void)rewardedVideoAdDidClicked:(MHGRewardedVideoAd *)rewardedVideoAd
                      placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdClick:nil];
}

- (void)rewardedVideoAdVideoDidRewarded:(MHGRewardedVideoAd *)rewardedVideoAd
                                 result:(BOOL)success
                            placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@ success=%d", NSStringFromSelector(_cmd), success);
    if (success) {
        [self.adStatusBridge atOnRewardedVideoAdRewarded];
    }
}

- (void)rewardedVideoAdVideoDidFinished:(MHGRewardedVideoAd *)rewardedVideoAd
                            placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdVideoEnd:nil];
}

@end
