//
//  LifeBandSettingTable.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/5.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import "LifeBandSettingTable.h"
#import "CavyLifeBandDefined.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
@interface LifeBandSettingTable ()
{
    int soundId;
}
@end

@implementation LifeBandSettingTable

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.RequsetDataPerSecSlider.minimumValue = 1.0f;
    self.RequsetDataPerSecSlider.maximumValue = 5.0f;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.CbtVibrateSwitch.on             = [userDefaults boolForKey:@"setting_CbtVibrateSwitch"];
    self.LostVibrateSwitch.on            = [userDefaults boolForKey:@"setting_LostVibrateSwitch"];
    self.ReconnectSwitch.on              = [userDefaults boolForKey:@"setting_ReconnectSwitch"];
    self.DisconnectAlertSoundSwitch.on   = [userDefaults boolForKey:@"setting_DisconnectAlertSoundSwitch"];
    self.DisconnectAlertVibrateSwitch.on = [userDefaults boolForKey:@"setting_DisconnectAlertVibrateSwitch"];
    self.RequsetDataPerSecSlider.value = [userDefaults floatForKey:@"setting_RequestDataPerSec"];
    self.RequstDataPerSec.text = [NSString stringWithFormat:@"%d", (int)[userDefaults floatForKey:@"setting_RequestDataPerSec"] ];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0,20, 0, 20);
    soundId = 1000;
    
    [self createNavigationItemBar];
    

}

- (void) createNavigationItemBar {
    
    UIBarButtonItem *leftBarItem = self.NavigationItemBar.leftBarButtonItem;
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer setWidth:-6];
    
    UIBarButtonItem *negativeSpacer10 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer10 setWidth:10];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [titleLab setText:MyLocalizeString(Localization_Settings)];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setTextAlignment:NSTextAlignmentLeft];
    UIBarButtonItem *titleBarItem = [[UIBarButtonItem alloc] initWithCustomView:titleLab];
    
    self.NavigationItemBar.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, leftBarItem, negativeSpacer10, titleBarItem, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [AppDelegate setDisplayViewController:(UIViewController*)self];
    //[[[[UIApplication sharedApplication] delegate] window] setRootViewController:self];
}

#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}*/

- (IBAction)returnPrePage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = MyLocalizeString(Localization_CallReminder);
            break;
        case 1:
            sectionName = MyLocalizeString(Localization_Reconnect);
            break;
        case 2:
            sectionName = MyLocalizeString(Localization_PhoneLossWarning);
            break;
        case 3:
            sectionName = MyLocalizeString(Localization_BandLossWarning);
            break;
        default:
            sectionName = @"Testing setting";
            break;
    }
    return sectionName;
}

- (IBAction)CbtVibrateSwitchValueChange:(UISwitch *)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:[sender isOn] forKey:@"setting_CbtVibrateSwitch"];
    [userDefaults synchronize];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"VIBRATE CALL" object:nil];
}

- (IBAction)LostVibrateSwitchValueChanged:(UISwitch *)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:[sender isOn] forKey:@"setting_LostVibrateSwitch"];
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LostVibrateSwitch_valueChange" object:nil];
}


- (IBAction)ReconnectSwitchValueChange:(UISwitch *)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:[sender isOn] forKey:@"setting_ReconnectSwitch"];
    [userDefaults synchronize];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"VIBRATE CALL" object:nil];
}

- (IBAction)DisconnectAlertSoundSwitchValueChanged:(UISwitch *)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:[sender isOn] forKey:@"setting_DisconnectAlertSoundSwitch"];
    [userDefaults synchronize];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"VIBRATE CALL" object:nil];
}

- (IBAction)DisconnectAlertVibrateSwitchValueChanged:(UISwitch *)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:[sender isOn] forKey:@"setting_DisconnectAlertVibrateSwitch"];
    [userDefaults synchronize];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"VIBRATE CALL" object:nil];
}
- (IBAction)RequestDataPerSecSliderValueChange:(UISlider*)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:sender.value  forKey:@"setting_RequestDataPerSec"];
    [userDefaults synchronize];
    
    self.RequstDataPerSec.text = [NSString stringWithFormat:@"%d",(int)sender.value];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestDatePerSec Change" object:nil];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
