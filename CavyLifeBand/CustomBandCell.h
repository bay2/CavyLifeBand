//
//  CustomBandCell.h
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/1.
//  Copyright (c) 2015年 blacksmith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
@interface CustomBandCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *peripheralName;
@property (weak, nonatomic) IBOutlet UILabel *peripheralUUID;
@property (weak, nonatomic) IBOutlet CustomButton *calibrateButton;
@property (weak, nonatomic) IBOutlet CustomButton *connectButton;
@property (weak, nonatomic) IBOutlet CustomButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UIView *separatorBotomLine;
@property (weak, nonatomic) IBOutlet UIView *separatorTopLine;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
-(void)InitButtonStyle;
@end
