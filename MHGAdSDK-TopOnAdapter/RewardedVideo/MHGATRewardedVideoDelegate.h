//
//  MHGATRewardedVideoDelegate.h
//  MHGAdSDK-AnyThinkAdapter
//

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <MHGAdSDK/MHGRewardedVideoAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHGATRewardedVideoDelegate : NSObject <MHGRewardedVideoAdDelegete>

@property (nonatomic, strong) ATRewardedAdStatusBridge *adStatusBridge;

@end

NS_ASSUME_NONNULL_END
