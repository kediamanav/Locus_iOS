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

@interface LeashViewController ()

@end

@implementation LeashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Load yes or no from the server data here, and everything else accordingly
    
    if(![_switchOn isOn]){
        [self.label1 setHidden:YES];
        [self.label2 setHidden:YES];
        [self.label3 setHidden:YES];
        [self.label4 setHidden:YES];
        [self.actionType setHidden:YES];
        [self.eventType setHidden:YES];
        [self.messageView setHidden:YES];
        [self.saveButton setHidden:YES];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue  sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)savePressed:(id)sender {
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
        [self.saveButton setHidden:NO];
        self.eventType.text = [[Utility getBeaconsEvents] firstObject];
        self.actionType.text = [[Utility getBeaconsActions] firstObject];
    }
    if(![_switchOn isOn]){
        [self.label1 setHidden:YES];
        [self.label2 setHidden:YES];
        [self.label3 setHidden:YES];
        [self.label4 setHidden:YES];
        [self.actionType setHidden:YES];
        [self.eventType setHidden:YES];
        [self.messageView setHidden:YES];
        [self.saveButton setHidden:YES];
    }
}

- (IBAction)eventPressed:(id)sender {
    [self performSegueWithIdentifier:@"ShowEventSegue" sender:self];
}

- (IBAction)actionPressed:(id)sender {
    [self performSegueWithIdentifier:@"ShowActionSegue" sender:self];
}


/*-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSague in ConfigViewController");
    isSeguePerformed = YES;
    if ([segue.identifier isEqualToString:@"EventSegue"]) {
        EventTableViewController *eventVC = [segue destinationViewController];
        if (self.isAddView) {
            eventVC.chosenEvent = self.existingBeacon.event;
        }
        else {
            eventVC.chosenEvent = self.selectedBeacon.event;
        }
        
        
    } else if ([segue.identifier isEqualToString:@"ActionSegue"]) {
        ActionTableViewController *actionVC = [segue destinationViewController];
        if (self.isAddView) {
            actionVC.chosenAction = self.existingBeacon.action;
        }
        else {
            actionVC.chosenAction = self.selectedBeacon.action;
        }
        
    }
    
}*/


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
