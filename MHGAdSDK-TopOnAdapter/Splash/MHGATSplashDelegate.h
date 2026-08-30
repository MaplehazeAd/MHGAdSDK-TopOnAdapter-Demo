//
//  MHGATSplashDelegate.h
//  MHGAdSDK-AnyThinkAdapter
//

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <MHGAdSDK/MHGSplashAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHGATSplashDelegate : NSObject <MHGSplashAdDelegete>

@property (nonatomic, strong) ATSplashAdStatusBridge *adStatusBridge;

@end

NS_ASSUME_NONNULL_END
