//
//  AddGroupTableViewController.h
//  BrainStormer
//
//  Created by Lun on 2016/10/1.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AddGroupOption) {
    JoinGroup,
    CreateGroup,
};

typedef void (^AddGroupOptionCallback)(AddGroupOption option);

@interface AddGroupTableViewController : UITableViewController

- (instancetype _Nonnull)initWithCallback:(AddGroupOptionCallback _Nullable)callback NS_DESIGNATED_INITIALIZER;

@end
