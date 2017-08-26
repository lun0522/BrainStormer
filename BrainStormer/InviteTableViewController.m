//
//  InviteTableViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/2.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "InviteTableViewController.h"

@interface InviteTableViewController () {
    NSArray *FriendNameList;
    NSArray *FriendIdList;
    NSMutableArray *TempNameList;
    NSMutableArray *TempIdList;
}

@end

@implementation InviteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVUser *currentUser = [AVUser currentUser];
    FriendNameList = [currentUser objectForKey:@"FriendNameList"];
    FriendIdList = [currentUser objectForKey:@"FriendIdList"];
    TempNameList = self.SelectedName;
    TempIdList = self.SelectedId;
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAction:)];
    [[self navigationItem] setLeftBarButtonItem:cancelBarButton];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = doneBarButton;
}

- (void)cancelAction:(id)sender {
    [TempNameList removeAllObjects];
    [TempIdList removeAllObjects];
    TempNameList = self.SelectedName;
    TempIdList = self.SelectedId;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneAction:(id)sender {
    CreatGroupViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateGroup"];
    [vc.InviteNameList removeAllObjects];
    [vc.InviteIdList removeAllObjects];
    vc.InviteNameList = TempNameList;
    vc.InviteIdList = TempIdList;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InvitedChangeNotification" object:nil userInfo:@{}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [FriendNameList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    static NSString * CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[[NSBundle mainBundle] loadNibNamed:@"InviteTableViewCell" owner:nil options:nil] firstObject];
    
    cell.userInteractionEnabled = YES;
    UILabel *Name = (UILabel *)[cell viewWithTag:1];
    Name.text = [FriendNameList objectAtIndex:row];
    UIImageView *Invited = (UIImageView *)[cell viewWithTag:2];
    UILabel *Id = (UILabel *)[cell viewWithTag:3];
    Id.text = [FriendIdList objectAtIndex:row];
    
    Id.hidden = YES;
    if ([self.SelectedName containsObject:Name.text]) {
        Invited.hidden = NO;
    }else {
        Invited.hidden = YES;
    }
    Invited.image = [UIImage imageNamed:@"invited.png"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *Name = (UILabel *)[cell viewWithTag:1];
    UIImageView *Invited = (UIImageView *)[cell viewWithTag:2];
    UILabel *Id = (UILabel *)[cell viewWithTag:3];
    
    if (Invited.hidden) {    //Not selected before
        [TempNameList addObject:Name.text];
        [TempIdList addObject:Id.text];
        Invited.hidden = NO;
    }else {    //Selected before
        [TempNameList removeObject:Name.text];
        [TempIdList removeObject:Id.text];
        Invited.hidden = YES;
    }
}

@end
