//
//  ImageViewController.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/30.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController


-(id) initWithFrame:(CGRect)frame withImage:(UIImage*)image
{
    self = [super init];
    self.imageView = [[UIImageView alloc] init];
    self.view.frame = frame;
    self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageView];
    return self;
}

-(id) initWithFrame:(CGRect)frame wittPHAsset:(PHAsset*)pHAsset
{
    self = [super init];
    self.imageView = [[UIImageView alloc] init];
    self.view.frame = frame;
    self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = NO;
        [[PHImageManager defaultManager] requestImageForAsset:pHAsset
                                                   targetSize:CGSizeMake(self.imageView.frame.size.width * [UIScreen mainScreen].scale
                                                                         , self.imageView.frame.size.height * [UIScreen mainScreen].scale)
                                                  contentMode:PHImageContentModeAspectFit
                                                      options:option
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    self.imageView.image  = result;
                                                }];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageView];
    return self;}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
