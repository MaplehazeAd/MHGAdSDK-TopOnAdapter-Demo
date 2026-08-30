//
//  MHGATSplashDelegate.m
//  MHGAdSDK-AnyThinkAdapter
//

#import "MHGATSplashDelegate.h"

@implementation MHGATSplashDelegate

- (void)splashAdDidLoad:(MHGSplashAd *)splashAd placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    NSInteger ecpm = [splashAd ecpm];
    NSLog(@"[MHGAT] ecpm=%ld", (long)ecpm);

    NSString *priceStr = [NSString stringWithFormat:@"%ld", (long)ecpm];
    if ([priceStr doubleValue] < 0) { priceStr = @"0"; }

    NSDictionary *extra = @{
        ATAdSendC2SBidPriceKey: priceStr,
        ATAdSendC2SCurrencyTypeKey: @(ATBiddingCurrencyTypeCNYCents)
    };
    [self.adStatusBridge atOnSplashAdLoadedExtra:extra];
}

- (void)splashAdLoadFailed:(MHGSplashAd *)splashAd
                 errorCode:(NSInteger)errorCode
              errorMessage:(NSString *)errorMessage {
    NSLog(@"[MHGAT] %@ errorCode=%ld msg=%@", NSStringFromSelector(_cmd), (long)errorCode, errorMessage);
    NSError *error = [NSError errorWithDomain:@"MHGSplashAd"
                                         code:errorCode
                                     userInfo:@{NSLocalizedDescriptionKey: errorMessage ?: @"unknown"}];
    [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
}

- (void)splashAdDidAppear:(MHGSplashAd *)splashAd placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdShow:nil];
}

- (void)splashAdDidClicked:(MHGSplashAd *)splashAd placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdClick:nil];
}

- (void)splashAdDidDisappear:(MHGSplashAd *)splashAd placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
    [self.adStatusBridge atOnAdClosed:nil];
}

- (void)splashAdDidPresentFullScreen:(MHGSplashAd *)splashAd placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
}

- (void)splashAdDidDismissFullScreen:(MHGSplashAd *)splashAd placementID:(NSString *)placementID {
    NSLog(@"[MHGAT] %@", NSStringFromSelector(_cmd));
}

@end
