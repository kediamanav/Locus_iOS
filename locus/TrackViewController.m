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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"Switching to edit view");
    if([[segue identifier] isEqualToString:@"ShowEditView"]){
        NSLog(@"Prepare for segue: %@", segue.destinationViewController);
        UINavigationController *segueNavigation = [segue destinationViewController];
        NSLog(@"Prepare for segue: %@", segue.identifier);
        UpdateBeaconViewController *transferViewController = (UpdateBeaconViewController *)[[segueNavigation viewControllers] objectAtIndex:0];
        NSLog(@"Prepare for segue: %@", segue.identifier);
        transferViewController.user_name = self.user_name;
        transferViewController.item_name = self.item_name;
        transferViewController.beaconImage = self.beaconImage;
        transferViewController.viewNumber = 1;
        NSLog(@"%@", transferViewController.user_name);
    }
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    UINavigationController *navController = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:1];
    LeashViewController *leash = (LeashViewController *) [[navController viewControllers] objectAtIndex:0];
    
    leash.user_name = _user_name;
    leash.item_name = _item_name;
    leash.beaconImage = self.beaconImage;
    //This will change the text of the label in controller B
}


- (IBAction)editPressed:(id)sender {
    [self performSegueWithIdentifier:@"ShowEditView" sender:self];
}

- (IBAction)unwindTrackView:(UIStoryboardSegue*)sender
{
    UpdateBeaconViewController *updateBeacon = [sender sourceViewController];
    self.item_name = updateBeacon.item_name;
    NSLog(@"Item name is trackview %@",self.item_name);
    self.beaconImage = updateBeacon.itemImage.image;
}

@end
