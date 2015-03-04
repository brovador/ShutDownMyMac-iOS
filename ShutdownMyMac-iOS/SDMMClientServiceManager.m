//
//  SDMMClientServiceManager.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SDMMClientServiceManager.h"
#import "SMShutdownService.h"

static SDMMClientServiceManager *_sharedServiceManager;

@interface SDMMClientServiceManager ()<NSNetServiceBrowserDelegate>

@property (nonatomic, strong) NSMutableArray *foundServices;
@property (nonatomic, strong) NSNetServiceBrowser *serviceBrowser;

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
    
    self.foundServices = [NSMutableArray new];
    self.serviceBrowser = netServiceBrowser;
}

- (void)stopSearch
{
    [self.serviceBrowser stop];
}

#pragma mark NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    SMShutdownService *shutdownService = [SMShutdownService new];
    shutdownService.netService = aNetService;
    [self.foundServices addObject:shutdownService];
    
    if (!moreComing) {
        [_delegate clientServiceManagerDidFindServices:self.foundServices];
        [self stopSearch];
    }
}


- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    NSLog(@"DID STOP SEARCH");
}

@end
