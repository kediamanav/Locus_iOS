//
//  scanBeaconViewController.m
//  sticky
//
//  Created by Manav Kedia on 08/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "scanBeaconViewController.h"
#import "Utility.h"
#import "AppDelegate.h"

@interface scanBeaconViewController (){
BOOL isAppInBackground;
}

@property (nonatomic, strong)NSArray *beacons;
@property (strong, nonatomic) NSMutableArray *regions;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scanner;
@property (weak, nonatomic) IBOutlet UITableView *beaconTable;
@property (weak, nonatomic) IBOutlet UILabel *headerText;
@property NSMutableArray *uuid;
@property NSMutableArray *major;
@property NSMutableArray *minor;

//@property NSUUID *uuid;
//@property NSString *major;
//@property NSString *minor;

@end

@implementation scanBeaconViewController

@synthesize locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.uuid = [[NSUUID alloc] initWithUUIDString:@"01122334-4556-6778-899A-ABBCCDDEEFF0"];
    //self.major = @"0";
    //self.minor = @"0";
    
    self.uuid = [[NSMutableArray alloc] init];
    self.major = [[NSMutableArray alloc] init];
    self.minor = [[NSMutableArray alloc] init];
    
    [self.beaconTable setHidden:YES];
    
    self.beaconTable.backgroundColor = [UIColor clearColor];
    self.beaconTable.backgroundView = [UIView new];
    
    //Call for loading the beacons here and as soon as we get the data display the table view and hide the activity indicator
    //sampleFunctionCall();
    
    //Just putting a simple wait to check the visibilities
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.scanner stopAnimating];
        [self.beaconTable setHidden:NO];
        [self.headerText setText:(@"Devices found!")];
        [self.headerText setTextAlignment:NSTextAlignmentCenter];
    });
    
    
    //Initialize locationManager
    locationManager = [[CLLocationManager alloc]init];
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    locationManager.delegate = self;
    isAppInBackground = NO;
    
    self.regions = [[NSMutableArray alloc]initWithCapacity:[[Utility getBeaconsUUIDS] count]];
    for (int index = 0; index < [[Utility getBeaconsUUIDS] count]; index++)
    {
        [self.regions addObject:[NSNull null]];
    }
    
}


-(void) viewDidAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSLog(@"viewDidAppear Beacons");
    
    for(int regionIndex = 0; regionIndex < [[Utility getBeaconsUUIDS]count]; regionIndex++ )
    {
        
        NSLog(@"Adding region %d with UUID %@",regionIndex, [[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
        if ([[self.regions objectAtIndex:regionIndex] isEqual:[NSNull null]]) {
            NSLog(@"Creating Region %d with UUID %@",regionIndex,[[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
            [self.regions replaceObjectAtIndex:regionIndex withObject:[Utility getRegionAtIndex:regionIndex]];
            [locationManager startMonitoringForRegion:[self.regions objectAtIndex:regionIndex]];
            [locationManager startRangingBeaconsInRegion:[self.regions objectAtIndex:regionIndex]];
        }
        else {
            NSLog(@"Region %d already exist with UUID %@",regionIndex,[[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
        }
        
        /*else {
            NSLog(@"No beacon is found or enable in Region %d with UUID %@",regionIndex,[[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
            
            if (![[self.regions objectAtIndex:regionIndex] isEqual:[NSNull null]]) {
                NSLog(@"Region %d with UUID %@ already exist and now removing it",regionIndex, [[[Utility getBeaconsUUIDS]objectAtIndex:regionIndex]UUIDString]);
                [locationManager stopMonitoringForRegion:[self.regions objectAtIndex:regionIndex]];
                [locationManager stopRangingBeaconsInRegion:[self.regions objectAtIndex:regionIndex]];
                [self.regions replaceObjectAtIndex:regionIndex withObject:[NSNull null]];
            }
        }*/
            
    }
}


- (NSManagedObjectContext *)managedObjectContext{
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = delegate.coreDataHelper.managedObjectContext;
    return context;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"newBeaconSelected"]){
        NSLog(@"Prepare for segue: %@", segue.identifier);
        NSIndexPath *selectedRowIndex = [self.beaconTable indexPathForSelectedRow];
        UINavigationController *segueNavigation = [segue destinationViewController];
        AddBeaconViewController *transferViewController = (AddBeaconViewController *)[[segueNavigation viewControllers] objectAtIndex:0];
        transferViewController.user_name = self.user_name;
        
        //Comment these two lines
        transferViewController.macAddress = [self.beaconTable cellForRowAtIndexPath:selectedRowIndex].textLabel.text;
        NSLog(@"%@, %@",transferViewController.macAddress, transferViewController.user_name);
        
        transferViewController.uuid = [self.uuid objectAtIndex:selectedRowIndex.row];
        transferViewController.major = [self.major objectAtIndex:selectedRowIndex.row];
        transferViewController.minor = [self.minor objectAtIndex:selectedRowIndex.row];
        
    }
}


#pragma mark - Table view data source
//@synthesize beaconTable;


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //Later we have to set this to the count of the number of beacons detected
    return [self.uuid count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.beaconTable dequeueReusableCellWithIdentifier:@"BeaconCell" forIndexPath:indexPath];
    
    // Configure the cell...
    //We have to configure the cell with the beacon properties
    //cell.textLabel.text = @"99:88:77:66:55:44";
    NSString *temp = [NSString stringWithFormat:@"%@ + %@ + %@",[self.uuid objectAtIndex:indexPath.row],[self.major objectAtIndex:indexPath.row],[self.minor objectAtIndex:indexPath.row]];
    cell.textLabel.text = temp;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [UIView new];
    cell.selectedBackgroundView = [UIView new];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"newBeaconSelected" sender:self];
}

- (IBAction) unwindToScanBeacon:(UIStoryboardSegue *)segue{
    
}



#pragma mark - CLLocationManager delegates

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
        
        for(int i = 0; i < [beacons count]; i++) //scanned beacons in Ranging
        {
            
            NSLog(@"Beacon UUID: %@",[[beacons[i] proximityUUID] UUIDString]);
            NSLog(@"Beacon Major: %@",[beacons[i] major]);
            NSLog(@"Beacon Minor: %@",[beacons[i] minor]);
            
            if([beacons[i] proximity] != CLProximityUnknown){
                [self.beaconTable reloadData];
                //Add to the data to be displayed in the tables
                
                NSManagedObjectContext *_context = [self managedObjectContext];
                NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Beacon" inManagedObjectContext:_context];
                NSFetchRequest *request = [[NSFetchRequest alloc]init];
                [request setEntity:entityDesc];
                NSPredicate *predSearch = [NSPredicate predicateWithFormat:@"(uuid = %@) AND (major = %@) AND (minor = %@)"
                                           ,[[beacons[i] proximityUUID] UUIDString],[[beacons[i] major] stringValue],[[beacons[i] minor] stringValue]];
                [request setPredicate:predSearch];
                NSError *error;
                NSArray *matchingRecords = [_context executeFetchRequest:request error:&error];
                if (matchingRecords.count==0) {
                    if (!([self.uuid containsObject:[[beacons[i] proximityUUID] UUIDString]] && [self.major containsObject:[beacons[i] major]] && [self.minor containsObject:[beacons[i] minor]])){
                        [self.uuid addObject:[[beacons[i] proximityUUID] UUIDString]];
                        [self.major addObject:[beacons[i] major]];
                        [self.minor addObject:[beacons[i] minor]];
                    }
                }
            }
        }
        
    }
    else {
        NSLog(@"No beacon found!");
    }
}


@end
