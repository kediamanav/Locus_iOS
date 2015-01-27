//
//  EventTableViewCell.h
//  locus
//
//  Created by Manav Kedia on 26/01/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@end
