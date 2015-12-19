//
//  CustomCameraView.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/12.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import "CustomCameraView.h"

@implementation CustomCameraView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //clear the background color of the overlay
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        //load an image to show in the overlay
        
        //UIImage *overlayImgae = [UIImage imageNamed:@"overlay.png"];
        //UIImageView *overlayImageView = [[UIImageView alloc]
        //                                 initWithImage:overlayImage];
        //overlayImageView.frame = CGRectMake(115, -20, 815, 815);
        //[self addSubview:overlayImageView];
        
    }
    
    return self;
}


@end
