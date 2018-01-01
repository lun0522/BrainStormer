//
//  InviteTableViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/2.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "BrainStormEntity.h"
#import "InviteTableViewController.h"

@interface InviteTableViewController () {
    NSMutableArray *_selectedList;
    SelectPeopleCallback _callback;
}

@end

@implementation InviteTableViewController

- (instancetype _Nonnull)initWithSelectedPeople:(NSArray<BrainStormPeople *> * _Nonnull)selectedPeople
                                       callback:(SelectPeopleCallback _Nonnull)callback {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _selectedList = selectedPeople.mutableCopy;
        _callback = callback;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(cancelAction:)];
    [[self navigationItem] setLeftBarButtonItem:cancelButton];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    _callback(nil);
    _callback = nil;
}

- (void)doneAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    _callback(_selectedList.copy);
    _callback = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return BrainStormUser.currentUser.friendsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
    
    static NSString * CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[[NSBundle mainBundle] loadNibNamed:@"InviteTableViewCell" owner:nil options:nil] firstObject];
    
    cell.userInteractionEnabled = YES;
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    name.text = BrainStormUser.currentUser.friendsList[row][BSPNameKey];
    UIImageView *invitedIcon = (UIImageView *)[cell viewWithTag:2];
    UILabel *uid = (UILabel *)[cell viewWithTag:3];
    uid.text = BrainStormUser.currentUser.friendsList[row][BSPIdKey];
    
    uid.hidden = YES;
    invitedIcon.hidden = [_selectedList containsObject:[BrainStormPeople peopleWithId:uid.text
                                                                                 name:name.text]];
    invitedIcon.image = [UIImage imageNamed:@"invited.png"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    UIImageView *invitedIcon = (UIImageView *)[cell viewWithTag:2];
    UILabel *uid = (UILabel *)[cell viewWithTag:3];
    BrainStormPeople *selectedPeople = [BrainStormPeople peopleWithId:uid.text
                                                                 name:name.text];
    
    if (invitedIcon.hidden) [_selectedList addObject:selectedPeople];
    else [_selectedList removeObject:selectedPeople];
    invitedIcon.hidden = !invitedIcon.hidden;
}

@end
