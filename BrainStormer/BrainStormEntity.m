//
//  BrainStormEntity.m
//  BrainStormer
//
//  Created by Lun on 2017/8/26.
//  Copyright © 2017年 Lun. All rights reserved.
//

#import <AVOSCloud.h>
#import <LCCKConversationViewController.h>
#import "ChatKitUtils.h"
#import "BrainStormEntity.h"

@implementation BrainStormGroup

+ (BrainStormGroup * _Nonnull)groupWithId:(NSString * _Nonnull)groupId
                                    topic:(NSString * _Nonnull)topic
                              creatorName:(NSString * _Nonnull)creatorName {
    return [[BrainStormGroup alloc] initWithGroupId:groupId
                                              topic:topic
                                        creatorName:creatorName];
}

- (instancetype)initWithGroupId:(NSString *)groupId
                          topic:(NSString *)topic
                    creatorName:(NSString *)creatorName {
    if (self = [super init]) {
        _groupId = groupId;
        _topic = topic;
        _creatorName = creatorName;
    }
    return self;
}

- (NSUInteger)hash {
    return _groupId.hash ^ _topic.hash ^ _creatorName.hash;
}

- (BOOL)isEqual:(id)object {
    if (![object isMemberOfClass:self.class]) return NO;
    BrainStormGroup *group = object;
    return group.groupId == _groupId && group.topic == _topic && group.creatorName == _creatorName;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p, %@>",
            self,
            [self class],
            @{
              @"id": _groupId,
              @"topic": _topic,
              @"creator": _creatorName,
              }
            ];
}

@end

@implementation NSDictionary (people)

NSString *const BSPIdKey = @"id";
NSString *const BSPNameKey = @"name";

+ (BrainStormPeople * _Nonnull)peopleWithId:(NSString * _Nonnull)uid
                                       name:(NSString * _Nonnull)name {
    return @{BSPIdKey: uid, BSPNameKey: name};
}

- (NSUInteger)hash {
    return ((NSString *)self[BSPIdKey]).hash ^ ((NSString *)self[BSPNameKey]).hash;
}

- (BOOL)isEqual:(id)object {
    if (![object isMemberOfClass:[self class]]) return NO;
    return object[BSPIdKey] == self[BSPIdKey];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p, %@>",
            self,
            [self class],
            @{
              @"id": self[BSPIdKey],
              @"name": self[BSPNameKey],
              }
            ];
}

@end

@implementation BrainStormUser {
    AVUser *_user;
    NSMutableArray<NSDictionary *> *_friendsList;
    NSMutableArray<BrainStormGroup *> *_joinedGroups;
    NSMutableArray<BrainStormGroup *> *_invitedGroups;
}

static BrainStormUser *sharedUser = nil;

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (!sharedUser) {
            sharedUser = [super allocWithZone:zone];
            return sharedUser;
        }
    }
    return nil;
}

+ (void)loginWithName:(NSString * _Nonnull)username
             password:(NSString * _Nonnull)password {
    @synchronized(self) {
        if (!sharedUser) sharedUser = [[BrainStormUser alloc] initWithUserame:username
                                                                     password:password];
        else NSLog(@"Not yet logout!");
    }
}

- (instancetype)initWithUserame:(NSString * _Nonnull)username
                       password:(NSString * _Nonnull)password {
    NSError *error;
    [AVUser logInWithUsername:username
                     password:password
                        error:&error];
    _user = AVUser.currentUser;
    if (error) {
        NSLog(@"Failed to login: %@", error.localizedDescription);
        return nil;
    } else {
        _friendsList = [NSMutableArray array];
        _joinedGroups = [NSMutableArray array];
        _invitedGroups = [NSMutableArray array];
        [ChatKitUtils userDidLoginWithId:_user.objectId];
        [self getAvatarFromURL:_user[@"avatarUrl"]
              saveWithFilename:_user[@"avatarFilename"]];
        
        return self;
    }
}

- (void)getAvatarFromURL:(NSString *)url saveWithFilename:(NSString *)filename {
    NSString *filePath = [self getFilePathWithFilename:filename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) return;
    UIImage *avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    [UIImageJPEGRepresentation(avatar, 1.0) writeToFile:filePath options:NSAtomicWrite error:nil];
}

- (NSString *)getFilePathWithFilename:(NSString *)filename {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)[0];
    return [path stringByAppendingPathComponent:filename];
}

+ (BrainStormUser * _Nullable)currentUser {
    if (!sharedUser) NSLog(@"Not yet login");
    return sharedUser;
}

- (void)logout {
    [AVUser logOut];
    [ChatKitUtils userDidLogOut];
    sharedUser = nil;
}

- (NSString * _Nonnull)userId {
    return _user.objectId.copy;
}

- (NSString * _Nonnull)userName {
    return _user.username.copy;
}

- (NSString * _Nonnull)avatarFilePath {
    return [self getFilePathWithFilename:_user[@"avatarFilename"]];
}

- (NSArray<BrainStormGroup *> * _Nonnull)joinedGroups {
    return _joinedGroups.copy;
}

- (NSArray<BrainStormGroup *> * _Nonnull)invitedGroups {
    return _invitedGroups.copy;
}

- (NSArray<BrainStormPeople *> * _Nonnull)friendsList {
    return _friendsList.copy;
}

- (void)createGroupWithTopic:(NSString * _Nonnull)topic
               invitedIdList:(NSArray<NSString *> * _Nonnull)idList
           completionHandler:(CreateGroupCompletionHandler _Nonnull)handler {
    // create group and fetch its id
    NSDictionary *params = @{
                             @"topic": topic,
                             @"creatorId": _user.objectId,
                             @"creatorName": _user.username,
                             @"invitedId": idList,
                             @"timestamp": [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]],
                             };
    [AVCloud callFunctionInBackground:@"create_group"
                       withParameters:params
                                block:^(id object, NSError *error) {
                                    if (error) {
                                        handler(error, nil);
                                    } else {
                                        NSString *newGroupId = object[@"groupId"];
                                        NSString *encrypted = object[@"encrypted"];
                                        
                                        // renew cloud
                                        if (_user[@"joinedGroups"]) [_user[@"joinedGroups"] addObject:newGroupId];
                                        else _user[@"joinedGroups"] = @[newGroupId].mutableCopy;
                                        [_user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                            if (error) NSLog(@"Failed to call cloud function: %@", error.localizedDescription);
                                        }];
                                        
                                        // renew local
                                        [_joinedGroups addObject:[BrainStormGroup groupWithId:newGroupId
                                                                                        topic:topic
                                                                                  creatorName:_user.username]];
                                        
                                        handler(nil, encrypted);
                                    }
                                }];
}

- (void)joinGroupWithId:(NSString * _Nonnull)groupId {
    BrainStormGroup *willJoinGroup;
    for (BrainStormGroup *group in _invitedGroups) {
        if (group.groupId == groupId) {
            willJoinGroup = group;
            break;
        }
    }
    
    if (!willJoinGroup) {
        NSLog(@"Failed to join group: Not in invited list!");
        return;
    }
    
    // renew cloud
    if (_user[@"joinedGroups"]) [_user[@"joinedGroups"] addObject:groupId];
    else _user[@"joinedGroups"] = @[groupId];
    [_user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) NSLog(@"Failed to renew cloud: %@", error.localizedDescription);
    }];
    
    // renew local
    [_joinedGroups addObject:[BrainStormGroup groupWithId:willJoinGroup.groupId
                                                    topic:willJoinGroup.topic
                                              creatorName:willJoinGroup.creatorName]];
    [_invitedGroups removeObject:willJoinGroup];
    
    // renew group members and delete invitations
    NSDictionary *params = @{
                             @"userId": _user.objectId,
                             @"groupId": groupId,
                             };
    [AVCloud callFunctionInBackground:@"join_group"
                       withParameters:params
                                block:^(id object, NSError *error) {
                                    if (error) NSLog(@"Failed to call cloud function: %@", error.localizedDescription);
                                }];
}

- (void)quitGroupWithId:(NSString * _Nonnull)groupId {
    BrainStormGroup *willQuitGroup;
    for (BrainStormGroup *group in _joinedGroups) {
        if (group.groupId == groupId) {
            willQuitGroup = group;
            break;
        }
    }
    
    if (!willQuitGroup) {
        NSLog(@"Failed to quit group: Not in joined list!");
        return;
    }
    
    // renew cloud
    [_user[@"joinedGroups"] removeObject:groupId];
    [_user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) NSLog(@"Failed to renew cloud: %@", error.localizedDescription);
    }];
    
    // renew local
    [_joinedGroups removeObject:willQuitGroup];
    
    // renew group members
    NSDictionary *params = @{
                             @"userId": _user.objectId,
                             @"groupId": groupId,
                             };
    [AVCloud callFunctionInBackground:@"quit_group"
                       withParameters:params
                                block:^(id object, NSError *error) {
                                    if (error) NSLog(@"Failed to call cloud function: %@", error.localizedDescription);
                                }];
}

- (void)renewUserInBackgroundWithOption:(RenewUserOption)option
                      completionHandler:(RenewUserCompletionHandler _Nullable)handler {
    if (!sharedUser) {
        if (handler) {
            NSInteger code = 0;
            NSString *errorReasonText = @"Not yet login";
            NSDictionary *errorInfo = @{
                                        @"code": @(code),
                                        NSLocalizedDescriptionKey: errorReasonText,
                                        };
            NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                                 code:code
                                             userInfo:errorInfo];
            handler(error);
        }
        return;
    }
    
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_queue_t dispatchQueue = dispatch_queue_create("com.lun.brainstormer.renewuser", DISPATCH_QUEUE_CONCURRENT);
    
    BOOL renewFriendsList   = option >> 0 & 1 || option >> 1 & 1;
    BOOL renewJoinedGroups  = option >> 0 & 1 || option >> 2 & 1;
    BOOL renewInvitedGroups = option >> 0 & 1 || option >> 3 & 1;
    
    if (renewFriendsList || renewJoinedGroups) {
        dispatch_group_enter(dispatchGroup);
        dispatch_group_async(dispatchGroup, dispatchQueue, ^{
            NSMutableArray *fetchInfo = [NSMutableArray array];
            if (renewFriendsList) {
                [fetchInfo addObject:@"friendsList"];
                [_friendsList removeAllObjects];
            }
            if (renewJoinedGroups) {
                [fetchInfo addObject:@"joinedGroups"];
                [_joinedGroups removeAllObjects];
            }
            
            // fetch ids of joined groups
            [_user fetchInBackgroundWithKeys:fetchInfo block:^(AVObject * _Nullable object,
                                                               NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Failed to renew joined groups: %@", error.localizedDescription);
                    dispatch_group_leave(dispatchGroup);
                } else {
                    if (renewFriendsList) {
                        // store friends
                        for (NSDictionary *people in _user[@"friendsList"]) {
                            [_friendsList addObject:[BrainStormPeople peopleWithId:people[@"id"]
                                                                              name:people[@"name"]]];
                        }
                    }
                    
                    if (renewJoinedGroups) {
                        // query details of each group
                        NSMutableArray *querys = [NSMutableArray array];
                        for (NSString *groupId in _user[@"joinedGroups"]) {
                            [querys addObject:[AVObject objectWithClassName:@"_Conversation"
                                                                   objectId:groupId]];
                        }
                        
                        [AVObject fetchAllInBackground:querys block:^(NSArray * _Nullable objects,
                                                                      NSError * _Nullable error) {
                            if (error) {
                                NSLog(@"Failed to query joined groups: %@", error.localizedDescription);
                            } else {
                                for (AVObject *group in objects) {
                                    [_joinedGroups addObject:[BrainStormGroup groupWithId:group.objectId
                                                                                    topic:group[@"name"]
                                                                              creatorName:group[@"creatorName"]]];
                                }
                            }
                            dispatch_group_leave(dispatchGroup);
                        }];
                    }
                }
            }];
        });
    }
    
    if (renewInvitedGroups) {
        dispatch_group_enter(dispatchGroup);
        dispatch_group_async(dispatchGroup, dispatchQueue, ^{
            [_invitedGroups removeAllObjects];
            
            // query invitations sent to the current user
            AVQuery *query = [AVQuery queryWithClassName:@"Invitation"];
            [query whereKey:@"invitedId" equalTo:self.userId];
            [query orderByDescending:@"createdAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                      NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Failed to query invitations: %@", error.localizedDescription);
                } else {
                    for (AVObject *group in objects) {
                        [_invitedGroups addObject:[BrainStormGroup groupWithId:group[@"groupId"]
                                                                         topic:group[@"topic"]
                                                                   creatorName:group[@"inviterName"]]];
                    }
                }
                dispatch_group_leave(dispatchGroup);
            }];
        });
    }
    
    dispatch_group_notify(dispatchGroup, dispatchQueue, ^{
        if (handler) handler(nil);
    });
}

@end
