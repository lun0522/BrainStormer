//
//  GroupRoomViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/4.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "GroupRoomViewController.h"

@interface GroupRoomViewController () <UIPopoverPresentationControllerDelegate> {
    NSArray *ViewControllers;
    NSArray *SegmentedTitles;
    UISegmentedControl *SegmentedControl;
    UIViewController *CurrentViewController;
    BOOL SeeSlides;
}

@end

@implementation GroupRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self RegisterNotiCenter];
    
    // Setups
    self.view.backgroundColor = [UIColor blueColor];
    UIBarButtonItem *OptionButton = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStylePlain target:self action:@selector(Option:)];
    self.navigationItem.rightBarButtonItem = OptionButton;
    SeeSlides = NO;
    
    // Initialize viewcontrollers
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LCCKConversationViewController *Discussion = [[LCCKConversationViewController alloc] initWithConversationId:self.GroupId];
    UIViewController *Presentation = [storyboard instantiateViewControllerWithIdentifier:@"Presentation"];
    UIViewController *Board = [storyboard instantiateViewControllerWithIdentifier:@"Board"];
    
    // Initialize segmentedcontrol
    ViewControllers = @[Discussion,Presentation,Board];
    SegmentedTitles = @[@"Discuss",@"Present",@"Board"];
    SegmentedControl = [[UISegmentedControl alloc] initWithItems: SegmentedTitles];
    [SegmentedControl addTarget: self
                              action: @selector(segmentClicked:)
                    forControlEvents: UIControlEventValueChanged];
    SegmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = SegmentedControl;

    
    // Set the first child viewcontroller
    CurrentViewController = ViewControllers[0];
    [self addChildViewController: CurrentViewController];
    CurrentViewController.view.frame = self.view.bounds;
    [self.view addSubview: CurrentViewController.view];
}

- (void)RegisterNotiCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SeeOrHide:) name:@"SeeSlidesNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SeeOrHide:) name:@"HideSlidesNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TellCSGroupId:) name:@"CSAskForGroupIdNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TellBVGroupId:) name:@"BVAskForGroupIdNotification" object:nil];
}

- (void)TellCSGroupId:(NSNotification *) notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TellCSGroupIdNotification" object:nil userInfo:[NSDictionary dictionaryWithObject:self.GroupId
                                                                                                                forKey:@"GroupId"]];
}

- (void)TellBVGroupId:(NSNotification *) notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TellBVGroupIdNotification" object:nil userInfo:[NSDictionary dictionaryWithObject:self.GroupId
                                                                                                                                            forKey:@"GroupId"]];
}

- (void)SeeOrHide:(NSNotification *) notification {
    SeeSlides = !SeeSlides;
}

- (void)Option:(id)sender {
    OptionsTableViewController *Table = [[OptionsTableViewController alloc] init];
    Table.SeeSlides = SeeSlides;
    Table.preferredContentSize = CGSizeMake(125, 44);
    Table.modalPresentationStyle = UIModalPresentationPopover;
    Table.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    Table.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    Table.popoverPresentationController.delegate = self;
    [self presentViewController:Table animated:YES completion:nil];
}

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}

- (void)segmentClicked:(id)sender
{
    if (sender == SegmentedControl)
    {
        NSUInteger index = SegmentedControl.selectedSegmentIndex;
        [self loadViewController: ViewControllers[index]];
    }
}

- (void)loadViewController:(UIViewController *)vc {
    [self addChildViewController: vc];
    
    [self transitionFromViewController: CurrentViewController
                      toViewController: vc
                              duration: 0
                               options: UIViewAnimationOptionTransitionNone
                            animations: ^{
                                [CurrentViewController.view removeFromSuperview];
                                vc.view.frame = self.view.bounds;
                                [self.view addSubview: vc.view];
                            } completion: ^(BOOL finished) {
                                [vc didMoveToParentViewController: self];
                                [CurrentViewController removeFromParentViewController];
                                CurrentViewController = vc;
                            }
     ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
