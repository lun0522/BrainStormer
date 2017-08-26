//
//  HowToAddViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/1.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "HowToAddViewController.h"

@interface HowToAddViewController ()
@end

@implementation HowToAddViewController

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
            cell.textLabel.text = @"Join in a group";
            break;
        case 1:
            cell.textLabel.text = @"Create a group";
            break;
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    if (row == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JoininNotification" object:nil userInfo:@{}];
        [self dismissViewControllerAnimated:NO completion:nil];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateNotification" object:nil userInfo:@{}];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
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
