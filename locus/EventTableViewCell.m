//
//  EventTableViewCell.m
//  locus
//
//  Created by Manav Kedia on 26/01/15.
//  Copyright (c) 2015 Manav Kedia. All rights reserved.
//

#import "EventTableViewCell.h"

@implementation EventTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
