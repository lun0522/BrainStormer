//
//  OptionsTableViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/5.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "OptionsTableViewController.h"

@interface OptionsTableViewController ()

@end

@implementation OptionsTableViewController

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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    NSUInteger row = [indexPath row];
    switch (row) {
        case 0:
            cell.textLabel.text = self.SeeSlides? @"Hide slides": @"See slides";
            cell.textLabel.font = [UIFont systemFontOfSize:19.0f];
            break;
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    if (row == 0) {
        if (self.SeeSlides) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideSlidesNotification" object:nil userInfo:@{}];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SeeSlidesNotification" object:nil userInfo:@{}];
        }
        self.SeeSlides = !self.SeeSlides;
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
