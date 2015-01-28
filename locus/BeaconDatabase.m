//
//  BeaconDatabase.m
//  locus
//
//  Created by Manav Kedia on 27/01/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import "BeaconDatabase.h"

@implementation BeaconDatabase

- (NSManagedObjectContext *)managedObjectContext{
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = delegate.coreDataHelper.managedObjectContext;
    return context;
}
- (NSArray *) readAllBeacons{
    NSManagedObjectContext *_context = [self managedObjectContext];
    [_context rollback];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Beacon" inManagedObjectContext:_context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *records = [_context executeFetchRequest:request error:&error];
    if ([records count] == 0) {
        NSLog(@"No Beacon is saved in Phone");
        return nil;
    }
    else {
        return records;
    }
}

- (void) deleteBeacon:(Beacon *)beacon{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:beacon];
    
    NSError *saveError;
    if (![context save:&saveError]) {
        NSLog(@"Error removing beacon from Phone");
    }
    else {
        NSLog(@"Beacon is removed from Phone");
    }
}

- (void) addNewBeacon:(Beacon *)beacon{
    NSLog(@"AddNewBeacon");
    NSLog(@"uuid: %@",beacon.uuid);
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Beacon" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSPredicate *predSearch = [NSPredicate predicateWithFormat:@"(uuid = %@) AND (major = %@) AND (minor = %@)"
                               ,beacon.uuid,beacon.major,beacon.minor];
    [request setPredicate:predSearch];
    NSError *error;
    Beacon *existingBeacon = [[context executeFetchRequest:request error:&error]lastObject];
    if (existingBeacon) {
        NSLog(@"Cant add beacon. it is already present");
    }
    else {
        /*Beacon *newBeacon = (Beacon *)[NSEntityDescription insertNewObjectForEntityForName:@"Beacon" inManagedObjectContext:context];
        [newBeacon setValue:beacon.uuid forKey:@"uuid"];
        [newBeacon setValue:beacon.item_name forKey:@"item_name"];
        [newBeacon setValue:beacon.user_name forKey:@"user_name"];
        [newBeacon setValue:beacon.major forKey:@"major"];
        [newBeacon setValue:beacon.minor forKey:@"minor"];
        [newBeacon setValue:beacon.event forKey:@"event"];
        [newBeacon setValue:beacon.action forKey:@"action"];
        [newBeacon setValue:beacon.message forKey:@"message"];*/
        
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"Error adding Beacon in Phone");
        }
        else {
            NSLog(@"Beacon is added in Phone");
        }
    }
}

- (void) updateBeacon:(Beacon *)beacon{
    //Check if UUID+Major+Minor combination already exist in database
    NSManagedObjectContext *_context = [self managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Beacon" inManagedObjectContext:_context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSPredicate *predSearch = [NSPredicate predicateWithFormat:@"(uuid = %@) AND (major = %@) AND (minor = %@)"
                               ,beacon.uuid,beacon.major,beacon.minor];
    [request setPredicate:predSearch];
    NSError *error;
    NSArray *matchingRecords = [_context executeFetchRequest:request error:&error];
    if (matchingRecords) {
        NSLog(@"number of similar Records: %lu",(unsigned long)matchingRecords.count);
        if (matchingRecords.count > 1) {
            NSLog(@"No update: Duplication has found in Beacons");
        }
        else {
            NSLog(@"No Duplication has found in Beacons, updating ...");
            Beacon *existingBeacon = [matchingRecords lastObject];
            [existingBeacon setValue:beacon.user_name forKey:@"user_name"];
            [existingBeacon setValue:beacon.item_name forKey:@"item_name"];
            [existingBeacon setValue:beacon.uuid forKey:@"uuid"];
            [existingBeacon setValue:beacon.major forKey:@"major"];
            [existingBeacon setValue:beacon.minor forKey:@"minor"];
            [existingBeacon setValue:beacon.event forKey:@"event"];
            [existingBeacon setValue:beacon.action forKey:@"action"];
            [existingBeacon setValue:beacon.message forKey:@"message"];
            
            NSError *saveError;
            if (![_context save:&saveError]) {
                NSLog(@"Error updating Beacon in Phone");
            }
            else {
                NSLog(@"Beacon is updated in Phone");
            }
        }
    }
    else {
        NSLog(@"No matching Beacon has found in database");
    }

}

- (Beacon *) readBeacon: (NSString *)username : (NSString *) itemname{
    NSManagedObjectContext *_context = [self managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Beacon" inManagedObjectContext:_context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSPredicate *predSearch = [NSPredicate predicateWithFormat:@"(user_name = %@) AND (item_name = %@)"
                               ,username,itemname];
    [request setPredicate:predSearch];
    NSError *error;
    NSArray *matchingRecords = [_context executeFetchRequest:request error:&error];
    Beacon *existingBeacon;
    if (matchingRecords) {
        NSLog(@"number of similar Records: %lu",(unsigned long)matchingRecords.count);
        if (matchingRecords.count > 1) {
            NSLog(@"Did Not retrive: Duplication has found in Beacons");
        }
        else {
            NSLog(@"No Duplication has found in Beacons, returning ...");
            
           existingBeacon = [matchingRecords lastObject];
            
            NSError *saveError;
            if (![_context save:&saveError]) {
                NSLog(@"Error updating Beacon in Phone");
            }
            else {
                NSLog(@"Beacon is updated in Phone");
            }
        }
    }
    else {
        NSLog(@"No matching Beacon has found in database");
    }
    return existingBeacon;
}



@end
