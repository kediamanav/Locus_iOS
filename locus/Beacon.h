//
//  Beacon.h
//  locus
//
//  Created by Manav Kedia on 28/03/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Beacon : NSManagedObject

@property (nonatomic, retain) NSNumber * action;
@property (nonatomic, retain) NSNumber * event;
@property (nonatomic, retain) NSString * item_name;
@property (nonatomic, retain) NSNumber * major;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * minor;
@property (nonatomic, retain) NSNumber * modified;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * item_new_name;

@end
