//
//  TrackViewController.m
//  locus
//
//  Created by Manav Kedia on 26/01/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import "TrackViewController.h"
#import "LeashViewController.h"

@interface TrackViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *beaconImageHolder;
- (IBAction)pressBuzzer:(id)sender;
- (IBAction)pressCamera:(id)sender;

@end

@implementation TrackViewController
@synthesize beaconImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Inside trackViewController");
    self.beaconImageHolder.image = self.beaconImage;
    self.beaconImageHolder.layer.cornerRadius = self.beaconImageHolder.frame.size.width /2;
    self.beaconImageHolder.clipsToBounds = YES;
    self.tabBarController.delegate = self;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    UINavigationController *navController = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:1];
    LeashViewController *leash = (LeashViewController *) [[navController viewControllers] objectAtIndex:0];
    
    leash.user_name = _user_name;
    leash.item_name = _item_name;
    //This will change the text of the label in controller B
}


- (IBAction)pressBuzzer:(id)sender {
}

- (IBAction)pressCamera:(id)sender {
}
@end
