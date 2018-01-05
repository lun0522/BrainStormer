//
//  CreatGroupViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/1.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import <Photos/Photos.h>
#import "BrainStormEntity.h"
#import "InviteTableViewController.h"
#import "CreatGroupViewController.h"

@interface CreatGroupViewController () <UITextFieldDelegate> {
    NSArray<BrainStormPeople *> *_invitePeopleList;
}

@property (weak, nonatomic) IBOutlet UIImageView *QRImage;
@property (weak, nonatomic) IBOutlet UITextField *topic;
@property (weak, nonatomic) IBOutlet UITextView *namesText;

- (IBAction)tapQRCode:(id)sender;
- (IBAction)inviteMore:(id)sender;
- (IBAction)createGroup:(id)sender;

@end

@implementation CreatGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _QRImage.hidden = YES;
    _QRImage.userInteractionEnabled = NO;
    
    _namesText.editable = NO;
    [self setNames:nil];
    _invitePeopleList = [NSArray array];
    
    _topic.layer.cornerRadius = 5.0f;
    _topic.layer.borderWidth = 1.0f;
    _namesText.layer.cornerRadius = 5.0f;
    _namesText.layer.borderWidth = 1.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setNames:(NSString *)names {
    _namesText.text = names && names.length != 0 ? names : @"Please invite at least one people...";
}

- (IBAction)tapQRCode:(id)sender {
    if (!self.QRImage.hidden) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                UIImageWriteToSavedPhotosAlbum(_QRImage.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                break;
            case PHAuthorizationStatusDenied:
                [self presentAlertWithTitle:@"Failed to save QR code..." message:@"No permission to access album"];
                break;
            case PHAuthorizationStatusNotDetermined: {
                    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authStatus) {
                        if (authStatus == PHAuthorizationStatusAuthorized) {
                            UIImageWriteToSavedPhotosAlbum(_QRImage.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                        } else {
                            [self presentAlertWithTitle:@"Failed to save QR code..." message:@"No permission to access album"];
                        }
                    }];
                    break;
                }
            default:
                break;
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self presentAlertWithTitle:error ? @"Failed in saving" : @"QR code saved!" message:nil];
}

- (IBAction)inviteMore:(id)sender {
    __weak CreatGroupViewController *weakSelf = self;
    InviteTableViewController *vc = [[InviteTableViewController alloc]
                                     initWithSelectedPeople:_invitePeopleList
                                     callback:^(NSArray<BrainStormPeople *> * _Nullable peopleList,
                                                NSString * _Nullable names) {
                                         if (peopleList) _invitePeopleList = peopleList;
                                         if (names) [weakSelf setNames:names];
                                     }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)createGroup:(id)sender {
    if (_topic.text.length == 0) {
        [self presentAlertWithTitle:@"Please enter a topic!" message:nil];
    } else {
        NSMutableArray *invitedIdList = [NSMutableArray array];
        for (BrainStormPeople *people in _invitePeopleList) {
            [invitedIdList addObject:people[BSPIdKey]];
        }
        
        __weak CreatGroupViewController *weakSelf = self;
        [BrainStormUser.currentUser createGroupWithTopic:_topic.text
                                           invitedIdList:invitedIdList
                                       completionHandler:^(NSError * _Nullable error,
                                                           NSString * _Nullable encrypted) {
                                           if (error) {
                                               [weakSelf presentAlertWithTitle:@"Failed to create a group" message:error.localizedDescription];
                                           } else {
                                               _invitePeopleList = [NSArray array];
                                               _topic.text = @"";
                                               [weakSelf setNames:nil];
                                               
                                               _QRImage.hidden = NO;
                                               _QRImage.userInteractionEnabled = YES;
                                               _QRImage.image = [self createQRForString:encrypted];
                                           }
                                       }];
    }
}

- (UIImage *)createQRForString:(NSString *)string {
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:stringData forKey:@"inputMessage"];
    CIImage *ciImage = filter.outputImage;
    UIImage *rawQRImage = [self nonInterpolatedUIImageFormCIImage:ciImage expectedSize:200];
    
    NSString *directoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    UIImage *avatarImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", directoryPath, BrainStormUser.currentUser.avatarFile]];
    
    UIGraphicsBeginImageContext(rawQRImage.size);
    [rawQRImage drawInRect:CGRectMake(0, 0, rawQRImage.size.width, rawQRImage.size.height)];
    
    CGFloat width = 40;
    CGFloat height = width;
    CGFloat x = (rawQRImage.size.width - width) * 0.5;
    CGFloat y = (rawQRImage.size.height - height) * 0.5;
    [avatarImage drawInRect:(CGRectMake(x, y, width, height))];
    
    UIImage *QRImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return QRImage;
}

- (UIImage *)nonInterpolatedUIImageFormCIImage:(CIImage *)image expectedSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)presentAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
