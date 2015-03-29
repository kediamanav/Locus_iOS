//
//  DeleteBeacon.m
//  locus
//
//  Created by Manav Kedia on 28/03/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import "DeleteBeacon.h"
#import "AppDelegate.h"

@implementation DeleteBeacon
@synthesize delegate = _delegate;
@synthesize item_name = _item_name;
@synthesize user_name = _user_name;
@synthesize success = _success;

#pragma mark - Life Cycle

- initWithNames:(NSString *)user_name item:(NSString *)item_name delegate:(id<DeleteBeaconDelegate>) theDelegate{
    
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.item_name = item_name;
        self.user_name = user_name;
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
        
        NSLog(@"Inside the threaded function");
        
        NSLog(@"Inside deleteItem.m, %@, %@",self.user_name,self.item_name);
        //Creating the key-value pair arrays to hold the post data
        NSArray *keys = [[NSArray alloc] initWithObjects:@"user_name",@"item_name", nil];
        NSArray *vals = [[NSArray alloc] initWithObjects:self.user_name,self.item_name, nil];
        
        NSURL *url=[NSURL URLWithString:@"http://locus-trak.rhcloud.com/login/deleteUserBeacon"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        
        NSMutableData *body = [NSMutableData data];
        
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
        
        [request setHTTPBody:body];
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
                    NSLog(@"Beacon successfully deleted from global database");
                    self.success = true;
                }
                else{
                    NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
                    NSLog(@"Beacon could not be deleted from global database: %@",error_msg);
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
            NSLog(@"Beacon could not be deleted. Exception: %@", e);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        
        
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(didFinishBeaconDelete:) withObject:self waitUntilDone:NO];
    }
}

@end
