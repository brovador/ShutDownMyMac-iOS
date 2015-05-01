//
//  SDMMWatchKitRequestsManager.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/5/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SMMClientServiceManager.h"
#import "SMMWatchKitRequestsManager.h"

static SMMWatchKitRequestsManager *instance;

@interface SMMWatchKitRequestsManager ()<SMMClientServiceManagerDelegate>

@property (nonatomic, strong) void(^listDevicesCallback)(NSDictionary*);

@end

@implementation SMMWatchKitRequestsManager

+ (id)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SMMWatchKitRequestsManager new];
    });
    return instance;
}


- (void)handleWatchkitRequest:(NSDictionary *)userInfo onComplete:(void (^)(NSDictionary *))onComplete
{
    NSLog(@"HANDLE REQUEST");
    SMMWatchkitRequestType requestType = [userInfo[@"requestType"] intValue];
    if (requestType == SMMWatchKitRequestsTypeListDevices) {
        [self _handleListDevicesRequest:userInfo onComplete:onComplete];
    } else if (requestType == SMMWatchKitRequestsTypeShutdownDevice) {
        //TODO..
    }
}


#pragma mark Private

- (void)_handleListDevicesRequest:(NSDictionary*)userInfo onComplete:(void (^)(NSDictionary *))onComplete
{
    self.listDevicesCallback = onComplete;
    
    [[SMMClientServiceManager sharedServiceManager] setDelegate:self];
    [[SMMClientServiceManager sharedServiceManager] searchServices];
}

#pragma mark SMMClientServiceManagerDelegate

- (void)clientServiceManagerDidFindServices:(NSArray *)shutdownServices
{
    [[SMMClientServiceManager sharedServiceManager] stopSearch];
    
    NSMutableArray *services = [NSMutableArray new];
    for (NSNetService *service in shutdownServices) {
        [services addObject:service.name];
    }
    
    void(^listDevicesCallback)(NSDictionary*) = self.listDevicesCallback;
    listDevicesCallback(@{@"services" : services});
    
    self.listDevicesCallback = nil;
}

@end
