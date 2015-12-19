//
//  LifeBandBLE.h
//  CavyLifeBand
//
//  Created by blacksmith on 2015/9/25.
//  Copyright (c) 2015年 blacksmith. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#ifndef CavyLifeBand_LifeBandBLE_h
#define CavyLifeBand_LifeBandBLE_h
#define getRootViewController [[[UIApplication sharedApplication].delegate window] rootViewController]

@interface LifeBandBLE : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate,CLLocationManagerDelegate, UIAlertViewDelegate>
@property (weak) UITableView *parentTableView;
@property bool isCalibreating;
@property bool canDoCalibreate;
@property bool IsScaning;
-(bool) StartScaning;
-(void) StopScaning;
-(void) Connect:(CBPeripheral*) connectPeripheral;
-(void) Disconnect;
-(void) Reconnect;
-(void) doCalibrate;
-(void)loadBatteryData;
-(void)loadRSSIData;
-(void)disconnectVibrateSwitch:(NSNotification*)notification;
-(NSMutableArray*) GetScanPeripheralList;
-(void)SetReconnectEnable:(bool)result;
//-(bool) Reconnect;
@end


#endif
