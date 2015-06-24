//
//  LoginViewController.h
//  sticky
//
//  Created by Manav Kedia on 10/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mainTableViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

-(IBAction) unwindToLogin: (UIStoryboardSegue *) segue;
@end
