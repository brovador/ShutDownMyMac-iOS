//
//  SMMCServiceViewController.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 2/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SMMCServiceViewController.h"
#import "SDMMBonjourHelperChannel.h"

typedef NS_ENUM(NSInteger, SDMMServiceManagerStatus) {
    SDMMServiceManagerStatusNotConnected,
    SDMMServiceManagerStatusConnected,
    SDMMServiceManagerStatusShutdownCommandSent
};

static NSString *const SDMMServiceManagerCommandPair = @"PAIR";
static NSString *const SDMMServiceManagerCommandShutdown = @"SHUTDOWN";

static NSString *const SDMMServiceManagerResponseSuccess = @"SUCCESS";
static NSString *const SDMMServiceManagerResponseFail = @"FAIL";


@interface SMMCServiceViewController ()

@property (nonatomic, assign) SDMMServiceManagerStatus serviceStatus;
@property (nonatomic, strong) SDMMBonjourHelperChannel *channel;

@property (nonatomic, assign) IBOutlet UILabel *lbServiceName;
@property (nonatomic, assign) IBOutlet UIButton *btnConnect;
@property (nonatomic, assign) IBOutlet UIButton *btnPair;
@property (nonatomic, assign) IBOutlet UIButton *btnShutdown;

@end

@implementation SMMCServiceViewController

- (void)setService:(NSNetService *)service
{
    if (service != _service) {
        _service = service;
        
        
        NSInputStream *inputStream = nil;
        NSOutputStream *outputStream = nil;
        [_service getInputStream:&inputStream outputStream:&outputStream];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onChannelCommandReceived:)
                                                     name:SDMMBonjourHelperChannelDidReceiveCommandNotification
                                                   object:nil];
        
        self.serviceStatus = SDMMServiceManagerStatusNotConnected;
        self.channel = [[SDMMBonjourHelperChannel alloc] initWithNetService:_service
                                                                inputStream:inputStream
                                                               outputStream:outputStream
                                                                       type:SDMMBonjourHelperChannelTypeReadWrite];
        

    }
}


- (void)setServiceStatus:(SDMMServiceManagerStatus)serviceStatus
{
    if (serviceStatus != _serviceStatus) {
        _serviceStatus = serviceStatus;
        [self _updateView];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _updateView];
    
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *command = [NSString stringWithFormat:@"%@:%@", SDMMServiceManagerCommandPair, deviceName];
    [_channel sendCommand:command];
}


- (void)dealloc
{
    [_channel disconnect];
}

#pragma mark IBActions

- (IBAction)backAction:(id)sender
{
    [self performSegueWithIdentifier:@"unwindToServicesSegue" sender:self];
}


- (IBAction)shutdownAction:(id)sender
{
    self.serviceStatus = SDMMServiceManagerStatusShutdownCommandSent;
    [_channel sendCommand:SDMMServiceManagerCommandShutdown];
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
    [_btnConnect setEnabled:(_serviceStatus == SDMMServiceManagerStatusNotConnected)];
    [_btnShutdown setEnabled:(_serviceStatus == SDMMServiceManagerStatusConnected)];
}

#pragma mark SDMMBonjourHelperChannel

- (void)onChannelCommandReceived:(NSNotification*)notification
{
    SDMMBonjourHelperChannel *channel = notification.object;
    if (channel == _channel) {
        NSString *command = notification.userInfo[SDMMBonjourHelperCommandNotificationKey];
        
        switch (_serviceStatus) {
            case SDMMServiceManagerStatusNotConnected:
                if ([command isEqualToString:SDMMServiceManagerResponseSuccess]) {
                    self.serviceStatus = SDMMServiceManagerStatusConnected;
                } else if ([command isEqualToString:SDMMServiceManagerResponseFail]) {
                    [self backAction:nil];
                }
                break;
            case SDMMServiceManagerStatusShutdownCommandSent:
                if ([command isEqualToString:SDMMServiceManagerResponseSuccess]) {
                    [self backAction:nil];
                } else {
                    self.serviceStatus = SDMMServiceManagerStatusConnected;
                    [self _showErrorAlert];
                }
            default:
                break;
        }
    }
}


@end
