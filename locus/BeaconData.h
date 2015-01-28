//
//  BeaconData.h
//  locus
//
//  Created by Manav Kedia on 27/01/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeaconData : NSObject
@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSNumber * enable;
@property (nonatomic, retain) NSString * event;
@property (nonatomic, retain) NSNumber * major;
@property (nonatomic, retain) NSNumber * minor;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;

@end
