//
//  MHNativeListAdCell.h
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2025/5/20.
//

#import <UIKit/UIKit.h>
#import "NativeModel.h"
#import <MHGAdSDK/MHGAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHNativeListAdCell : UITableViewCell

@property (nonatomic, strong) MHGNativeAd *nativeAd;

- (void)setCell:(MHGNativeAdModel *)nativeAdModel;


@end

NS_ASSUME_NONNULL_END
