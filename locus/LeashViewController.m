//
//  LeashViewController.m
//  locus
//
//  Created by Manav Kedia on 26/01/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import "LeashViewController.h"
#import "Utility.h"
#import "EventTableViewController.h"
#import "ActionTableViewController.h"
#import "BeaconDatabase.h"

@interface LeashViewController ()
@property BeaconDatabase *beaconData;
@property Beacon *beacon;
@end

@implementation LeashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.beaconData =[[BeaconDatabase alloc]init];
    NSLog(@"%@ %@",_user_name,_item_name);
    //self.user_name = @"kediamanav";
    //self.item_name = @"headphones";
    self.beacon = [self.beaconData readBeacon:self.user_name :self.item_name];
    NSLog(@"uuid %@, major %ld, minor %ld, action %ld, event %ld, message %@",_beacon.uuid,(long)[_beacon.major integerValue],(long)[_beacon.minor integerValue],(long)[_beacon.action integerValue],(long)[_beacon.event integerValue],_beacon.message);
    
    if([self.beacon.action integerValue]!=0){
        NSLog(@"E-Leash set before. Set everything");
        [self.switchOn setOn:YES animated:YES];
        self.eventType.text = [[Utility getBeaconsEvents] objectAtIndex:[_beacon.event integerValue]-1];
        self.actionType.text = [[Utility getBeaconsActions] objectAtIndex:[_beacon.action integerValue]-1];
    }
    else{
        [self.switchOn setOn:NO animated:YES];
        [self.label1 setHidden:YES];
        [self.label2 setHidden:YES];
        [self.label3 setHidden:YES];
        [self.label4 setHidden:YES];
        [self.actionType setHidden:YES];
        [self.eventType setHidden:YES];
        [self.messageView setHidden:YES];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* Create alert if some required field something is missing*/
- (void) alertStatus : (NSString *)msg :(NSString *)title{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertview show];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue  sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)savePressed:(id)sender {
    if([self.switchOn isOn]){
        NSString *event =self.eventType.text;
        NSString *action = self.actionType.text;
        NSLog(@"%@    %@",event,action);
        NSInteger index1 = [[Utility getBeaconsEvents] indexOfObject:event]+1;
        NSInteger index2 = [[Utility getBeaconsActions] indexOfObject:action]+1;
        
        NSLog(@"%ld, %ld",(long)index1,(long)index2);
        self.beacon.event = [NSNumber numberWithInt:(int)index1];
        self.beacon.action = [NSNumber numberWithInt:(int)index2];
        self.beacon.message = self.messageView.text;
    }
    else{
        self.beacon.message = @"";
        self.beacon.action = [NSNumber numberWithInt:(int)0];
        self.beacon.event = [NSNumber numberWithInt:(int)0];
        self.beacon.modified = [NSNumber numberWithInt:(int)1];
    }
    NSLog(@"Sending beacon to update");
    if([self.beaconData updateBeacon:self.beacon]==1){
        NSLog(@"Beacon updated");
        [self alertStatus:@"Beacon successfully updated" :@"Beacon Notification!"];
    }
    else{
        NSLog(@"Beacon update failed");
        [self alertStatus:@"Beacon could not be updated" :@"Beacon Error!"];
    }
}

- (IBAction)switchPressed:(id)sender {
    if([self.switchOn isOn]){
        [self.label1 setHidden:NO];
        [self.label2 setHidden:NO];
        [self.label3 setHidden:NO];
        [self.label4 setHidden:NO];
        [self.actionType setHidden:NO];
        [self.eventType setHidden:NO];
        [self.messageView setHidden:NO];
        if([self.beacon.action integerValue]==0){
            self.eventType.text = [[Utility getBeaconsEvents] firstObject];
            self.actionType.text = [[Utility getBeaconsActions] firstObject];
        }
        else{
            self.eventType.text = [[Utility getBeaconsEvents] objectAtIndex:[_beacon.event integerValue]-1];
            self.actionType.text = [[Utility getBeaconsActions] objectAtIndex:[_beacon.action integerValue]-1];
        }
    }
    if(![_switchOn isOn]){
        [self.label1 setHidden:YES];
        [self.label2 setHidden:YES];
        [self.label3 setHidden:YES];
        [self.label4 setHidden:YES];
        [self.actionType setHidden:YES];
        [self.eventType setHidden:YES];
        [self.messageView setHidden:YES];
    }
}

- (IBAction)eventPressed:(id)sender {
    [self performSegueWithIdentifier:@"ShowEventSegue" sender:self];
}

- (IBAction)actionPressed:(id)sender {
    [self performSegueWithIdentifier:@"ShowActionSegue" sender:self];
}


- (IBAction)unwindEventSelector:(UIStoryboardSegue*)sender
{
    EventTableViewController *eventVC = [sender sourceViewController];
    self.eventType.text = eventVC.chosenEvent;
   
}

- (IBAction)unwindActionSelector:(UIStoryboardSegue*)sender
{
    ActionTableViewController *actionVC = [sender sourceViewController];
    self.actionType.text = actionVC.chosenAction;
}

@end
