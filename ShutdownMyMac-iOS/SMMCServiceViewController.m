//
//  SMMCServiceViewController.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 2/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SMMCServiceViewController.h"
#import "SMMShutdownService.h"


@interface SMMCServiceViewController ()

@property (nonatomic, assign) IBOutlet UILabel *lbServiceName;
@property (nonatomic, assign) IBOutlet UIButton *btnConnect;
@property (nonatomic, assign) IBOutlet UIButton *btnPair;
@property (nonatomic, assign) IBOutlet UIButton *btnShutdown;

@end

@implementation SMMCServiceViewController

- (void)setService:(SMMShutdownService *)service
{
    if (service != _service) {
        [_service removeObserver:self forKeyPath:@"connectionStatus"];
        _service = service;
        [_service addObserver:self forKeyPath:@"connectionStatus" options:NSKeyValueObservingOptionNew context:NULL];
    }
}


- (void)dealloc
{
    [_service removeObserver:self forKeyPath:@"connectionStatus"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _updateView];
    
    NSString *deviceName = [[UIDevice currentDevice] name];
    [_service sendConnectCommand:deviceName onComplete:^(NSError *error) {
        if (error) {
            [self backAction:nil];
        }
    }];
}

#pragma mark IBActions

- (IBAction)backAction:(id)sender
{
    [self performSegueWithIdentifier:@"unwindToServicesSegue" sender:self];
}


- (IBAction)shutdownAction:(id)sender
{
    [_service sendShutdownCommand:^(NSError *error) {
        if (error) {
            [self _showErrorAlert];
        } else {
            [self backAction:nil];
        }
    }];
}

#pragma mark Private

- (void)_showErrorAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"There was an error sending the command"
                                                   delegate:nil
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)_updateView
{
    [_lbServiceName setText:_service.name];
    [_btnConnect setEnabled:_service.connectionStatus == SMMShutdownServiceConnectionStatusNotConnected];
    [_btnShutdown setEnabled:_service.connectionStatus == SMMShutdownServiceConnectionStatusConnected];
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _service) {
        [self _updateView];
    }
}


@end
