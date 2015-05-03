//
//  SMMWatchkitRequestsHandler.h
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 3/5/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMMWatchkitRequestHandler : NSObject

- (void)handleWatchkitRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply;

@end
