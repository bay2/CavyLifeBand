//
//  PressHighlightButton.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/22.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import "PressHighlightButton.h"
#import "CustomBandCell.h"
@implementation PressHighlightButton

-(void)awakeFromNib
{
//    self.layer.masksToBounds = YES;
//    self.layer.cornerRadius = self.frame.size.width / 2;
}

-(void)setHighlighted:(BOOL)highlighted
{
    if(highlighted) {
        self.backgroundColor = [CustomBandCell colorFromHexString:@"#f5f5f5"];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    [super setHighlighted:highlighted];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
