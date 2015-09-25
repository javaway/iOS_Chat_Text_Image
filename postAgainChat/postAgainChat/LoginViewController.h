//
//  LoginViewController.h
//  postAgainChat
//
//  Created by Hidayathulla on 9/20/15.
//  Copyright (c) 2015 iosonfly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (nonatomic,weak) IBOutlet UILabel *textLabel;
@property(nonatomic, strong) IBOutlet UITextField *userName;
@property (nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)segmentedControlIndexChanged:(id)sender;


@end

