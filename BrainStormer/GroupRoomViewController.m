//
//  GroupRoomViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/4.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import <ChatKit/LCChatKit.h>
#import "PresentationViewController.h"
#import "BoardViewController.h"
#import "OptionsTableViewController.h"
#import "GroupRoomViewController.h"

@interface GroupRoomViewController () <UIPopoverPresentationControllerDelegate> {
    NSString *_groupId;
    NSArray *_viewControllers;
    NSArray *_segmentedTitles;
    UISegmentedControl *_segmentedControl;
    UIViewController *_currentViewController;
}

@end

@implementation GroupRoomViewController

- (instancetype _Nonnull)initWithGroupId:(NSString * _Nonnull)groupId {
    if (self = [super init]) {
        _groupId = groupId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setups
    self.view.backgroundColor = [UIColor blueColor];
    UIBarButtonItem *OptionButton = [[UIBarButtonItem alloc] initWithTitle:@"Options"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(Option:)];
    self.navigationItem.rightBarButtonItem = OptionButton;
    
    // Initialize viewcontrollers
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LCCKConversationViewController *discussion = [[LCCKConversationViewController alloc] initWithConversationId:_groupId];
    UIViewController *presentation = [storyboard instantiateViewControllerWithIdentifier:@"Presentation"];
    UIViewController *board = [storyboard instantiateViewControllerWithIdentifier:@"Board"];
    
    // Initialize segmentedcontrol
    _viewControllers = @[discussion, presentation, board];
    _segmentedTitles = @[@"Discuss", @"Present", @"Board"];
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:_segmentedTitles];
    [_segmentedControl addTarget:self
                          action:@selector(segmentClicked:)
                forControlEvents:UIControlEventValueChanged];
    _segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = _segmentedControl;

    // Set the first child viewcontroller
    _currentViewController = _viewControllers[0];
    [self addChildViewController:_currentViewController];
    _currentViewController.view.frame = self.view.bounds;
    [self.view addSubview:_currentViewController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)Option:(id)sender {
    OptionsTableViewController *vc = [[OptionsTableViewController alloc] init];
    vc.preferredContentSize = CGSizeMake(125, 44);
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    vc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    vc.popoverPresentationController.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController * ) controller {
    return UIModalPresentationNone;
}

- (void)segmentClicked:(id)sender {
    if (sender == _segmentedControl) {
        NSUInteger index = _segmentedControl.selectedSegmentIndex;
        [self loadViewController:_viewControllers[index]];
    }
}

- (void)loadViewController:(UIViewController *)vc {
    [self addChildViewController:vc];
    
    [self transitionFromViewController:_currentViewController
                      toViewController:vc
                              duration:0
                               options:UIViewAnimationOptionTransitionNone
                            animations:^{
                                [_currentViewController.view removeFromSuperview];
                                vc.view.frame = self.view.bounds;
                                [self.view addSubview:vc.view];
                            } completion: ^(BOOL finished) {
                                [vc didMoveToParentViewController:self];
                                [_currentViewController removeFromParentViewController];
                                _currentViewController = vc;
                            }
     ];
}

@end
