//
//  GroupListViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/1.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "GroupListViewController.h"

@interface GroupListViewController ()

@end

@implementation GroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initiation of userdefaults and arrays
    [self InitArray];
    
    // Setup Chatkit
    [self ChatkitSetup];
    
    // Get portrait of currentuser
    [self GetPortrait];
    
    // Navigation items setting
    [self SetupNaviItem];
    
    // Register notification centers
    [self RegisterNotiCenter];
    
    // Initiation of refresher
    [self InitRefresher];
}

- (void)InitRefresher {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self
                            action:@selector(controlEventValueChanged:)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)controlEventValueChanged:(id)sender {
    if (self.refreshControl.refreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
        [self performSelector:@selector(DragToRefresh) withObject:nil afterDelay:0.3];
    }
}

- (void)DragToRefresh {
    [self RefreshData];
    [self.refreshControl endRefreshing];
}

- (void)InitArray {
    AVUser *currentUser = [AVUser currentUser];
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    users = [[NSMutableArray alloc] initWithCapacity:0];
    JoinedTopic = [NSMutableArray arrayWithArray:[userDefaults arrayForKey:[@"GLArrayJoinedTopic" stringByAppendingString:currentUser.objectId]]];
    JoinedCreator = [NSMutableArray arrayWithArray:[userDefaults arrayForKey:[@"GLArrayJoinedCreator" stringByAppendingString:currentUser.objectId]]];
    JoinedGroupId = [NSMutableArray arrayWithArray:[userDefaults arrayForKey:[@"GLArrayJoinedGroupId" stringByAppendingString:currentUser.objectId]]];
    InvitedTopic = [NSMutableArray arrayWithArray:[userDefaults arrayForKey:[@"GLArrayInvitedTopic" stringByAppendingString:currentUser.objectId]]];
    Inviter = [NSMutableArray arrayWithArray:[userDefaults arrayForKey:[@"GLArrayInviter" stringByAppendingString:currentUser.objectId]]];
    InvitedGroupId = [NSMutableArray arrayWithArray:[userDefaults arrayForKey:[@"GLArrayInvitedGroupId" stringByAppendingString:currentUser.objectId]]];
    
    [self RefreshData];
}

- (void)RegisterNotiCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GotoJoinin:) name:@"JoininNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GotoCreate:) name:@"CreateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GroupCreated:) name:@"CreateGroupNotification" object:nil];
}

- (void)SetupNaviItem {
    self.title = @"Groups";
    
    UIBarButtonItem *LogoutButton = [[UIBarButtonItem alloc] initWithTitle:@"➖" style:UIBarButtonItemStylePlain target:self action:@selector(Logout:)];
    self.navigationItem.leftBarButtonItem = LogoutButton;
    
    UIBarButtonItem *AddButton = [[UIBarButtonItem alloc] initWithTitle:@"➕" style:UIBarButtonItemStylePlain target:self action:@selector(AddGroup:)];
    self.navigationItem.rightBarButtonItem = AddButton;
}

- (void)GetPortrait {
    AVUser *currentUser = [AVUser currentUser];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *File = [[currentUser objectForKey:@"PortraitUrl"] substringWithRange:NSMakeRange(31, 23)];
    NSString *Filename = [File stringByAppendingString:@".jpg"];
    NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:Filename];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    if (!blHave) {
        UIImage *Portrait = [self getImageFromURL:[currentUser objectForKey:@"PortraitUrl"]];
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        [self saveImage:Portrait withFileName:File ofType:@"jpg" inDirectory:documentsDirectoryPath];
    }
}

- (void)ChatkitSetup {
    AVUser *currentUser = [AVUser currentUser];
    
    [AVIMClient setTimeoutIntervalInSeconds:20];
    [LCCKInputViewPluginTakePhoto registerSubclass];
    [LCCKInputViewPluginPickImage registerSubclass];
    [LCCKInputViewPluginLocation registerSubclass];
    
    [self SetAppInfo];
    [self FetchProfiles];
    [self SetupConversationInvalidedHandler];
    [self SetupLoadLatestMessages];
    [self SetupLongPressMessage];
    [self SetupForceReconect];
    
    [[LCChatKit sharedInstance]
     openWithClientId:currentUser.objectId
     callback:^(BOOL succeeded, NSError *error) {
         if (succeeded) {
             NSUserDefaults *defaultsSet = [NSUserDefaults standardUserDefaults];
             [defaultsSet setObject:nil forKey:currentUser.objectId];
             [defaultsSet synchronize];
         } else {
             NSLog(@"Failed to login: %@",error);
         }
     }];
}

- (void)SetAppInfo {
    [LCChatKit setAppId:@"uHJ7ToKFNLSGbR7elEchJcsV-gzGzoHsz" appKey:@"jCoBvWXyj63DBUprSuN2tn6d"];
}

- (void)FetchProfiles {
    [[LCChatKit sharedInstance] setFetchProfilesBlock:^(NSArray<NSString *> *userIds, LCCKFetchProfilesCompletionHandler completionHandler) {
        [users removeAllObjects];
        
        if (userIds.count == 0) {
            NSInteger code = 0;
            NSString *errorReasonText = @"User ids is nil";
            NSDictionary *errorInfo = @{
                                        @"code":@(code),
                                        NSLocalizedDescriptionKey : errorReasonText,
                                        };
            NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                                 code:code
                                             userInfo:errorInfo];
            
            !completionHandler ?: completionHandler(nil, error);
            return;
        }else {
            // Query for these users
            for (NSInteger i = 0; i < [userIds count]; i++) {
                AVQuery *query = [AVQuery queryWithClassName:@"_User"];
                [query getObjectInBackgroundWithId:[userIds objectAtIndex:i] block:^(AVObject *object, NSError *error) {
                    NSString *name = [object objectForKey:@"username"];
                    NSURL *avatarURL = [object objectForKey:@"PortraitUrl"];
                    NSString *clientId = [userIds objectAtIndex:i];
                    LCCKUser *user_ = [LCCKUser userWithUserId:[userIds objectAtIndex:i]
                                                          name:name
                                                     avatarURL:avatarURL
                                                      clientId:clientId];
                    [users addObject:user_];
                    NSLog(@"here1: %@",users);
                }];
                NSLog(@"here2: %@",users);
            }
            NSLog(@"here3: %@",users);
            !completionHandler ?: completionHandler([users copy], nil);
        }
    }];
}

- (void)SetupConversationInvalidedHandler {
    [[LCChatKit sharedInstance] setConversationInvalidedHandler:^(NSString *conversationId, LCCKConversationViewController *conversationController, id<LCCKUserDelegate> administrator, NSError *error) {
        NSLog(@"Failed to create a conversation: %@",error);
        //Error code list：https://leancloud.cn/docs/realtime_v2.html#%E4%BA%91%E7%AB%AF%E9%94%99%E8%AF%AF%E7%A0%81%E8%AF%B4%E6%98%8E
    }];
}

- (void)SetupLongPressMessage {
    [[LCChatKit sharedInstance] setLongPressMessageBlock:^NSArray<UIMenuItem *> *(
                                                                                  LCCKMessage *message, NSDictionary *userInfo) {
        LCCKMenuItem *copyItem = [[LCCKMenuItem alloc]
                                  initWithTitle:LCCKLocalizedStrings(@"copy")
                                  block:^{
                                      UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                      [pasteboard setString:[message text]];
                                  }];
        
        LCCKConversationViewController *conversationViewController =
        userInfo[LCCKLongPressMessageUserInfoKeyFromController];
        // Menu and corresponding operation
        LCCKMenuItem *transpondItem = [[LCCKMenuItem alloc]
                                       initWithTitle:LCCKLocalizedStrings(@"transpond")
                                       block:^{
                                           [self TranspondMessage:message
                                          toConversationViewController:conversationViewController];
                                       }];
        NSArray *menuItems = [NSArray array];
        if (message.mediaType == kAVIMMessageMediaTypeText) {
            menuItems = @[ copyItem, transpondItem ];
        }
        return menuItems;
    }];
}

- (void)TranspondMessage:(LCCKMessage *)message
 toConversationViewController:(LCCKConversationViewController *)conversationViewController {
    LCCKLog(@"Transpond the message");
}

- (void)SetupLoadLatestMessages {
    [[LCChatKit sharedInstance]
     setLoadLatestMessagesHandler:^(LCCKConversationViewController *conversationController, BOOL succeeded, NSError *error) {
         if (!succeeded) {
             NSLog(@"Failed to load previous chat record: %@",error);
             
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failed in loading previous chat record!" message:nil preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
             [alertController addAction:cancelAction];
             [self presentViewController:alertController animated:YES completion:nil];
         }
     }];
}

- (void)SetupForceReconect {
    [[LCChatKit sharedInstance] setForceReconnectSessionBlock:^(
                                                                NSError *aError, BOOL granted,
                                                                __kindof UIViewController *viewController,
                                                                LCCKReconnectSessionCompletionHandler completionHandler) {

        // User says yes
        if (granted == YES) {
            BOOL force = (aError.code == 4111);
            [[LCChatKit sharedInstance]  openWithClientId:[LCChatKit sharedInstance].clientId  force:force  callback:^(BOOL succeeded, NSError *error) {
                if (error != nil) {
                    NSLog(@"Failed to reconnect: %@",error);
                }
            }];
            return;
        }else {    // User says no. Pop back to the LoginView
            [AVUser logOut];
            
            UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"FirstPage"];
            [self presentViewController:vc animated:YES completion:nil];
        }
        
        // - 显示返回信息
        NSInteger code = 0;
        NSString *errorReasonText = @"not granted";
        NSDictionary *errorInfo = @{
                                    @"code" : @(code),
                                    NSLocalizedDescriptionKey : errorReasonText,
                                    };
        NSError *error =
        [NSError errorWithDomain:NSStringFromClass([self class]) code:code userInfo:errorInfo];
        !completionHandler ?: completionHandler(NO, error);
    }];
}

- (void)GroupCreated:(NSNotification *) notification {
    [self RefreshData];
}

- (void)GotoJoinin:(NSNotification *) notification {
    UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"JoininGroup"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)GotoCreate:(NSNotification *) notification {
    UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"CreateGroup"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)Logout:(id)sender {
    [AVUser logOut];
    
    [[LCChatKit sharedInstance] removeAllCachedProfiles];
    [[LCChatKit sharedInstance] closeWithCallback:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Logout success");
        } else {
            NSLog(@"Failed to logout: %@",error);
        }
    }];
    
    UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"FirstPage"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)AddGroup:(id)sender {
    HowToAddViewController *Table = [[HowToAddViewController alloc] init];
    Table.preferredContentSize = CGSizeMake(150, 87);
    Table.modalPresentationStyle = UIModalPresentationPopover;
    Table.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    Table.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    Table.popoverPresentationController.delegate = self;
    [self presentViewController:Table animated:YES completion:nil];
}

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    NSLog(@"Downloading Image");
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}

-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        NSLog(@"Not jpg");
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    static NSString * CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (row < [JoinedGroupId count] && [JoinedGroupId count] != 0) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.userInteractionEnabled = YES;
        cell.imageView.image = [UIImage imageNamed:@"bulb.png"];
        cell.textLabel.text = [JoinedTopic objectAtIndex:row];
        cell.detailTextLabel.text = [@"Created by " stringByAppendingString:[JoinedCreator objectAtIndex:row]];
    }else if (row < [JoinedGroupId count]+[InvitedGroupId count] && [InvitedGroupId count] != 0) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"InvitationLetterViewCell" owner:nil options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *JoinedTopicLabel = (UILabel *)[cell viewWithTag:1];
        JoinedTopicLabel.text = [@"【Invitation】" stringByAppendingString:[InvitedTopic objectAtIndex:row-[JoinedGroupId count]]];
        UILabel *JoinedCreatorLabel = (UILabel *)[cell viewWithTag:2];
        JoinedCreatorLabel.text = [@"Created by " stringByAppendingString:[Inviter objectAtIndex:row-[JoinedGroupId count]]];
        UIButton *YesButton = (UIButton *)[cell viewWithTag:3];
//        UIButton *NoButton = (UIButton *)[cell viewWithTag:4];
//        UIButton *MoreInfo = (UIButton *)[cell viewWithTag:5];
        
        // Use tag to transfer
        [YesButton setTag:row];
        [YesButton addTarget:self action:@selector(AgreeToJoin:) forControlEvents:UIControlEventTouchUpInside];
    }else {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.userInteractionEnabled = NO;
    }
    return cell;
}

- (void)AgreeToJoin:(UIButton *)TapYes {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Agree to join in this group?" message:[@"Topic: " stringByAppendingString:[InvitedTopic objectAtIndex:TapYes.tag-[JoinedGroupId count]]] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // Todo: delete invitations; renew involved list (cloud and singleton); renew grouplist; get into the group
        AVUser *currentUser = [AVUser currentUser];
        
        // Delete invitations
        AVQuery *query = [AVQuery queryWithClassName:@"Invitation"];
        [query whereKey:@"InvitedId" equalTo:currentUser.objectId];
        [query whereKey:@"InvitedToGroup" equalTo:[InvitedGroupId objectAtIndex:TapYes.tag-[JoinedGroupId count]]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (NSInteger i = 0; i < [objects count]; i++) {
                [[objects objectAtIndex:i] deleteInBackground];
            }
            
            // renew involved list (cloud)
            NSArray *PreviousInvolved = [currentUser objectForKey:@"GroupInvolved"];
            NSMutableArray *NewInvolved = [NSMutableArray arrayWithArray:PreviousInvolved];
            [NewInvolved addObject:[InvitedGroupId objectAtIndex:TapYes.tag-[JoinedGroupId count]]];
            AVObject *renew = [AVObject objectWithClassName:@"_User" objectId:currentUser.objectId];
            [renew setObject:NewInvolved forKey:@"GroupInvolved"];
            [renew saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error != nil) {
                    NSLog(@"Failed to renew GroupInvolved list on Leancloud :%@",error);
                }else {    // renew involved list (singleton)
                    AVObject *RenewSingleton = [AVObject objectWithClassName:@"_User" objectId:currentUser.objectId];
                    NSArray *keys = [NSArray arrayWithObjects:@"GroupInvolved", nil];
                    [RenewSingleton fetchInBackgroundWithKeys:keys block:^(AVObject *object, NSError *error) {
                        if (error != nil) {
                            NSLog(@"Failed to renew the singleton: %@",error);
                        }else {
                            [currentUser setObject:[object objectForKey:@"GroupInvolved"] forKey:@"GroupInvolved"];

                            // get into the group
                            LCCKConversationViewController *conversationViewController = [[LCCKConversationViewController alloc] initWithConversationId:[InvitedGroupId objectAtIndex:TapYes.tag-[JoinedGroupId count]]];
                            conversationViewController.enableAutoJoin = YES;
                            [self.navigationController pushViewController:conversationViewController animated:YES];
                            
                            // renew grouplist
                            [self RefreshData];
                        }
                    }];
                }
            }];
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    if (row < [JoinedGroupId count]) {
        GroupRoomViewController *GroupRoom = [[GroupRoomViewController alloc] init];
        GroupRoom.GroupId = [JoinedGroupId objectAtIndex:row];
        [self.navigationController pushViewController:GroupRoom animated:YES];
    }
}

- (void)RefreshData {
    AVUser *currentUser = [AVUser currentUser];
    
    [JoinedTopic removeAllObjects];
    [JoinedCreator removeAllObjects];
    [JoinedGroupId removeAllObjects];
    [InvitedTopic removeAllObjects];
    [Inviter removeAllObjects];
    [InvitedGroupId removeAllObjects];
    
    NSArray *GroupInvolved = [currentUser objectForKey:@"GroupInvolved"];
    
    if ([GroupInvolved count]) {    // Previously involved in some groups
        for (NSInteger i = 0; i < [GroupInvolved count]; i++) {
            AVQuery *queryinvolved = [AVQuery queryWithClassName:@"_Conversation"];
            [queryinvolved getObjectInBackgroundWithId:[GroupInvolved objectAtIndex:i] block:^(AVObject *object, NSError *error) {
                [JoinedTopic addObject:[object objectForKey:@"Topic"]];
                [JoinedCreator addObject:[object objectForKey:@"Creator"]];
                [JoinedGroupId addObject:[GroupInvolved objectAtIndex:i]];
                if (i == [GroupInvolved count]-1) {
                    [userDefaults setObject:JoinedTopic forKey:[@"GLArrayJoinedTopic" stringByAppendingString:currentUser.objectId]];
                    [userDefaults setObject:JoinedCreator forKey:[@"GLArrayJoinedCreator" stringByAppendingString:currentUser.objectId]];
                    [userDefaults setObject:JoinedGroupId forKey:[@"GLArrayJoinedGroupId" stringByAppendingString:currentUser.objectId]];
                    
                    AVQuery *queryinvitation = [AVQuery queryWithClassName:@"Invitation"];
                    [queryinvitation whereKey:@"InvitedId" equalTo:currentUser.objectId];
                    [queryinvitation orderByDescending:@"createdAt"];
                    [queryinvitation findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        for (NSInteger j = 0; j < [objects count]; j++) {
                            [InvitedTopic addObject:[[objects objectAtIndex:j] objectForKey:@"GroupTopic"]];
                            [Inviter addObject:[[objects objectAtIndex:j] objectForKey:@"InviterName"]];
                            [InvitedGroupId addObject:[[objects objectAtIndex:j] objectForKey:@"InvitedToGroup"]];
                        }
                        [userDefaults setObject:InvitedTopic forKey:[@"GLArrayInvitedTopic" stringByAppendingString:currentUser.objectId]];
                        [userDefaults setObject:Inviter forKey:[@"GLArrayInviter" stringByAppendingString:currentUser.objectId]];
                        [userDefaults setObject:InvitedGroupId forKey:[@"GLArrayInvitedGroupId" stringByAppendingString:currentUser.objectId]];
                        
                        [self.tableView reloadData];
                    }];
                }
            }];
        }
    }else {    //Previously Not involved
        AVQuery *queryinvitation = [AVQuery queryWithClassName:@"Invitation"];
        [queryinvitation whereKey:@"InvitedId" equalTo:currentUser.objectId];
        [queryinvitation orderByDescending:@"createdAt"];
        [queryinvitation findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (NSInteger j = 0; j < [objects count]; j++) {
                [InvitedTopic addObject:[[objects objectAtIndex:j] objectForKey:@"GroupTopic"]];
                [Inviter addObject:[[objects objectAtIndex:j] objectForKey:@"InviterName"]];
                [InvitedGroupId addObject:[[objects objectAtIndex:j] objectForKey:@"InvitedToGroup"]];
            }
            [userDefaults setObject:JoinedTopic forKey:[@"GLArrayJoinedTopic" stringByAppendingString:currentUser.objectId]];
            [userDefaults setObject:JoinedCreator forKey:[@"GLArrayJoinedCreator" stringByAppendingString:currentUser.objectId]];
            [userDefaults setObject:JoinedGroupId forKey:[@"GLArrayJoinedGroupId" stringByAppendingString:currentUser.objectId]];
            [userDefaults setObject:InvitedTopic forKey:[@"GLArrayInvitedTopic" stringByAppendingString:currentUser.objectId]];
            [userDefaults setObject:Inviter forKey:[@"GLArrayInviter" stringByAppendingString:currentUser.objectId]];
            [userDefaults setObject:InvitedGroupId forKey:[@"GLArrayInvitedGroupId" stringByAppendingString:currentUser.objectId]];
            
            [self.tableView reloadData];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
