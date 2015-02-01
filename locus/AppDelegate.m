//
//  AppDelegate.m
//  sticky
//
//  Created by Manav Kedia on 08/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "AppDelegate.h"
#import "Items.h"
#include "Beacon.h"
#include "Users.h"
#include "mainTableViewController.h"

@implementation AppDelegate

@synthesize pendingOperations = _pendingOperations;

#define debug 0

- (NSManagedObjectContext *)getManagedObjectContext{
    NSLog(@"Here here");
    return _coreDataHelper.managedObjectContext;
}

- (CoreDataHelper*)cdh {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (!_coreDataHelper) {
        _coreDataHelper = [CoreDataHelper new];
        [_coreDataHelper setupCoreData];
        NSLog(@"Coredata setup");
    }
    return _coreDataHelper;
}


-(Users *) checkIfUserLoggedIn{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    
    /* For conditional fetching*/
    //NSPredicate *filter = [NSPredicate predicateWithFormat:@"user_name = 'kediamanav'"];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"user_loggedin == %d",[[NSNumber numberWithInt:1] intValue]];
    [request setPredicate:filter];
    
    NSArray *fetchedObjects = [_coreDataHelper.managedObjectContext executeFetchRequest:request error:nil];
    
    for(Users *user in fetchedObjects){
        NSLog(@"password:%@, email:%@, username:%@",user.user_password,user.user_email,user.user_name);
        return user;
    }
    return nil;
}

-(void) checkForModifiedItems{
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Items"];
    
    // For conditional fetching
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"item_modified == %d",[[NSNumber numberWithInt:1] intValue]];
    [fetchRequest setPredicate:filter];
    
    NSArray *fetchedObjects = [_coreDataHelper.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSLog(@"Checking modified");
    for(Items *item in fetchedObjects){
        //This function is supposed to handle both add and update
        //Write php part to handle updates, i.e. modify the entire row if the item exists before with the value being changed
        NSLog(@"Found modified");
        [self startItemUploading:item];
    }
}

-(void) checkForModifiedBeacons{
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Beacon"];
    
    // For conditional fetching
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"modified == %d",[[NSNumber numberWithInt:1] intValue]];
    [fetchRequest setPredicate:filter];
    
    NSArray *fetchedObjects = [_coreDataHelper.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSLog(@"Checking for modified beacon");
    for(Beacon *beacon in fetchedObjects){
        //This function is supposed to handle both add and update
        //Write php part to handle updates, i.e. modify the entire row if the item exists before with the value being changed
        NSLog(@"Found modified");
        NSLog(@"%@ %@ %@ %ld %ld %ld %ld %@", beacon.user_name,beacon.item_name,beacon.uuid, (long)[beacon.major integerValue],(long)[beacon.minor integerValue],(long)[beacon.event integerValue],(long)[beacon.action integerValue], beacon.message);
        [self startBeaconUploading:beacon];
    }
}


#pragma mark -Lazy initialization

- (PendingUploads *)pendingOperations {
    if (!_pendingOperations) {
        NSLog(@"Pending operation existed");
        _pendingOperations = [[PendingUploads alloc] init];
    }
    NSLog(@"Pending operation did not exist");
    return _pendingOperations;
}

- (void)startItemUploading:(Items *)item {
    ItemUploader *itemUploader = [[ItemUploader alloc] initWithItems:item delegate:self];
    [self.pendingOperations.uploadQueue addOperation:itemUploader];
}

- (void)itemUploadDidFinish:(ItemUploader *)uploader {
    
    NSString *item_name = uploader.item_name;
    NSString *user_name = uploader.user_name;
    BOOL success = uploader.success;
    
    //Update here that the item is no longer modified
    if(success==true){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Items"];
        
        // For conditional fetching
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"(user_name=%@) AND (item_name=%@)",user_name,item_name];
        [request setPredicate:filter];
        
        NSError *error = nil;
        Items *item = nil;
        item = [[_coreDataHelper.managedObjectContext executeFetchRequest:request error:&error] lastObject];
        
        if(error){
            NSLog(@"Can't execute fetch request! %@ %@", error, [error localizedDescription]);
        }
        if(item){
            item.item_modified = [NSNumber numberWithInt:(int)0];
            [_coreDataHelper saveContext];
        }
    }
}

- (void)startBeaconUploading:(Beacon *)beacon {
    BeaconUploader *beaconUploader = [[BeaconUploader alloc] initWithItems:beacon delegate:self];
    [self.pendingOperations.uploadQueue addOperation:beaconUploader];
}

- (void)beaconUploadDidFinish:(BeaconUploader *)uploader {
    
    NSString *item_name = uploader.item_name;
    NSString *user_name = uploader.user_name;
    BOOL success = uploader.success;
    
    //Update here that the item is no longer modified
    if(success==true){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Beacon"];
        
        // For conditional fetching
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"(user_name=%@) AND (item_name=%@)",user_name,item_name];
        [request setPredicate:filter];
        
        NSError *error = nil;
        Beacon *beacon = nil;
        beacon = [[_coreDataHelper.managedObjectContext executeFetchRequest:request error:&error] lastObject];
        
        if(error){
            NSLog(@"Can't execute fetch request! %@ %@", error, [error localizedDescription]);
        }
        if(beacon){
            beacon.modified = [NSNumber numberWithInt:(int)0];
            [_coreDataHelper saveContext];
        }
    }
}



#pragma mark - Other functions
-(void)demo{
    /*
     **  Method to add to existing database
     */
    /*NSArray *newItemNames = [NSArray arrayWithObjects:@"Apples", @"Milk", @"Bread", @"Cheese", @"Sausages", @"Butter",@"Orange Juice", @"Cereal", @"Coffee", @"Eggs", @"Tomatoes", @"Fish",nil];
     
     for (NSString *newItemName in newItemNames) {
     Items *newItem =
     [NSEntityDescription insertNewObjectForEntityForName:@"Items" inManagedObjectContext:_coreDataHelper.managedObjectContext];
     newItem.item_name = newItemName;
     NSLog(@"Inserted New Managed Object for '%@'", newItem.item_name);
     }*/
    
    /*
     **  Method to fetch all the objects from the database
     */
    
    
    NSFetchRequest *request1 = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"Items"];
    NSFetchRequest *request3 = [NSFetchRequest fetchRequestWithEntityName:@"Beacon"];
    
    //For sorting the data based on an item_key
    //NSSortDescriptor *sort =[NSSortDescriptor sortDescriptorWithKey:@"item_name" ascending:YES];
    //[request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    //For conditional fetching
    //NSPredicate *filter = [NSPredicate predicateWithFormat:@"item_name!=%@",@"Coffee"];
    //[request setPredicate:filter];
    
    NSArray *fetchedObjects1 = [_coreDataHelper.managedObjectContext executeFetchRequest:request1 error:nil];
    NSArray *fetchedObjects2 = [_coreDataHelper.managedObjectContext executeFetchRequest:request2 error:nil];
    NSArray *fetchedObjects3 = [_coreDataHelper.managedObjectContext executeFetchRequest:request3 error:nil];
    
    for(Beacon *beacon in fetchedObjects3){
        NSLog(@"Fetched Object = %@",beacon.item_name);
        //For deleting an object
        [_coreDataHelper.managedObjectContext deleteObject:beacon];
    }
    
    for(Items *item in fetchedObjects2){
        NSLog(@"Fetched Object = %@",item.item_name);
        //For deleting an object
        [_coreDataHelper.managedObjectContext deleteObject:item];
    }
    
    for(Users *user in fetchedObjects1){
        NSLog(@"Fetched Object = %@",user.user_name);
        //For deleting an object
        [_coreDataHelper.managedObjectContext deleteObject:user];
    }
    
    [_coreDataHelper saveContext];
}

#pragma mark - AppDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if(debug==1){
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    [self cdh];
    //Call this to erase all the item and user data
    [self demo];
    
    
    Users *user=[self checkIfUserLoggedIn];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *homeScreenVC;
    if(user==nil){
        homeScreenVC = [storyboard instantiateInitialViewController];
        mainTableViewController *mainScreen = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        [homeScreenVC setViewControllers:[NSArray arrayWithObjects:mainScreen, nil] animated:NO];
    }
    else{
        homeScreenVC = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"MainNVI"];
        NSLog(@"HERE: %@", user.user_name);
        mainTableViewController *mainScreen = [storyboard instantiateViewControllerWithIdentifier:@"mainTableViewController"];
        mainScreen.user_name = [[NSString alloc] initWithFormat:@"%@", user.user_name];
        mainScreen.loadFromLocal = 1;
        [homeScreenVC setViewControllers:[NSArray arrayWithObjects:mainScreen, nil] animated:NO];
        
    }
    
    self.window.rootViewController = homeScreenVC;
    [self.window makeKeyAndVisible];
    
    [self checkForModifiedItems];
    [self checkForModifiedBeacons];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if(debug==1){
        NSLog(@"Running %@ '%@'",self.class, NSStringFromSelector(_cmd));
    }
    [self setPendingOperations:nil];
    [[self cdh] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
