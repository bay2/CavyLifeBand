//
//  ImageViewController.h
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/30.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@interface ImageViewController : UIViewController

@property (strong) UIImageView *imageView;
@property  NSUInteger index;
-(id) initWithFrame:(CGRect)frame withImage:(UIImage*)image;
-(id) initWithFrame:(CGRect)frame wittPHAsset:(PHAsset*)pHAsset;

@end
