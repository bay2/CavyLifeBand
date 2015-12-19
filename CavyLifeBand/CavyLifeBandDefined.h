//
//  CavyLifeBandDefined.h
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/6.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#ifndef CavyLifeBandDefined_h
#define CavyLifeBandDefined_h
#import <Foundation/Foundation.h>

#define IS_OS_8_OR_LATER ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 )
#define IS_UI_ALERT_CONTROLLER_CAN_NOT_USE ( NSClassFromString(@"UIAlertController") == nil )

#define CAVYLIFEBAND_lastConnectBand @"CavyLifeBand_lastConnectBand"
#define CAVYLIFEBAND_DbName @"PairedPeripheral"
#define CTCALLCENTER_IncomingPhoneCall @"IncomingPhoneCall"
//------------------------------------Localization part---------------------------------
//main page part
extern const NSString *Localization_CavyBand               ;
extern const NSString *Localization_SearchingDevices       ;
extern const NSString *Localization_ClickToSearchDevices   ;
extern const NSString *Localization_Connect                ;
extern const NSString *Localization_Disconnect             ;

//setting page part
extern const NSString *Localization_Settings                   ;
extern const NSString *Localization_CallReminder               ;
extern const NSString *Localization_CallReminderBandVibrates   ;
extern const NSString *Localization_Reconnect                  ;
extern const NSString *Localization_AutoReconnect              ;
extern const NSString *Localization_PhoneLossWarning           ;
extern const NSString *Localization_PhoneLossBandVibrates      ;
extern const NSString *Localization_BandLossWarning            ;
extern const NSString *Localization_BandLossPhoneAlarms        ;
extern const NSString *Localization_BandLossPhoneVibrates      ;

//camera page part
extern const NSString *Localization_CameraFlashLightOn     ;
extern const NSString *Localization_CameraFlashLightOff    ;
extern const NSString *Localization_CameraFlashLightAuto   ;
extern const NSString *Localization_Photo;

//计步
extern const NSString *Localization_Walking;
extern const NSString *Localization_TodayCount;
extern const NSString *Localization_SevenDay;
extern const NSString *Locatization_EveryDay;
extern const NSString *Locatization_Distance;
extern const NSString *Locatization_ActiveTime;

//dialog message part
extern const NSString *Localization_BandConnecting            ;
extern const NSString *Localization_BandDisconnected          ;
extern const NSString *Localization_CheckBandStatusMessage    ;
extern const NSString *Localization_Dismiss                   ;
extern const NSString *Localization_ConnectionFailed          ;
extern const NSString *Localization_ConnectionFailedMessage   ;
extern const NSString *Localization_Confirm                   ;
extern const NSString *Localization_BluetoothOff              ;
//-------------------------------------------------------------------------------------

//-------------------------------------NSNotification Key part--------------------------
extern const NSString *NotificationKey_FoundNewBand;
extern const NSString *NotificationKey_CancelConnecting;
//--------------------------------------------------------------------------------------

NSString* MyLocalizeString(const NSString *key);
#endif /* CavyLifeBandDefined_h */
