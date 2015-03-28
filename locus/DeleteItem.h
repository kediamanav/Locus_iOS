//
//  DeleteItem.h
//  locus
//
//  Created by Manav Kedia on 28/03/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//
#import <Foundation/Foundation.h>
#include "SBJson.h"

@protocol DeleteItemDelegate;


@interface DeleteItem : NSOperation
@property NSString *item_name;
@property NSString *user_name;
@property BOOL success;

@property (nonatomic, assign) id <DeleteItemDelegate> delegate;

- (id)initWithNames:(NSString *)user_name item:(NSString *)item_name delegate:(id<DeleteItemDelegate>) theDelegate;

@end

@protocol DeleteItemDelegate <NSObject>
- (void)didFinishItemDelete:(DeleteItem *)uploader;
@end




