//
//  LeashViewController.m
//  locus
//
//  Created by Manav Kedia on 26/01/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import "LeashViewController.h"

@interface LeashViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchOn;
@property (weak, nonatomic) IBOutlet UILabel *eventType;
@property (weak, nonatomic) IBOutlet UILabel *actionType;
@property (weak, nonatomic) IBOutlet UITextView *messageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
- (IBAction)savePressed:(id)sender;
- (IBAction)switchPressed:(id)sender;

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
@end
