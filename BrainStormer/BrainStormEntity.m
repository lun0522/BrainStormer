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
        [self getAvatarFromURL:_user[@"avatarUrl"]];
        [self renewUserInBackgroundWithOption:RenewJoinedGroups | RenewInvitedGroups
                            completionHandler:^(NSError * _Nullable error) {
                                if (error) NSLog(@"Failed to renew: %@", error.localizedDescription);
                            }];
        return self;
    }
}

- (void)getAvatarFromURL:(NSString *)url {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *file = [url substringWithRange:NSMakeRange(31, 23)];
    NSString *filename = [file stringByAppendingString:@".jpg"];
    NSString *uniquePath=[paths[0] stringByAppendingPathComponent:filename];
    BOOL isDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    if (!isDownloaded) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *avatar = [self downloadImageFromURL:url];
            NSString * documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            [self saveImage:avatar withFileName:file ofType:@"jpg" inDirectory:documentsDirectoryPath];
        });
    }
}

- (UIImage *)downloadImageFromURL:(NSString *)url {
    NSLog(@"Downloading image");
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
}

- (void)saveImage:(UIImage *)image
     withFileName:(NSString *)imageName
           ofType:(NSString *)extension
      inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        NSLog(@"Not jpg");
    }
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

- (NSString * _Nonnull)avatarFile {
    return [[_user[@"avatarUrl"] substringWithRange:NSMakeRange(31, 23)] stringByAppendingString:@".jpg"];
}

- (NSArray<BrainStormGroup *> * _Nonnull)joinedGroups {
    return _joinedGroups.copy;
}

- (NSArray<BrainStormGroup *> * _Nonnull)invitedGroups {
    return _joinedGroups.copy;
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
                             @"creatorId": BrainStormUser.currentUser.userId,
                             @"inviterName": _user.username,
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
                                        [_user[@"joinedGroups"] addObject:newGroupId];
                                        [_user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                            if (error) NSLog(@"Failed to renew cloud: %@", error.localizedDescription);
                                        }];
                                        
                                        // renew local
                                        [_joinedGroups addObject:[BrainStormGroup groupWithId:newGroupId
                                                                                        topic:topic
                                                                                  creatorName:_user.username]];
                                        
                                        handler(nil, encrypted);
                                    }
                                }];
}

- (UIViewController * _Nullable)joinGroupWithId:(NSString * _Nonnull)groupId {
    BrainStormGroup *willJoinGroup;
    for (BrainStormGroup *group in _invitedGroups) {
        if (group.groupId == groupId) {
            willJoinGroup = group;
            break;
        }
    }
    
    if (!willJoinGroup) {
        NSLog(@"Failed to join group: Not in invited list!");
        return nil;
    }
    
    // renew cloud
    [_user[@"joinedGroups"] addObject:groupId];
    [_user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) NSLog(@"Failed to renew cloud: %@", error.localizedDescription);
    }];
    
    // delete invitations
    AVQuery *query = [AVQuery queryWithClassName:@"Invitation"];
    [query whereKey:@"invitedId" equalTo:BrainStormUser.currentUser.userId];
    [query whereKey:@"groupId" equalTo:groupId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [AVObject deleteAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) NSLog(@"Failed to delete invitations: %@", error.localizedDescription);
        }];
    }];
    
    // renew local
    [_joinedGroups addObject:[BrainStormGroup groupWithId:willJoinGroup.groupId
                                                    topic:willJoinGroup.topic
                                              creatorName:willJoinGroup.creatorName]];
    [_invitedGroups removeObject:willJoinGroup];
    
    return [[LCCKConversationViewController alloc] initWithConversationId:groupId];
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
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.lun.brainstormer.query", DISPATCH_QUEUE_CONCURRENT);
    
    if (option >> 0 & 1 || option >> 1 & 1 || option >> 2 & 1) {
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            NSMutableArray *fetchInfo = [NSMutableArray array];
            if (option >> 0 & 1 || option >> 1 & 1) {
                [fetchInfo addObject:@"friendsList"];
                [_friendsList removeAllObjects];
            }
            if (option >> 0 & 1 || option >> 2 & 1) {
                [fetchInfo addObject:@"joinedGroups"];
                [_joinedGroups removeAllObjects];
            }
            
            // fetch ids of joined groups
            [_user fetchInBackgroundWithKeys:fetchInfo block:^(AVObject * _Nullable object,
                                                               NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Failed to renew joined groups: %@", error.localizedDescription);
                    dispatch_group_leave(group);
                } else {
                    // store friends
                    for (NSDictionary *people in _user[@"friendsList"]) {
                        [_friendsList addObject:[BrainStormPeople peopleWithId:people[@"id"]
                                                                          name:people[@"name"]]];
                    }
                    
                    // query details of each group
                    NSMutableArray *querys = [NSMutableArray array];
                    for (NSString *groupId in _user[@"joinedGroups"]) {
                        AVQuery *query = [AVQuery queryWithClassName:@"_Conversation"];
                        [query whereKey:@"objectId" equalTo:groupId];
                        [querys addObject:query];
                    }
                    
                    [AVObject fetchAllInBackground:querys block:^(NSArray * _Nullable objects,
                                                                  NSError * _Nullable error) {
                        if (error) {
                            NSLog(@"Failed to query joined groups: %@", error.localizedDescription);
                        } else {
                            for (AVObject *group in objects) {
                                [_joinedGroups addObject:[BrainStormGroup groupWithId:group.objectId
                                                                                topic:group[@"topic"]
                                                                          creatorName:group[@"creatorName"]]];
                            }
                        }
                        dispatch_group_leave(group);
                    }];
                }
            }];
        });
    }
    
    if (option >> 0 & 1 || option >> 3 & 1) {
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
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
                dispatch_group_leave(group);
            }];
        });
    }
    
    dispatch_group_notify(group, queue, ^{
        if (handler) handler(nil);
    });
}

@end
