//
//  CreatGroupViewController.m
//  BrainStormer
//
//  Created by Lun on 2016/10/1.
//  Copyright © 2016年 Lun. All rights reserved.
//

#import "CreatGroupViewController.h"

@interface CreatGroupViewController ()

@end

@implementation CreatGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.QRImage.hidden = YES;
    self.QRImage.userInteractionEnabled = NO;
    
    [self SetTextView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InvitedChange:) name:@"InvitedChangeNotification" object:nil];
}

- (void)SetTextView {
    self.InviteList.editable = NO;
    self.InviteList.text = @"Please invite at least one people...";
    self.InviteNameList = [[NSMutableArray alloc] initWithObjects:@"Alloc", nil];
    [self.InviteNameList removeAllObjects];
    self.InviteIdList = [[NSMutableArray alloc] initWithObjects:@"Alloc", nil];
    [self.InviteIdList removeAllObjects];
    self.Topic.layer.cornerRadius = 5.0f;
    self.Topic.layer.borderWidth = 1.0f;
    self.InviteList.layer.cornerRadius = 5.0f;
    self.InviteList.layer.borderWidth = 1.0f;
}

- (void)InvitedChange:(NSNotification *) notification {
    if ([self.InviteNameList count] == 0) {
        self.InviteList.text = @"Please invite at least one people...";
    }else {
        self.InviteList.text = [self.InviteNameList componentsJoinedByString:@", "];
    }
}

- (IBAction)TapQR:(id)sender {
    if (!self.QRImage.hidden) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

        if (status == PHAuthorizationStatusAuthorized) {
            // Access has been granted.
            [self saveImageToPhotos:self.QRImage.image];
        }
        else if (status == PHAuthorizationStatusDenied) {
            // Access has been denied.
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Fail" message:@"We can't save the QR code to your album without a permission." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Good!" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        else if (status == PHAuthorizationStatusNotDetermined) {
            // Access has not been determined.
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    // Access has been granted.
                    [self saveImageToPhotos:self.QRImage.image];
                }
                else {
                    // Access has been denied.
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Fail" message:@"We can't save the QR code to your album without a permission." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Good!" style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }];  
        }
        else if (status == PHAuthorizationStatusRestricted) {
            // Restricted access - normally won't happen.
        }
    }
}

- (IBAction)InviteMore:(id)sender {
    InviteTableViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"InviteTable"];
    [vc.SelectedName removeAllObjects];
    [vc.SelectedId removeAllObjects];
    vc.SelectedName = self.InviteNameList;
    vc.SelectedId = self.InviteIdList;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)CreateGroup:(id)sender {
    if (self.Topic.text.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please say something about the topic!" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else {
        AVUser *currentUser = [AVUser currentUser];
        NSArray *namelist = [[NSArray alloc] initWithObjects:currentUser.objectId, [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]], nil];
        NSMutableDictionary *dicParameters = [NSMutableDictionary dictionary];
        [dicParameters setObject:namelist forKey:@"namelist"];
        
        [AVCloud callFunctionInBackground:@"CreateGroup"
                           withParameters:dicParameters
                                    block:^(id object, NSError *error) {
                                        if (error != nil) {
                                            NSLog(@"Failed to create a group: %@",error);
                                        }else {
                                            NSMutableDictionary *returnValue = object;
                                            [self RenewGroupList:[returnValue objectForKey:@"objectId"]];
                                            
                                            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Successfully created a group!" message:@"Others can join the group by scaaning the QR code. Please tap to save it." preferredStyle:UIAlertControllerStyleAlert];
                                            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Good!" style:UIAlertActionStyleCancel handler:nil];
                                            [alertController addAction:cancelAction];
                                            [self presentViewController:alertController animated:YES completion:nil];
                                        }
                                    }];
    }
}

- (void)RenewGroupList:(NSString *)NewGroupId {
    AVUser *currentUser = [AVUser currentUser];
    NSArray *PreviousInvolved = [currentUser objectForKey:@"GroupInvolved"];
    NSMutableArray *NewInvolved = [NSMutableArray arrayWithArray:PreviousInvolved];
    [NewInvolved addObject:NewGroupId];
    
    // Renew GroupInvolved list on Leancloud
    AVObject *renew = [AVObject objectWithClassName:@"_User" objectId:currentUser.objectId];
    [renew setObject:NewInvolved forKey:@"GroupInvolved"];
    [renew saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {
            NSLog(@"Failed to renew GroupInvolved list on Leancloud :%@",error);
        }else {
            // Renew AVUser singleton
            AVObject *RenewSingleton = [AVObject objectWithClassName:@"_User" objectId:currentUser.objectId];
            NSArray *keys = [NSArray arrayWithObjects:@"GroupInvolved", nil];
            [RenewSingleton fetchInBackgroundWithKeys:keys block:^(AVObject *object, NSError *error) {
                if (error != nil) {
                    NSLog(@"Failed to renew the singleton: %@",error);
                }else {
                    [currentUser setObject:[object objectForKey:@"GroupInvolved"] forKey:@"GroupInvolved"];
                    
                    // Save group topic, title, creator name and picture to _Conversation
                    AVObject *setgroup = [AVObject objectWithClassName:@"_Conversation" objectId:NewGroupId];
                    [setgroup setObject:self.Topic.text forKey:@"Topic"];
                    [setgroup setObject:currentUser.username forKey:@"Creator"];
                    [setgroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error != nil) {
                            NSLog(@"Failed to update group :%@",error);
                        }else {
                            // After the singleton and conversation renewed, Let GroupListView know and refresh
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateGroupNotification" object:nil userInfo:@{}];
                            
                            // Clean topic, to avoid creating a same group
                            self.Topic.text = @"";
                        }
                    }];
                }
            }];
        }
    }];
    
    // Post invitations to invited persons
    for (NSInteger j = 0; j < [self.InviteIdList count]; j++) {
        
        AVObject *InvitationLetter = [AVObject objectWithClassName:@"Invitation"];
        [InvitationLetter setObject:[self.InviteIdList objectAtIndex:j] forKey:@"InvitedId"];
        [InvitationLetter setObject:NewGroupId forKey:@"InvitedToGroup"];
        [InvitationLetter setObject:self.Topic.text forKey:@"GroupTopic"];
        [InvitationLetter setObject:currentUser.username forKey:@"InviterName"];
        [InvitationLetter saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error != nil) {
                NSLog(@"Failed to send an invitation: %@",error);
            }else {
                // Clean invitelist, to avoid creating a same group
                self.InviteList.text = @"";
            }
        }];
    }
    
    self.QRImage.hidden = NO;
    self.QRImage.userInteractionEnabled = YES;
    NSString *Media = [self.Topic.text stringByAppendingString:@" "];
    self.QRImage.image =[self createQRForString:[Media stringByAppendingString:NewGroupId]];
}

- (UIImage *)createQRForString:(NSString *)qrString
{
    AVUser *currentUser = [AVUser currentUser];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:stringData forKey:@"inputMessage"];
    CIImage *ciImage = [filter outputImage];
    UIImage *image = [self creatImage:ciImage size:200];
    //Add a portrait
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *File = [[currentUser objectForKey:@"PortraitUrl"] substringWithRange:NSMakeRange(31, 23)];
    UIImage *icon = [self loadImage:File ofType:@"jpg" inDirectory:documentsDirectoryPath];
    UIImage *newImage = [self creatImageIcon:image icon:icon];
    return newImage;
}

- (UIImage *)creatImage:(CIImage *)image size:(CGFloat )size
{
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

- (UIImage *)creatImageIcon:(UIImage *)bgImage icon:(UIImage *)iconImage
{
    UIGraphicsBeginImageContext(bgImage.size);
    [bgImage drawInRect:(CGRectMake(0, 0, bgImage.size.width, bgImage.size.height))];
    CGFloat width = 40;
    CGFloat height = width;
    CGFloat x = (bgImage.size.width - width) * 0.5;
    CGFloat y = (bgImage.size.height - height) * 0.5;
    [iconImage drawInRect:(CGRectMake(x, y, width, height))];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    return result;
}

- (void)saveImageToPhotos:(UIImage*)savedImage{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    NSString *msg;
    if(error != NULL) {
        msg = @"Failed in saving...";
    }else {
        msg = @"QR code saved!";
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
