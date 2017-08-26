//
//  BoardViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/4.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "BoardViewController.h"

@interface BoardViewController ()

@end

@implementation BoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self SetScrollView];
    
    [self SetButton];
    
    [self RegisterNotiCenter];
    
    [self SetDrawArrowClick];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
}

- (void)SetDrawArrowClick {
    DrawArrowClick =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(DrawArrow:)];
    [WhiteBoard addGestureRecognizer:DrawArrowClick];
}

- (void)SetButton {
    Locked = NO;
    self.LockButton.imageView.image = [UIImage imageNamed:@"unlocked.png"];
    [self.LockButton addTarget:self action:@selector(ClickLock:) forControlEvents:UIControlEventTouchDown];
    
    AddingArrow = NO;
    WaitForSecondClick = NO;
    self.ArrowButton.imageView.image = [UIImage imageNamed:@"unarrow.png"];
    [self.ArrowButton addTarget:self action:@selector(AddArrow:) forControlEvents:UIControlEventTouchDown];
    FirstPointX = 0;
    FirstPointY = 0;
}

- (void)SetScrollView {
    float StartHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
    CGRect ScrollRect = CGRectMake(0, StartHeight, self.view.bounds.size.width, self.view.bounds.size.height);
    self.ScrollView.frame = ScrollRect;
    WhiteBoard = [[UIView alloc] initWithFrame:CGRectMake(0, 2, self.view.bounds.size.width * 6.0, self.view.bounds.size.height * 3.0)];
    [self.ScrollView addSubview:WhiteBoard];
    self.ScrollView.contentSize = WhiteBoard.frame.size;
    self.ScrollView.delegate = self;
    self.ScrollView.maximumZoomScale = 4.0;
    self.ScrollView.minimumZoomScale = 0.5;
}

- (void)RegisterNotiCenter {
    // Get GroupId
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetGroupId:) name:@"TellBVGroupIdNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BVAskForGroupIdNotification" object:nil userInfo:@{}];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddStickerFromCreate:) name:@"BoardAddStickerNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SaveSticker:) name:@"SaveStickerNotification" object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"addstickerpopover"]) {
        CreateStickerViewController *vc = [[CreateStickerViewController alloc] init];
        vc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        vc = segue.destinationViewController;
        UIPopoverPresentationController *ppc = vc.popoverPresentationController;
        if (ppc) {
            ppc.delegate = self;
        }
    }
}

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}

- (void)GetGroupId:(NSNotification *) notification {
    GroupId = [[notification userInfo] objectForKey:@"GroupId"];
}

- (void)AddStickerFromCreate:(NSNotification *) notification {
    [self AddSticker:[[notification userInfo] objectForKey:@"Title"] :[[notification userInfo] objectForKey:@"Detail"]];
}

- (void)AddSticker:(NSString *)Title :(NSString *)Detail {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(imageMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [button addTarget:self action:@selector(imageMoved:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
    [button setImage:[UIImage imageNamed:@"Sticker.png"] forState:UIControlStateNormal];
    
    UITextView *TitleView = [[UITextView alloc] initWithFrame:CGRectMake(Margin, CeilingMargin, StickerWidth - Margin * 2, Margin)];
    [TitleView setFont:[UIFont systemFontOfSize:TitleFont]];
    TitleView.delegate = self;
    TitleView.scrollEnabled = NO;
    TitleView.backgroundColor = [UIColor clearColor];
    TitleView.text = Title;
    CGSize constraintSizeTitle = CGSizeMake(StickerWidth - Margin * 2, MAXFLOAT);
    CGSize sizeTitle = [TitleView sizeThatFits:constraintSizeTitle];
    TitleView.frame = CGRectMake(TitleView.frame.origin.x, TitleView.frame.origin.y, StickerWidth - Margin * 2, sizeTitle.height);
    [button addSubview:TitleView];
    
    UITextView *DetailView = [[UITextView alloc] initWithFrame:CGRectMake(Margin, TitleView.frame.origin.y + sizeTitle.height + DistanceTitleDetail, StickerWidth - Margin * 2, Margin)];
    [DetailView setFont:[UIFont systemFontOfSize:DetailFont]];
    DetailView.delegate = self;
    DetailView.userInteractionEnabled = NO;
    DetailView.backgroundColor = [UIColor clearColor];
    DetailView.text = Detail;
    CGSize constraintSizeDetail = CGSizeMake(StickerWidth - Margin * 2, MAXFLOAT);
    CGSize sizeDetail = [DetailView sizeThatFits:constraintSizeDetail];
    DetailView.frame = CGRectMake(DetailView.frame.origin.x, DetailView.frame.origin.y, StickerWidth - Margin * 2, sizeDetail.height);
    [button addSubview:DetailView];
    
    button.frame = CGRectMake(0, 0, StickerWidth, DetailView.frame.origin.y + sizeDetail.height + Margin);
    // button.tag = 10011;
    
    // to use it:
//    UIButton *button = (UIButton *)sender;
//    NSLog(@"%ld", (long)[button tag]);
    [WhiteBoard addSubview:button];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressSticker:)];
    [button addGestureRecognizer:longPress];
    
    [self.ScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)LongPressSticker:(UITapGestureRecognizer *)sender {
    UIButton *button = (UIButton*)sender.view;
    StickerMenuViewController *Menu = [[StickerMenuViewController alloc] init];
    Menu.preferredContentSize = CGSizeMake(90, 88);
    Menu.modalPresentationStyle = UIModalPresentationPopover;
    Menu.popoverPresentationController.sourceView = button;
    Menu.popoverPresentationController.sourceRect = button.bounds;
    Menu.popoverPresentationController.delegate = self;
    [self presentViewController:Menu animated:YES completion:nil];
}

- (void)SaveSticker:(NSNotification *) notification {
    self.AddStickerTitle = [[notification userInfo] objectForKey:@"Title"];
    self.AddStickerDetail = [[notification userInfo] objectForKey:@"Detail"];
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *) popoverPresentationController{
    // Save unfinished new sticker
    AVUser *currentUser = [AVUser currentUser];
    NSString *Media = [currentUser.objectId stringByAppendingString:GroupId];
    [userDefaults setObject:self.AddStickerTitle forKey:[Media stringByAppendingString:@"Title"]];
    [userDefaults setObject:self.AddStickerDetail forKey:[Media stringByAppendingString:@"Detail"]];
}

- (void)ClickLock:(id)sender {
    [self.LockButton setImage:Locked? [UIImage imageNamed:@"unlocked.png"]: [UIImage imageNamed:@"locked.png"] forState:UIControlStateNormal];
    [self.ScrollView setScrollEnabled:Locked? YES: NO];
    Locked = !Locked;
}

- (void)AddArrow:(id)sender {
    if (!AddingArrow) {    // Make sure that scrollview is locked, and other buttons uninteractable
        if (!Locked) {
            [self.LockButton setImage:[UIImage imageNamed:@"locked.png"] forState:UIControlStateNormal];
            [self.ScrollView setScrollEnabled:NO];
            Locked = !Locked;
        }
        [self.ArrowButton setImage:[UIImage imageNamed:@"Arrow.png"] forState:UIControlStateNormal];
        self.LockButton.userInteractionEnabled = NO;
        self.AddButton.userInteractionEnabled = NO;
        AddingArrow = !AddingArrow;
    }else {    // When drawing, click this button to cancel
        AddingArrow = !AddingArrow;
        WaitForSecondClick = NO;
        self.LockButton.userInteractionEnabled = YES;
        self.AddButton.userInteractionEnabled = YES;
        [self.ArrowButton setImage:[UIImage imageNamed:@"unarrow.png"] forState:UIControlStateNormal];
    }
}

- (void)DrawArrow:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:WhiteBoard];
    if (AddingArrow) {
        if (!WaitForSecondClick) {
            FirstPointX = point.x;
            FirstPointY = point.y;
            WaitForSecondClick = !WaitForSecondClick;
        }else {
            CGFloat xDist = (point.x - FirstPointX);
            CGFloat yDist = (point.y - FirstPointY);
            CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
            
            UIBezierPath *path=[UIBezierPath dqd_bezierPathWithArrowFromPoint:CGPointMake(FirstPointX, FirstPointY)
                                                                      toPoint:CGPointMake(point.x, point.y)
                                                                    tailWidth:15.0f
                                                                    headWidth:30.0f
                                                                   headLength:distance / 2.5];
            
            CAShapeLayer *shape = [CAShapeLayer layer];
            shape.path = path.CGPath;
            shape.fillColor = [UIColor colorWithRed:255/255.0 green:215/255.0 blue:0/255.0 alpha:1].CGColor;
            
            [WhiteBoard.layer addSublayer:shape];
            
            AddingArrow = !AddingArrow;
            WaitForSecondClick = !WaitForSecondClick;
            self.LockButton.userInteractionEnabled = YES;
            self.AddButton.userInteractionEnabled = YES;
            [self.ArrowButton setImage:[UIImage imageNamed:@"unarrow.png"] forState:UIControlStateNormal];
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return WhiteBoard;
}

- (IBAction) imageMoved:(id) sender withEvent:(UIEvent *) event
{
    UIControl *control = sender;
    
    UITouch *t = [[event allTouches] anyObject];
    CGPoint pPrev = [t previousLocationInView:control];
    CGPoint p = [t locationInView:control];
    
    CGPoint center = control.center;
    center.x += p.x - pPrev.x;
    center.y += p.y - pPrev.y;
    control.center = center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
