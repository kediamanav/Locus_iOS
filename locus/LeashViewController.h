//
//  LeashViewController.h
//  locus
//
//  Created by Manav Kedia on 26/01/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeashViewController : UIViewController

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
- (IBAction)eventPressed:(id)sender;
- (IBAction)actionPressed:(id)sender;
@end
