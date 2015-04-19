//
//  ViewController.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 1/3/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "SMMCServicesViewController.h"
#import "SDMMClientServiceManager.h"
#import "SMMCServiceViewController.h"

static NSString * const ShowServiceSegueIdentifier = @"showService";
static inline UIColor* PurpleColor()
{
    return [UIColor colorWithRed:172/255.0f green:30/255.0f blue:247/255.0f alpha:1.0f];
}

@interface SMMCServicesViewController ()<UITableViewDataSource, UITableViewDelegate, SMMClientServiceManagerDelegate>

@property (nonatomic, assign) UITableViewController *vcTableView;
@property (nonatomic, assign) IBOutlet UITableView *tblServices;

@property (nonatomic, strong) NSArray *services;

@end

@implementation SMMCServicesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_tblServices registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
    [[SDMMClientServiceManager sharedServiceManager] setDelegate:self];
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    refreshControl.tintColor = PurpleColor();
    [refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    
    UITableViewController *vcTableView = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    vcTableView.tableView = _tblServices;
    vcTableView.refreshControl = refreshControl;
    [self addChildViewController:vcTableView];
    self.vcTableView = vcTableView;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[SDMMClientServiceManager sharedServiceManager] searchServices];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[SDMMClientServiceManager sharedServiceManager] stopSearch];
}


#pragma mark UIStoryboardSegues

- (IBAction)unwindToServices:(UIStoryboardSegue*)sender
{
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:ShowServiceSegueIdentifier]) {
        SMMCServiceViewController *vc = (SMMCServiceViewController*)segue.destinationViewController;
        vc.service = _services[[_tblServices indexPathForSelectedRow].row];
    }
}


#pragma mark UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_services count];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNetService *service = [_services objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.textLabel.text = service.name;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = PurpleColor();
    
    return cell;
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:ShowServiceSegueIdentifier sender:self];
}


#pragma mark UIRefreshControl

- (void)handleRefresh
{
    [[SDMMClientServiceManager sharedServiceManager] stopSearch];
    [[SDMMClientServiceManager sharedServiceManager] searchServices];
}


#pragma mark SMMClientServiceMAnagerDelegate

- (void)clientServiceManagerDidFindServices:(NSArray *)shutdownServices
{
    self.services = shutdownServices;
    [_tblServices reloadData];
    [_vcTableView.refreshControl endRefreshing];
}

@end
