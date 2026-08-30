//
//  MHGATBaseAdapter.m
//  MHGAdSDK-AnyThinkAdapter
//

#import "MHGATBaseAdapter.h"
#import "MHGATInitAdapter.h"

@implementation MHGATBaseAdapter

- (Class)initializeClassName {
    return [MHGATInitAdapter class];
}

@end
