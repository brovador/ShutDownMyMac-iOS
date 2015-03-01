//
//  ViewController.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "ViewController.h"
#import "SDMMClientServiceManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SDMMClientServiceManager sharedServiceManager] searchServices];
}

@end
