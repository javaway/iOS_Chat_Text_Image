//
//  postAgainChatRoomViewController.h
//  postAgainChat
//
//  Created by Gitex4 on 9/20/15.
//  Copyright (c) 2015 iosonfly. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "chatTextTableViewCell.h"
#import "EGORefreshTableHeaderView.h"
#import "Reachability.h"

@interface PostAgainChatRoomViewController : UIViewController <UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource,EGORefreshTableHeaderDelegate,UIImagePickerControllerDelegate,UINavigationBarDelegate>
{
    UITextField             *tfEntry;
    IBOutlet UITableView    *chatTable;
    NSMutableArray          *chatData;
    BOOL                    _reloading;
    NSString                *className;
    NSString                *userName;
    NSString                *loggedInUserName;
    UIImageView             *imageView;
    UIScrollView            *scrollView;
    EGORefreshTableHeaderView *_refreshHeaderView;
}

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) IBOutlet UITextField *tfEntry;
@property (nonatomic, retain) UITableView *chatTable;
@property (nonatomic, retain) NSMutableArray *chatData;
@property (strong, nonatomic) IBOutlet UIButton *imageButton;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic, copy) NSString *loggedInUserName;
@property(nonatomic, strong) IBOutlet UIScrollView *scrollView;


- (IBAction) imageChatButton : (id)sender;
- (IBAction) sendChatButton : (id)sender;

-(void) registerForKeyboardNotifications;
-(void) freeKeyboardNotifications;
-(void) keyboardWasShown:(NSNotification*)aNotification;
-(void) keyboardWillHide:(NSNotification*)aNotification;

- (void)loadLocalChat;

- (NSString *)stringFromStatus:(NetworkStatus )status;

@end