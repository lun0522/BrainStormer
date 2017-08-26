//
//  HowToAddViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/1.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "HowToAddViewController.h"

@interface HowToAddViewController () {
    NSArray *ChoiceArray;
}

@end

@implementation HowToAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ChoiceArray = [[NSArray alloc] initWithObjects:@"Join in a group",@"Creat a group", nil];
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
        [self dismissViewControllerAnimated:NO completion:nil];
        UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"JoininGroup"];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        [self dismissViewControllerAnimated:NO completion:nil];
        UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"CreateGroup"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
