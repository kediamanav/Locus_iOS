//
//  EventTableViewController.m
//  locus
//
//  Created by Manav Kedia on 26/01/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import "EventTableViewController.h"
#import "EventTableViewCell.h"
#import "Utility.h"

@interface EventTableViewController ()

@end

@implementation EventTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"login_bg.jpg"]]];
    self.tableView.backgroundView.alpha = 0.6;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[Utility getBeaconsEvents]count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventDetailCell" forIndexPath:indexPath];
    cell.eventLabel.text = [[Utility getBeaconsEvents] objectAtIndex:indexPath.row];
    cell.eventImage.image = [[Utility getBeaconsEventsImages] objectAtIndex:indexPath.row];
    
    if ([[[Utility getBeaconsEvents] objectAtIndex:indexPath.row] isEqual:self.chosenEvent]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [UIView new];
    cell.selectedBackgroundView = [UIView new];
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath * selectionIndexPath = [self.tableView indexPathForSelectedRow];
    NSString *event = [[Utility getBeaconsEvents] objectAtIndex:selectionIndexPath.row];
    self.chosenEvent = event;
}

@end
