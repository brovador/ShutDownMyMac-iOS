//
//  SMMCServiceViewController.h
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 2/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMShutdownService;

@interface SMMCServiceViewController : UIViewController

@property (nonatomic, strong) SMShutdownService *service;

@end
