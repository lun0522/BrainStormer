//
//  GroupListViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/1.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import <ChatKit/LCChatKit.h>
#import "BrainStormEntity.h"
#import "GroupListViewController.h"
#import "HowToAddViewController.h"
#import "GroupRoomViewController.h"

@interface GroupListViewController () {
    BrainStormUser *currentUser;
}

@end

@implementation GroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNaviItem];
    [self setRefresher];
    [self setCurrentUser];
}

- (void)setNaviItem {
    self.title = @"Groups";
    
    UIBarButtonItem *LogoutButton = [[UIBarButtonItem alloc] initWithTitle:@"➖"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(Logout:)];
    self.navigationItem.leftBarButtonItem = LogoutButton;
    
    UIBarButtonItem *AddButton = [[UIBarButtonItem alloc] initWithTitle:@"➕"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(AddGroup:)];
    self.navigationItem.rightBarButtonItem = AddButton;
}

- (void)setRefresher {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self
                            action:@selector(controlEventValueChanged:)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)setCurrentUser {
    currentUser = [BrainStormUser currentUser];
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
    [BrainStormUser logOut];
    
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
    
    if (row < currentUser.joinedGroupsList.count && currentUser.joinedGroupsList.count != 0) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.userInteractionEnabled = YES;
        cell.imageView.image = [UIImage imageNamed:@"bulb.png"];
        cell.textLabel.text = currentUser.joinedGroupsList[row].topic;
        cell.detailTextLabel.text = [@"Created by " stringByAppendingString:currentUser.joinedGroupsList[row].creatorName];
    }else if (row < currentUser.joinedGroupsList.count + currentUser.invitedGroupsList.count && currentUser.invitedGroupsList.count != 0) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"InvitationLetterViewCell" owner:nil options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *joinedTopicLabel = (UILabel *)[cell viewWithTag:1];
        joinedTopicLabel.text = [@"【Invitation】" stringByAppendingString:currentUser.invitedGroupsList[row - currentUser.joinedGroupsList.count].topic];
        UILabel *joinedCreatorLabel = (UILabel *)[cell viewWithTag:2];
        joinedCreatorLabel.text = [@"Created by " stringByAppendingString:currentUser.invitedGroupsList[row - currentUser.joinedGroupsList.count].creatorName];
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Agree to join in this group?"
                                                                             message:[@"Topic: " stringByAppendingString:currentUser.invitedGroupsList[TapYes.tag - currentUser.joinedGroupsList.count].topic]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // Todo: delete invitations; renew involved list (cloud and singleton); renew grouplist; get into the group
        
        // Delete invitations
        AVQuery *query = [AVQuery queryWithClassName:@"Invitation"];
        [query whereKey:@"InvitedId" equalTo:currentUser.objectId];
        [query whereKey:@"InvitedToGroup" equalTo:currentUser.invitedGroupsList[TapYes.tag - currentUser.joinedGroupsList.count].groupId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (NSInteger i = 0; i < [objects count]; i++) {
                [[objects objectAtIndex:i] deleteInBackground];
            }
            
            // renew involved list (cloud)
            NSArray *PreviousInvolved = [currentUser objectForKey:@"GroupInvolved"];
            NSMutableArray *NewInvolved = [NSMutableArray arrayWithArray:PreviousInvolved];
            [NewInvolved addObject:currentUser.invitedGroupsList[TapYes.tag - currentUser.joinedGroupsList.count].groupId];
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
                            LCCKConversationViewController *conversationViewController = [[LCCKConversationViewController alloc] initWithConversationId:currentUser.invitedGroupsList[TapYes.tag - currentUser.joinedGroupsList.count].groupId];
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
    
    if (row < currentUser.joinedGroupsList.count) {
        GroupRoomViewController *GroupRoom = [[GroupRoomViewController alloc] init];
        GroupRoom.GroupId = currentUser.joinedGroupsList[row].groupId;
        [self.navigationController pushViewController:GroupRoom animated:YES];
    }
}

- (void)controlEventValueChanged:(id)sender {
    if (self.refreshControl.refreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
        [self RefreshData];
        [self.refreshControl endRefreshing];
    }
}

- (void)RefreshData {
    [currentUser clearJoinedGroups];
    [currentUser clearInvitedGroups];
    
    NSArray *GroupInvolved = [currentUser objectForKey:@"GroupInvolved"];
    
    if ([GroupInvolved count]) {    // Previously involved in some groups
        for (NSInteger i = 0; i < [GroupInvolved count]; i++) {
            AVQuery *queryinvolved = [AVQuery queryWithClassName:@"_Conversation"];
            [queryinvolved getObjectInBackgroundWithId:[GroupInvolved objectAtIndex:i] block:^(AVObject *object, NSError *error) {
                [currentUser addJoinedGroup:[BrainStormGroup groupWithId:GroupInvolved[i]
                                                                   topic:object[@"topic"]
                                                             creatorName:object[@"creatorName"]]];
                if (i == [GroupInvolved count]-1) {
                    
                    AVQuery *queryinvitation = [AVQuery queryWithClassName:@"Invitation"];
                    [queryinvitation whereKey:@"InvitedId" equalTo:currentUser.objectId];
                    [queryinvitation orderByDescending:@"createdAt"];
                    [queryinvitation findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        for (NSInteger j = 0; j < [objects count]; j++) {
                            [currentUser addInvitedGroup:[BrainStormGroup groupWithId:objects[j][@"groupId"]
                                                                                topic:objects[j][@"topic"]
                                                                          creatorName:objects[j][@"inviterName"]]];
                        }
                        
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
                [currentUser addInvitedGroup:[BrainStormGroup groupWithId:objects[j][@"groupId"]
                                                                    topic:objects[j][@"topic"]
                                                              creatorName:objects[j][@"inviterName"]]];
            }
            
            [self.tableView reloadData];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
