//
//  InviteTableViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/2.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "BrainStormEntity.h"
#import "InviteTableViewCell.h"
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
    _callback(nil, nil);
    _callback = nil;
}

- (void)doneAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    NSString *names = @"";
    for (BrainStormPeople *people in _selectedList) {
        names = [names stringByAppendingString:people[BSPNameKey]];
    }
    _callback(_selectedList.copy, names);
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
    InviteTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"InviteTableViewCell" owner:nil options:nil] firstObject];
    cell.name.text = BrainStormUser.currentUser.friendsList[row][BSPNameKey];
    cell.invited.image = [UIImage imageNamed:@"invited.png"];
    cell.invited.hidden = ![_selectedList containsObject:BrainStormUser.currentUser.friendsList[row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BrainStormPeople *selectedPeople = BrainStormUser.currentUser.friendsList[indexPath.row];
    if ([_selectedList containsObject:selectedPeople]) [_selectedList removeObject:selectedPeople];
    else [_selectedList addObject:selectedPeople];
    
    InviteTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.invited.hidden = !cell.invited.hidden;
}

@end
