//
//  BoardViewController.h
//  BrainStormer
//
//  Created by Lun on 2016/10/4.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>
#import "CreateStickerViewController.h"
#import "dqd_arrowhead+UIBezierPath.h"
#import "StickerMenuViewController.h"

#define TitleFont 22
#define DetailFont 14
#define StickerWidth 260
#define CeilingMargin 40
#define Margin 20
#define DistanceTitleDetail 0

@interface BoardViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate> {
    UIView *WhiteBoard;
    BOOL Locked;
    NSUserDefaults *userDefaults;
    NSString *GroupId;
    BOOL AddingArrow;
    BOOL WaitForSecondClick;
    UITapGestureRecognizer *DrawArrowClick;
    float FirstPointX;
    float FirstPointY;
}

@property (weak, nonatomic) IBOutlet UIButton *LockButton;
@property (weak, nonatomic) IBOutlet UIButton *AddButton;
@property (weak, nonatomic) IBOutlet UIButton *ArrowButton;
@property (weak, nonatomic) IBOutlet UIScrollView *ScrollView;
@property (nonatomic,strong) NSString *AddStickerTitle;
@property (nonatomic,strong) NSString *AddStickerDetail;

@end
