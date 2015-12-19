//
//  LifeBandSettingTable.h
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/5.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LifeBandSettingTable : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *CbtVibrateLabel;
@property (weak, nonatomic) IBOutlet UISwitch *CbtVibrateSwitch;
@property (weak, nonatomic) IBOutlet UILabel *LostVibrateLabel;
@property (weak, nonatomic) IBOutlet UISwitch *LostVibrateSwitch;

@property (weak, nonatomic) IBOutlet UILabel *ReconnectLabel;
@property (weak, nonatomic) IBOutlet UISwitch *ReconnectSwitch;

@property (weak, nonatomic) IBOutlet UILabel *DisconnectAlertSoundLabel;
@property (weak, nonatomic) IBOutlet UISwitch *DisconnectAlertSoundSwitch;
@property (weak, nonatomic) IBOutlet UILabel *DisconnectAlertVibrateLabel;
@property (weak, nonatomic) IBOutlet UISwitch *DisconnectAlertVibrateSwitch;
@property (weak, nonatomic) IBOutlet UILabel *RequstDataPerSec;
@property (weak, nonatomic) IBOutlet UISlider *RequsetDataPerSecSlider;
@property (weak, nonatomic) IBOutlet UINavigationItem *NavigationItemBar;

@end
