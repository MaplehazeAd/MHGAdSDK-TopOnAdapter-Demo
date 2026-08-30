//
//  MHGATNativeCouponModel.h
//  MHGAdSDK-AnyThinkAdapter
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Adapter-layer coupon model mirroring MHGNativeAdCouponModel
@interface MHGATNativeCouponModel : NSObject

/// Coupon Type: 1 = Spend-Based Discount
@property (nonatomic, assign) NSInteger couponType;

/// Coupon Discount Amount (Unit: Cents)
@property (nonatomic, assign) NSInteger couponValue;

/// Coupon Minimum Spend Threshold (Unit: Cents)
@property (nonatomic, assign) NSInteger couponThreshold;

/// Coupon Validity Period (Unit: Minutes)
@property (nonatomic, assign) NSInteger couponTime;

/// Coupon source
@property (nonatomic, copy, nullable) NSString *couponSource;

/// Coupon disclaimer
@property (nonatomic, copy, nullable) NSString *couponDisclaimer;

/// Coupon description
@property (nonatomic, copy, nullable) NSString *couponDescription;

@end

NS_ASSUME_NONNULL_END
