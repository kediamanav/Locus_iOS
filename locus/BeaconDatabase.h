//
//  BeaconDatabase.h
//  locus
//
//  Created by Manav Kedia on 27/01/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Beacon.h"
#import "AppDelegate.h"
#import "Utility.h"

@interface BeaconDatabase : NSObject

- (NSArray *) readAllBeacons;
- (void) deleteBeacon:(Beacon *)beacon;
- (int) updateBeacon:(Beacon *)beacon;
- (Beacon *) readBeacon: (NSString *)username : (NSString *)itemname;

@end
