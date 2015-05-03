//
//  SMMShutdownService.h
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/5/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SMMShutdownServiceConnectionStatus) {
    SMMShutdownServiceConnectionStatusNotConnected,
    SMMShutdownServiceConnectionStatusConnecting,
    SMMShutdownServiceConnectionStatusConnected
};

@interface SMMShutdownService : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) SMMShutdownServiceConnectionStatus connectionStatus;

- (instancetype)initWithService:(NSNetService*)service;

- (BOOL)sendConnectCommand:(NSString*)deviceName onComplete:(void (^)(NSError *))onComplete;
- (BOOL)sendShutdownCommand:(void(^)(NSError *error))onComplete;

@end

