//
//  OptionsTableViewController.h
//  BrainStormer
//
//  Created by Lun on 2016/10/5.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsTableViewController : UITableViewController <UIPopoverPresentationControllerDelegate>

@property (nonatomic,getter=isOn) BOOL SeeSlides;

@end
