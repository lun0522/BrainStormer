//
//  LoginViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/9/30.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "BrainStormEntity.h"
#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ShortCutButton.layer.cornerRadius = 10.0f;
    self.ShortCutButton.layer.borderWidth = 1.0f;
    self.ShortCutButton.tintColor = [UIColor blackColor];
    
    self.FacebookButton.layer.cornerRadius = 10.0f;
    self.FacebookButton.layer.borderWidth = 1.0f;
    self.FacebookButton.tintColor = [UIColor blackColor];
    
    [self.ShortCutButton addTarget:self action:@selector(Shortcut:) forControlEvents:UIControlEventTouchDown];
    [self.FacebookButton addTarget:self action:@selector(FBLogin:) forControlEvents:UIControlEventTouchDown];
}

- (IBAction)FBLogin:(id)sender {
    // TODO
}

- (IBAction)Shortcut:(id)sender {
    UIAlertController * alertController =
    [UIAlertController alertControllerWithTitle: @"Which test user?"
                                        message: nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:
     [UIAlertAction actionWithTitle: @"user1"
                              style: UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action) {
                                [BrainStormUser userWithName:@"testuser1"
                                                    password:@"testuser"];
                                UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"RootNavi"];
                                [self presentViewController:vc animated:YES completion:nil];
                            }]];
    [alertController addAction:
     [UIAlertAction actionWithTitle: @"user2"
                              style: UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action) {
                                [BrainStormUser userWithName:@"testuser2"
                                                    password:@"testuser"];
                                UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"RootNavi"];
                                [self presentViewController:vc animated:YES completion:nil];
                            }]];
    [alertController addAction:
     [UIAlertAction actionWithTitle: @"user3"
                              style: UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action) {
                                [BrainStormUser userWithName:@"testuser3"
                                                    password:@"testuser"];
                                UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"RootNavi"];
                                [self presentViewController:vc animated:YES completion:nil];
                            }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler:nil]];
    [self presentViewController: alertController animated: YES completion: nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
@end
