//
//  BrainStormEntity.h
//  BrainStormer
//
//  Created by Lun on 2017/8/26.
//  Copyright © 2017年 Lun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud.h>

@interface BrainStormGroup : NSObject

@property (nonatomic, copy, readonly) NSString * _Nonnull groupId;
@property (nonatomic, copy, readonly) NSString * _Nonnull topic;
@property (nonatomic, copy, readonly) NSString * _Nonnull creatorName;

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (BrainStormGroup * _Nonnull)groupWithId:(NSString * _Nonnull)groupId
                                    topic:(NSString * _Nonnull)topic
                              creatorName:(NSString * _Nonnull)creatorName;

@end

@interface BrainStormUser : AVUser

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (BrainStormUser * _Nullable)userWithName:(NSString * _Nonnull)username
                                  password:(NSString * _Nonnull)password;

- (NSArray<BrainStormGroup *> * _Nonnull)joinedGroupsList;
- (void)addJoinedGroup:(BrainStormGroup * _Nonnull)group;
- (void)clearJoinedGroups;

- (NSArray<BrainStormGroup *> * _Nonnull)invitedGroupsList;
- (void)addInvitedGroup:(BrainStormGroup * _Nonnull)group;
- (void)clearInvitedGroups;

@end
