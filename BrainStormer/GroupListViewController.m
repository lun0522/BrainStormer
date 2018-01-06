//
//  GroupListViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/1.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "BrainStormEntity.h"
#import "AddGroupTableViewController.h"
#import "GroupRoomViewController.h"
#import "GroupListViewController.h"

@interface GroupListViewController () <UIPopoverPresentationControllerDelegate>

@end

@implementation GroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self refreshTableWithCompletionHandler:nil];
    [self setNaviItem];
    [self setRefresher];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

- (void)Logout:(id)sender {
    [BrainStormUser.currentUser logout];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)AddGroup:(id)sender {
    __weak GroupListViewController *weakSelf = self;
    AddGroupTableViewController *tvc = [[AddGroupTableViewController alloc] initWithCallback:^(AddGroupOption option) {
        UIViewController *vc;
        
        if (option == AGJoinGroup) vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JoinGroup"];
        else if (option == AGCreateGroup) vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateGroup"];
        else NSLog(@"Unknown add group option!");
        
        if (vc) [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    tvc.preferredContentSize = CGSizeMake(150, 87);
    tvc.modalPresentationStyle = UIModalPresentationPopover;
    tvc.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    tvc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    tvc.popoverPresentationController.delegate = self;
    [self presentViewController:tvc animated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
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
    NSUInteger row = indexPath.row;
    NSUInteger joinedGroupsCount = BrainStormUser.currentUser.joinedGroups.count;
    NSUInteger invitedGroupsCount = BrainStormUser.currentUser.invitedGroups.count;
    
    static NSString * CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (joinedGroupsCount != 0 && row < joinedGroupsCount) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.imageView.image = [UIImage imageNamed:@"bulb.png"];
        cell.textLabel.text = BrainStormUser.currentUser.joinedGroups[row].topic;
        cell.detailTextLabel.text = [@"Created by " stringByAppendingString:BrainStormUser.currentUser.joinedGroups[row].creatorName];
    } else if (invitedGroupsCount != 0 && row < joinedGroupsCount + invitedGroupsCount) {
        NSUInteger idx = row - joinedGroupsCount;
        cell = [[[NSBundle mainBundle] loadNibNamed:@"InvitationLetterViewCell" owner:nil options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *topicLabel = (UILabel *)[cell viewWithTag:1];
        topicLabel.text = [@"【Invitation】" stringByAppendingString:BrainStormUser.currentUser.invitedGroups[idx].topic];
        UILabel *creatorLabel = (UILabel *)[cell viewWithTag:2];
        creatorLabel.text = [@"Created by " stringByAppendingString:BrainStormUser.currentUser.invitedGroups[idx].creatorName];
        UIButton *YesButton = (UIButton *)[cell viewWithTag:3];
//        UIButton *NoButton = (UIButton *)[cell viewWithTag:4];
//        UIButton *MoreInfo = (UIButton *)[cell viewWithTag:5];
        
        // Use tag to transfer
        [YesButton setTag:row];
        [YesButton addTarget:self action:@selector(agreeToJoin:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.userInteractionEnabled = NO;
    }
    return cell;
}

- (void)agreeToJoin:(UIButton *)TapYes {
    __weak GroupListViewController *weakSelf = self;
    BrainStormGroup *group = BrainStormUser.currentUser.invitedGroups[TapYes.tag - BrainStormUser.currentUser.joinedGroups.count];
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"Join this group?"
                                        message:group.topic
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Confirm"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [BrainStormUser.currentUser joinGroupWithId:group.groupId];
                                                          GroupRoomViewController *vc = [[GroupRoomViewController alloc] initWithGroupId:group.groupId];
                                                          [weakSelf.navigationController pushViewController:vc animated:YES];
                                                          [weakSelf refreshTableWithCompletionHandler:nil];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger row = indexPath.row;
    
    if (row < BrainStormUser.currentUser.joinedGroups.count) {
        GroupRoomViewController *vc = [[GroupRoomViewController alloc] initWithGroupId:BrainStormUser.currentUser.joinedGroups[row].groupId];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)controlEventValueChanged:(id)sender {
    if (self.refreshControl.refreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
        [self refreshTableWithCompletionHandler:^{
            [self.refreshControl endRefreshing];
        }];
    }
}

- (void)refreshTableWithCompletionHandler:(void (^)(void))handler {
    __weak GroupListViewController *weakSelf = self;
    [BrainStormUser.currentUser
     renewUserInBackgroundWithOption:BSURenewAllInfo
     completionHandler:^(NSError * _Nullable error) {
         if (error) {
             NSLog(@"Failed to refresh: %@", error.localizedDescription);
         } else {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf.tableView reloadData];
                 if (handler) handler();
             });
         }
     }];
}

@end
