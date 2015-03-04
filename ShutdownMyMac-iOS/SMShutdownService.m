//
//  SMShutdownService.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SMShutdownService.h"

NSString * const SMCOMMAND_SHUTDOWN = @"SHUTDOWN";

@interface SMShutdownService()<NSNetServiceDelegate, NSStreamDelegate>

@property (nonatomic, assign) BOOL hasSpaceAvailable;
@property (nonatomic, assign) BOOL isConnected;


@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, strong) NSMutableArray *commandQueue;

@end

@implementation SMShutdownService

- (id)init
{
    self = [super init];
    if (self) {
        self.commandQueue = [NSMutableArray new];
    }
    return self;
}

- (NSString*)name
{
    return _netService.name;
}

- (void)connect
{
    self.isConnected = NO;
    
    NSOutputStream *outputStream;
    [_netService getInputStream:NULL outputStream:&outputStream];
    
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream setDelegate:self];
    [outputStream open];
    
    self.outputStream = outputStream;
}


- (void)disconnect
{
    if (_outputStream) {
        [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_outputStream close];
    }
    [self.delegate shutdownServiceDidDisconnect:self];
    self.isConnected = NO;
}


- (void)sendCommand:(NSString*)command
{
    [self.commandQueue addObject:command];
    if (self.hasSpaceAvailable){
        [self _sendCommandBuffer];
    }
}

#pragma mark Private

- (void)_sendCommandBuffer
{
    if ([_commandQueue count] > 0 && self.hasSpaceAvailable) {
        self.hasSpaceAvailable = NO;
        
        NSString *command = [_commandQueue firstObject];
        [_commandQueue removeObjectAtIndex:0];
        
        NSData *commandData = [command dataUsingEncoding:NSUTF8StringEncoding];
        [self.outputStream write:[commandData bytes] maxLength:[commandData length]];
    }
}

#pragma mark NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            self.isConnected = YES;
            [self.delegate shutdownServiceDidConnect:self];
            break;
        case NSStreamEventHasSpaceAvailable:
            self.hasSpaceAvailable = YES;
            [self _sendCommandBuffer];
            break;
        case NSStreamEventErrorOccurred:
            self.isConnected = NO;
            [self.delegate shutdownServiceDidFailConnect:self];
            break;
        case NSStreamEventEndEncountered:
            [self disconnect];
            break;
        default:
            break;
    }
}

@end
