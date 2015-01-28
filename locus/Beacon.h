//
//  Beacon.h
//  locus
//
//  Created by Manav Kedia on 27/01/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Beacon : NSManagedObject

@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * item_name;
@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSString * event;
@property (nonatomic, retain) NSNumber * major;
@property (nonatomic, retain) NSNumber * minor;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * message;

@end
