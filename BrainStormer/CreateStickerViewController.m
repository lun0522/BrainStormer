//
//  CreateStickerViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/5.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "CreateStickerViewController.h"

@interface CreateStickerViewController ()

@end

@implementation CreateStickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self SetButton];
    
    [self RegisterNotiCenter];
}

- (void)RegisterNotiCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetGroupId:) name:@"TellCSGroupIdNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CSAskForGroupIdNotification" object:nil userInfo:@{}];
}

- (void)SetButton {
    self.CreateButton.layer.cornerRadius = 7.0f;
    self.CreateButton.layer.borderWidth = 1.0f;
    self.CreateButton.tintColor = [UIColor blackColor];
    [self.CreateButton addTarget:self action:@selector(CreateSticker:) forControlEvents:UIControlEventTouchDown];
    
    self.DeleteButton.layer.cornerRadius = 7.0f;
    self.DeleteButton.layer.borderWidth = 1.0f;
    self.DeleteButton.tintColor = [UIColor blackColor];
    [self.DeleteButton addTarget:self action:@selector(DeleteSticker:) forControlEvents:UIControlEventTouchDown];
    
    self.PicPickerButton.layer.cornerRadius = 3.0f;
    self.PicPickerButton.layer.borderWidth = 1.0f;
    self.PicPickerButton.tintColor = [UIColor blackColor];
    
    self.Title.text = @"";
    self.Detail.text = @"";
    self.Title.layer.cornerRadius = 5.0f;
    self.Detail.layer.cornerRadius = 5.0f;
    self.Title.layer.borderWidth = 0.5f;
    self.Detail.layer.borderWidth = 0.5f;
}

- (void)GetGroupId:(NSNotification *) notification {
    AVUser *currentUser = [AVUser currentUser];
    GroupId = [[notification userInfo] objectForKey:@"GroupId"];
    NSString *Media = [currentUser.objectId stringByAppendingString:GroupId];
    self.Title.text = [userDefaults stringForKey:[Media stringByAppendingString:@"Title"]];
    self.Detail.text = [userDefaults stringForKey:[Media stringByAppendingString:@"Detail"]];
}

- (void)CreateSticker:(id)sender {
    NSDictionary *TitleAndDetail = [NSDictionary dictionaryWithObjectsAndKeys:self.Title.text,@"Title",self.Detail.text,@"Detail", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BoardAddStickerNotification" object:nil userInfo:TitleAndDetail];
    
    [self ClearUserDefaults];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)DeleteSticker:(id)sender {
    [self ClearUserDefaults];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)ClearUserDefaults {
    AVUser *currentUser = [AVUser currentUser];
    NSString *Media = [currentUser.objectId stringByAppendingString:GroupId];
    [userDefaults setObject:@"" forKey:[Media stringByAppendingString:@"Title"]];
    [userDefaults setObject:@"" forKey:[Media stringByAppendingString:@"Detail"]];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSDictionary *TitleAndDetail = [NSDictionary dictionaryWithObjectsAndKeys:self.Title.text,@"Title",self.Detail.text,@"Detail", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveStickerNotification" object:nil userInfo:TitleAndDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
