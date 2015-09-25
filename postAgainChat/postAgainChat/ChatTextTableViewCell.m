//
//  chatTextTableViewCell.m
//  postAgainChat
//
//  Created by Hidayathulla on 9/20/15.
//  Copyright (c) 2015 iosonfly. All rights reserved.
//

#import "ChatTextTableViewCell.h"

@implementation ChatTextTableViewCell

@synthesize userLabel;
@synthesize imageView;
@synthesize textString;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.userLabel.frame = CGRectMake(10.0f , 0.0f, 100.0f, 35.0f);
    self.textString.frame = CGRectMake(110.0f , 0.0f, 200.0f, 35.0f);
    self.imageView.frame = CGRectMake(110.0f , 0.0f, 200.0f, 35.0f);
}

@end
