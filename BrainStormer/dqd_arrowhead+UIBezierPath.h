//
//  dqd_arrowhead+UIBezierPath.h
//  BrainStormer
//
//  Created by Lun on 2016/10/6.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (dqd_arrowhead)

+ (UIBezierPath *)dqd_bezierPathWithArrowFromPoint:(CGPoint)startPoint
                                           toPoint:(CGPoint)endPoint
                                         tailWidth:(CGFloat)tailWidth
                                         headWidth:(CGFloat)headWidth
                                        headLength:(CGFloat)headLength;

@end
