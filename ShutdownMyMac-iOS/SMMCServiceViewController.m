//
//  SMMCServiceViewController.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 2/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SMMCServiceViewController.h"
#import "SMShutdownService.h"

@interface SMMCServiceViewController ()<SMMShutdownServiceDelegate>

@property (nonatomic, assign) IBOutlet UILabel *lbServiceName;

@end

@implementation SMMCServiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_lbServiceName setText:_service.name];
    
    [_service setDelegate:self];
    [_service connect];
}


- (void)dealloc
{
    [self.service disconnect];
}

#pragma mark IBActions

- (IBAction)onBackButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"unwindToServicesSegue" sender:self];
}


- (IBAction)onShutdownButtonPressed:(id)sender
{
    [self.service sendCommand:SMCOMMAND_SHUTDOWN];
}

#pragma mark SMMShutdownServiceDelegate

- (void)shutdownServiceDidConnect:(SMShutdownService *)shutdownService
{
    
}

- (void)shutdownServiceDidDisconnect:(SMShutdownService *)shutdownService
{
    
}

- (void)shutdownServiceDidFailConnect:(SMShutdownService *)shutdownService
{
    
}


@end
