//
//  SDMMWatchKitRequestsManager.h
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/5/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMMWatchKitRequestsManager : NSObject

+ (instancetype)sharedManager;

- (void)requestListDevices:(void(^)(NSArray * devices, NSError *error))onComplete;
- (void)requestConnectDevice:(NSString*)deviceName onComplete:(void(^)(NSError *error))onComplete;
- (void)requestShutdownDevice:(NSString*)deviceName onComplete:(void(^)(NSError *error))onComplete;

- (void)handleWatchkitRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *info))reply;

@end
