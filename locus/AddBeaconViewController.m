//
//  AddBeaconViewController.m
//  sticky
//
//  Created by Manav Kedia on 15/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "AddBeaconViewController.h"
#import "BeaconDatabase.h"

@interface AddBeaconViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *pictureBeacon;
@property (weak, nonatomic) IBOutlet UITextField *nameBeacon;
@property (weak, nonatomic) IBOutlet UITextView *descriptionBeacon;
- (IBAction)editPressed:(id)sender;

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) NSMutableArray *capturedImages;
@property (nonatomic) NSInteger picTaken;

@property UITextField *activeField;
@property UITextView *activeView;

@property UIActionSheet* attachmentMenuSheet;
@property BeaconDatabase *beaconData;


@end

@implementation AddBeaconViewController

# pragma mark - on load functions
- (void)viewDidLoad {
    self.capturedImages = [[NSMutableArray alloc] init];
    
    self.pictureBeacon.image = [UIImage imageNamed:@"item_default.png"];
    self.pictureBeacon.layer.cornerRadius = self.pictureBeacon.frame.size.width /2;
    self.pictureBeacon.clipsToBounds = YES;
    
    self.tfRange.text = @"0" ;
    self.picTaken = 0;
    
    if([_user_name isEqualToString:@""]){
        [self alertStatus:@"Not logged in" :@"Adding beacon failed!"];
        [self performSegueWithIdentifier:@"unwindSegueToScanBeacon" sender:self];
    }
    else if([_macAddress isEqualToString:@""]){
        [self alertStatus:@"Beacon not identified properly" :@"Adding beacon failed!"];
        [self performSegueWithIdentifier:@"unwindSegueToScanBeacon" sender:self];
    }
    self.nameBeacon.delegate=self;
    self.descriptionBeacon.delegate=self;
    
    self.beaconData = [[BeaconDatabase alloc]init];
}

- (NSManagedObjectContext *)managedObjectContext{
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = delegate.coreDataHelper.managedObjectContext;
    return context;
}


#pragma mark - UITextViewDelegate methods


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeField = textField;
    NSLog(@"TextView: %@",[_activeField text]);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeField = nil;
    //[textField resignFirstResponder];
    [self.view endEditing:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _activeView = textView;
    NSLog(@"TextView: %@",[_activeField text]);
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _activeView = nil;
    //[textField resignFirstResponder];
    [self.view endEditing:YES];
}


#pragma mark - Choose image from camera or from library

- (IBAction)editPressed:(id)sender{
    [self createUIActionSheet];
}

- (void)createUIActionSheet {
    
    _attachmentMenuSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Choose from Gallery", @"Take Photo", nil];
    
    // Show the sheet
    [_attachmentMenuSheet showInView:[UIApplication sharedApplication].keyWindow];
    //[_attachmentMenuSheet showFromRect:attachmentRect inView:textView animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == _attachmentMenuSheet) {
        //FLOG(@"Button %d", buttonIndex);
        switch (buttonIndex) {
                
            case 0:
                //FLOG(@" Choose from Gallery");
                [self choosePicButton];
                break;
                
            case 1:
                //FLOG(@"  Save to Camera Roll");
                [self clickPicButton];
                break;
                
            default:
                break;
        }
    }
}


/*Function to pick images for the gallery*/
- (void)choosePicButton {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

/*Function to click picture from the camera*/
- (void)clickPicButton {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (self.capturedImages.count > 0)
    {
        [self.capturedImages removeAllObjects];
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    [self.capturedImages addObject:image];
    [self finishAndUpdate];
}

 - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    if ([self.capturedImages count] > 0)
    {
        if ([self.capturedImages count] == 1)
        {
            // Camera took a single picture.
            [self.pictureBeacon setImage:[self.capturedImages objectAtIndex:0]];
        }
        else
        {
            [self.pictureBeacon setImage:[self.capturedImages objectAtIndex:self.capturedImages.count-1]];
        }
        
        // To be ready to start again, clear the captured images array.
        self.picTaken = 1;
        [self.capturedImages removeAllObjects];
    }
    
    self.imagePickerController = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Sending the new data to server

/* Create alert if some required field something is missing*/
- (void) alertStatus : (NSString *)msg :(NSString *)title{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertview show];
}

# pragma mark - Save to database

/* Saves to local database*/
- (void) saveToLocalDatabase : (NSString *)item_name :(NSString *) item_description :(NSInteger ) range :(NSInteger ) isLost :(NSInteger ) eLeashOn :(NSString *)dateTimeStamp{
    //Add to persistent store here
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Create a new managed object
    Items *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Items" inManagedObjectContext:context];
    newItem.user_name = _user_name;
    newItem.item_name = item_name;
    newItem.item_description = item_description;
    newItem.item_macAddress = _macAddress;
    newItem.item_isLost = [NSNumber numberWithInt:(int)isLost];
    newItem.item_eLeashRange = [NSNumber numberWithInt:(int)range];
    newItem.item_eLeashOn = [NSNumber numberWithInt:(int)eLeashOn];
    newItem.item_DOB = dateTimeStamp;
    newItem.item_lastTracked = dateTimeStamp;
    newItem.item_modified = [NSNumber numberWithInt:(int)1];
    
    if(self.picTaken == 1){
        NSData *imageData = UIImageJPEGRepresentation(self.pictureBeacon.image, 90);
        newItem.item_picture = imageData;
    }
    else{
        newItem.item_picture = nil;
    }
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        [self alertStatus:[error localizedDescription]:@"Adding beacon Failed!"];
        [self performSegueWithIdentifier:@"unwindSegueToScanBeacon" sender:self];
    }
    else{
        [self alertStatus:@"Adding beacon successful!" : @"Successful"];
        [self performSegueWithIdentifier:@"unwindAfterAddingBeacon" sender:self];
        //Call the save to global database
        //[self saveToGlobalDatabase:newItem];
    }
}

- (int) sendBeaconDataToServer : (NSString *) item_name{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Create a new managed object
    NSLog(@"AddNewBeacon");
    NSLog(@"uuid: %@, major: %@, minor: %@",self.uuid, self.major, self.minor);
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Beacon" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSPredicate *predSearch = [NSPredicate predicateWithFormat:@"(uuid = %@) AND (major = %@) AND (minor = %@)"
                               ,self.uuid,self.major,self.minor];
    [request setPredicate:predSearch];
    NSError *error;
    Beacon *existingBeacon = [[context executeFetchRequest:request error:&error]lastObject];
    if (existingBeacon) {
        NSLog(@"Cant add beacon. it is already present");
    }
    else {
        Beacon *beacon = [NSEntityDescription insertNewObjectForEntityForName:@"Beacon" inManagedObjectContext:context];
        beacon.user_name = _user_name;
        beacon.item_name = item_name;
        beacon.uuid = self.uuid;
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSLog(@"Here");
        //beacon.major = [f numberFromString:self.major];
        beacon.major = [NSNumber numberWithInt:(int)0];
        NSLog(@"Problem here");
        //beacon.minor = [f numberFromString:self.minor];
        beacon.minor = [NSNumber numberWithInt:(int)0];
        NSLog(@"Here");
        
        NSString  *temp = [NSString stringWithFormat:@"%@%@%@", @"Your ", item_name,@" is going out of range."];
        beacon.message = temp;
        NSLog(@"Here");
        beacon.action = [NSNumber numberWithInt:(int)3];
        beacon.event = [NSNumber numberWithInt:(int)3];
        beacon.modified = [NSNumber numberWithInt:(int)1];
        
        NSLog(@"Here");
        
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"Error adding Beacon in Phone");
        }
        else {
            NSLog(@"Beacon is added in Phone");
            return 1;
        }
    }
    return 0;
}


/* Sends the data of the newly added item to the server*/
- (void) sendDataToServer : (NSString *)item_name :(NSString *) item_description :(NSInteger ) range :(NSInteger ) isLost :(NSInteger ) eLeashOn {
    
    //Getting today's date
    NSDate *currentTime = [[NSDate alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTimeStamp = [dateFormat stringFromDate:currentTime];
    NSLog(@"%@",dateTimeStamp);
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    if([item_name isEqualToString:@""]) {
        [self alertStatus:@"Please enter the name of the item" :@"Adding beacon failed!"];
    }
    else{
        [self saveToLocalDatabase:item_name :item_description :range :isLost :eLeashOn :dateTimeStamp];
    }
}

#pragma mark - UI button functionalities

- (IBAction)counterPressed:(id)sender {
    self.tfRange.text = [NSString stringWithFormat:@"%.f", self.rangeCounter.value];
}

- (IBAction)addButtonPressed:(id)sender {
    NSString *item_name = _nameBeacon.text;
    NSString *item_description = _descriptionBeacon.text;
    NSInteger range = _tfRange.text.integerValue;
    NSInteger eLeashOn;
    if(range==0){
        eLeashOn=0;
    }
    else{
        eLeashOn=1;
    }
    NSInteger isLost=0;
    NSLog(@"%@, %@, %@, %@, %ld, %ld, %ld", _user_name, _macAddress, item_name, item_description, (long)range, (long)eLeashOn, (long)isLost);
    
    //Sends the data to the server, replace with the local database
    if ([self sendBeaconDataToServer: item_name]==1){
        [self sendDataToServer: item_name : item_description : range : isLost : eLeashOn];
    }
    else{
        [self alertStatus:@"Failed to add beacon":@"Adding beacon Failed!"];
        [self performSegueWithIdentifier:@"unwindSegueToScanBeacon" sender:self];
    }
}


@end
