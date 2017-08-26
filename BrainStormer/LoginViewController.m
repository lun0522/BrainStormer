//
//  LoginViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/9/30.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "LoginViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self SetButton];
    
    // Clear user defaults
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

- (void)SetButton {
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
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithReadPermissions: @[@"public_profile", @"user_friends"]
                        fromViewController:self
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                       if (error) {
                                           NSLog(@"Process error: %@",error);
                                       } else if (result.isCancelled) {
                                           NSLog(@"Cancelled");
                                       } else {
                                           NSLog(@"Logged in");
                                           if ([FBSDKAccessToken currentAccessToken]) {
                                               FBSDKGraphRequest *graphRequest;
                                               graphRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                                                parameters:@{ @"fields" : @"id,name,picture.width(100).height(100)"}];
                                               [graphRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                                   if (!error) {
                                                       NSString *nameOfLoginUser = [result valueForKey:@"name"];
                                                       NSString *imageStringOfLoginUser = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
                                                       NSLog(@"Name of user: %@",nameOfLoginUser);
                                                       NSLog(@"Image URL: %@",imageStringOfLoginUser);
                                                   }
                                               }];
                                           }
                                       }
                                   }];
}

- (IBAction)Shortcut:(id)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Which test user?"
                                                                              message: nil
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction: [UIAlertAction actionWithTitle: @"user1"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
        [AVUser logInWithUsernameInBackground:@"testuser1"
                                     password:@"testuser"
                                        block:^(AVUser *user, NSError *error) {
            UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"RootNavi"];
            [self presentViewController:vc animated:YES completion:nil];
        }];
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"user2"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
        [AVUser logInWithUsernameInBackground:@"testuser2"
                                     password:@"testuser"
                                        block:^(AVUser *user, NSError *error) {
            UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"RootNavi"];
            [self presentViewController:vc animated:YES completion:nil];
        }];
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"user3"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
        [AVUser logInWithUsernameInBackground:@"testuser3"
                                     password:@"testuser"
                                        block:^(AVUser *user, NSError *error) {
            UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"RootNavi"];
            [self presentViewController:vc animated:YES completion:nil];
        }];
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController: alertController animated: YES completion: nil];
}

- (UIImage *)GetImageFromURL:(NSString *)imageURL {
    NSLog(@"Downloading image");
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
@end
