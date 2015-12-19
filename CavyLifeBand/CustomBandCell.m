//
//  CustomBandCell.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/1.
//  Copyright (c) 2015年 blacksmith. All rights reserved.
//

#import "CustomBandCell.h"
#include "CavyLifeBandDefined.h"

@implementation CustomBandCell

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(void)InitButtonStyle
{
    self.calibrateButton.layer.borderWidth = 1.0f;
    self.calibrateButton.layer.borderColor = [CustomBandCell colorFromHexString:@"#568ae8"].CGColor;
    self.calibrateButton.layer.cornerRadius = 5.0f;
    self.calibrateButton.ButtonTag = 1;
    
    self.connectButton.layer.borderWidth = 1.0f;
    self.connectButton.layer.borderColor = [CustomBandCell colorFromHexString:@"#3e76db"].CGColor;
    self.connectButton.layer.cornerRadius = 5.0f;
    self.connectButton.ButtonTag = 0;
    
    self.disconnectButton.layer.borderWidth = 1.0f;
    self.disconnectButton.layer.borderColor = [CustomBandCell colorFromHexString:@"#568ae8"].CGColor;
    self.disconnectButton.layer.cornerRadius = 5.0f;
    self.disconnectButton.ButtonTag = 1;
}


@end
