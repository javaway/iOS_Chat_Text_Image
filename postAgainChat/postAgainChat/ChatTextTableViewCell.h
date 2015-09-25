//
//  chatTextTableViewCell.h
//  postAgainChat
//
//  Created by Hidayathulla on 9/20/15.
//  Copyright (c) 2015 iosonfly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatTextTableViewCell : UITableViewCell
{
    IBOutlet UILabel *userLabel;
    IBOutlet UITextView *textString;
    IBOutlet UIImageView *imageView;
}

@property (nonatomic,retain) IBOutlet UILabel *userLabel;
@property (nonatomic,retain) IBOutlet UITextView *textString;
@property (nonatomic,retain) IBOutlet UIImageView *imageView;

@end
