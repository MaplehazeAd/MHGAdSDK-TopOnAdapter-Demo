//
//  MHNativeRenderAdDisplayViewController.h
//  MHGAdSDKDemo
//
//  Created by Jianheng on 2026/1/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHNativeRenderAdDisplayViewController : UIViewController

@property (nonatomic, assign) BOOL isMuted;
@property (nonatomic, assign) BOOL isAutoPlayMobileNetwork;
@property (nonatomic, copy) NSString *placementID;

@end

NS_ASSUME_NONNULL_END
