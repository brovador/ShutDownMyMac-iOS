//
//  SDMMBonjourHelperChannel.m
//  ShutdownMyMac-MacOSX
//
//  Created by Jesús on 14/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SMMBonjourHelperChannel.h"

#define BUFFER_SIZE 1024

NSString * const SDMMBonjourHelperChannelStartConnectionNotification = @"SDMMBonjourHelperChannelStartConnectionNotification";
NSString * const SDMMBonjourHelperChannelEndConnectionNotification = @"SDMMBonjourHelperChannelEndConnectionNotification";
NSString * const SDMMBonjourHelperChannelDidReceiveCommandNotification = @"SDMMBonjourHelperChannelDidReceiveCommandNotification";

NSString * const SDMMBonjourHelperCommandNotificationKey = @"SDMMBonjourHelperCommandNotificationKey";

@interface SMMBonjourHelperChannel()<NSStreamDelegate>

@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) BOOL hasSpaceAvailable;

@property (nonatomic, assign) SDMMBonjourHelperChannelType channelType;
@property (nonatomic, strong) NSNetService *netService;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, strong) NSMutableArray *commandQueue;

@end


@implementation SMMBonjourHelperChannel

- (instancetype)initWithNetService:(NSNetService *)netService inputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream type:(SDMMBonjourHelperChannelType)type
{
    self = [super init];
    if (self) {
        
        self.channelType = type;
        self.netService = netService;
        self.commandQueue = [NSMutableArray new];
        
        if ([self _isReadChannel] && inputStream) {
            inputStream.delegate = self;
            [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [inputStream open];
            
            self.inputStream = inputStream;
        }
        
        if ([self _isWriteChannel] && outputStream) {
            outputStream.delegate = self;
            [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [outputStream open];
            
            self.outputStream = outputStream;
        }
    }
    return self;
}

#pragma mark Public

- (void)sendCommand:(NSString *)command
{
    if ([self _isWriteChannel]) {
        [self.commandQueue addObject:command];
        [self _sendCommandBuffer];
    } else {
        //TODO: send error?
    }
}


- (void)disconnect
{
    _connected = NO;
    
    if ([self _isReadChannel]) {
        [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    if ([self _isWriteChannel]) {
        [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SDMMBonjourHelperChannelEndConnectionNotification
                                                        object:nil];
}


#pragma mark Private

- (void)_sendCommandBuffer
{
    if (_hasSpaceAvailable && [_commandQueue count] > 0) {
        NSString *nextCommand = [_commandQueue objectAtIndex:0];
        [_commandQueue removeObjectAtIndex:0];
        
        NSData *data = [nextCommand dataUsingEncoding:NSUTF8StringEncoding];
        [_outputStream write:[data bytes] maxLength:[data length]];
    }
}

- (BOOL)_isReadChannel
{
    return (_channelType == SDMMBonjourHelperChannelTypeRead || _channelType == SDMMBonjourHelperChannelTypeReadWrite);
}


- (BOOL)_isWriteChannel
{
    return (_channelType == SDMMBonjourHelperChannelTypeWrite || _channelType == SDMMBonjourHelperChannelTypeReadWrite);
}

#pragma mark NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            _connected = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:SDMMBonjourHelperChannelStartConnectionNotification
                                                                object:nil];
            break;
        case NSStreamEventHasSpaceAvailable:
            _hasSpaceAvailable = YES;
            [self _sendCommandBuffer];
            break;
        case NSStreamEventHasBytesAvailable: {
            
            if ([self _isReadChannel]) {
                uint8_t buf[1024];
                NSInteger len = [(NSInputStream*)aStream read:buf maxLength:BUFFER_SIZE];
                
                if (len > 0) {
                    NSData *data = [NSData dataWithBytes:buf length:len];
                    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:SDMMBonjourHelperChannelDidReceiveCommandNotification
                                                                        object:self
                                                                      userInfo:@{
                                                                                 SDMMBonjourHelperCommandNotificationKey : message
                                                                                 }];
                }
            }
            
            break;
        }
        case NSStreamEventErrorOccurred:
        case NSStreamEventEndEncountered:
            [self disconnect];
            break;
        default:
            break;
    }
}

@end

