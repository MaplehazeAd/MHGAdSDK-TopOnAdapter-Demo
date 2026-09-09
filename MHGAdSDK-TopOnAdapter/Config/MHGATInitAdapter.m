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

    // Personalized ads
    config.personalizedState = adInitArgument.personalizedAdState;

    // Register with MHGAdSDK
    [[MHGAdManager sharedManager] registerApp];

    // MHGAdSDK has no explicit init success/failure callback, notify success directly
    [self notificationNetworkInitSuccess];
}

+ (nullable NSString *)sdkVersion {
    return [[MHGAdManager sharedManager] version];
}

+ (nullable NSString *)adapterVersion {
    return kMHGATAdapterVersion;
}

@end
