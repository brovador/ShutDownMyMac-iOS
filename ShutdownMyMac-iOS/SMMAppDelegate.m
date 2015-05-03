//
//  AppDelegate.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SMMAppDelegate.h"
#import "SMMWatchkitRequestHandler.h"

@interface SMMAppDelegate ()

@property (nonatomic, strong) SMMWatchkitRequestHandler *watchkitRequestsHandler;

@end

@implementation SMMAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply
{
    if (_watchkitRequestsHandler == nil) {
        _watchkitRequestsHandler = [SMMWatchkitRequestHandler new];
    }
    
    [_watchkitRequestsHandler handleWatchkitRequest:userInfo reply:reply];
}

@end
