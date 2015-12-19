//
//  CustomCameraPhoto.h
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/12.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCameraPhoto : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *FlashLightSwitch;
@property (weak, nonatomic) IBOutlet UIButton *CameraFrontBackSwitch;
@property (weak, nonatomic) IBOutlet UIButton *FlashLightOn;
@property (weak, nonatomic) IBOutlet UIButton *FlashLightOff;
@property (weak, nonatomic) IBOutlet UIButton *FlashLightAuto;


@property (weak, nonatomic) IBOutlet UIButton *CancelToPreSceneButton;
@property (weak, nonatomic) IBOutlet UIButton *ShutterButton;
@property (weak, nonatomic) IBOutlet UIImageView *LastPhotoImage;
@property (weak, nonatomic) IBOutlet UIView *CameraView;

@property (weak, nonatomic) IBOutlet UIImageView *flash_auto_imageView;
@property (weak, nonatomic) IBOutlet UIImageView *flash_off_imageView;
@property (weak, nonatomic) IBOutlet UIImageView *flash_on_imageView;


+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size;
@end
