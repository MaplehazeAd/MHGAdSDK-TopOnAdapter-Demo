//
//  MHGATInitAdapter.m
//  MHGAdSDK-AnyThinkAdapter
//

#import "MHGATInitAdapter.h"
#import <MHGAdSDK/MHGAdSDK.h>

static NSString *const kMHGATAdapterVersion = @"1.0.0";

@implementation MHGATInitAdapter

- (void)initWithInitArgument:(ATAdInitArgument *)adInitArgument {
    NSDictionary *serverInfo = adInitArgument.serverContentDic;

    NSString *appID = serverInfo[@"appID"];
    if (!appID.length) {
        appID = serverInfo[@"app_id"];
    }

    MHGAdConfiguration *config = [MHGAdConfiguration sharedConfig];
    if (appID.length) {
        config.appID = appID;
    }

    // 个性化推荐
    config.personalizedState = adInitArgument.personalizedAdState;

    // 执行 MHGAdSDK 注册
    [[MHGAdManager sharedManager] registerApp];

    // MHGAdSDK 没有明确的初始化成功/失败回调，直接通知成功
    [self notificationNetworkInitSuccess];
}

+ (nullable NSString *)sdkVersion {
    return [[MHGAdManager sharedManager] version];
}

+ (nullable NSString *)adapterVersion {
    return kMHGATAdapterVersion;
}

@end
