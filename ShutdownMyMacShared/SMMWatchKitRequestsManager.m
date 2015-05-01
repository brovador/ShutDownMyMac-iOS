//
//  SDMMWatchKitRequestsManager.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/5/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//
#import <WatchKit/WatchKit.h>

#import "SMMClientServiceManager.h"
#import "SMMWatchKitRequestsManager.h"

static NSString *const SMMWatchkitRequestTypeKey = @"request";
static NSString *const SMMWatchkitRequestDeviceNameKey = @"device";

static NSString *const SMMWatchkitReplyDevices = @"devices";

static SMMWatchKitRequestsManager *instance;

typedef NS_ENUM(NSInteger, SMMWatchkitRequestType) {
    SMMWatchkitRequestTypeListDevices,
    SMMWatchkitRequestTypeConnectToDevice,
    SMMWatchkitRequestTypeShutdownDevice
};

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


- (void)requestListDevices:(void(^)(NSArray * devices, NSError *error))onComplete
{
    NSDictionary *userInfo = @{
                               SMMWatchkitRequestTypeKey : @(SMMWatchkitRequestTypeListDevices)
                               };
    [WKInterfaceController openParentApplication:userInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        NSArray *devices;
        if (error == nil) {
            devices = replyInfo[SMMWatchkitReplyDevices];
        }
        onComplete(devices, error);
    }];
}


- (void)requestConnectDevice:(NSString*)deviceName onComplete:(void(^)(NSError *error))onComplete
{
    NSDictionary *userInfo = @{
                               SMMWatchkitRequestTypeKey : @(SMMWatchkitRequestTypeConnectToDevice),
                               SMMWatchkitRequestDeviceNameKey : deviceName
                               };
    [WKInterfaceController openParentApplication:userInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        onComplete(error);
    }];
}


- (void)requestShutdownDevice:(NSString*)deviceName onComplete:(void(^)(NSError *error))onComplete
{
    NSDictionary *userInfo = @{
                               SMMWatchkitRequestTypeKey : @(SMMWatchkitRequestTypeShutdownDevice),
                               SMMWatchkitRequestDeviceNameKey : deviceName
                               };
    [WKInterfaceController openParentApplication:userInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        onComplete(error);
    }];
}


- (void)handleWatchkitRequest:(NSDictionary *)userInfo onComplete:(void (^)(NSDictionary *))onComplete
{
    SMMWatchkitRequestType requestType = [userInfo[SMMWatchkitRequestTypeKey] intValue];
    if (requestType == SMMWatchkitRequestTypeListDevices) {
        [self _handleListDevicesRequest:userInfo onComplete:onComplete];
    } else if (requestType == SMMWatchkitRequestTypeConnectToDevice) {
        
    } else if (requestType == SMMWatchkitRequestTypeShutdownDevice) {
        
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
