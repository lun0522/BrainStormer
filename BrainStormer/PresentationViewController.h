//
//  PresentationViewController.h
//  BrainStormer
//
//  Created by Lun on 2016/10/4.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PresentationViewController : UIViewController

- (IBAction)ShowFile:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *Webview;

@end
