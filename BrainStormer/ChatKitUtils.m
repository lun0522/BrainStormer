//
//  ChatKitUtils.m
//  BrainStormer
//
//  Created by Lun on 2017/8/26.
//  Copyright © 2017年 Lun. All rights reserved.
//

#import <ChatKit/LCChatKit.h>
#import "AVOSCloudUtils.h"
#import "LCCKUser.h"
#import "BrainStormEntity.h"
#import "ChatKitUtils.h"

@implementation ChatKitUtils

+ (void)applicationDidfinishLaunch {
    [LCCKInputViewPluginTakePhoto registerSubclass];
    [LCCKInputViewPluginPickImage registerSubclass];
    [LCCKInputViewPluginLocation registerSubclass];
}

+ (void)setAppInfo {
    [LCChatKit setAppId:BSM_AVOSCloudAppId appKey:BSM_AVOSCloudAppKey];
}

+ (void)setFetchProfiles {
    [[LCChatKit sharedInstance] setFetchProfilesBlock:^(NSArray<NSString *> *userIds, LCCKFetchProfilesCompletionHandler completionHandler) {
        
        if (!completionHandler) {
            NSLog(@"No completion handler");
            return;
        }
        
        if (userIds.count == 0) {
            NSInteger code = 0;
            NSString *errorReasonText = @"User ids is nil";
            NSDictionary *errorInfo = @{
                                        @"code": @(code),
                                        NSLocalizedDescriptionKey: errorReasonText,
                                        };
            NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                                 code:code
                                             userInfo:errorInfo];
            completionHandler(nil, error);
            return;
        }
        
        // Query for users
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        NSMutableArray *querys = [NSMutableArray array];
        NSMutableArray *users = [NSMutableArray array];
        for (NSString *uid in userIds) {
            [querys addObject:[AVObject objectWithClassName:@"_User"
                                                   objectId:uid]];
        }
        
        [AVObject fetchAllInBackground:querys
                                 block:^(NSArray * _Nullable objects,
                                         NSError * _Nullable error) {
                                     for (AVObject *user in objects) {
                                         [users addObject:[LCCKUser userWithUserId:user.objectId
                                                                              name:user[@"username"]
                                                                         avatarURL:user[@"avatarUrl"]]];
                                     }
                                     dispatch_semaphore_signal(semaphore);
                                 }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        completionHandler(users.copy, nil);
    }];
}

+ (void)setConversationInvalidedHandler {
    [[LCChatKit sharedInstance] setConversationInvalidedHandler:^(NSString *conversationId, LCCKConversationViewController *conversationController, id<LCCKUserDelegate> administrator, NSError *error) {
        if (error) NSLog(@"Failed to create a conversation: %@", error.localizedDescription);
        //Error code list：https://leancloud.cn/docs/realtime_v2.html#%E4%BA%91%E7%AB%AF%E9%94%99%E8%AF%AF%E7%A0%81%E8%AF%B4%E6%98%8E
    }];
}

+ (void)setLoadLatestMessages {
    [[LCChatKit sharedInstance] setLoadLatestMessagesHandler:^(LCCKConversationViewController *conversationController, BOOL succeeded, NSError *error) {
         if (error) NSLog(@"Failed to load previous chat record: %@", error.localizedDescription);
     }];
}

+ (void)setLongPressMessage {
    [[LCChatKit sharedInstance] setLongPressMessageBlock:^NSArray<UIMenuItem *> *(LCCKMessage *message, NSDictionary *userInfo) {
        if (message.mediaType != kAVIMMessageMediaTypeText) return nil;
        
        // Menu and corresponding operation
        LCCKMenuItem *copyItem =
        [[LCCKMenuItem alloc] initWithTitle:LCCKLocalizedStrings(@"copy")
                                      block:^{
                                          UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                          [pasteboard setString:[message text]];
                                      }];
        
        LCCKConversationViewController *conversationViewController = userInfo[LCCKLongPressMessageUserInfoKeyFromController];
        LCCKMenuItem *transpondItem =
        [[LCCKMenuItem alloc] initWithTitle:LCCKLocalizedStrings(@"transpond")
                                      block:^{
                                          [self TranspondMessage:message
                                    toConversationViewController:conversationViewController];
                                      }];
        return @[copyItem, transpondItem];
    }];
}

+ (void)TranspondMessage:(LCCKMessage *)message
toConversationViewController:(LCCKConversationViewController *)conversationViewController {
    LCCKLog(@"Transpond the message");
}

+ (void)setForceReconect {
    [[LCChatKit sharedInstance] setForceReconnectSessionBlock:
     ^(NSError *aError, BOOL granted,
       __kindof UIViewController *viewController,
       LCCKReconnectSessionCompletionHandler completionHandler) {
        
        // User says yes
        if (granted) {
            BOOL force = (aError.code == 4111);
            [[LCChatKit sharedInstance]  openWithClientId:[LCChatKit sharedInstance].clientId
                                                    force:force
                                                 callback:^(BOOL succeeded, NSError *error) {
                                                     if (error) NSLog(@"Failed to reconnect: %@", error.localizedDescription);
                                                 }];
            return;
        }else { // User says no
            if (BrainStormUser.currentUser) [BrainStormUser.currentUser logout];
        }
        
        // Show error info
        NSInteger code = 0;
        NSString *errorReasonText = @"Not granted";
        NSDictionary *errorInfo = @{
                                    @"code": @(code),
                                    NSLocalizedDescriptionKey: errorReasonText,
                                    };
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:code
                                         userInfo:errorInfo];
        if (completionHandler) completionHandler(NO, error);
    }];
}

+ (void)userDidLoginWithId:(NSString * _Nonnull)userId {
    [self setAppInfo];
    [self setFetchProfiles];
    [self setConversationInvalidedHandler];
    [self setLoadLatestMessages];
    [self setLongPressMessage];
    [self setForceReconect];
    [[LCChatKit sharedInstance] openWithClientId:userId
                                        callback:^(BOOL succeeded, NSError *error) {
                                            if (error) NSLog(@"Failed to login chat: %@", error.localizedDescription);
                                        }];
}

+ (void)userDidLogOut {
    [[LCChatKit sharedInstance] removeAllCachedProfiles];
    [[LCChatKit sharedInstance] closeWithCallback:^(BOOL succeeded, NSError *error) {
        if (error) NSLog(@"Failed to logout chat: %@", error.localizedDescription);
    }];
}

@end
