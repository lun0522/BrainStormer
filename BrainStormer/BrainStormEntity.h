//
//  BrainStormEntity.h
//  BrainStormer
//
//  Created by Lun on 2017/8/26.
//  Copyright © 2017年 Lun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrainStormGroup : NSObject

@property (nonatomic, copy, readonly) NSString *groupId;
@property (nonatomic, copy, readonly) NSString *topic;
@property (nonatomic, copy, readonly) NSString *creatorName;

- (instancetype)initWithGroupId:(NSString *)groupId
                          topic:(NSString *)topic
                    creatorName:(NSString *)creatorName;

@end

@interface BrainStormUser : AVUser

+ (instancetype)logInWithUsername:(NSString *)username
                         password:(NSString *)password
                            error:(NSError **)error;

- (NSMutableArray<BrainStormGroup *> *)getJoinedGroupsList;
- (void)addJoinedGroup:(BrainStormGroup *)group;
- (void)clearJoinedGroups;

- (NSMutableArray<BrainStormGroup *> *)getInvitedGroupsList;
- (void)addInvitedGroup:(BrainStormGroup *)group;
- (void)clearInvitedGroups;

@end
