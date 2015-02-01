//
//  mainTableViewController.m
//  sticky
//
//  Created by Manav Kedia on 08/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "mainTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Utility.h"
#import "BeaconDatabase.h"
#import "Beacon.h"

@interface mainTableViewController (){
    BOOL isAppInBackground, isActionPerformed;
}

@property NSInteger totalItems;
@property NSInteger itemsLoaded;
@property UIImage *beaconImageDetail;
@property NSString *beaconNameDetail;
@property (nonatomic, strong)NSArray *beacons;
@property (strong, nonatomic) BeaconDatabase *database;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSMutableArray *regions;
@property (strong, nonatomic) NSMutableArray *beaconsRange;
@end

@implementation mainTableViewController

@synthesize user_name;
@synthesize locationManager;
@synthesize audioPlayer;
@synthesize pendingOperations = _pendingOperations;

/* To recover the managed context object from the app delegate*/
- (NSManagedObjectContext *)managedObjectContext{
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = delegate.coreDataHelper.managedObjectContext;
    return context;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _totalItems = 0;
    _itemsLoaded = 0;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_bg.jpg"]];
    self.tableView.backgroundView.alpha = 0.6;
    //Check the username here, passed via segue
    NSLog(@"Username is : %@",self.user_name);
    
    //Allocate the array
    self.items = [[NSMutableArray alloc] init];
    
    //Initialize locationManager
    self.database = [[BeaconDatabase alloc]init];
    locationManager = [[CLLocationManager alloc]init];
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    locationManager.delegate = self;
    isAppInBackground = NO;
    [self initSound];
    
    self.regions = [[NSMutableArray alloc]initWithCapacity:[[Utility getBeaconsUUIDS] count]];
    for (int index = 0; index < [[Utility getBeaconsUUIDS] count]; index++)
    {
        [self.regions addObject:[NSNull null]];
    }
    
    /*self.beacons = [self.database readAllBeacons];
    NSLog(@"Number of beacons found : %lu",(unsigned long)[self.beacons count]);
    isActionPerformed = NO;
    self.beaconsRange = [[NSMutableArray alloc] initWithCapacity:[self.beacons count]];
    for (int index = 0; index < [self.beacons  count]; index++)
    {
        [self.beaconsRange addObject:[NSNull null]];
    }
    [self regionCreators];*/

    
    //Call the function to load the array data for the table
    [self loadTableData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void) regionCreators{
    //[super viewWillAppear:YES];
    NSLog(@"regionCreator Beacons");
    
    /*
     * Create Regions for each unique Beacon UUID provided in the app and these should be fixed and known
     * and assign each region unique identifier
     * if Beacon is saved with one of these provided UUIDs then register Region having that UUID
     * Unregister Region if there is not any saved or enabled Beacon found having that UUID
     */
    
    for(int regionIndex = 0; regionIndex < [[Utility getBeaconsUUIDS]count]; regionIndex++ )
    {
        BOOL isBeaconFound = NO;
        BOOL isLeashEnable = NO;
        
        for(int beaconIndex = 0; beaconIndex < [self.beacons count]; beaconIndex++)
        {
            NSLog(@"Before checking UUID's");
            if ([[[[Utility getBeaconsUUIDS] objectAtIndex:regionIndex] UUIDString] caseInsensitiveCompare:[[self.beacons objectAtIndex:beaconIndex]uuid]]==NSOrderedSame) {
                isBeaconFound = YES;
                if ([(Beacon *)[self.beacons objectAtIndex:beaconIndex]event]) {
                    isLeashEnable = YES;
                }
            }
        }
        //if Beacon/Beacons Found in Region (regionIndex) and
        //atleast one Beacon is enabled in that Region then check the corresponding Region
        // if Region is not exist already then create Region and start Monitoring and Ranging
        if (isBeaconFound && isLeashEnable) {
            NSLog(@"Atleast one Beacon is enable in Region %d with UUID %@",regionIndex, [[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
            if ([[self.regions objectAtIndex:regionIndex] isEqual:[NSNull null]]) {
                NSLog(@"Creating Region %d with UUID %@",regionIndex,[[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
                [self.regions replaceObjectAtIndex:regionIndex withObject:[Utility getRegionAtIndex:regionIndex]];
                [locationManager startMonitoringForRegion:[self.regions objectAtIndex:regionIndex]];
                [locationManager startRangingBeaconsInRegion:[self.regions objectAtIndex:regionIndex]];
            }
            else {
                NSLog(@"Region %d already exist with UUID %@",regionIndex,[[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
            }
            
        }
        // if NO Beacon found or No Beacon is enable in Region (regionIndex) then check the corresponding Region
        // if Region exist already then stop Monitoring and Ranging and assign nil to Region
        else {
            NSLog(@"No beacon is found or enable in Region %d with UUID %@",regionIndex,[[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
            
            if (![[self.regions objectAtIndex:regionIndex] isEqual:[NSNull null]]) {
                NSLog(@"Region %d with UUID %@ already exist and now removing it",regionIndex, [[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
                [locationManager stopMonitoringForRegion:[self.regions objectAtIndex:regionIndex]];
                [locationManager stopRangingBeaconsInRegion:[self.regions objectAtIndex:regionIndex]];
                [self.regions replaceObjectAtIndex:regionIndex withObject:[NSNull null]];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActiveBackground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}


-(void)appDidEnterBackground:(NSNotification *)_notification
{
    isAppInBackground = YES;
    NSLog(@"App is in background");
}

-(void)appDidBecomeActiveBackground:(NSNotification *)_notification
{
    isAppInBackground = NO;
    NSLog(@"App is in foreground");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initSound
{
    NSError *error  = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"low" ofType:@"aiff"]];
    audioPlayer = [[AVAudioPlayer alloc]
                   initWithContentsOfURL:url
                   error:&error];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@",
              [error localizedDescription]);
    } else {
        [audioPlayer prepareToPlay];
    }
}


-(void) viewDidUnload{
    [self setPendingOperations:nil];
}


/*
 **Executed when the user comes back from after the search of beacons
 * so we should again search and see if any new data was added or not
 */
- (IBAction)unwindToList:(UIStoryboardSegue *)seque{
    if(_loadFromLocal==0){
        self.totalItems = 0;
        self.itemsLoaded = 0;
    }
    [self loadTableData];
}

#pragma mark -Lazy initialization

- (PendingOperations *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"itemsloaded: %ld, total: %ld", (long)self.itemsLoaded,(long)self.totalItems);
    if(_loadFromLocal ==0 && self.itemsLoaded == self.totalItems){
        NSLog(@"load from local set");
        _loadFromLocal = 1;
    }
    if([[segue identifier] isEqualToString:@"scanBeaconSegue"]){
        NSLog(@"Prepare for segue: %@", segue.identifier);
        UINavigationController *segueNavigation = [segue destinationViewController];
        scanBeaconViewController *transferViewController = (scanBeaconViewController *)[[segueNavigation viewControllers] objectAtIndex:0];
        transferViewController.user_name = self.user_name;
        NSLog(@"%@", transferViewController.user_name);
    }
    if([[segue identifier] isEqualToString:@"BeaconDetailSegue"]){
        NSLog(@"Prepare for segue: %@", segue.identifier);
        UITabBarController *segueNavigation = [segue destinationViewController];
        NSLog(@"%@",[[segueNavigation viewControllers] objectAtIndex:1]);
        UINavigationController *navController = (UINavigationController *)[[segueNavigation viewControllers] objectAtIndex:0];
        TrackViewController *transferViewController = (TrackViewController *)[[navController viewControllers] objectAtIndex:0];
        transferViewController.user_name = self.user_name;
        NSLog(@"%@", transferViewController.user_name);
        transferViewController.item_name = self.beaconNameDetail;
        NSLog(@"Name OK, %@",transferViewController.item_name);
        transferViewController.beaconImage = self.beaconImageDetail;
    }
}

#pragma mark - Loading from databases

/*
 ** This method is to load the table from local database
 */
- (void) loadFromLocalDatabase{
    
    /*
     **  Method to fetch all the objects from the database
     */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Items"];
    
    /* For conditional fetching*/
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"user_name=%@",user_name];
    [request setPredicate:filter];
    
    //Add to persistent store here
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
    
    NSMutableArray *records = [NSMutableArray array];
    for(Items *item in fetchedObjects){
        NSLog(@"Fetched Object = %@",item.item_name);
        
        beaconClass *item1=[[beaconClass alloc] init];
        item1.name = item.item_name;
        item1.lastTracked = item.item_lastTracked;
        
        NSData *picture_data = item.item_picture;
        PhotoRecord *record = [[PhotoRecord alloc] init];
        //NSLog(@"%@",picture_data);
        if(picture_data==nil){
            //item1.imageData = [UIImage imageNamed:@"item_default.png"];
            record.itemImage = false;
        }
        else{
            item1.imageData = picture_data;
            record.itemImage = true;
            record.loadFromLocal = true;
        }
        [records addObject:record];
        record=nil;
        
        [self.items addObject:item1];
        NSLog(@"Name: %@, Last-tracked: %@",item1.name, item1.lastTracked);
    }
    self.photos = records;
    self.beacons = [self.database readAllBeacons];
    NSLog(@"Number of beacons found : %lu",(unsigned long)[self.beacons count]);
    isActionPerformed = NO;
    self.beaconsRange = [[NSMutableArray alloc] initWithCapacity:[self.beacons count]];
    for (int index = 0; index < [self.beacons  count]; index++)
    {
        [self.beaconsRange addObject:[NSNull null]];
    }
    [self regionCreators];
    
    NSLog(@"Before table reload");
    [self.tableView reloadData];
    NSLog(@"After table reload");
    
}

- (void) loadGlobalItemDatabase{
    NSString *post =[[NSString alloc] initWithFormat:@"user_name=%@",user_name];
    NSLog(@"PostData: %@",post);
    
    NSURL *url=[NSURL URLWithString:@"http://locus-trak.rhcloud.com/login/getUserItems"];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    AFHTTPRequestOperation *datasource_download_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [datasource_download_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData *datasource_data = (NSData *)responseObject;
        
        NSString *responseData = [[NSString alloc]initWithData:datasource_data encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
        
        SBJsonParser *jsonParser = [SBJsonParser new];
        NSArray  *itemList = [jsonParser objectWithString:responseData error:NULL];
        
        NSMutableArray *records = [NSMutableArray array];
        if(![responseData isEqualToString:@"{\"success\":0,\"error_message\":\"\"}"]){
            
            for (NSDictionary *item in itemList){
                
                // Now add it to the CoreData database also
                // Add to persistent store here
                NSManagedObjectContext *context = [self managedObjectContext];
                Items *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Items" inManagedObjectContext:context];
                
                beaconClass *item1=[[beaconClass alloc] init];
                item1.name = [item objectForKey:@"item_name"];
                item1.lastTracked = [item objectForKey:@"item_lastTracked"];
                
                NSString *pictureURL = [item objectForKey:@"item_picture"];
                PhotoRecord *record = [[PhotoRecord alloc] init];
                if(![pictureURL isEqual: [NSNull null]]){
                    NSString *urlString = [pictureURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    record.URL = [NSURL URLWithString:urlString];
                    NSLog(@"pictureURL: %@,",[record.URL absoluteString]);
                    record.itemImage = true;
                }
                else{
                    record.itemImage = false;
                    newItem.item_picture = [[NSData alloc] init];
                }
                
                [records addObject:record];
                record = nil;
                NSLog(@"Size of photos array: %lu", (unsigned long)records.count);
                item1.imageURL = pictureURL;
                
                [self.items addObject:item1];
                NSLog(@"Name: %@, Last-tracked: %@",item1.name, item1.lastTracked);
                
                newItem.user_name = user_name;
                newItem.item_name = [item objectForKey:@"item_name"];
                newItem.item_description = [item objectForKey:@"item_description"];
                newItem.item_macAddress = [item objectForKey:@"item_macAddress"];
                //newItem.item_id = [NSNumber numberWithInt:(int)[[item objectForKey:@"item_id"] integerValue]];
                newItem.item_isLost = [NSNumber numberWithInt:(int)[[item objectForKey:@"item_isLost"] integerValue]];
                newItem.item_eLeashRange = [NSNumber numberWithInt:(int)[[item objectForKey:@"item_eLeashRange"] integerValue]];
                newItem.item_eLeashOn = [NSNumber numberWithInt:(int)[[item objectForKey:@"item_eLeashOn"] integerValue]];
                newItem.item_DOB = [item objectForKey:@"item_DOB"];
                newItem.item_lastTracked = [item objectForKey:@"item_lastTracked"];
                
                //Now save the context
                NSError *error = nil;
                // Save the object to persistent store
                if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
        }
        self.totalItems = self.items.count;
        self.photos = records;
        NSLog(@"Before table reload");
        [self.tableView reloadData];
        NSLog(@"After table reload");
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        alert = nil;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    NSLog(@"Before add operation");
    [self.pendingOperations.downloadQueue addOperation:datasource_download_operation];
    NSLog(@"After calling add operation");
}

- (void) loadGlobalBeaconDatabase{
    NSString *post =[[NSString alloc] initWithFormat:@"user_name=%@",user_name];
    NSLog(@"PostData: %@",post);
    
    NSURL *url=[NSURL URLWithString:@"http://locus-trak.rhcloud.com/login/getUserBeacons"];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *response = nil;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"Response code: %ld", (long)[response statusCode]);
    if ([response statusCode] >=200 && [response statusCode] <300)
    {
        NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
    
    
    
    /*AFHTTPRequestOperation *datasource_download_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"Before sending HTTP request");
    [datasource_download_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Just inside");
        NSData *datasource_data = (NSData *)responseObject;
        
        NSString *responseData = [[NSString alloc]initWithData:datasource_data encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
        */
        SBJsonParser *jsonParser = [SBJsonParser new];
        NSArray  *beaconList = [jsonParser objectWithString:responseData error:NULL];
        
        if(![responseData isEqualToString:@"{\"success\":0,\"error_message\":\"\"}"]){
            
            for (NSDictionary *beacon in beaconList){
                
                // Now add it to the CoreData database also
                // Add to persistent store here
                NSManagedObjectContext *context = [self managedObjectContext];
                Beacon *newBeacon = [NSEntityDescription insertNewObjectForEntityForName:@"Beacon" inManagedObjectContext:context];
                
                newBeacon.user_name = user_name;
                newBeacon.item_name = [beacon objectForKey:@"item_name"];
                newBeacon.uuid = [beacon objectForKey:@"uuid"];
                newBeacon.major = [NSNumber numberWithInt:(int)[[beacon objectForKey:@"major"] integerValue]];
                newBeacon.minor = [NSNumber numberWithInt:(int)[[beacon objectForKey:@"minor"] integerValue]];
                newBeacon.event = [NSNumber numberWithInt:(int)[[beacon objectForKey:@"event"] integerValue]];
                newBeacon.action = [NSNumber numberWithInt:(int)[[beacon objectForKey:@"action"] integerValue]];
                newBeacon.message = [beacon objectForKey:@"message"];
                newBeacon.modified = [NSNumber numberWithInt:0];
                
                //Now save the context
                NSError *error = nil;
                // Save the object to persistent store
                if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
        }
        NSLog(@"Beacon added to beacon database");
        self.beacons = [self.database readAllBeacons];
        NSLog(@"Number of beacons found : %lu",(unsigned long)[self.beacons count]);
        isActionPerformed = NO;
        self.beaconsRange = [[NSMutableArray alloc] initWithCapacity:[self.beacons count]];
        for (int index = 0; index < [self.beacons  count]; index++)
        {
            [self.beaconsRange addObject:[NSNull null]];
        }
        [self regionCreators];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } /*failure:^(AFHTTPRequestOperation *operation, NSError *error){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        alert = nil;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];*/
}

/*
 ** Load from the global database and also add to the local database
 */
- (void) loadFromGlobalDatabase{
    if([user_name isEqualToString:@""]) {
        [self alertStatus:@"Not logged in" :@"Error!"];
    } else {
        [self loadGlobalBeaconDatabase];
        [self loadGlobalItemDatabase];
    }
}

/*
 **This function loads the table with the data from the server
 */
- (void)loadTableData{
    
    //Load the data into the array, this is from the server
    //First clear the array and then load data into the array
    [self.items removeAllObjects];
    [self.photos removeAllObjects];
    
    //Choose between the 2 based on whether the database exists or not
    if(_loadFromLocal==1){
        NSLog(@"LOCAL");
        [self loadFromLocalDatabase];
    }
    else{
        //Clear the local database
        NSLog(@"GLOBAL ITEMS AND BEACONS");
        NSFetchRequest *request1 = [NSFetchRequest fetchRequestWithEntityName:@"Items"];
        NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"Beacon"];
        
        //For conditional fetching
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"user_name=%@",user_name];
        [request1 setPredicate:filter];
        [request2 setPredicate:filter];
        
        //Add to persistent store here
        NSManagedObjectContext *context = [self managedObjectContext];
        
        NSArray *fetchedObjects1 = [context executeFetchRequest:request1 error:nil];
        NSArray *fetchedObjects2 = [context executeFetchRequest:request2 error:nil];
        
        for(Items *item in fetchedObjects1){
            //For deleting an object
            [context deleteObject:item];
        }
        for(Beacon *beacon in fetchedObjects2){
            //For deleting an object
            [context deleteObject:beacon];
        }
        [self loadFromGlobalDatabase];
    }
}

- (void) alertStatus : (NSString *)msg :(NSString *)title{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertview show];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    BeaconTableViewCell *cell = (BeaconTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    
    /*if (cell == nil)
     {
     NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListPrototypeCell" owner:self options:nil];
     cell = [nib objectAtIndex:0];
     }*/
    // Configure the cell...
    beaconClass *curItem = [self.items objectAtIndex:indexPath.row];
    cell.nameLabel.text = curItem.name;
    //cell.lastTrackedLabel.text = [self getBeaconRange:[self.beaconsRange objectAtIndex:indexPath.row]];
    cell.lastTrackedLabel.text=curItem.lastTracked;
    
    PhotoRecord *aRecord = [self.photos objectAtIndex:indexPath.row];
    NSLog(@"LoadFromLocal from phptorecord: %d",aRecord.loadFromLocal);
    
    if(aRecord.loadFromLocal){
        [cell.activityBar setHidden:true];
        cell.thumbnailImage.image = [UIImage imageWithData:curItem.imageData];
    }
    else if(!(aRecord.itemImage)||aRecord.isFailed){
        [cell.activityBar stopAnimating];
        [cell.activityBar setHidden:true];
        cell.thumbnailImage.image = [UIImage imageNamed:@"item_default.png"];
        //Increase the number of items loaded
        self.itemsLoaded = self.itemsLoaded +1;
    }
    else if (aRecord.hasImage) {
        [cell.activityBar stopAnimating];
        [cell.activityBar setHidden:true];
        cell.thumbnailImage.image = aRecord.image;
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Items"];
        
        // For conditional fetching
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"(user_name=%@) AND (item_name=%@)",user_name,curItem.name];
        [request setPredicate:filter];
        
        //Add to persistent store here
        NSManagedObjectContext *context = [self managedObjectContext];
        
        NSError *error = nil;
        Items *item = nil;
        item = [[context executeFetchRequest:request error:&error] lastObject];
        
        if(error){
            NSLog(@"Can't execute fetch request! %@ %@", error, [error localizedDescription]);
        }
        if(item){
            item.item_picture = aRecord.imageData;
            error = nil;
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            else{
                //Increase the number of items loaded
                self.itemsLoaded = self.itemsLoaded +1;
            }
        }
        //cell.thumbnailImage.image = [UIImage imageWithData:item.item_picture];
    }
    else {
        [cell.activityBar startAnimating];
        [self startOperationsForPhotoRecord:aRecord atIndexPath:indexPath];
    }
    
    /*UIImage *cellImage;
     if([curItem.imageURL isEqual: [NSNull null]]){
     cellImage = [UIImage imageNamed:@"item_default.png"];
     }
     else{
     NSURL *imageURL = [NSURL URLWithString:curItem.imageURL];
     NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
     cellImage = [UIImage imageWithData:imageData];
     }
     cell.thumbnailImage.image = cellImage;*/
    
    
    cell.thumbnailImage.layer.cornerRadius = cell.thumbnailImage.frame.size.width /2;
    cell.thumbnailImage.clipsToBounds = YES;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [UIView new];
    cell.selectedBackgroundView = [UIView new];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BeaconTableViewCell *curItem = (BeaconTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    self.beaconImageDetail = curItem.thumbnailImage.image;
    self.beaconNameDetail = curItem.nameLabel.text;
    [self performSegueWithIdentifier:@"BeaconDetailSegue" sender:self];
}

- (void)startOperationsForPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    
    if (!record.hasImage) {
        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
    }
}

- (void)startImageDownloadingForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld",(long)indexPath.row);
    NSLog(@"Inside the startImageDownloadingForRecord function");
    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath]) {
        NSLog(@"URL : %@",[record.URL absoluteString]);
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
}

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}


-(NSString *)getBeaconRange:(NSNumber *)range
{
    if ([range isEqual:[NSNull null]]) {
        return @"Beacon Not Found";
    }
    switch([range intValue]) {
        case 0:
            return @"At beacon";
        case 1:
            return @"Near";
        case 2:
            return @"Far";
        case 3:
            return @"Unknown";
        default:
            return @"Invalid Location";
    }
    
}

-(void)showBackgroundAlert:(NSString *)message
{
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.alertAction = @"Show";
    notification.alertBody = message;
    notification.hasAction = NO;
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    notification.timeZone = [NSTimeZone  defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
}

-(void)showForegroundAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"nRF Beacons" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}


- (void)showMonalisa
{
    //[self performSegueWithIdentifier:@"MonalisaSegue" sender:self];
}

- (void)openWebsite
{
    //if ([self isInternetConnectionAvailable]) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.nordicsemi.com"]];
    //}
    //else {
    //    [self showForegroundAlert:@"Internet connection not availble to open website"];
    //}
}

- (void)playAlarm
{
    [audioPlayer play];
}

#pragma mark - CLLocationManager delegates

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"*****didEnterRegion******");
    
    [self performActionForEvent:[NSNumber numberWithInt:4] withIdentifier:region.identifier];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"***********didExitRegion***********");
    [self performActionForEvent:[NSNumber numberWithInt:3] withIdentifier:region.identifier];
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"didStartMonitoringForRegion");
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"didRangeBeacons");
    if ([beacons count] > 0) {
        NSLog(@"beacons founds: %lu",(unsigned long)[beacons count]);
        CLBeacon *beacon = [beacons objectAtIndex:0];
        
        
        NSLog(@"Beacons UUID: %@",beacon.proximityUUID);
        NSLog(@"Beacons Major: %@",beacon.major);
        NSLog(@"Beacons Minor: %@",beacon.minor);
        
        
        for(int i = 0; i < [beacons count]; i++) //scanned beacons in Ranging
        {
            for(int j=0; j<[self.beacons count]; j++) //stored beacons in database
            {
                if (([[[beacons[i] proximityUUID] UUIDString] caseInsensitiveCompare:[self.beacons[j] uuid]]==NSOrderedSame) &&
                    ([[beacons[i] major] integerValue] == [[self.beacons[j] major] integerValue]) &&
                    ([[beacons[i] minor] integerValue] == [[self.beacons[j] minor] integerValue]) &&
                    ([(Beacon *)self.beacons[j] event]))
                {
                    NSLog(@"Found Beacon and enabled");
                    NSLog(@"Beacon UUID: %@",[beacons[i] proximityUUID]);
                    NSLog(@"Beacon Major: %@",[beacons[i] major]);
                    NSLog(@"Beacon Minor: %@",[beacons[i] minor]);
                    
                    //Finding Scanned Beacon Proximity and converting it to the Event of stored Beacon
                    if ([beacons[i] proximity] == CLProximityImmediate) {
                        NSLog(@"Immidiate Proximity: %@",beacon.proximityUUID);
                        [self.beaconsRange replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:At_Beacon]];
                        //[self.tableView reloadData];
                        if ([[self.beacons[j] event] integerValue]==1) {
                            NSLog(@"Close Event matched");
                            [self performAction:[self.beacons[j] action]];
                        }
                    }
                    else if ([beacons[i] proximity] == CLProximityNear) {
                        NSLog(@"Near Proximity: %@",beacon.proximityUUID);
                        [self.beaconsRange replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:NEAR]];
                        //[self.tableView reloadData];
                        if ([[self.beacons[j] event] integerValue]==2) {
                            NSLog(@"Near Event matched");
                            [self performAction:[self.beacons[j] action]];
                        }
                    }
                    else if ([beacons[i] proximity] == CLProximityFar) {
                        NSLog(@"Far Proximity: %@",beacon.proximityUUID);
                        [self.beaconsRange replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:FAR]];
                        //[self.tableView reloadData];
                    }
                    else if ([beacons[i] proximity] == CLProximityUnknown) {
                        NSLog(@"Unknown Proximity: %@",beacon.proximityUUID);
                        [self.beaconsRange replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:UNKNOWN]];
                        //[self.tableView reloadData];
                        
                    }
                    
                }
            }
        }
        
    }
    else {
        NSLog(@"No beacon found!");
    }
}

//Perform actions on Ranging Events Near and Close
- (void)performAction:(NSNumber *)action
{
    NSLog(@"Action number: %ld",(long)[action integerValue]);
    if(!isActionPerformed) {
        if([action integerValue]==1) {
            NSLog(@"showMonalisa");
            if (isAppInBackground) {
                [self showBackgroundAlert:@"Mona Lisa"];
            }
            [self showMonalisa];
            isActionPerformed = YES;
        }
        else if([action integerValue]==2) {
            NSLog(@"Open Website");
            [self openWebsite];
            if (isAppInBackground) {
                [self showBackgroundAlert:@"Nordic Semiconductor"];
            }
            isActionPerformed = YES;
        }
        else if([action integerValue]==3) {
            NSLog(@"Playing Alarm");
            [self playAlarm];
            if (isAppInBackground) {
                [self showBackgroundAlert:@"Playing Alarm"];
            }
        }
    }
}

//Perform actions for Regions event Enter and Exit
- (void)performActionForEvent:(NSNumber *)event withIdentifier:(NSString *)identifier
{
    NSString *regionUUIDFromIdentifier = [self getRegionUUIDFromIdentifier:identifier];
    NSLog(@"Performing action for event: %@ RegionUUID %@",event,regionUUIDFromIdentifier);
    for(int index = 0; index < [self.beacons count]; index ++)
    {
        if (([regionUUIDFromIdentifier caseInsensitiveCompare:[self.beacons[index] uuid]]==NSOrderedSame)  &&
            ([(Beacon *)self.beacons[index] event])) {
            NSLog(@"*******Beaon found with Exit or Enter Event Now changing Ranging Status to nil ***********");
            [self.beaconsRange replaceObjectAtIndex:index withObject:[NSNull null]];
            //[self.tableView reloadData];
            if ([self.beacons[index] event]==event) {
                if ([[self.beacons[index] action] isEqualToString:@"Show Mona Lisa"]) {
                    NSLog(@"showMonalisa");
                    if (isAppInBackground) {
                        [self showBackgroundAlert:@"Mona Lisa"];
                    }
                    [self showMonalisa];
                    return;
                }
                else if ([[self.beacons[index] action] isEqualToString:@"Open Website"]) {
                    NSLog(@"Open Website");
                    if (isAppInBackground) {
                        [self showBackgroundAlert:@"Nordic Semiconductor ASA"];
                    }
                    [self openWebsite];
                    return;
                }
                else if ([[self.beacons[index] action] isEqualToString:@"Play Alarm"]) {
                    NSLog(@"Playing Alarm");
                    if (isAppInBackground) {
                        [self showBackgroundAlert:@"Playing Alarm"];
                    }
                    [self playAlarm];
                    return;
                }
            }
        }
    }
}

- (NSString *) getRegionUUIDFromIdentifier:(NSString *)regionIdentifier
{
    if ([regionIdentifier isEqualToString:@"Nordic Semiconductor ASA 1"]) {
        return [[[Utility getBeaconsUUIDS]objectAtIndex:0]UUIDString];
    }
    else if ([regionIdentifier isEqualToString:@"Nordic Semiconductor ASA 2"]) {
        return [[[Utility getBeaconsUUIDS]objectAtIndex:1]UUIDString];
    }
    else if ([regionIdentifier isEqualToString:@"Nordic Semiconductor ASA 3"]) {
        return [[[Utility getBeaconsUUIDS]objectAtIndex:2]UUIDString];
    }
    else if ([regionIdentifier isEqualToString:@"Nordic Semiconductor ASA 4"]) {
        return [[[Utility getBeaconsUUIDS]objectAtIndex:3]UUIDString];
    }
    return nil;
}



@end
