//
//  SDMMWatchKitRequestsManager.h
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/5/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SMMWatchkitRequestType) {
    SMMWatchKitRequestsTypeListDevices,
    SMMWatchKitRequestsTypeShutdownDevice
};

@interface SMMWatchKitRequestsManager : NSObject

+ (instancetype)sharedManager;

- (void)handleWatchkitRequest:(NSDictionary*)userInfo onComplete:(void (^)(NSDictionary *))onComplete;

@end
