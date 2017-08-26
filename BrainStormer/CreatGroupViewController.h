//
//  CreatGroupViewController.h
//  BrainStormer
//
//  Created by Lun on 2016/10/1.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>
#import <ChatKit/LCChatKit.h>
#import "Photos/Photos.h"
#import "InviteTableViewController.h"

@interface CreatGroupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *QRImage;
@property (weak, nonatomic) IBOutlet UITextField *Topic;
@property (weak, nonatomic) IBOutlet UITextView *InviteList;
@property (nonatomic,strong) NSMutableArray *InviteNameList;
@property (nonatomic,strong) NSMutableArray *InviteIdList;
- (IBAction)TapQR:(id)sender;
- (IBAction)InviteMore:(id)sender;
- (IBAction)CreateGroup:(id)sender;

@end
