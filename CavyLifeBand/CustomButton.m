//
//  CustomButton.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/7.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import "CustomButton.h"
#import "CustomBandCell.h"
@interface CustomButton ()
@property (strong) UIColor *hBackgroundColor;
@property (strong) UIColor *unhBackgroundColor;
@property (strong) UIColor *hTextColor;
@property (strong) UIColor *unhTextColor;
@end

@implementation CustomButton

-(void)getTitleLabelColor
{
    self.hTextColor = [UIColor alloc];
    self.unhTextColor = [UIColor alloc];
    switch (self.ButtonTag) {
        case 0:
            self.hTextColor = [CustomBandCell colorFromHexString:@"#FFFFFF"];
            self.unhTextColor = [CustomBandCell colorFromHexString:@"#3e76db"];
            break;
        case 1:
            self.hTextColor = [CustomBandCell colorFromHexString:@"#FFFFFF"];
            self.unhTextColor = [CustomBandCell colorFromHexString:@"#FFFFFF"];
            break;
        case 2:
            self.hTextColor = [CustomBandCell colorFromHexString:@"#FFFFFF"];
            self.unhTextColor = [CustomBandCell colorFromHexString:@"#FFFFFF"];
            break;
            
        default:
            self.hTextColor = [CustomBandCell colorFromHexString:@"#FFFFFF"];
            self.unhTextColor = [CustomBandCell colorFromHexString:@"#3e76db"];
            break;
    }
}

-(void)getBackgroundColor
{
    self.hBackgroundColor = [UIColor alloc];
    self.unhBackgroundColor = [UIColor alloc];
    switch (self.ButtonTag) {
        case 0:
            self.hBackgroundColor = [CustomBandCell colorFromHexString:@"#3e76db"];
            self.unhBackgroundColor = [CustomBandCell colorFromHexString:@"#FFFFFF"];
            break;
        case 1:
            self.hBackgroundColor = [CustomBandCell colorFromHexString:@"#3e76db"];
            self.unhBackgroundColor = [CustomBandCell colorFromHexString:@"#568ae8"];
            break;
        case 2:
            self.hBackgroundColor = [CustomBandCell colorFromHexString:@"#FFFFFF"];
            self.unhBackgroundColor = [CustomBandCell colorFromHexString:@"#FFFFFF"];
            break;
            
        default:
            self.hBackgroundColor = [CustomBandCell colorFromHexString:@"#FFFFFF"];
            self.unhBackgroundColor = [CustomBandCell colorFromHexString:@"#3e76db"];
            break;
    }
}

-(void) setHighlighted:(BOOL)highlighted {
    if(self.unhBackgroundColor == nil && self.hBackgroundColor == nil)
    {
        [self getBackgroundColor];
    }
    if(self.hTextColor == nil && self.unhTextColor == nil)
    {
        [self getTitleLabelColor];
    }
    
    if(highlighted) {
        self.backgroundColor = self.hBackgroundColor;
        self.titleLabel.textColor = self.hTextColor;
    } else {
        self.backgroundColor = self.unhBackgroundColor;
        self.titleLabel.textColor = self.unhTextColor;
    }
    [super setHighlighted:highlighted];
}
/*
-(void) setSelected:(BOOL)selected {
    
    if(selected) {
        self.backgroundColor = [CustomBandCell colorFromHexString:@"#FFFFFF"];
        self.titleLabel.textColor = [CustomBandCell colorFromHexString:@"#FFFFFF"];
    } else {
        self.backgroundColor = [CustomBandCell colorFromHexString:@"#FFFFFF"];
        self.titleLabel.textColor = [CustomBandCell colorFromHexString:@"#3e76db"];
    }
    [super setSelected:selected];
}
*/
@end
