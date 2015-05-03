//
//  SDMMWatchKitRequestsManager.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/5/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//
#import <WatchKit/WatchKit.h>

#import "SMMWatchkitRequestsDefines.h"
#import "SMMWatchKitRequest.h"

@interface SMMWatchKitRequest ()

@end

@implementation SMMWatchKitRequest

- (void)requestListDevices:(void(^)(NSArray * devices, NSError *error))onComplete
{
    NSDictionary *userInfo = @{
                               SMMWatchkitRequestTypeKey : @(SMMWatchkitRequestTypeListDevices)
                               };
    
    //TODO: fix this
    //UGLY HACK: AppDelegate of the first call is destroyed when reply is sent. We made a fake first call in
    //order to make the real logic in the 2nd one.
    [WKInterfaceController openParentApplication:@{} reply:^(NSDictionary *replyInfo, NSError *error) {}];
    
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

@end
