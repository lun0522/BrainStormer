//
//  InvitationLetterViewCell.h
//  BrainStormer
//
//  Created by Lun on 2016/10/3.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvitationLetterViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *Topic;
@property (weak, nonatomic) IBOutlet UILabel *Inviter;
@property (weak, nonatomic) IBOutlet UIButton *YesButton;
@property (weak, nonatomic) IBOutlet UIButton *NoButton;
@property (nonatomic, retain) IBOutlet UIButton *MoreInfo;

@end
