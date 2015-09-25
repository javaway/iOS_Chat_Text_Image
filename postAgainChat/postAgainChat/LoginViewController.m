//
//  LoginViewController.m
//  postAgainChat
//
//  Created by Hidayathulla on 9/20/15.
//  Copyright (c) 2015 iosonfly. All rights reserved.
//

#import "LoginViewController.h"
#import "PostAgainChatRoomViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize userName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}



-(IBAction) segmentedControlIndexChanged:(id)sender
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
            break;
        case 1:
            [self performSegueWithIdentifier:@"postAgainChatSegue" sender:self];
            break;
        default: 
            break; 
    } 
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    PostAgainChatRoomViewController *postAgainChatVC = (PostAgainChatRoomViewController *)segue.destinationViewController;
    if (self.userName) {
         [postAgainChatVC setLoggedInUserName: self.userName.text];
    }
   
    
}

#pragma mark - UITextfield

-(IBAction) textFieldDoneEditing : (id) sender
{
    [sender resignFirstResponder];
    [userName resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
