//
//  BrainStormEntity.m
//  BrainStormer
//
//  Created by Lun on 2017/8/26.
//  Copyright © 2017年 Lun. All rights reserved.
//

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

@end

@implementation BrainStormUser {
    NSMutableArray *_joinedGroups;
    NSMutableArray *_invitedGroups;
}

+ (BrainStormUser * _Nullable)userWithName:(NSString * _Nonnull)username
                                  password:(NSString * _Nonnull)password {
    NSError *error;
    BrainStormUser *user = [self logInWithUsername:username
                                          password:password
                                             error:&error];
    if (!error) {
        [self getAvatar];
        [ChatKitUtils userDidLoginWithId:BrainStormUser.currentUser.objectId];
        return user;
    } else {
        NSLog(@"Failed to login: %@", error.localizedDescription);
        return nil;
    }
}

+ (void)getAvatar {
    NSString *avatarURL = [BrainStormUser currentUser][@"avatarURL"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *File = [avatarURL substringWithRange:NSMakeRange(31, 23)];
    NSString *Filename = [File stringByAppendingString:@".jpg"];
    NSString *uniquePath=[paths[0] stringByAppendingPathComponent:Filename];
    BOOL isDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    if (!isDownloaded) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *avatar = [self downloadImageFromURL:avatarURL];
            NSString * documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            [self saveImage:avatar withFileName:File ofType:@"jpg" inDirectory:documentsDirectoryPath];
        });
    }
}

+ (UIImage *)downloadImageFromURL:(NSString *)imageURL {
    NSLog(@"Downloading image");
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
}

+ (void)saveImage:(UIImage *)image
     withFileName:(NSString *)imageName
           ofType:(NSString *)extension
      inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        NSLog(@"Not jpg");
    }
}

- (NSArray<BrainStormGroup *> * _Nonnull)joinedGroupsList {
    if (!_joinedGroups) {
        _joinedGroups = [[NSMutableArray alloc] init];
    }
    return [_joinedGroups copy];
}

- (void)addJoinedGroup:(BrainStormGroup * _Nonnull)group {
    [_joinedGroups addObject:group];
}

- (void)clearJoinedGroups {
    [_joinedGroups removeAllObjects];
}

- (NSArray<BrainStormGroup *> * _Nonnull)invitedGroupsList {
    if (!_invitedGroups) {
        _invitedGroups = [[NSMutableArray alloc] init];
    }
    return [_invitedGroups copy];
}

- (void)addInvitedGroup:(BrainStormGroup * _Nonnull)group {
    [_invitedGroups addObject:group];
}

- (void)clearInvitedGroups {
    [_invitedGroups removeAllObjects];
}

@end
