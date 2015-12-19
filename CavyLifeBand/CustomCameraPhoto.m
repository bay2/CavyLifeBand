//
//  CustomCameraPhoto.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/12.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import "CustomCameraPhoto.h"
#import "CavyLifeBandDefined.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomBandCell.h"
#import "PhotoView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#include <Photos/Photos.h>
#import "AppDelegate.h"
@interface CustomCameraPhoto()
{
    bool IsBackCameraMode;
    AVCaptureFlashMode BackCameraFlashMode;
    UIImage *PhotoImage;
}
@property (strong) AVCaptureSession *CaptureSession;
@property (strong) AVCaptureStillImageOutput *CaptureImageOutPut;
@property (strong) AVCaptureDevice *BackCamera;
@property (strong) AVCaptureDevice *FrontCamera;
@property (strong) UIImagePickerController *imagePicker;
@property (strong) AVCaptureVideoPreviewLayer *PreviewLayew;
@property (strong) UIImageView *shutterAnimationView;
@property CGFloat BackCameraScale;
@property (strong, nonatomic) PHFetchResult *phFetchResult;
@end

@implementation CustomCameraPhoto


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.LastPhotoImage.hidden = YES;
    _CaptureSession = [[AVCaptureSession alloc] init];
    [_CaptureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    self.BackCameraScale = 1.0f;
    IsBackCameraMode = true;
    if(!_BackCamera || !_FrontCamera )
    {
        _BackCamera = [CustomCameraPhoto backCamera];
        _FrontCamera = [CustomCameraPhoto frontCamera];
        if( [_BackCamera hasFlash] && [_BackCamera hasTorch])
            BackCameraFlashMode = AVCaptureFlashModeAuto;
        [self changeFlashLightSwitchImage];
    }
    NSError *error;
    AVCaptureDeviceInput *DeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_BackCamera error:&error];
    if([_CaptureSession canAddInput:DeviceInput])
    {
        [_CaptureSession addInput:DeviceInput];
    }
    _PreviewLayew = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_CaptureSession];
    [_PreviewLayew setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    
    [rootLayer insertSublayer:_PreviewLayew atIndex:0];
    
    NSLog(@"insert sub layer");
    _CaptureImageOutPut = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *setting = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_CaptureImageOutPut setOutputSettings:setting];
    
    [_CaptureSession addOutput:_CaptureImageOutPut];
    self.CameraView.backgroundColor = [UIColor clearColor];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handlePinchToZoomRecognizer:)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPreview:)];
    
    [self.CameraView addGestureRecognizer:pinchGesture];
    [self.CameraView addGestureRecognizer:tap];
    
    
    UITapGestureRecognizer *tapLastPhotoImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLastPhotoImage:)];
    [self.LastPhotoImage setUserInteractionEnabled:YES];
    [self.LastPhotoImage addGestureRecognizer:tapLastPhotoImage];
    
    [_CaptureSession startRunning];
    self.shutterAnimationView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.shutterAnimationView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(takePhoto:)
                                                 name:@"BLE KEY_PRESS" object:nil];
    [self getLastPhoto];
}

- (void)dealloc
{
    // be careful in this method! can't access properties! almost gone from heap
    // unregister notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.LastPhotoImage.layer.masksToBounds=YES;
    self.LastPhotoImage.layer.cornerRadius = self.LastPhotoImage.frame.size.width / 2;
    self.LastPhotoImage.layer.borderColor = [CustomBandCell colorFromHexString:@"#FFFFFF"].CGColor;
    self.LastPhotoImage.hidden = NO;

    [super viewDidAppear:animated];
    
    if( !CGRectEqualToRect(_PreviewLayew.frame, self.CameraView.frame) )
    {
        [_PreviewLayew setFrame:self.CameraView.frame];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if( ![_CaptureSession isRunning] )
    {
        [_CaptureSession startRunning];
    }
    [AppDelegate setDisplayViewController:(UIViewController*)self];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.CaptureSession stopRunning];
}

-(void)tapLastPhotoImage:(UITapGestureRecognizer*)gesture
{
    NSLog(@"tap LastPhotoImage");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PhotoView *myVC = (PhotoView *)[storyboard instantiateViewControllerWithIdentifier:@"PhotoView"];
    PhotoView *photoView = [myVC initWithImage:PhotoImage frameSize:self.CameraView.frame];
    [self presentViewController:myVC animated:YES completion:nil];
}

-(void)getLastPhoto
{
    if( PhotoImage == nil)
    {
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        self.phFetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
        PHAsset *lastAsset = [self.phFetchResult lastObject];
        [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                                   targetSize:CGSizeMake(lastAsset.pixelWidth, lastAsset.pixelHeight)
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:PHImageRequestOptionsVersionCurrent
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        PhotoImage = result;
                                                        self.LastPhotoImage.image = [CustomCameraPhoto imageWithImage:PhotoImage scaledToFillSize:self.LastPhotoImage.frame.size];
                                                        self.LastPhotoImage.layer.borderWidth = 1.0f;
                                                    });
                                                }];
        
    }
}

/// 预览图层点击事件
- (void)tapPreview:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];
    CGPoint p = [self.PreviewLayew captureDevicePointOfInterestForPoint:point];
    [self focusAtPoint:p];
}

-(void) handlePinchToZoomRecognizer:(UIPinchGestureRecognizer*)pinchRecognizer {
    // 缩放结束时记录当前倍焦
    if(!IsBackCameraMode)
        return;
    if (pinchRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = self.BackCameraScale + (pinchRecognizer.scale - 1);
        if (scale >= 5) scale = 5;   // 最大5倍焦距
        if (scale <= 1) scale = 1;   // 最小1倍焦距
        NSError *error = nil;
        if ([_BackCamera lockForConfiguration:&error]) {
            _BackCamera.videoZoomFactor = scale;
            [_BackCamera unlockForConfiguration];
        } else {
            NSLog(@"error: %@", error);
        }
        self.BackCameraScale = scale;
    }
}

-(IBAction) switchCamera:(id)sender
{
    [self switchCameraTapped];
    [self ShowBackCameraFlashSettingButton];
}

- (IBAction)takePhoto:(id)sender {
    [self takePhoto];
    [self ShutterFlashAnimationOn];
}

-(void)ShutterFlashAnimationOn
{
    [UIView animateWithDuration: 0.1f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         self.shutterAnimationView.backgroundColor = [UIColor whiteColor];
                     }
                     completion: ^(BOOL finished){
                         self.shutterAnimationView.backgroundColor = [UIColor clearColor];
                     }
     ];
}

-(IBAction) returnPreSence:(id)sender
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)showDetailOfFlashLightSettingButton:(id)sender
{
    if(IsBackCameraMode)
    {
        if(self.FlashLightAuto.hidden)
        {
            self.FlashLightSwitch.hidden = NO;
            self.FlashLightOn.hidden = NO;
            self.FlashLightOff.hidden = NO;
            self.FlashLightAuto.hidden = NO;
            self.CameraFrontBackSwitch.hidden = YES;
            [self changeColorOfFlashModeButton];
            [self.FlashLightSwitch setAttributedTitle:nil forState:UIControlStateNormal];
        }
        else
        {
            [self changeFlashLightSwitchImage];
        }
    }
}

-(IBAction)selectFlashMode:(UIButton*)sender
{
    switch (sender.tag) {
        case 0://on
            BackCameraFlashMode = AVCaptureFlashModeOn;
            
            break;
        case 1://off
            BackCameraFlashMode = AVCaptureFlashModeOff;
            
            break;
        case 2://auto
            BackCameraFlashMode = AVCaptureFlashModeAuto;
            
            break;
        default:
            break;
    }
    [self changeFlashLightSwitchImage];
}

-(void)changeFlashLightSwitchImage
{
    NSAttributedString *attributedTitle = [self.FlashLightSwitch attributedTitleForState:UIControlStateNormal];
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithAttributedString:attributedTitle];
    
    if(BackCameraFlashMode == AVCaptureFlashModeOn)
    {
        [self.FlashLightSwitch setImage:self.flash_on_imageView.image forState:UIControlStateNormal];
        [mas.mutableString setString:self.FlashLightOn.titleLabel.text];
        [mas addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]  range:NSMakeRange(0, [self.FlashLightOn.titleLabel.text length])];
    }
    else if( BackCameraFlashMode == AVCaptureFlashModeOff )
    {
        [self.FlashLightSwitch setImage:self.flash_off_imageView.image forState:UIControlStateNormal];
        [mas.mutableString setString:self.FlashLightOff.titleLabel.text];
        [mas addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]  range:NSMakeRange(0, [self.FlashLightOff.titleLabel.text length])];

    }
    else
    {
        [self.FlashLightSwitch setImage:self.flash_auto_imageView.image forState:UIControlStateNormal];
        [mas.mutableString setString:self.FlashLightAuto.titleLabel.text];
        [mas addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]  range:NSMakeRange(0, [self.FlashLightAuto.titleLabel.text length])];
    }
    [self.FlashLightSwitch setAttributedTitle:mas forState:UIControlStateNormal];
    mas = nil;
    [self resetFlashModeButton];
    [self ShowBackCameraFlashSettingButton];
    [self setBackCameraFlashMode];
}

//flashlight mode setting button
-(void)ShowBackCameraFlashSettingButton
{
    if(IsBackCameraMode && [_BackCamera hasTorch] && [_BackCamera hasFlash])
    {
        self.FlashLightSwitch.hidden = NO;
    }
    else
    {
        self.FlashLightSwitch.hidden = YES;
    }
    self.FlashLightAuto.hidden = YES;
    self.FlashLightOn.hidden = YES;
    self.FlashLightOff.hidden = YES;
    self.CameraFrontBackSwitch.hidden = NO;
}

//set the flashlight mode for back-camera
-(void)setBackCameraFlashMode
{
    if ([_BackCamera hasTorch] && [_BackCamera hasFlash]){
        [_BackCamera lockForConfiguration:nil];
        [_BackCamera setFlashMode:BackCameraFlashMode];
        [_BackCamera unlockForConfiguration];
    }
}

//change the selected flash mode button's color
-(void)changeColorOfFlashModeButton
{
    if(BackCameraFlashMode == AVCaptureFlashModeOn)
    {
        NSAttributedString *attributedTitle = [self.FlashLightOn attributedTitleForState:UIControlStateNormal];
        NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithAttributedString:attributedTitle];
        [mas.mutableString setString:self.FlashLightOn.titleLabel.text];
        [mas addAttribute:NSForegroundColorAttributeName value:[CustomBandCell colorFromHexString:@"#ffaf14"]  range:NSMakeRange(0, [self.FlashLightOn.titleLabel.text length])];
        [self.FlashLightOn setAttributedTitle:mas forState:UIControlStateNormal];
    }
    else if( BackCameraFlashMode == AVCaptureFlashModeOff )
    {
        NSAttributedString *attributedTitle = [self.FlashLightOff attributedTitleForState:UIControlStateNormal];
        NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithAttributedString:attributedTitle];
        [mas.mutableString setString:self.FlashLightOff.titleLabel.text];
        [mas addAttribute:NSForegroundColorAttributeName value:[CustomBandCell colorFromHexString:@"#ffaf14"]  range:NSMakeRange(0, [self.FlashLightOff.titleLabel.text length])];
        [self.FlashLightOff setAttributedTitle:mas forState:UIControlStateNormal];
        
    }
    else
    {
        NSAttributedString *attributedTitle = [self.FlashLightAuto attributedTitleForState:UIControlStateNormal];
        NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithAttributedString:attributedTitle];
        [mas.mutableString setString:self.FlashLightAuto.titleLabel.text];
        [mas addAttribute:NSForegroundColorAttributeName value:[CustomBandCell colorFromHexString:@"#ffaf14"]  range:NSMakeRange(0, [self.FlashLightAuto.titleLabel.text length])];
        [self.FlashLightAuto setAttributedTitle:mas forState:UIControlStateNormal];
    }
}

//reset flash mode button color
-(void)resetFlashModeButton
{
    NSAttributedString *attributedTitle0 = [self.FlashLightOn attributedTitleForState:UIControlStateNormal];
    NSMutableAttributedString *mas0 = [[NSMutableAttributedString alloc] initWithAttributedString:attributedTitle0];
    [mas0.mutableString setString:self.FlashLightOn.titleLabel.text];
    [mas0 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]  range:NSMakeRange(0, [self.FlashLightOn.titleLabel.text length])];
    [self.FlashLightOn setAttributedTitle:mas0 forState:UIControlStateNormal];

    NSAttributedString *attributedTitle1 = [self.FlashLightOff attributedTitleForState:UIControlStateNormal];
    NSMutableAttributedString *mas1 = [[NSMutableAttributedString alloc] initWithAttributedString:attributedTitle1];
    [mas1.mutableString setString:self.FlashLightOff.titleLabel.text];
    [mas1 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]  range:NSMakeRange(0, [self.FlashLightOff.titleLabel.text length])];
    [self.FlashLightOff setAttributedTitle:mas1 forState:UIControlStateNormal];
    
    NSAttributedString *attributedTitle2 = [self.FlashLightAuto attributedTitleForState:UIControlStateNormal];
    NSMutableAttributedString *mas2 = [[NSMutableAttributedString alloc] initWithAttributedString:attributedTitle2];
    [mas2.mutableString setString:self.FlashLightAuto.titleLabel.text];
    [mas2 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]  range:NSMakeRange(0, [self.FlashLightAuto.titleLabel.text length])];
    [self.FlashLightAuto setAttributedTitle:mas2 forState:UIControlStateNormal];
    
}
-(AVCaptureDevice*)getCurrentInputDevice
{
    if(IsBackCameraMode)
    {
        return _BackCamera;
    }
    else
    {
        return _FrontCamera;
    }
}

- (void)focusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [self getCurrentInputDevice];
    NSError *error;
    if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus] && [device isFocusPointOfInterestSupported])
    {
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];     // 对焦点
            [device setFocusMode:AVCaptureFocusModeAutoFocus];  // 自动对焦模式
            if( [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeAutoExpose] )
            {
                [device setExposurePointOfInterest:point];  // 曝光点
                [device setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            [device unlockForConfiguration];
        } else {
            NSLog(@"Error: %@", error);
        }
    }
    else if( [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeAutoExpose] )
    {
         if ([device lockForConfiguration:&error]) {
             [device setExposurePointOfInterest:point];  // 曝光点
             [device setExposureMode:AVCaptureExposureModeAutoExpose];
             [device unlockForConfiguration];
         }else {
             NSLog(@"Error: %@", error);
         }
    }
}

-(void)switchCameraTapped
{
    //Change camera source
    if(_CaptureSession)
    {
        //Indicate that some changes will be made to the session
        [_CaptureSession beginConfiguration];
        
        //Remove existing input
        AVCaptureInput* currentCameraInput = [_CaptureSession.inputs objectAtIndex:0];
        [_CaptureSession removeInput:currentCameraInput];
        
        //Get new input
        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
        {
            newCamera = _FrontCamera;
            IsBackCameraMode = false;
        }
        else
        {
            newCamera = _BackCamera;
            IsBackCameraMode = true;
        }
        
        //Add input to session
        NSError *err = nil;
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
        if(!newVideoInput || err)
        {
            NSLog(@"Error creating capture device input: %@", err.localizedDescription);
        }
        else
        {
            [_CaptureSession addInput:newVideoInput];
        }
        
        //Commit all the configuration changes at once
        [_CaptureSession commitConfiguration];
    }
}

-(void)takePhoto
{
    AVCaptureConnection * videoConnection = nil;
    
    for(AVCaptureConnection * connect in _CaptureImageOutPut.connections)
    {
        for(AVCaptureInputPort * port in [connect inputPorts])
        {
            if( [[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connect;
                break;
            }
        }
        if(videoConnection)
            break;
    }
    [_CaptureImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if(imageDataSampleBuffer != nil)
        {
            NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            PhotoImage = [UIImage imageWithData:data];
            UIImageWriteToSavedPhotosAlbum(PhotoImage, nil, nil, nil);
            self.LastPhotoImage.image = [CustomCameraPhoto imageWithImage:PhotoImage scaledToFillSize:self.LastPhotoImage.frame.size];
            self.LastPhotoImage.layer.borderWidth = 1.0f;
        }
    }];
}

// 后置相机
+ (AVCaptureDevice *)backCamera {
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionBack) return device;
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

// 前置相机
+ (AVCaptureDevice *)frontCamera {
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionFront) return device;
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image croppedToSize:(CGSize)size
{
    return image;
    CGSize centerSquareSize;
    double oriImgWid = CGImageGetWidth(image.CGImage);
    double oriImgHgt = CGImageGetHeight(image.CGImage);
    NSLog(@"oriImgWid==[%.1f], oriImgHgt==[%.1f]", oriImgWid, oriImgHgt);
    //if(oriImgHgt <= oriImgWid) {
    //    centerSquareSize.width = oriImgHgt;
    //    centerSquareSize.height = oriImgHgt;
    //}else {
        centerSquareSize.width = oriImgWid;
        centerSquareSize.height = oriImgWid;
    //}
    
    NSLog(@"frame size.w==[%.1f], size.h==[%.1f]", size.width, size.height);
    
    double x = (oriImgWid - centerSquareSize.width) / 2.0;
    double y = (oriImgHgt - centerSquareSize.height) / 2.0;
    NSLog(@"x==[%.1f], x==[%.1f]", x, y);
    
    CGRect cropRect = CGRectMake(x, y, centerSquareSize.height, centerSquareSize.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    
    return cropped;
//    return newImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
