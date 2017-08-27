//
//  BrainStormEntity.m
//  BrainStormer
//
//  Created by Lun on 2017/8/26.
//  Copyright © 2017年 Lun. All rights reserved.
//

#import <AVOSCloud.h>
#import "ChatKitUtils.h"
#import "BrainStormEntity.h"

@implementation BrainStormGroup

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
    NSMutableArray *m_JoinedGroups;
    NSMutableArray *m_InvitedGroups;
}

+ (instancetype)logInWithUsername:(NSString *)username
                         password:(NSString *)password
                            error:(NSError **)error {
    BrainStormUser *user = [super logInWithUsername:username password:password error:error];
    if (!error) {
        [self getAvatar];
        [ChatKitUtils userDidLoginWithId:BrainStormUser.currentUser.objectId];
    }
    return user;
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
            UIImage *avatar = [self getImageFromURL:avatarURL];
            NSString * documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            [self saveImage:avatar withFileName:File ofType:@"jpg" inDirectory:documentsDirectoryPath];
        });
    }
}

+ (UIImage *)getImageFromURL:(NSString *)imageURL {
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

- (NSMutableArray<BrainStormGroup *> *)getJoinedGroupsList {
    if (!m_JoinedGroups) {
        m_JoinedGroups = [[NSMutableArray alloc] init];
    }
    return m_JoinedGroups;
}

- (void)addJoinedGroup:(BrainStormGroup *)group {
    [m_JoinedGroups addObject:group];
}

- (void)clearJoinedGroups {
    [m_JoinedGroups removeAllObjects];
}

- (NSMutableArray<BrainStormGroup *> *)getInvitedGroupsList {
    if (!m_InvitedGroups) {
        m_InvitedGroups = [[NSMutableArray alloc] init];
    }
    return m_InvitedGroups;
}

- (void)addInvitedGroup:(BrainStormGroup *)group {
    [m_InvitedGroups addObject:group];
}

- (void)clearInvitedGroups {
    [m_InvitedGroups removeAllObjects];
}

@end
