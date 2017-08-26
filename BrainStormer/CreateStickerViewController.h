//
//  CreateStickerViewController.h
//  BrainStormer
//
//  Created by Lun on 2016/10/5.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>

@interface CreateStickerViewController : UIViewController <UIPopoverPresentationControllerDelegate> {
    NSUserDefaults *userDefaults;
    NSString *GroupId;
}

@property (weak, nonatomic) IBOutlet UITextView *Title;
@property (weak, nonatomic) IBOutlet UITextView *Detail;
@property (weak, nonatomic) IBOutlet UIButton *CreateButton;
@property (weak, nonatomic) IBOutlet UIButton *DeleteButton;
@property (weak, nonatomic) IBOutlet UIButton *PicPickerButton;
@property (weak, nonatomic) IBOutlet UIImageView *Image;


@end
