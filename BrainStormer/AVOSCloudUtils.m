//
//  AVOSCloudUtils.m
//  BrainStormer
//
//  Created by Lun on 2017/8/26.
//  Copyright © 2017年 Lun. All rights reserved.
//

#import <AVOSCloud.h>
#import <AVIMClient.h>
#import "BrainStormEntity.h"
#import "ChatKitUtils.h"
#import "AVOSCloudUtils.h"

@implementation AVOSCloudUtils

NSString *const BSM_AVOSCloudAppId = @"SNNDXwGf0dAJrqbEON4M4Ry0-MdYXbMMI";
NSString *const BSM_AVOSCloudAppKey = @"taVP3U4xG0JyFp5WM58ckSMA";

+ (void)applicationDidfinishLaunch {
    [AVOSCloud setServiceRegion:AVServiceRegionUS];
    [AVOSCloud setApplicationId:BSM_AVOSCloudAppId clientKey:BSM_AVOSCloudAppKey];
    [AVIMClient setUnreadNotificationEnabled:YES];
    [AVIMClient setTimeoutIntervalInSeconds:20];
}

+ (void)getObjectInBackgroundWithClassName:(NSString *)className
                                  objectId:(NSString *)objectId
                                completion:(void (^)(AVObject *object, NSError *error))completion{
    AVQuery *query = [AVQuery queryWithClassName:className];
    [query getObjectInBackgroundWithId:objectId
                                 block:^(AVObject * _Nullable object, NSError * _Nullable error) {
                                     completion(object, error);
                                 }];
}

@end
