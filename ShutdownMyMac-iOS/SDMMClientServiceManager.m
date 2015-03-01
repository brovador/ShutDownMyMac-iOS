//
//  SDMMClientServiceManager.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SDMMClientServiceManager.h"

static SDMMClientServiceManager *_sharedServiceManager;

@interface SDMMClientServiceManager ()<NSNetServiceBrowserDelegate, NSStreamDelegate>

@property (nonatomic, strong) NSNetServiceBrowser *serviceBrowser;

@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSInputStream *inputStream;

@end

@implementation SDMMClientServiceManager

+ (instancetype)sharedServiceManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedServiceManager = [SDMMClientServiceManager new];
    });
    return _sharedServiceManager;
}

- (void)searchServices
{
    NSNetServiceBrowser *netServiceBrowser = [NSNetServiceBrowser new];
    [netServiceBrowser setDelegate:self];
    [netServiceBrowser searchForServicesOfType:@"_shutdownmymac._tcp" inDomain:@"local"];
    
    
    self.serviceBrowser = netServiceBrowser;
}

#pragma mark NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSLog(@"DID FIND SERVICE: %@", aNetService);
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    
    [aNetService getInputStream:&inputStream outputStream:&outputStream];
    
    [outputStream setDelegate:self];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream open];
    
//    [inputStream setDelegate:self];
//    [inputStream open];
    
    self.outputStream = outputStream;
//    self.inputStream = inputStream;
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    NSLog(@"DID STOP SEARCH");
}

#pragma mark NSStreamDelegate

static int messageTimes = 0;

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventHasSpaceAvailable: {
            NSLog(@"EVENT HAS BYTES AVAILABLE");
            if (messageTimes < 3) {
                NSLog(@"WRITING MESSAGE... %d", messageTimes);
                NSData *data = [@"Hello world" dataUsingEncoding:NSUTF8StringEncoding];
                [(NSOutputStream*)aStream write:[data bytes] maxLength:[data length]];
                messageTimes++;
            } else {
                messageTimes = 0;
                [aStream close];
            }
            break;
        }
        case NSStreamEventEndEncountered:
            NSLog(@"EVENT END ENCOUNTERED");
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"EVENT ERROR OCURRED");
            break;
        default:
            break;
    }
}

@end
