//
//  SDMMWatchKitRequestsManager.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/5/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//
#import <WatchKit/WatchKit.h>

#import "SMMClientServiceManager.h"
#import "SMMShutdownService.h"
#import "SMMWatchKitRequestsManager.h"

static NSString *const SMMWatchkitRequestTypeKey = @"request";
static NSString *const SMMWatchkitRequestDeviceNameKey = @"device";

static NSString *const SMMWatchkitReplyDevicesKey = @"devices";
static NSString *const SMMWatchkitReplyErrorKey = @"error";

static SMMWatchKitRequestsManager *instance;

typedef NS_ENUM(NSInteger, SMMWatchkitRequestType) {
    SMMWatchkitRequestTypeListDevices,
    SMMWatchkitRequestTypeConnectToDevice,
    SMMWatchkitRequestTypeShutdownDevice
};

@interface SMMWatchKitRequestsManager ()<SMMClientServiceManagerDelegate>

@property (nonatomic, strong) NSArray *services;
@property (nonatomic, strong) SMMShutdownService *shutdownService;

@property (nonatomic, strong) void(^handleRequestCallback)(NSDictionary* info);

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


- (void)dealloc
{
    NSLog(@"WATCHKITREQUESTS MANAGER dealloc: %@", self);
}

- (void)requestListDevices:(void(^)(NSArray * devices, NSError *error))onComplete
{
    NSDictionary *userInfo = @{
                               SMMWatchkitRequestTypeKey : @(SMMWatchkitRequestTypeListDevices)
                               };
    [WKInterfaceController openParentApplication:userInfo reply:^(NSDictionary *replyInfo, NSError *replyError) {
        NSArray *devices;
        NSError *error = replyError;
        
        if (!replyError && replyInfo[SMMWatchkitReplyErrorKey]) {
            //TODO: fill error properly
            error = [NSError new];
        }
        
        if (error == nil) {
            devices = replyInfo[SMMWatchkitReplyDevicesKey];
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
    [WKInterfaceController openParentApplication:userInfo reply:^(NSDictionary *replyInfo, NSError *replyError) {
        NSError *error = replyError;
        if (!replyError && replyInfo[SMMWatchkitReplyErrorKey]) {
            //TODO: fill error properly
            error = [NSError new];
        }
        onComplete(error);
    }];
}


- (void)requestShutdownDevice:(NSString*)deviceName onComplete:(void(^)(NSError *error))onComplete
{
    NSDictionary *userInfo = @{
                               SMMWatchkitRequestTypeKey : @(SMMWatchkitRequestTypeShutdownDevice),
                               SMMWatchkitRequestDeviceNameKey : deviceName
                               };
    [WKInterfaceController openParentApplication:userInfo reply:^(NSDictionary *replyInfo, NSError *replyError) {
        NSError *error = replyError;
        if (!replyError && replyInfo[SMMWatchkitReplyErrorKey]) {
            //TODO: fill error properly
            error = [NSError new];
        }
        onComplete(error);
    }];
}


- (void)handleWatchkitRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply
{
    SMMWatchkitRequestType requestType = [userInfo[SMMWatchkitRequestTypeKey] intValue];
    if (requestType == SMMWatchkitRequestTypeListDevices) {
        [self _handleListDevicesRequest:userInfo onComplete:reply];
    } else if (requestType == SMMWatchkitRequestTypeConnectToDevice) {
        [self _handleConnectToDeviceRequest:userInfo onComplete:reply];
    } else if (requestType == SMMWatchkitRequestTypeShutdownDevice) {
        [self _handleShutdownDeviceRequest:userInfo onComplete:reply];
    }
}


#pragma mark Private

- (void)_handleListDevicesRequest:(NSDictionary*)userInfo onComplete:(void (^)(NSDictionary *info))onComplete
{
    self.handleRequestCallback = onComplete;
    [[SMMClientServiceManager sharedServiceManager] setDelegate:self];
    [[SMMClientServiceManager sharedServiceManager] searchServices];
}


- (void)_handleConnectToDeviceRequest:(NSDictionary*)userInfo onComplete:(void(^)(NSDictionary *info))onComplete
{
    NSString *deviceName = userInfo[SMMWatchkitRequestDeviceNameKey];
    NSNetService *service = [self _serviceWithName:deviceName];
    if (service) {
        self.shutdownService = [[SMMShutdownService alloc] initWithService:service];
        [_shutdownService sendConnectCommand:deviceName onComplete:^(NSError *error) {
            if (error) {
                onComplete(@{SMMWatchkitReplyErrorKey : @""});
            } else {
                onComplete(nil);
            }
        }];
    } else {
        //TODO: write error
        onComplete(@{SMMWatchkitReplyErrorKey : @""});
    }
}


- (void)_handleShutdownDeviceRequest:(NSDictionary*)userInfo onComplete:(void(^)(NSDictionary *info))onComplete
{
    if (_shutdownService.connectionStatus == SMMShutdownServiceConnectionStatusConnected) {
        __block SMMWatchKitRequestsManager* weakSelf = self;
        [_shutdownService sendShutdownCommand:^(NSError *error) {
            if (error) {
                onComplete(@{SMMWatchkitReplyErrorKey : @""});
            } else {
                onComplete(nil);
            }
            weakSelf.shutdownService = nil;
        }];
    } else {
        //TODO: write error
        onComplete(@{SMMWatchkitReplyErrorKey : @""});
    }
}


- (NSNetService*)_serviceWithName:(NSString*)name
{
    NSNetService *result = nil;
    for (NSNetService *service in _services) {
        if ([service.name isEqualToString:name]) {
            result = service;
            break;
        }
    }
    return result;
}

#pragma mark SMMClientServiceManagerDelegate

- (void)clientServiceManagerDidFindServices:(NSArray *)shutdownServices
{
    [[SMMClientServiceManager sharedServiceManager] stopSearch];
    
    NSMutableArray *services = [NSMutableArray new];
    self.services = shutdownServices;
    for (NSNetService *service in shutdownServices) {
        [services addObject:service.name];
    }
    
    void(^listDevicesCallback)(NSDictionary*) = self.handleRequestCallback;
    listDevicesCallback(@{SMMWatchkitReplyDevicesKey : services});
    
    self.handleRequestCallback = nil;
}

@end
