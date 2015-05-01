//
//  SMMShutdownService.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/5/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SMMShutdownService.h"
#import "SMMBonjourHelperChannel.h"

static NSString *const SMMShutdownServiceCommandPair = @"PAIR";
static NSString *const SMMShutdownServiceCommandShutdown = @"SHUTDOWN";

static NSString *const SMMShutdownServiceResponseSuccess = @"SUCCESS";
static NSString *const SMMShutdownServiceResponseFail = @"FAIL";

@interface SMMShutdownService ()

@property (nonatomic, readwrite) SMMShutdownServiceConnectionStatus connectionStatus;

@property (nonatomic, strong) NSNetService *service;
@property (nonatomic, strong) SMMBonjourHelperChannel *channel;

@property (nonatomic, strong) void(^onCommandCompleteBlock)(NSError *error);

@end

@implementation SMMShutdownService

- (instancetype)initWithService:(NSNetService*)service
{
    self = [super init];
    if (self) {
        
        self.service = service;
        
        NSInputStream *inputStream = nil;
        NSOutputStream *outputStream = nil;
        [_service getInputStream:&inputStream outputStream:&outputStream];
        
        
        self.channel = [[SMMBonjourHelperChannel alloc] initWithNetService:service inputStream:inputStream outputStream:outputStream type:SDMMBonjourHelperChannelTypeReadWrite];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelCommnadReceived:) name:SDMMBonjourHelperChannelDidReceiveCommandNotification object:_channel];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Public

- (BOOL)sendConnectCommand:(NSString*)deviceName onComplete:(void (^)(NSError *))onComplete
{
    BOOL success = NO;
    
    if (_connectionStatus == SMMShutdownServiceConnectionStatusNotConnected
        && _onCommandCompleteBlock == nil) {
        _connectionStatus = SMMShutdownServiceConnectionStatusConnecting;
        NSString *command = [NSString stringWithFormat:@"%@:%@", SMMShutdownServiceCommandPair, deviceName];
        [_channel sendCommand:command];
        self.onCommandCompleteBlock = onComplete;
        success = YES;
    }
    
    return success;
}


- (BOOL)sendShutdownCommand:(void (^)(NSError *))onComplete
{
    BOOL success = NO;
    
    if (_connectionStatus == SMMShutdownServiceConnectionStatusConnected
        && _onCommandCompleteBlock == nil) {
        [_channel sendCommand:SMMShutdownServiceCommandShutdown];
        self.onCommandCompleteBlock = onComplete;
        success = YES;
    }
    
    return success;
}

#pragma mark Notifications

- (void)onChannelCommnadReceived:(NSNotification*)notification
{
    SMMBonjourHelperChannel *channel = notification.object;
    if (channel == _channel) {
        NSString *command = notification.userInfo[SDMMBonjourHelperCommandNotificationKey];
        
        if (_connectionStatus == SMMShutdownServiceConnectionStatusConnecting) {
            if ([command isEqualToString:SMMShutdownServiceResponseSuccess]) {
                _connectionStatus = SMMShutdownServiceConnectionStatusConnected;
            } else {
                _connectionStatus = SMMShutdownServiceConnectionStatusNotConnected;
            }
        }
        _onCommandCompleteBlock([NSError new]);
        self.onCommandCompleteBlock = nil;
    }
}

@end
