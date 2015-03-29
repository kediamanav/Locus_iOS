//
//  UpdateBeaconViewController.m
//  locus
//
//  Created by Manav Kedia on 28/03/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import "UpdateBeaconViewController.h"

@interface UpdateBeaconViewController ()
- (IBAction)backPressed:(id)sender;

@end

@implementation UpdateBeaconViewController

# pragma mark - on load functions
- (void)viewDidLoad {
    self.capturedImages = [[NSMutableArray alloc] init];
    
    //self.itemImage.image = [UIImage imageNamed:@"item_default.png"];
    self.itemImage.image = self.beaconImage;
    self.itemImage.layer.cornerRadius = self.itemImage.frame.size.width /2;
    self.itemImage.clipsToBounds = YES;
    self.itemName.text = self.item_name;
    
    //Get item description
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Items"];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"(user_name=%@) AND (item_name=%@)",self.user_name,self.item_name];
    [request setPredicate:filter];
    
    NSError *error = nil;
    Items *item = nil;
    item = [[context executeFetchRequest:request error:&error] lastObject];
    
    if(error){
        NSLog(@"Can't execute fetch request! %@ %@", error, [error localizedDescription]);
    }
    if(item){
        self.itemDescription.text = item.item_description;
    }

    self.picTaken = 0;
    
    if([_user_name isEqualToString:@""]){
        [self alertStatus:@"Not logged in" :@"Adding beacon failed!"];
        [self performSegueWithIdentifier:@"unwindSegueToScanBeacon" sender:self];
    }
    self.itemName.delegate=self;
    self.itemDescription.delegate=self;
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

- (IBAction)editButton:(id)sender{
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
            [self.itemImage setImage:[self.capturedImages objectAtIndex:0]];
        }
        else
        {
            [self.itemImage setImage:[self.capturedImages objectAtIndex:self.capturedImages.count-1]];
        }
        
        // To be ready to start again, clear the captured images array.
        self.picTaken = 1;
        [self.capturedImages removeAllObjects];
    }
    
    self.imagePickerController = nil;
}


#pragma mark - Sending the new data to server

/* Create alert if some required field something is missing*/
- (void) alertStatus : (NSString *)msg :(NSString *)title{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertview show];
}

# pragma mark - Save to database

/* Saves to local database*/
- (void) saveToLocalDatabase : (NSString *)item_name :(NSString *) item_description :(NSString *)dateTimeStamp{
    //Add to persistent store here
    
    //Updating Item
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Items"];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"(user_name=%@) AND (item_name=%@)",_user_name,self.item_name];
    [request setPredicate:filter];
    
    //Updating Beacon
    NSFetchRequest *request1 = [NSFetchRequest fetchRequestWithEntityName:@"Beacon"];
    NSPredicate *filter1 = [NSPredicate predicateWithFormat:@"(user_name=%@) AND (item_name=%@)",_user_name,self.item_name];
    [request1 setPredicate:filter1];
    
    NSLog(@"Removing item: %@, from user %@",self.item_name,self.user_name);
    
    NSError *error = nil;
    NSError *error1 = nil;
    Items *item = nil;
    item = [[context executeFetchRequest:request error:&error] lastObject];
    Beacon *beacon = nil;
    beacon = [[context executeFetchRequest:request1 error:&error] lastObject];
    
    if(error|| error1){
        NSLog(@"Can't execute fetch request! %@ %@", error, [error localizedDescription]);
    }
    if(item && beacon){
        item.item_new_name = item_name;
        item.item_description = item_description;
        item.item_lastTracked = dateTimeStamp;
        item.item_modified = [NSNumber numberWithInt:1];
        
        beacon.modified = [NSNumber numberWithInt:1];
        beacon.item_new_name = item_name;
        
        if(self.picTaken == 1){
            NSData *imageData = UIImageJPEGRepresentation(self.itemImage.image, 90);
            item.item_picture = imageData;
        }
        error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            [self alertStatus:[error localizedDescription]:@"Updating beacon Failed!"];
        }
        else{
            [self alertStatus:@"Beacon successfully updated!" : @"Successful"];
        }
    }
}


/* Sends the data of the newly added item to the server*/
- (void) sendDataToServer : (NSString *)item_name :(NSString *) item_description {
    
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
        [self saveToLocalDatabase:item_name :item_description :dateTimeStamp];
    }
}


-(IBAction)updateButton:(id)sender {
    NSString *item_name = _itemName.text;
    NSString *item_description = _itemDescription.text;
    
    NSLog(@"Updated item details : %@, %@, %@", _user_name, item_name, item_description);
    
    //Sends the data to the server, replace with the local database
    [self sendDataToServer: item_name : item_description];
}

- (IBAction)backPressed:(id)sender {
    
}
@end
