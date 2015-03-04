//
//  SMShutdownService.h
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const SMCOMMAND_SHUTDOWN;

@protocol SMMShutdownServiceDelegate;

@interface SMShutdownService : NSObject

@property NSObject<SMMShutdownServiceDelegate> *delegate;
@property (nonatomic, strong) NSNetService *netService;

- (NSString*)name;

- (void)connect;
- (void)disconnect;

- (void)sendCommand:(NSString*)command;

@end


@protocol SMMShutdownServiceDelegate <NSObject>

- (void)shutdownServiceDidConnect:(SMShutdownService*)shutdownService;
- (void)shutdownServiceDidFailConnect:(SMShutdownService*)shutdownService;
- (void)shutdownServiceDidDisconnect:(SMShutdownService*)shutdownService;

@end
