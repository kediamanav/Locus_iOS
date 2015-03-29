//
//  BeaconUploader.h
//  locus
//
//  Created by Manav Kedia on 01/02/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Beacon.h"
#include "SBJson.h"

@protocol BeaconUploaderDelegate;

@interface BeaconUploader : NSOperation

@property NSString *item_name;
@property NSString *user_name;
@property NSString *item_new_name;
@property BOOL success;

@property (nonatomic, assign) id <BeaconUploaderDelegate> delegate;

@property (nonatomic, readonly, strong) Beacon *beacon;

- (id)initWithItems:(Beacon *)userBeacon delegate:(id<BeaconUploaderDelegate>) theDelegate;

@end

@protocol BeaconUploaderDelegate <NSObject>
- (void)beaconUploadDidFinish:(BeaconUploader *)uploader;
@end
