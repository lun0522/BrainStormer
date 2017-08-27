//
//  AVOSCloudUtils.h
//  BrainStormer
//
//  Created by Lun on 2017/8/26.
//  Copyright © 2017年 Lun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVObject;

@interface AVOSCloudUtils : NSObject

extern NSString *const BSM_AVOSCloudAppId;
extern NSString *const BSM_AVOSCloudAppKey;

+ (void)applicationDidfinishLaunch;
+ (void)getObjectInBackgroundWithClassName:(NSString *)className
                                  objectId:(NSString *)objectId
                                completion:(void (^)(AVObject *object, NSError *error))completion;

@end
