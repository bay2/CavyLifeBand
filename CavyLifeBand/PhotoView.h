//
//  PhotoView.h
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/6.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@interface PhotoView : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIScrollViewDelegate, UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageController;

@property (weak, nonatomic) IBOutlet UIImageView *ImageView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollPhotoView;
@property (weak, nonatomic) IBOutlet UIButton *BackButton;
@property (weak, nonatomic) IBOutlet UILabel *CountLabel;

- (id)initWithImage:(UIImage *)image frameSize:(CGRect)frame;
@end
