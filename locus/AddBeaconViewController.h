//
//  AddBeaconViewController.h
//  sticky
//
//  Created by Manav Kedia on 15/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <CoreData/CoreData.h>
#include "SBJson.h"
#import "AppDelegate.h"
#import "Items.h"

@interface AddBeaconViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfRange;
@property (weak, nonatomic) IBOutlet UIStepper *rangeCounter;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property NSString *user_name;
@property NSString *macAddress;

@property NSString *major;
@property NSString *minor;
@property NSUUID *uuid;

- (IBAction)counterPressed:(id)sender;
- (IBAction)addButtonPressed:(id)sender;

@end
