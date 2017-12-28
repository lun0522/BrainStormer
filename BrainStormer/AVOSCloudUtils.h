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

extern NSString * _Nonnull const BSM_AVOSCloudAppId;
extern NSString * _Nonnull const BSM_AVOSCloudAppKey;

+ (void)applicationDidfinishLaunch;
+ (void)getObjectInBackgroundWithClassName:(NSString * _Nonnull)className
                                  objectId:(NSString * _Nonnull)objectId
                                completion:(void (^ _Nullable)(AVObject * _Nullable object,
                                                               NSError * _Nullable error))completion;

@end
