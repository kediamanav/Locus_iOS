//
//  BeaconUploader.m
//  locus
//
//  Created by Manav Kedia on 01/02/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import "BeaconUploader.h"
#import "AppDelegate.h"

@interface BeaconUploader ()
@property (nonatomic, readwrite, strong) Beacon* beacon;
@end


@implementation BeaconUploader
@synthesize delegate = _delegate;
@synthesize beacon = _beacon;
@synthesize item_name = _item_name;
@synthesize user_name = _user_name;
@synthesize success = _success;

#pragma mark - Life Cycle

- (id)initWithItems:(Beacon *)userBeacon delegate:(id<BeaconUploaderDelegate>) theDelegate {
    
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.beacon = userBeacon;
        self.item_name = userBeacon.item_name;
        self.user_name = userBeacon.user_name;
        self.item_new_name = userBeacon.item_new_name;
        self.success = false;
    }
    return self;
}

/* To recover the managed context object from the app delegate*/
- (NSManagedObjectContext *)managedObjectContext{
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = delegate.coreDataHelper.managedObjectContext;
    return context;
}

-(void)main{
    @autoreleasepool {
        
        NSLog(@"Inside the threaded function, old value : %@, new value :%@",self.item_name,self.item_new_name);
        
        //Creating the key-value pair arrays to hold the post data
        //NSArray *keys = [[NSArray alloc] initWithObjects:@"user_name",@"item_name",@"uuid",@"major",@"minor",@"event",@"action",@"message", nil];
        //NSArray *vals = [[NSArray alloc] initWithObjects:_beacon.user_name,_beacon.item_name, _beacon.uuid, _beacon.major, _beacon.minor, _beacon.event, _beacon.action, _beacon.message , nil];
        //NSLog(@"%@ %@ %@ %ld %ld %ld %ld %@", _beacon.user_name,_beacon.item_name,_beacon.uuid, (long)[_beacon.major integerValue],(long)[_beacon.minor integerValue],(long)[_beacon.event integerValue],(long)[_beacon.action integerValue], _beacon.message);
        
        NSString *post =[[NSString alloc] initWithFormat:@"user_name=%@&item_name=%@&uuid=%@&major=%ld&minor=%ld&event=%ld&action=%ld&message=%@&item_new_name=%@",_beacon.user_name,self.item_name,_beacon.uuid, (long)[_beacon.major integerValue],(long)[_beacon.minor integerValue],(long)[_beacon.event integerValue],(long)[_beacon.action integerValue], _beacon.message, self.item_new_name];
        NSLog(@"PostData: %@",post);
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        NSURL *url=[NSURL URLWithString:@"http://locus-trak.rhcloud.com/login/addUserBeacon"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        
        /*NSMutableData *body = [NSMutableData data];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        // Post data parameters
        for(int i=0;i<[keys count];i++){
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [keys objectAtIndex:i]] dataUsingEncoding:NSASCIIStringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@",[vals objectAtIndex:i]] dataUsingEncoding:NSASCIIStringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        }
        NSLog(@"Body: %@", [[NSString alloc] initWithData:body encoding:NSActivityAutomaticTerminationDisabled ]);*/
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        NSLog(@"Body is set");
        
        
        NSError *error = nil;
        NSHTTPURLResponse *response = nil;
        
        @try {
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            NSLog(@"Response code: %ld", (long)[response statusCode]);
            if ([response statusCode] >=200 && [response statusCode] <300)
            {
                NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                NSLog(@"Response ==> %@", responseData);
                
                SBJsonParser *jsonParser = [SBJsonParser new];
                NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
                NSLog(@"%@",jsonData);
                NSInteger success = [(NSNumber *) [jsonData objectForKey:@"success"] integerValue];
                NSLog(@"%ld",(long)success);
                if(success == 1)
                {
                    NSLog(@"Beacon successfully added to global beacon database");
                    self.success = true;
                }
                else{
                    NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
                    NSLog(@"Beacon could not be added to global database: %@",error_msg);
                }
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
            }
            else {
                if (error)
                    NSLog(@"Error: %@", error);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
            
        }
        @catch (NSException * e) {
            NSLog(@"Beacon could not be added. Exception: %@", e);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        
        
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(beaconUploadDidFinish:) withObject:self waitUntilDone:NO];
        
        /*AFHTTPRequestOperation *datasource_download_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
         [datasource_download_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSData *datasource_data = (NSData *)responseObject;
         
         NSString *responseData = [[NSString alloc]initWithData:datasource_data encoding:NSUTF8StringEncoding];
         NSLog(@"Response ==> %@", responseData);
         
         SBJsonParser *jsonParser = [SBJsonParser new];
         NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
         NSLog(@"%@",jsonData);
         NSInteger success = [(NSNumber *) [jsonData objectForKey:@"success"] integerValue];
         NSLog(@"%ld",(long)success);
         if(success == 1)
         {
         NSLog(@"Beacon successfully added to global database");
         }
         else{
         NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
         NSLog(@"Beacon could not be added to global database: %@",error_msg);
         }
         
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         } failure:^(AFHTTPRequestOperation *operation, NSError *error){
         NSLog(@"Beacon could not be added to global database: %@",error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         }];
         NSLog(@"Before addItem operation");
         [self.pendingOperations.downloadQueue addOperation:datasource_download_operation];
         NSLog(@"After calling addItem operation");
         */
    }
}

@end
