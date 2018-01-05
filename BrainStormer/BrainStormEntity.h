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

extern NSString * _Nonnull const BSPIdKey;
extern NSString * _Nonnull const BSPNameKey;

typedef NSDictionary BrainStormPeople;

@interface NSDictionary (people)

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (BrainStormPeople * _Nonnull)peopleWithId:(NSString * _Nonnull)uid
                                       name:(NSString * _Nonnull)name;

@end

@class UIViewController;

typedef NS_OPTIONS(NSInteger, RenewUserOption) {
    RenewAllInfo       = 1 << 0,
    RenewFriendsList   = 1 << 1,
    RenewJoinedGroups  = 1 << 2,
    RenewInvitedGroups = 1 << 3,
};

typedef void (^CreateGroupCompletionHandler)(NSError * _Nullable error, NSString * _Nullable encrypted);
typedef void (^RenewUserCompletionHandler)(NSError * _Nullable error);

@interface BrainStormUser : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (void)loginWithName:(NSString * _Nonnull)username
             password:(NSString * _Nonnull)password;
+ (BrainStormUser * _Nullable)currentUser;
- (void)logout;

- (NSString * _Nonnull)userId;
- (NSString * _Nonnull)userName;
- (NSString * _Nonnull)avatarFile;
- (NSArray<BrainStormGroup *> * _Nonnull)joinedGroups;
- (NSArray<BrainStormGroup *> * _Nonnull)invitedGroups;
- (NSArray<BrainStormPeople *> * _Nonnull)friendsList;

- (void)createGroupWithTopic:(NSString * _Nonnull)topic
               invitedIdList:(NSArray<NSString *> * _Nonnull)idList
           completionHandler:(CreateGroupCompletionHandler _Nonnull)handler;
- (UIViewController * _Nullable)joinGroupWithId:(NSString * _Nonnull)groupId;
- (void)quitGroupWithId:(NSString * _Nonnull)groupId;
- (void)renewUserInBackgroundWithOption:(RenewUserOption)option
                      completionHandler:(RenewUserCompletionHandler _Nullable)handler;

@end
