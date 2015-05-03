//
//  SMMWKServiceInterfaceController.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 3/5/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SMMWKServiceInterfaceController.h"
#import "SMMWatchKitRequestsManager.h"

@interface SMMWKServiceInterfaceController ()

@property (nonatomic, copy) NSString *deviceName;

@property (nonatomic, assign) IBOutlet WKInterfaceLabel *lbDeviceName;
@property (nonatomic, assign) IBOutlet WKInterfaceButton *btnShutdown;

@end

@implementation SMMWKServiceInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.deviceName = context;
    
    [_btnShutdown setEnabled:NO];
    [_lbDeviceName setText:_deviceName];
}

- (void)willActivate {
    [super willActivate];
    
    __block SMMWKServiceInterfaceController *weakSelf = self;
    [[SMMWatchKitRequestsManager sharedManager] requestConnectDevice:_deviceName onComplete:^(NSError *error) {
        if (error) {
            [weakSelf dismissController];
        } else {
            [_btnShutdown setEnabled:YES];
        }
    }];
}


- (void)didDeactivate {
    [super didDeactivate];
}

#pragma mark IBActions

- (IBAction)shutdownAction
{
    [_btnShutdown setEnabled:NO];
    
    __block SMMWKServiceInterfaceController *weakSelf = self;
    [[SMMWatchKitRequestsManager sharedManager] requestShutdownDevice:_deviceName onComplete:^(NSError *error) {
        if (error) {
            //TODO: handle error...
            [_btnShutdown setEnabled:YES];
        } else {
            [weakSelf dismissController];
        }
    }];
}

#pragma mark Private

- (void)_localizeView
{
    [_btnShutdown setTitle:NSLocalizedString(@"WK_SHUTDOWN_BUTTON", @"")];
}

@end



