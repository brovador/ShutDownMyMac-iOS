//
//  SDMMBonjourHelperChannel.h
//  ShutdownMyMac-MacOSX
//
//  Created by Jesús on 14/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const SDMMBonjourHelperChannelStartConnectionNotification;
extern NSString * const SDMMBonjourHelperChannelEndConnectionNotification;
extern NSString * const SDMMBonjourHelperChannelDidReceiveCommandNotification;

extern NSString * const SDMMBonjourHelperCommandNotificationKey;

typedef NS_ENUM(NSInteger, SDMMBonjourHelperChannelType) {
    SDMMBonjourHelperChannelTypeRead,
    SDMMBonjourHelperChannelTypeWrite,
    SDMMBonjourHelperChannelTypeReadWrite
};

@protocol SDMMBonjourHelperChannelDelegate;

@interface SMMBonjourHelperChannel : NSObject

- (instancetype)initWithNetService:(NSNetService*)netService inputStream:(NSInputStream*)inputStream outputStream:(NSOutputStream*)outputStream type:(SDMMBonjourHelperChannelType)type;

- (void)sendCommand:(NSString*)command;
- (void)disconnect;

@end
