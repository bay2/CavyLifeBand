//
//  CavyLifeBandDefined.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/14.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import "CavyLifeBandDefined.h"

NSString* MyLocalizeString(const NSString *key)
{
    return  [NSString stringWithFormat:NSLocalizedString((NSString*)key, nil)];
}

NSString const *Localization_CavyBand               = @"CavyBand";
NSString const *Localization_SearchingDevices       = @"Searching Devices…";
NSString const *Localization_ClickToSearchDevices   = @"Click to Search Devices";
NSString const *Localization_Connect                = @"Connect";
NSString const *Localization_Disconnect             = @"Disconnect";

//setting page part
NSString const *Localization_Settings                   = @"Settings";
NSString const *Localization_CallReminder               = @"Call Reminder";
NSString const *Localization_CallReminderBandVibrates   = @"CallReminder Band Vibrates";
NSString const *Localization_Reconnect                  = @"Reconnect";
NSString const *Localization_AutoReconnect              = @"Auto Reconnect";
NSString const *Localization_PhoneLossWarning           = @"Phone Loss Warning";
NSString const *Localization_PhoneLossBandVibrates      = @"PhoneLoss Band Vibrates";
NSString const *Localization_BandLossWarning            = @"Band Loss Warning";
NSString const *Localization_BandLossPhoneAlarms        = @"BandLoss Phone Alarms";
NSString const *Localization_BandLossPhoneVibrates      = @"BandLoss Phone Vibrates";

//camera page part
NSString const *Localization_CameraFlashLightOn     = @"FlashLight On";
NSString const *Localization_CameraFlashLightOff    = @"FlashLight Off";
NSString const *Localization_CameraFlashLightAuto   = @"FlashLight Auto";
NSString const *Localization_Photo   = @"Photo";

//计步页面
NSString const *Localization_Walking = @"Walking";
NSString const *Localization_TodayCount = @"Todoy Count";
NSString const *Localization_SevenDay   = @"Seven Day";
NSString const *Locatization_EveryDay   = @"Every Day Count Avg";
NSString const *Locatization_Distance   = @"Distance";
NSString const *Locatization_ActiveTime = @"Active Time";


//dialog message part
NSString const *Localization_BandConnecting             = @"Connecting…";
NSString const *Localization_BandDisconnected           = @"Band Disconnected";
NSString const *Localization_CheckBandStatusMessage     = @"Check the band location and battery status.";
NSString const *Localization_Dismiss                    = @"Dismiss";
NSString const *Localization_ConnectionFailed           = @"Connection Failed";
NSString const *Localization_ConnectionFailedMessage    = @"Connection time out, please check band power status.";
NSString const *Localization_Confirm                    = @"ConfirmOK";
NSString const *Localization_BluetoothOff               = @"BluetoothOffMessage";

NSString const *NotificationKey_FoundNewBand  = @"Notification_FoundNewBand";
NSString const *NotificationKey_CancelConnecting  = @"Notification_CancelConnecting";