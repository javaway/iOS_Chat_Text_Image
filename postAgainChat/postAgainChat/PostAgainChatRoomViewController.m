//
//  PostAgainChatRoomViewController.m
//  postAgainChat
//
//  Copyright (c) 2015 iosonfly. All rights reserved.
//

#import "PostAgainChatRoomViewController.h"

#define TABBAR_HEIGHT 49.0f
#define TEXTFIELD_HEIGHT 70.0f
#define MAX_ENTRIES_LOADED 25

@interface PostAgainChatRoomViewController ()

@end

@implementation PostAgainChatRoomViewController{
    BOOL keyboardIsShown;
    float scrollViewHeight;
    float keyboardHeight;
    float selfViewHeight;
    UIActivityIndicatorView *loadingSpinner;
}

@synthesize tfEntry;
@synthesize chatTable;
@synthesize chatData;
@synthesize imageView;
@synthesize scrollView;
@synthesize loggedInUserName;

BOOL isShowingAlertView = NO;
BOOL isFirstShown = YES;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // ImageView
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Img1.jpg"]];
    
    // Textfield
    tfEntry.delegate = self;
    tfEntry.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self registerForKeyboardNotifications];
    
    CGRect tableFrame = self.chatTable.frame;
    tableFrame.size.height = 300;
    self.chatTable.frame = tableFrame;
    
    // UIScrollView
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(320,scrollView.frame.size.height +1)];
    scrollViewHeight = scrollView.frame.size.height;
    selfViewHeight = self.view.frame.size.height;
    scrollView.delaysContentTouches = NO;
    
    // EGORefreshTableHeaderView
    if (_refreshHeaderView == nil) {
        
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - chatTable.bounds.size.height, self.view.frame.size.width, chatTable.bounds.size.height)];
        view.delegate = self;
        [chatTable addSubview:view];
        _refreshHeaderView = view;
    }
    //  update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
    
    // Check for Camera support on simulator
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera support"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status == NotReachable){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network"
                                                        message:[self stringFromStatus: status]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    className = @"postAgainChatData";
    chatData  = [[NSMutableArray alloc] init];
    [self loadLocalChat];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self freeKeyboardNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) imageChatButton : (id)sender{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction) sendChatButton : (id)sender{
    
    if (tfEntry.text.length>0) {
        // updating the table immediately
        NSArray *keys = [NSArray arrayWithObjects:@"text", @"userName", nil];
        
        NSArray *objects = [NSArray arrayWithObjects:tfEntry.text, self.loggedInUserName, nil];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [chatData addObject:dictionary];
        
        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [insertIndexPaths addObject:newPath];
        [chatTable beginUpdates];
        [chatTable insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        [chatTable endUpdates];
        [chatTable reloadData];
        
        // going for the parsing
        PFObject *newMessage = [PFObject objectWithClassName:className];
        [newMessage setObject:tfEntry.text forKey:@"text"];
        [newMessage setObject:self.loggedInUserName forKey:@"userName"];
        //  [newMessage setObject:[NSDate date] forKey:@"date"];
        [newMessage saveInBackground];
        tfEntry.text = @"";
    }
    
    // reload the data
    [self loadLocalChat];
}

-(void) imageSend {
    //Place the loading spinner
    loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingSpinner.center = self.view.center;
    [loadingSpinner startAnimating];
    
    [self.view addSubview:loadingSpinner];
    
    //Take a new picture
    NSData *pictureData = UIImageJPEGRepresentation(imageView.image, 1.0);
    
    PFFile *file = [PFFile fileWithName:@"img" data:pictureData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            if (succeeded){
                
                // test data
                NSArray *keys = [NSArray arrayWithObjects: @"userName",@"image", nil];
                NSArray *objects = [NSArray arrayWithObjects: self.loggedInUserName,self.imageView, nil];
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                [chatData addObject:dictionary];
                
                NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [insertIndexPaths addObject:newPath];
                [chatTable beginUpdates];
                [chatTable insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                [chatTable endUpdates];
                [chatTable reloadData];
                // test data
                
                //Add the image to the object, and add the comments, the user, and the geolocation (fake)
                PFObject *imageObject = [PFObject objectWithClassName:className];
                [imageObject setObject:file forKey:@"image"];
                [imageObject setObject:self.loggedInUserName forKey:@"userName"];
                
                PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:52 longitude:-4];
                [imageObject setObject:point forKey:@"location"];
                
                [imageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded){
                        //Go back to the wall
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else{
                        NSString *errorString = [[error userInfo] objectForKey:@"error"];
                        [self showErrorView:errorString];
                    }
                }];
            }
        }
        else{
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            [self showErrorView:errorString];
        }
        
        [loadingSpinner stopAnimating];
        [loadingSpinner removeFromSuperview];
        
    } progressBlock:^(int percentDone) {
        NSLog(@"percent done is %d",percentDone);
    }];
    
    // reload the data
    [self loadLocalChat];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    // save image on parse
    [self imageSend];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void)showErrorView:(NSString *)errorMsg
{
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [errorAlertView show];
}



- (void) viewDidLayoutSubviews {
    loadingSpinner.center = self.view.center;
}

#pragma mark - Chat textfield

-(IBAction) textFieldDoneEditing : (id) sender
{
    NSLog(@"the text content%@",tfEntry.text);
    [sender resignFirstResponder];
    [tfEntry resignFirstResponder];
}

-(IBAction) backgroundTap:(id) sender
{
    [self.tfEntry resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Keyboard Notifications

-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

-(void) freeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, tfEntry.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, tfEntry.frame.origin.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardDidHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Parse

- (void)loadLocalChat
{
    PFQuery *query = [PFQuery queryWithClassName:className];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    __block int totalNumberOfEntries = 0;
    [query orderByAscending:@"createdAt"];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            // The count request succeeded. Log the count
            NSLog(@"There are currently %d entries", number);
            totalNumberOfEntries = number;
            if (totalNumberOfEntries > [chatData count]) {
                NSLog(@"Retrieving data");
                int theLimit;
                if (totalNumberOfEntries-[chatData count]>MAX_ENTRIES_LOADED) {
                    theLimit = MAX_ENTRIES_LOADED;
                }
                else {
                    theLimit = totalNumberOfEntries-[chatData count];
                }
                query.limit = [NSNumber numberWithInt:theLimit];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        // The find succeeded.
                        NSLog(@"Successfully retrieved %lu chats.", (unsigned long)objects.count);
                        [chatData addObjectsFromArray:objects];
                        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                        for (int ind = 0; ind < objects.count; ind++) {
                            NSIndexPath *newPath = [NSIndexPath indexPathForRow:ind inSection:0];
                            [insertIndexPaths addObject:newPath];
                        }
                        [chatTable beginUpdates];
                        [chatTable insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                        [chatTable endUpdates];
                        [chatTable reloadData];
                        [chatTable scrollsToTop];
                    } else {
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
            }
            
        } else {
            // The request failed, we'll keep the chatData count?
            number = [chatData count];
        }
    }];
}


#pragma mark - Table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chatData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"chatTextIdentifier"];
    NSUInteger row = [chatData count]-[indexPath row]-1;
    
    if (row < chatData.count){
        
        NSString *chatText = [[chatData objectAtIndex:row] objectForKey:@"text"];
        UIFont *font = [UIFont systemFontOfSize:14];
        CGSize size = [chatText sizeWithFont:font constrainedToSize:CGSizeMake(225.0f, 1000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
        cell.textString.frame = CGRectMake(75, 14, size.width +20, size.height + 20);
        cell.textString.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        cell.textString.text = chatText;
        [cell.textString sizeToFit];
        
        
        PFFile *image = (PFFile *)[[chatData objectAtIndex:row] objectForKey:@"image"];
        cell.imageView.image = [UIImage imageWithData:image.getData];
        
        cell.userLabel.text = [[chatData objectAtIndex:row] objectForKey:@"userName"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [[chatData objectAtIndex:chatData.count-indexPath.row-1] objectForKey:@"text"];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 35;
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    _reloading = YES;
    [self loadLocalChat];
    [chatTable reloadData];
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:chatTable];
    
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollViewParam{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollViewParam];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollViewParam willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollViewParam];
    
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

#pragma mark - Connections

- (NSString *)stringFromStatus:(NetworkStatus ) status {
    NSString *string; switch(status) {
        case NotReachable:
            string = @"You are not connected to the internet";
            break;
        case ReachableViaWiFi:
            string = @"Reachable via WiFi";
            break;
        case ReachableViaWWAN:
            string = @"Reachable via WWAN";
            break;
        default:
            string = @"Unknown connection";
            break;
    }
    return string;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Alert View dismissed with button at index %ld",(long)buttonIndex);
    if (buttonIndex != 0) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSLog(@"Plain text input: %@",textField.text);
        userName = textField.text;
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"chatName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        isShowingAlertView = NO;
    }
    else if (isFirstShown){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Ooops"
                              message:@"Something's gone wrong. To post in this room you must have a chat name. Go to the options panel to define one"
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Dismiss", nil];
        [alert show];
        isFirstShown = NO;
    }
    [chatTable setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-TABBAR_HEIGHT)];
}

@end