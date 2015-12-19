//
//  PhotoView.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/6.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import "PhotoView.h"
#import "CavyLifeBandDefined.h"
#import "ImageScrollView.h"
#import "ImageViewController.h"
#import "AppDelegate.h"
@interface PhotoView()
{
    NSUInteger photoNumber;
    CGRect     photoFrameSize;
}
@property (nonatomic, strong) UIImage *image;
@property (strong, nonatomic) PHFetchOptions *fetchOptions;
@property (strong, nonatomic) PHFetchResult *phFetchResult;
@end

@implementation PhotoView

-(void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *leftBarItem = self.navigationTitle.leftBarButtonItem;
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer setWidth:-6];
    //    UIBarButtonItem *rightBarItem = self.navigationItem.rightBarButtonItem;
    self.navigationTitle.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,leftBarItem,nil];
    self.navigationTitle.title = MyLocalizeString(Localization_Settings);
    
    self.fetchOptions = [[PHFetchOptions alloc] init];
    self.fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    self.phFetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:self.fetchOptions];
    photoNumber = [self.phFetchResult count] - 1;
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.dataSource = self;
    
    
    [[self.pageController view] setFrame:photoFrameSize];
    ImageViewController * imageViewController = [self newImageViewControllerWithFrame:photoFrameSize withPHAsset:(PHAsset*)[self.phFetchResult objectAtIndex:photoNumber] withIndex:photoNumber];
    //ImageViewController * imageViewController = [self getImageViewControllerWithFrame:self.ImageView.frame withImage:self.image withIndex:photoNumber];
    
    [self showPageIndexLabel:photoNumber];
    [self.pageController setViewControllers:@[imageViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}

-(ImageViewController*)getImageViewControllerWithFrame:(CGRect)frame withImage:(UIImage*)image withIndex:(NSUInteger)index
{
    ImageViewController *imageViewController = [[ImageViewController alloc] initWithFrame:frame withImage:image];
    imageViewController.index = index;
    return imageViewController;
}

-(ImageViewController*)newImageViewControllerWithFrame:(CGRect)frame withPHAsset:(PHAsset*)pHAsset withIndex:(NSUInteger)index
{
    ImageViewController *imageViewController = [[ImageViewController alloc] initWithFrame:frame wittPHAsset:pHAsset];
    imageViewController.index = index;
    //[self showPageIndexLabel:index];
    return imageViewController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationTitle.title = MyLocalizeString(Localization_Photo);
    
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [AppDelegate setDisplayViewController:(UIViewController*)self];
}

- (id)initWithImage:(UIImage *)image frameSize:(CGRect)frame
{
    self.image = image;
    photoFrameSize = frame;
    return self;
}

- (IBAction)returnPrePage:(id)sender {
    self.pageController = nil;
    self.phFetchResult = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showPageIndexLabel:(NSUInteger)index
{
    self.CountLabel.text = [NSString stringWithFormat:@"%d/%d", (int)index+1, (int)self.phFetchResult.count];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(ImageViewController *)vc
{
    NSUInteger index = vc.index;
    //NSLog(@"before index = %ld", index );
    [self showPageIndexLabel:index];
    //return [PhotoViewController photoViewControllerForPageIndex:(index - 1)];
    if(index == 0)
        return nil;
    index--;
    ImageViewController * view = [self newImageViewControllerWithFrame:self.ImageView.frame withPHAsset:(PHAsset*)[self.phFetchResult objectAtIndex:index] withIndex:index];
    return  view;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(ImageViewController *)vc
{
    NSUInteger index = vc.index;
    [self showPageIndexLabel:index];
    //return [PhotoViewController photoViewControllerForPageIndex:(index + 1)];
    //NSLog(@"after index = %ld", index );
    if(index == [self.phFetchResult count] - 1)
    {
        return nil;
    }
    index++;
    ImageViewController * view = [self newImageViewControllerWithFrame:self.ImageView.frame withPHAsset:(PHAsset*)[self.phFetchResult objectAtIndex:index] withIndex:index];
    return  view;
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
@end
