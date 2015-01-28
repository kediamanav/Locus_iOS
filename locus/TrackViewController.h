//
//  TrackViewController.h
//  locus
//
//  Created by Manav Kedia on 26/01/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackViewController : UIViewController <UITabBarControllerDelegate>

@property (strong, nonatomic) NSString *user_name;
@property (strong, nonatomic) NSString *item_name;
@property (strong, nonatomic) IBOutlet UIImage *beaconImage;

@end
