//
//  InterfaceController.m
//  ShutdownMyMac WatchKit Extension
//
//  Created by Jesús on 26/4/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SMMWKDevicesInterfaceController.h"
#import "SMMWatchKitRequestsManager.h"

static NSString * const SMMWKDeviceRowType = @"DeviceRow";

@interface SMMWKDeviceRow : WKInterfaceButton

@property (nonatomic, assign) IBOutlet WKInterfaceLabel *lbTitle;

@end

@implementation SMMWKDeviceRow

@end

@interface SMMWKDevicesInterfaceController()

@property (nonatomic, assign) IBOutlet WKInterfaceLabel *lbTitle;
@property (nonatomic, assign) IBOutlet WKInterfaceTable *tblDevices;

@end


@implementation SMMWKDevicesInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self _localizeView];
    
    __block SMMWKDevicesInterfaceController *weakSelf = self;
    [[SMMWatchKitRequestsManager sharedManager] requestListDevices:^(NSArray *devices, NSError *error) {
        if (!error) {
            [weakSelf _updateDevicesTable:devices];
        }
    }];
}

- (void)willActivate {
    [super willActivate];
    
}

- (void)didDeactivate {
    [super didDeactivate];
}


#pragma mark Private

- (void)_localizeView
{
    [_lbTitle setText:NSLocalizedString(@"DEVICES_LIST", @"")];
}


- (void)_updateDevicesTable:(NSArray*)devices
{
    [_tblDevices setNumberOfRows:[devices count] withRowType:SMMWKDeviceRowType];
    for (int i = 0; i < [devices count]; i++) {
        NSString *deviceName = devices[i];
        SMMWKDeviceRow *deviceRow = [_tblDevices rowControllerAtIndex:i];
        [deviceRow.lbTitle setText:deviceName];
    }
}

@end



