//
//  Items.h
//  locus
//
//  Created by Manav Kedia on 28/03/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Items : NSManagedObject

@property (nonatomic, retain) NSString * item_description;
@property (nonatomic, retain) NSString * item_DOB;
@property (nonatomic, retain) NSNumber * item_eLeashOn;
@property (nonatomic, retain) NSNumber * item_eLeashRange;
@property (nonatomic, retain) NSNumber * item_eLeashType;
@property (nonatomic, retain) NSNumber * item_id;
@property (nonatomic, retain) NSNumber * item_isLost;
@property (nonatomic, retain) NSString * item_lastTracked;
@property (nonatomic, retain) NSString * item_macAddress;
@property (nonatomic, retain) NSNumber * item_modified;
@property (nonatomic, retain) NSString * item_name;
@property (nonatomic, retain) NSData * item_picture;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * item_new_name;

@end
