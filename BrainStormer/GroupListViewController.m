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

@interface GroupListViewController ()

@end

@implementation GroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNaviItem];
    [self setRefresher];

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
    [BrainStormUser.currentUser logout];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    NSUInteger row = [indexPath row];
    
    static NSString * CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (BrainStormUser.currentUser.invitedGroups.count != 0 && row < BrainStormUser.currentUser.invitedGroups.count) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.userInteractionEnabled = YES;
        cell.imageView.image = [UIImage imageNamed:@"bulb.png"];
        cell.textLabel.text = BrainStormUser.currentUser.invitedGroups[row].topic;
        cell.detailTextLabel.text = [@"Created by " stringByAppendingString:BrainStormUser.currentUser.invitedGroups[row].creatorName];
    } else if (BrainStormUser.currentUser.invitedGroups.count != 0 && row < BrainStormUser.currentUser.invitedGroups.count + BrainStormUser.currentUser.invitedGroups.count) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"InvitationLetterViewCell" owner:nil options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *joinedTopicLabel = (UILabel *)[cell viewWithTag:1];
        joinedTopicLabel.text = [@"【Invitation】" stringByAppendingString:BrainStormUser.currentUser.invitedGroups[row - BrainStormUser.currentUser.invitedGroups.count].topic];
        UILabel *joinedCreatorLabel = (UILabel *)[cell viewWithTag:2];
        joinedCreatorLabel.text = [@"Created by " stringByAppendingString:BrainStormUser.currentUser.invitedGroups[row - BrainStormUser.currentUser.invitedGroups.count].creatorName];
        UIButton *YesButton = (UIButton *)[cell viewWithTag:3];
//        UIButton *NoButton = (UIButton *)[cell viewWithTag:4];
//        UIButton *MoreInfo = (UIButton *)[cell viewWithTag:5];
        
        // Use tag to transfer
        [YesButton setTag:row];
        [YesButton addTarget:self action:@selector(AgreeToJoin:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.userInteractionEnabled = NO;
    }
    return cell;
}

- (void)AgreeToJoin:(UIButton *)TapYes {
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"Agree to join this group?"
                                        message:[@"Topic: " stringByAppendingString:BrainStormUser.currentUser.invitedGroups[TapYes.tag - BrainStormUser.currentUser.invitedGroups.count].topic]
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes!" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         UIViewController *vc = [BrainStormUser.currentUser joinGroupWithId:BrainStormUser.currentUser.invitedGroups[TapYes.tag - BrainStormUser.currentUser.joinedGroups.count].groupId];
                                                         if (vc) {
                                                             [self.navigationController pushViewController:vc animated:YES];
                                                             [self RefreshData];
                                                         }
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
    
    if (row < BrainStormUser.currentUser.invitedGroups.count) {
        GroupRoomViewController *GroupRoom = [[GroupRoomViewController alloc] init];
        GroupRoom.GroupId = BrainStormUser.currentUser.invitedGroups[row].groupId;
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
    __weak GroupListViewController *weakSelf = self;
    [BrainStormUser.currentUser renewUserWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) NSLog(@"Failed to refresh: %@", error.localizedDescription);
        else [weakSelf.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
