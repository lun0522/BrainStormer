//
//  InvitationLetterViewCell.m
//  BrainStormer
//
//  Created by Lun on 2016/10/3.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "InvitationLetterViewCell.h"

@implementation InvitationLetterViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.Topic.tag = 1;
    self.Inviter.tag = 2;
    self.YesButton.tag = 3;
    self.NoButton.tag = 4;
    self.MoreInfo.tag = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
