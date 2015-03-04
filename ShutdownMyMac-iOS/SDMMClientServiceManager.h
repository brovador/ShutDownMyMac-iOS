//
//  SDMMClientServiceManager.h
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SMMClientServiceManagerDelegate;

@interface SDMMClientServiceManager : NSObject

@property (nonatomic, assign) NSObject<SMMClientServiceManagerDelegate> *delegate;

+ (instancetype)sharedServiceManager;

- (void)searchServices;
- (void)stopSearch;

@end

@protocol SMMClientServiceManagerDelegate <NSObject>

- (void)clientServiceManagerDidFindServices:(NSArray*)shutdownServices;

@end
