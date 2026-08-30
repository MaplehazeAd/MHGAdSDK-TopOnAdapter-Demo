//
//  MHGATInterstitialDelegate.m
//  MHGAdSDK-AnyThinkAdapter
//

#import "MHGATInterstitialDelegate.h"

@implementation MHGATInterstitialDelegate

- (void)interstitialAdDidLoad:(MHGInterstitialAd *)interstitialAd
                  placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    NSInteger ecpm = [interstitialAd ecpm];
    NSLog(@"[MHGAT] ecpm=%ld", (long)ecpm);

    NSString *priceStr = [NSString stringWithFormat:@"%ld", (long)ecpm];
    if ([priceStr doubleValue] < 0) { priceStr = @"0"; }

    NSDictionary *extra = @{
        ATAdSendC2SBidPriceKey: priceStr,
        ATAdSendC2SCurrencyTypeKey: @(ATBiddingCurrencyTypeUS)
    };
    [self.adStatusBridge atOnInterstitialAdLoadedExtra:extra];
}

- (void)interstitialAdLoadFailed:(MHGInterstitialAd *)interstitialAd
                     placementID:(NSString *)placementID
                       errorCode:(NSInteger)errorCode
                    errorMessage:(NSString *)errorMessage {
    NSLog(@"[MHGAT] %@ errorCode=%ld msg=%@", NSStringFromSelector(_cmd), (long)errorCode, errorMessage);
    NSError *error = [NSError errorWithDomain:@"MHGInterstitialAd"
                                         code:errorCode
                                     userInfo:@{NSLocalizedDescriptionKey: errorMessage ?: @"unknown"}];
    [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
}

- (void)interstitialAdDidAppear:(MHGInterstitialAd *)interstitialAd
                    placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdShow:nil];
}

- (void)interstitialAdDidDisappear:(MHGInterstitialAd *)interstitialAd
                       placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdClosed:nil];
}

- (void)interstitialAdDidClicked:(MHGInterstitialAd *)interstitialAd
                     placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdClick:nil];
}

@end
