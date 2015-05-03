//
//  InterfaceController.m
//  ShutdownMyMac WatchKit Extension
//
//  Created by Jesús on 26/4/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SMMWKServicesInterfaceController.h"
#import "SMMWatchKitRequest.h"

#define MAX_DEVICES_TO_SHOW 20

static NSString * const SMMWKServiceSegue = @"ServiceSegue";
static NSString * const SMMWKDeviceRowType = @"DeviceRow";

@interface SMMWKDeviceRow : NSObject

@property (nonatomic, assign) IBOutlet WKInterfaceLabel *lbTitle;

@end

@implementation SMMWKDeviceRow

@end

@interface SMMWKServicesInterfaceController()

@property (nonatomic, strong) NSArray *devices;

@property (nonatomic, assign) IBOutlet WKInterfaceLabel *lbTitle;
@property (nonatomic, assign) IBOutlet WKInterfaceTable *tblDevices;

@end


@implementation SMMWKServicesInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self _localizeView];
    
    __block SMMWKServicesInterfaceController *weakSelf = self;
    SMMWatchKitRequest *watchkitRequest = [SMMWatchKitRequest new];
    
    [watchkitRequest requestListDevices:^(NSArray *devices, NSError *error) {
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

#pragma mark Segues

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex
{
    id result = nil;
    if ([SMMWKServiceSegue isEqualToString:segueIdentifier]) {
        result = [_devices objectAtIndex:rowIndex];
    }
    return result;
}

#pragma mark Private

- (void)_localizeView
{
    [_lbTitle setText:NSLocalizedString(@"WK_DEVICES_LIST", @"")];
}


- (void)_updateDevicesTable:(NSArray*)devices
{
    self.devices = devices;
    
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



