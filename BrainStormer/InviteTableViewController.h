//
//  InviteTableViewController.h
//  BrainStormer
//
//  Created by Lun on 2016/10/2.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BrainStormPeople;

typedef void (^SelectPeopleCallback)(NSArray<BrainStormPeople *> * _Nullable peopleList,
                                     NSString * _Nullable names);

@interface InviteTableViewController : UITableViewController

- (instancetype _Nonnull)init NS_UNAVAILABLE;
- (instancetype _Nonnull)initWithSelectedPeople:(NSArray<BrainStormPeople *> * _Nonnull)selectedPeople
                                       callback:(SelectPeopleCallback _Nonnull)callback;

@end
