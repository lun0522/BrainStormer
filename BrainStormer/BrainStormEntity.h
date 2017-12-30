//
//  BrainStormEntity.h
//  BrainStormer
//
//  Created by Lun on 2017/8/26.
//  Copyright © 2017年 Lun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrainStormGroup : NSObject

@property (nonatomic, readonly, copy) NSString * _Nonnull groupId;
@property (nonatomic, readonly, copy) NSString * _Nonnull topic;
@property (nonatomic, readonly, copy) NSString * _Nonnull creatorName;

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (BrainStormGroup * _Nonnull)groupWithId:(NSString * _Nonnull)groupId
                                    topic:(NSString * _Nonnull)topic
                              creatorName:(NSString * _Nonnull)creatorName;

@end

typedef void (^RenewUserCompletionHandler)(NSError * _Nullable error);

@class LCCKConversationViewController;

@interface BrainStormUser : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (void)loginWithName:(NSString * _Nonnull)username
             password:(NSString * _Nonnull)password;
+ (BrainStormUser * _Nullable)currentUser;
- (void)logout;

- (NSString * _Nonnull)userId;
- (NSArray<BrainStormGroup *> * _Nonnull)joinedGroups;
- (NSArray<BrainStormGroup *> * _Nonnull)invitedGroups;

- (LCCKConversationViewController * _Nullable)joinGroupWithId:(NSString * _Nonnull)groupId;
- (void)quitGroupWithId:(NSString * _Nonnull)groupId;
- (void)renewUserWithCompletionHandler:(RenewUserCompletionHandler _Nullable)handler;

@end
