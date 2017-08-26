//
//  InviteTableViewController.h
//  BrainStormer
//
//  Created by Lun on 2016/10/2.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>
#import "CreatGroupViewController.h"

@interface InviteTableViewController : UITableViewController

@property (nonatomic,strong) NSMutableArray *SelectedName;
@property (nonatomic,strong) NSMutableArray *SelectedId;

@end
