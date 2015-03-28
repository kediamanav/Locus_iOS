//
//  UpdateBeaconViewController.h
//  locus
//
//  Created by Manav Kedia on 28/03/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include "SBJson.h"

@interface UpdateBeaconViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *itemImage;
- (IBAction)editButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *itemName;
@property (weak, nonatomic) IBOutlet UITextView *itemDescription;
- (IBAction)updateButton:(id)sender;

@property (strong, nonatomic) NSString *user_name;
@property (strong, nonatomic) NSString *item_name;
@property (strong, nonatomic) IBOutlet UIImage *beaconImage;

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) NSMutableArray *capturedImages;
@property (nonatomic) NSInteger picTaken;

@property UITextField *activeField;
@property UITextView *activeView;

@property UIActionSheet* attachmentMenuSheet;


@end
