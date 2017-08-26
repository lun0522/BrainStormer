//
//  GroupListViewController.h
//  BrainStormer
//
//  Created by Lun on 2016/10/1.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>
#import <AVUser.h>
#import <ChatKit/LCChatKit.h>
#import "HowToAddViewController.h"
#import "GroupRoomViewController.h"
#import "LCCKUser.h"

@interface GroupListViewController : UITableViewController {
    NSMutableArray *users;
    NSMutableArray *JoinedTopic;
    NSMutableArray *JoinedCreator;
    NSMutableArray *JoinedGroupId;
    NSMutableArray *InvitedTopic;
    NSMutableArray *Inviter;
    NSMutableArray *InvitedGroupId;
    NSUserDefaults *userDefaults;
}

@end
