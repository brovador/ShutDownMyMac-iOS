//
//  InterfaceController.m
//  ShutdownMyMac WatchKit Extension
//
//  Created by Jesús on 26/4/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "InterfaceController.h"
#import "SMMWatchKitRequestsManager.h"


@interface InterfaceController()

@property (nonatomic, assign) IBOutlet WKInterfaceLabel *lbTest;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [[SMMWatchKitRequestsManager sharedManager] requestListDevices:^(NSArray *devices, NSError *error) {
        if (!error) {
            NSLog(@"DEVICES RETRIEVED: %@", devices);
        }
    }];
    
    [_lbTest setText:@"OK running"];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



