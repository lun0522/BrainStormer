//
//  StickerMenuViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/7.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "StickerMenuViewController.h"

@interface StickerMenuViewController ()

@end

@implementation StickerMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    NSUInteger row = [indexPath row];
    switch (row) {
        case 0:
            cell.textLabel.text = @"Edit";
            break;
        case 1:
            cell.textLabel.text = @"Delete";
        default:
            break;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:19.0f];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- ( void )tableView:( UITableView *)tableView willDisplayCell:( UITableViewCell *)cell forRowAtIndexPath:( NSIndexPath *)indexPath {
    if ([cell respondsToSelector : @selector (setSeparatorInset:)]) {
        [cell setSeparatorInset : UIEdgeInsetsZero ];
    }
    
    if ([cell respondsToSelector : @selector (setLayoutMargins:)]) {
        [cell setLayoutMargins : UIEdgeInsetsZero ];
    }
}

@end
