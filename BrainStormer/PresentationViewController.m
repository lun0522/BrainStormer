//
//  PresentationViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/4.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "PresentationViewController.h"

@interface PresentationViewController ()

@end

@implementation PresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)ShowFile:(id)sender {
    NSURL *targetURL = [NSURL URLWithString:@"https://www.ics.uci.edu/~corps/phaseii/DiMaggioPowell-IronCageRevisited-ASR.pdf"];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [self.Webview loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
