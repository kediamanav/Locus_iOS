//
//  ImageDownloader.m
//  sticky
//
//  Created by Manav Kedia on 15/12/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;
@end


@implementation ImageDownloader
@synthesize delegate = _delegate;
@synthesize indexPathInTableView = _indexPathInTableView;
@synthesize photoRecord = _photoRecord;

#pragma mark - Life Cycle

- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>)theDelegate {
    
    if (self = [super init]) {
        // 2
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
        self.photoRecord = record;
    }
    return self;
}

#pragma mark - Downloading image

- (void)main {
    
    @autoreleasepool {
        //NSLog(@"Inside ImageDownloader");
        if(_photoRecord.itemImage==false){
            return;
        }
        if (self.isCancelled)
            return;
        
        //NSLog(@"Before loading image data");
        //NSURL *url = [NSURL URLWithString:@"http://locus-trak.rhcloud.com/public/itemImages/kediamanav_nrf%20beacon.jpg"];
        //NSLog(@"URL : %@",[self.photoRecord.URL absoluteString]);
        //NSLog(@"URL : %@",url);
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.photoRecord.URL];
        self.photoRecord.imageData = imageData;
        
        if (self.isCancelled) {
            imageData = nil;
            NSLog(@"Image loading cancelled");
            return;
        }
        
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.photoRecord.image = downloadedImage;
            NSLog(@"Download successful");
        }
        else {
            self.photoRecord.failed = YES;
            NSLog(@"Download failed");
        }
        
        imageData = nil;
        
        if (self.isCancelled)
            return;
        
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
    }
}

@end
