//
//  Ad2048View.h
//  MHAdSDKDemo
//
//  Created by 郭建恒 on 2025/1/9.
//

#import <UIKit/UIKit.h>
#import <MHGAdSDK/MHGAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface NativeView : UIView

@property (assign, nonatomic) NSInteger index;

@property (strong, nonatomic) UIImageView * iconImageView;
@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) UIButton * adButton;

// 广告
@property (strong, nonatomic) MHGNativeAdView * adView;

@property (strong, nonatomic) UILabel * descriptionLabel;

@property (strong, nonatomic) UIImageView * logoImageView; // 显示广告的小灰色文字
@property (strong, nonatomic) UILabel * adLabel; // 显示广告的小灰色文字

- (instancetype)initWithFrame:(CGRect)frame;
- (void)updateTag:(NSInteger )tag; // 用来更新tag


@end

NS_ASSUME_NONNULL_END
