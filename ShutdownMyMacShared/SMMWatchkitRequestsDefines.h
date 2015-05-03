//
//  SMMWatchkitRequestsDefines.h
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 3/5/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#ifndef ShutdownMyMac_iOS_SMMWatchkitRequestsDefines_h
#define ShutdownMyMac_iOS_SMMWatchkitRequestsDefines_h

extern NSString *const SMMWatchkitRequestTypeKey;
extern NSString *const SMMWatchkitRequestDeviceNameKey;

extern NSString *const SMMWatchkitReplyDevicesKey;
extern NSString *const SMMWatchkitReplyErrorKey;

typedef NS_ENUM(NSInteger, SMMWatchkitRequestType) {
    SMMWatchkitRequestTypeListDevices,
    SMMWatchkitRequestTypeConnectToDevice,
    SMMWatchkitRequestTypeShutdownDevice
};

#endif
