//
//  SDMMClientServiceManager.h
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDMMClientServiceManager : NSObject

+ (instancetype)sharedServiceManager;

- (void)searchServices;

@end
