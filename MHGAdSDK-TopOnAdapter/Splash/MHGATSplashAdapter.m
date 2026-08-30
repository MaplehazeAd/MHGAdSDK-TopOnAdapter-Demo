//
//  MHGATSplashAdapter.m
//  MHGAdSDK-AnyThinkAdapter
//

#import "MHGATSplashAdapter.h"
#import "MHGATSplashDelegate.h"
#import <MHGAdSDK/MHGSplashAd.h>

@interface MHGATSplashAdapter ()

@property (nonatomic, strong) MHGATSplashDelegate *splashDelegate;
@property (nonatomic, strong) MHGSplashAd *splashAd;

@end

@implementation MHGATSplashAdapter

@synthesize adStatusBridge = _adStatusBridge;

- (MHGATSplashDelegate *)splashDelegate {
    if (!_splashDelegate) {
        _splashDelegate = [[MHGATSplashDelegate alloc] init];
        _splashDelegate.adStatusBridge = self.adStatusBridge;
    }
    return _splashDelegate;
}

- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    NSDictionary *serverContentDic = argument.serverContentDic;
    NSString *placementID = serverContentDic[@"slot_id"];
    if (!placementID.length) {
        placementID = serverContentDic[@"placement_id"];
    }

    self.splashAd = [[MHGSplashAd alloc] initWithPlacementID:placementID];
    self.splashAd.delegate = self.splashDelegate;

    CGSize adSize = argument.nativeSize;
    if (adSize.width * adSize.height == 0) {
        adSize = [UIScreen mainScreen].bounds.size;
    }
    self.splashAd.viewSize = adSize;

    [self.splashAd loadAd];
}

- (void)showSplashAdInWindow:(UIWindow *)window
            inViewController:(UIViewController *)inViewController
                   parameter:(NSDictionary *)parameter {
    [self.splashAd showInWindow:window withBottomView:nil skipView:nil];
}

- (BOOL)adReadySplashWithInfo:(NSDictionary *)info {
    return self.splashAd != nil;
}

- (void)didReceiveBidResult:(ATBidWinLossResult *)result {
    if (result.bidResultType == ATBidWinLossResultTypeWin && self.splashAd) {
        NSInteger price = result.winPrice ? [result.winPrice integerValue] : 0;
        [self.splashAd sendWinNotification:price];
    } else if (self.splashAd) {
        NSInteger price = result.secondPrice ? [result.secondPrice integerValue] : 0;
        [self.splashAd sendLossNotification:price];
    }
}

@end
