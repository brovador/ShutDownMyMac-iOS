//
//  InterfaceController.m
//  ShutdownMyMac WatchKit Extension
//
//  Created by Jesús on 26/4/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SMMWKServicesInterfaceController.h"
#import "SMMWatchKitRequestsManager.h"

#define MAX_DEVICES_TO_SHOW 20

static NSString * const SMMWKDeviceRowType = @"DeviceRow";

@interface SMMWKDeviceRow : NSObject

@property (nonatomic, assign) IBOutlet WKInterfaceLabel *lbTitle;

@end

@implementation SMMWKDeviceRow

@end

@interface SMMWKServicesInterfaceController()

@property (nonatomic, assign) IBOutlet WKInterfaceLabel *lbTitle;
@property (nonatomic, assign) IBOutlet WKInterfaceTable *tblDevices;

@end


@implementation SMMWKServicesInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self _localizeView];
    
    __block SMMWKServicesInterfaceController *weakSelf = self;
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

#pragma mark WKInterfaceTable handlers

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    NSLog(@"SELECTED ELEMENT: %ld", rowIndex);
}

#pragma mark Private

- (void)_localizeView
{
    [_lbTitle setText:NSLocalizedString(@"DEVICES_LIST", @"")];
}


- (void)_updateDevicesTable:(NSArray*)devices
{
    //Apple recommends to show less than 20 rows in tables
    //we limit the results to the first 20.
    //TODO: show a "more" button at the end to continue showing devices
    NSInteger devicesToDisplay = MIN([devices count], MAX_DEVICES_TO_SHOW);
    [_tblDevices setNumberOfRows:devicesToDisplay withRowType:SMMWKDeviceRowType];
    
    for (int i = 0; i < devicesToDisplay; i++) {
        NSString *deviceName = devices[i];
        SMMWKDeviceRow *deviceRow = [_tblDevices rowControllerAtIndex:i];
        [deviceRow.lbTitle setText:deviceName];
    }
}

@end



