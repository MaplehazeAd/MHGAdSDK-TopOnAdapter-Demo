//
//  MHGATInterstitialDelegate.h
//  MHGAdSDK-AnyThinkAdapter
//

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <MHGAdSDK/MHGInterstitialAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHGATInterstitialDelegate : NSObject <MHGInterstitialAdDelegete>

@property (nonatomic, strong) ATInterstitialAdStatusBridge *adStatusBridge;

@end

NS_ASSUME_NONNULL_END
