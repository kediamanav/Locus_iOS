//
//  TrackViewController.h
//  locus
//
//  Created by Manav Kedia on 26/01/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <MapKit/MapKit.h>

@interface TrackViewController : UIViewController <CLLocationManagerDelegate>

@property NSString *user_name;
@property (strong) NSString *beaconName;
@property (strong, nonatomic) IBOutlet UIImage *beaconImage;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
