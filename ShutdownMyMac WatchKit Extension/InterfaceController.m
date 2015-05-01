//
//  InterfaceController.m
//  ShutdownMyMac WatchKit Extension
//
//  Created by Jesús on 26/4/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "InterfaceController.h"
#import "SMMClientServiceManager.h"


@interface InterfaceController()

@property (nonatomic, assign) IBOutlet WKInterfaceLabel *lbTest;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [WKInterfaceController openParentApplication:@{@"requestType": @(0)} reply:^(NSDictionary *replyInfo, NSError *error) {
        [_lbTest setText:@"REPLY RECEIVED"];
        NSLog(@"%@", replyInfo);
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



