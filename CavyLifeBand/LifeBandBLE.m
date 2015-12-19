//
//  LifeBandBLE.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/9/25.
//  Copyright (c) 2015年 blacksmith. All rights reserved.
//
#include "LifeBandBLE.h"
#include "CavyLifeBandDefined.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "OnlineLog.h"
const int SystemStatusDuration = 2;
//------------------------------
//  9xBLE return Value
//------------------------------
const int16_t PACKET_DATA_BNO055 = 0xA1;
const int16_t PACKET_DATA_BATTERY =0xB1;
const int16_t PACKET_DATA_SYSTEM =0xC1;
const int16_t PACKET_DATA_BUTTON =0xD1;

//------------------------------
//  9xBLE Mode Value
//------------------------------
const int LOW_POWER_MODE = 1;
const int LOW_POWER_MODE_SLEEP = 0;// default
const int LOW_POWER_MODE_IDLE = 1;
const int LOW_POWER_MODE_STANDBY = 2;

const int SNIFF_MODE = 2;
const int SNIFF_MODE_NO_CHANGE = 0;// default
const int SNIFF_MODE_ACC_ON = 1;
const int SNIFF_MODE_MAG_ON = 2;
const int SNIFF_MODE_ACC_MAG_ON = 3;

const int NORMAL_MODE = 3;
const int NORMAL_MODE_6x_COMPASS = 1;
const int NORMAL_MODE_6x_M4G = 2;
const int NORMAL_MODE_9x_NDOF_FMC_OFF = 3;
const int NORMAL_MODE_9x_NDOF = 4;// default

const int NORMAL_SAVE_POWER_MODE = 4;
const int NORMAL_SAVE_POWER_MODE_6x_COMPASS = 1;
const int NORMAL_SAVE_POWER_MODE_6x_M4G = 2;
const int NORMAL_SAVE_POWER_MODE_9x_NDOF_FMC_OFF = 3;
const int NORMAL_SAVE_POWER_MODE_9x_NDOF = 4;// default

//------------------------------
// BLE Socket status
//------------------------------
const int SOCKET_DISCONNECTED = 0;
const int SOCKET_CONNECTING = 1;
const int SOCKET_CONNECTED = 2;
const int SOCKET_UNITY_CONNECT = 3;

//------------------------------
// ControlLED constants
//------------------------------
const int RED_LED_ID = 0;
const int GREEN_LED_ID = 1;
const int BLUE_LED_ID = 2;
const int LED_OFF = 0;
const int LED_ON = 1;
const int LED_FLASH = 2;
const int MIN_LED_POWER = 1;
const int MAX_LED_POWER = 100;

//------------------------------
// DoVibrate constants
//------------------------------
const int VIBRATE_OFF = 0;
const int VIBRATE_ONCE = 1;
const int VIBRATE_TWICE = 2;
const int MIN_VIBRATE_POWER = 1;
const int MAX_VIBRATE_POWER = 100;

//------------------------------
// API return values
//------------------------------
const int SUCCESS = 0;
const int FAIL = 1;
const int ERR_INVALID_PARAMETERS = -1;
const int ERR_SEND_COMMAND_EXCEPTION = -2;
const int ERR_STILL_CONNECTING = -3;
const int ERR_NOT_CONNECTED = -4;
const int ERR_BLUETOOTH_DEVICE_ERROR = -5;

//------------------------------
// OnlineFailErrorCode
//------------------------------
const int ONLINE_ERROR_CODE_OPEN_APP = 0;
const int ONLINE_ERROR_CODE_CONNECT_SUCCESS = 1;
const int ONLINE_ERROR_CODE_CONNECT_FAIL = 2;

@interface LifeBandBLE ()
{
    CLLocationManager * _locationManager;
    CBCentralManager * _centralManager;
    CBPeripheral * _connectPeripheral;
    CBCharacteristic *_sendCharacteristic;
    CBCharacteristic *_receiveCharacteristic;
    NSMutableArray * _peripheralDict;
    NSTimer        * _calibreateTimer;
    CBPeripheral   * _calibreatingPeripheral;
    UIAlertView    * mUIAlertView;
    
    SystemSoundID myAlertSound;
    SystemSoundID DisconnectSoundID;
    bool Calibrated;
    bool IsDisconnectRecent;
    bool CanRequestBatteryData;
    int CONNECT_STATUS;
    int InquireSystemCount;
    int RSSIData;
    BOOL isFirsttime;
    UIAlertController *DisconnectUIAlert;
    UIAlertController *BluetoothOffUIAlert;
    NSDate *disconnectTime;
}
@property bool ReconnectEnable;
@property NSMutableArray *WriteToPeripheralQueue;
@property NSTimeInterval queueInterval;
@property NSTimer *after20SecSniffMode;
@property NSTimer *alertForDisconnectedTimer;
@property (nonatomic, strong) NSMutableData *responseData;
@end

@implementation LifeBandBLE
NSString *const serviceUUID = @"14839AC4-7D7E-415C-9A42-167340CF2339";
NSString *const sendCommandCharacteristicUUID = @"8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3";
NSString *const getResultCharacteristicUUID = @"0734594A-A8E7-4B1A-A6B1-CD5243059A57";

/**
 *  Initialize
 *  Init on app start
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(id)init
{
    NSLog(@"LifeBandBLE init!!");
    isFirsttime = YES;
    _IsScaning = false;
    self.WriteToPeripheralQueue = [[NSMutableArray alloc] init];
    _peripheralDict = [[NSMutableArray alloc] init];
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
    CONNECT_STATUS = SOCKET_DISCONNECTED;
    _connectPeripheral = nil;
    InquireSystemCount = 0;
    DisconnectUIAlert = nil;
    RSSIData = 0;
    disconnectTime = nil;
    BluetoothOffUIAlert = nil;
    CanRequestBatteryData = NO;
    self.isCalibreating = NO;
    self.canDoCalibreate = NO;
    self.ReconnectEnable = NO;
    self.alertForDisconnectedTimer = nil;
    NSString *soundFile = [[NSBundle mainBundle]pathForResource:@"alert" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile], &DisconnectSoundID);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IncomingCallVibrate:)
                                                 name:CTCALLCENTER_IncomingPhoneCall object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disconnectVibrateSwitch:)
                                                 name:@"LostVibrateSwitch_valueChange" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterForegrounf:)
                                                 name:@"applicationDidBecomeActive" object:nil];
    self.queueInterval =1.0f;
    [self WriteToBand:nil];
    
    NSError* error;
    [[AVAudioSession sharedInstance]
     setCategory:AVAudioSessionCategoryPlayAndRecord
     error:&error];
    if (error == nil) {
        NSURL *url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/alarm.caf"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &myAlertSound);
        
        //AudioServicesPlaySystemSound(myAlertSound);
    }
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [_locationManager requestWhenInUseAuthorization];
    return self;
}

- (void)dealloc
{
    // be careful in this method! can't access properties! almost gone from heap
    // unregister notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)didEnterForegrounf:(NSNotification*)notification
{
    if(_centralManager)
    {
        [self centralManagerDidUpdateState:_centralManager];
        if(isFirsttime)
        {
            //only open app first time
            [self sendFailureOnlineLog:ONLINE_ERROR_CODE_OPEN_APP msg:@"OPEN_IOS_LIFEAPP"];
            isFirsttime = NO;
            return;
        }
        _IsScaning = false;
        [_centralManager stopScan];
    }
}

-(void)sendFailureOnlineLog:(int)errorCode msg:(NSString*)errorMsg
{
    [_locationManager startUpdatingLocation];
    float latitude = _locationManager.location.coordinate.latitude;
    float longitude = _locationManager.location.coordinate.longitude;
    NSString *LBS = [NSString stringWithFormat:@"%d,%d", (int)latitude, (int)longitude];
    [_locationManager stopUpdatingLocation];
    NSString *bandIdentifier = @" ";
    if( errorCode != 0 )
    {
        bandIdentifier = _connectPeripheral.identifier.UUIDString;
    }
    NSString *log = onlineFailureLog(_connectPeripheral.identifier.UUIDString, [NSString stringWithFormat:@"%d", errorCode], errorMsg, LBS);
    NSLog(@"sendFailureOnlineLog URL : %@", log);

    NSURL *url = [NSURL URLWithString:log];

    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
  
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
             NSLog(@"Code: %@, Msg: %@", (NSString*)[results objectForKey:@"code"], [results objectForKey:@"msg"]);
         }
     }];
}

#pragma mark - NSURLConnection delegate Part
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    //NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    //NSLog(@"%@", self.responseData);
}

#pragma mark - BLE CentralManager Part
/**
 *  CentalManager didUpdateStates delegate
 *  the didUpdateStates delegate
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if([self isBLECapableHardware:central.state]){
        if(BluetoothOffUIAlert != nil)
        {
            NSLog(@"BlueOFF Alert");
            if(_connectPeripheral)
            {
                NSLog(@"Connected Band: %@", _connectPeripheral);
                [_centralManager cancelPeripheralConnection:_connectPeripheral];
                NSLog(@"Disconnect Connected Peripheral!!");
                CONNECT_STATUS = SOCKET_DISCONNECTED;
                [self.parentTableView reloadData];
            }
            [BluetoothOffUIAlert dismissViewControllerAnimated:YES completion:nil];
            BluetoothOffUIAlert = nil;
        }
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        _IsScaning = YES;
    }
}
/**
 *  IsBLECapableHardware
 *  check BLE environment
 *  edit by Jack in BlackSmith on 2015/10/16
 */
- (bool) isBLECapableHardware:(CBCentralManagerState)centralState
{
    NSString * state = nil;
    switch (centralState)
    {
        case CBCentralManagerStatePoweredOn:
            return true;
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            [self OpenBluetoothPower];
            return false;
        case CBCentralManagerStateUnknown:
            state=[NSString stringWithFormat:@"Device Error %d", (int)centralState];
            break;
        default:
            break;
    }
    NSLog(@"%@",state);
    return false;
}

/**
 *  CentalManager didDiscoverPeripheral delegate
 *  the didDiscoverPeripheral delegate, and check if it is Cavy Band
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if(peripheral.name == nil)
        return;
    if ([peripheral.name rangeOfString:@"Cavy"].location == NSNotFound)
    {
        [self PlayBandDebugLog:[NSString stringWithFormat:@"not band"]];
    }
    else
    {
        [self PlayBandDebugLog:[NSString stringWithFormat:@"is band %@", peripheral]];
        
        if( [_peripheralDict indexOfObject:peripheral] == NSNotFound )
        {
            [_peripheralDict addObject:peripheral];
            [[NSNotificationCenter defaultCenter] postNotificationName:(NSString*)NotificationKey_FoundNewBand object:nil userInfo:nil];
        }
    }
}

/**
 *  CentalManager didConnectPeripheral delegate
 *  the didConnectPeripheral delegate
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connect to %@", peripheral.name);
    self.ReconnectEnable = NO;
    CONNECT_STATUS = SOCKET_CONNECTED;
    _connectPeripheral = peripheral;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:_connectPeripheral.identifier.UUIDString forKey:CAVYLIFEBAND_lastConnectBand];
    [userDefaults synchronize];
    
    [peripheral discoverServices:nil];
}

/**
 *  CentalManager didFailToConnectPeripheral delegate
 *  the didFailToConnectPeripheral delegate
 *  edit by Jack in BlackSmith on 2015/10/16
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    CONNECT_STATUS = SOCKET_DISCONNECTED;
    if (error) {
        self.ReconnectEnable = YES;
        NSLog(@"Error in didFailToConnectPeripheral: %@", [error localizedDescription]);
    }
    NSLog(@"Fail connect to: %@", peripheral.name);
    
    //send the online log
    [self sendFailureOnlineLog:ONLINE_ERROR_CODE_CONNECT_FAIL msg:@"CONNECT_FAILED"];
}

/**
 *  CentalManager didDisconnectPeripheral delegate
 *  the didDisconnectPeripheral delegate, when disconnect peripheral cancel calibreation if isCalibreating is On and reload the UITableView of main page
 *  edit by Jack in BlackSmith on 2015/10/16
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    CONNECT_STATUS = SOCKET_DISCONNECTED;
    if (error) {
        self.ReconnectEnable = YES;
        NSLog(@"Error in didDisconnectPeripheral: %@", [error localizedDescription]);
    }
    IsDisconnectRecent = YES;
    disconnectTime = [NSDate date];
    CanRequestBatteryData = NO;
    NSLog(@"DisConnect to %@", peripheral.name);
    if(_isCalibreating)
    {
        _isCalibreating = NO;
    }
    [self.parentTableView reloadData];
    [self Reconnect];
        
}

#pragma mark - BLE Peripheral Part
/**
 *  CBPeripheral didDiscoverServices delegate
 *  the didDiscoverServices delegate, if found service then do discover for Characteristcs
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    [self PlayBandDebugLog:[NSString stringWithFormat:@"%@ didDiscoverServices",peripheral.name]];
    
    for (CBService *service in peripheral.services) {
        
        [self PlayBandDebugLog:[NSString stringWithFormat:@"Discovered service with UUID: %@", service.UUID]];
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:serviceUUID]])
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }
        
    }
}

/**
 *  CBPeripheral didDiscoverCharacteristicsForService delegate
 *  the didDiscoverCharacteristicsForService delegate, found the receive&send characteristics
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:serviceUUID]])
    {
        for (CBCharacteristic *achar in service.characteristics) {
            if ([achar.UUID isEqual:[CBUUID UUIDWithString:sendCommandCharacteristicUUID]])
            {
                [self PlayBandDebugLog:[NSString stringWithFormat:@"found SEND COMMAND characteristic"]];
                _sendCharacteristic = achar;
            } else if ([achar.UUID isEqual:[CBUUID UUIDWithString:getResultCharacteristicUUID]])
            {
                [self PlayBandDebugLog:[NSString stringWithFormat:@"found GET RESULT characteristic"]];
                _receiveCharacteristic = achar;
                
                [self RegisterNotifyForData];
            }
        }
        
        if(RSSIData < -80)
        {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            NSLog(@"手機震動！！！！！！");
        }
        self.canDoCalibreate = YES;
        [self ControlLED:2 Mode:2 Ratio:30 OnPeriod:100 OffPeriod:2000];
        [self WriteOutputStream:@"%led=0,0\n"];
        [self SelectOperation:3 Operation:4 DataPerSecond:50];
        if(self.after20SecSniffMode)
        {
            [self.after20SecSniffMode invalidate];
            self.after20SecSniffMode = nil;
        }
        self.after20SecSniffMode = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(SelectSniffOperationAfter20Sec:) userInfo: nil repeats: NO];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:_connectPeripheral forKey:CAVYLIFEBAND_lastConnectBand];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE CONNECT SUCCESS" object:nil userInfo:userInfo];
        
        //send the online log
        [self sendFailureOnlineLog:ONLINE_ERROR_CODE_CONNECT_SUCCESS msg:@"CONNECT_SUCCESS"];
    }
}

/**
 *  CBPeripheral didUpdateValueForCharacteristic delegate
 *  the didUpdateValueForCharacteristic delegate, receive data from peripheral(Band)
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //NSLog(@"didUpdateValueForCharacteristic");
    if (error)
    {
        NSLog(@"Error writing characteristic value: %@", [error localizedDescription]);
        self.ReconnectEnable = YES;
        return;
    }

    if( DisconnectUIAlert )
    {
        [self unregisteAlertDisconnected];
        [DisconnectUIAlert dismissViewControllerAnimated:YES completion:nil];
        DisconnectUIAlert = nil;
    }
    
    NSData *data=characteristic.value;
    int len = 17;
    
    if(data.length!=len){
        //F
        [self PlayBandDebugLog:[NSString stringWithFormat:@"data.length error: %d",(int)data.length]];
        return;
    }
    
    Byte byteData[len];
    [data getBytes:&byteData length:len];
    int16_t b0=byteData[0];
    if(b0!=36){
        //NSLog(@"data[0] != $");
        [self PlayBandDebugLog:[NSString stringWithFormat:@"data[0] error"]];
        return;
    }
    int16_t b1=byteData[1];
    
    if(b1==PACKET_DATA_BNO055){
        //[self onSensorData:byteData];
    }else if(b1==PACKET_DATA_SYSTEM){
        // NSLog(@"data[1]:%x",b1);
        [self onSystemData:byteData];
    }else if(b1==PACKET_DATA_BATTERY){
        // NSLog(@"data[1]:%x",b1);
        [self onBatteryData:byteData];
    }else if(b1==PACKET_DATA_BUTTON){
        //  NSLog(@"data[1]:%x",b1);
        [self onButtonData:byteData];
    }
    
    return;
}

/**
 *  CBPeripheral peripheralDidUpdateRSSI delegate
 *  the peripheralDidUpdateRSSI delegate, receive RSSI data from peripheral(Band)
 *  edit by Jack in BlackSmith on 2015/10/16
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error get RSSI: %@", [error localizedDescription]);
    }
    else
    {
        int rssi = [peripheral.RSSI intValue];
        NSData *data = [NSData dataWithBytes:&rssi length:sizeof(int)];
        RSSIData = rssi;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:data forKey:@"rssi_value"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE RSSI" object:nil userInfo:userInfo];
        
    }
}

#pragma mark - Controll Part
/**
 *  RegisterNotifyForData
 *  refister characteristic for peripheral update
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)RegisterNotifyForData
{
    if(_connectPeripheral && _receiveCharacteristic)
    {
        NSLog(@"RegisterNotifyForData");
        [_connectPeripheral setNotifyValue:YES forCharacteristic:_receiveCharacteristic];
    }
}
/**
 *  UnRegisterNotifyForData
 *  unrefister characteristic for peripheral update
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)UnRegisterNotifyForData
{
    if(_connectPeripheral && _receiveCharacteristic)
    {
        [_connectPeripheral setNotifyValue:NO forCharacteristic:_receiveCharacteristic];
    }
}
/**
 *  ControlLED
 *  change connected peripheral(Band) LED mode
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(int)ControlLED:(int)iParam1 Mode:(int)iParam2 Ratio:(int)iParam3 OnPeriod:(int)iParam4 OffPeriod:(int)iParam5 {
    if (iParam1 < RED_LED_ID || iParam1 > BLUE_LED_ID || iParam2 < LED_OFF || iParam2 > LED_FLASH || iParam4 < 0 || iParam5 < 0) {
        return ERR_INVALID_PARAMETERS;
    }
    
    if(iParam3 < MIN_LED_POWER){
        iParam3=MIN_LED_POWER;
    }else if(iParam3 > MAX_LED_POWER){
        iParam3=MAX_LED_POWER;
    }
    
    NSString *_CmdStr;
    if (iParam2 == LED_OFF) {
        _CmdStr = [NSString stringWithFormat:@"%%LED=%d,%d\n", iParam1, iParam2];
    } else if (iParam2 == LED_ON) {
        _CmdStr = [NSString stringWithFormat:@"%%LED=%d,%d,%d\n", iParam1, iParam2,iParam3];
    } else if (iParam2 == LED_FLASH) {
        _CmdStr = [NSString stringWithFormat:@"%%LED=%d,%d,%d,%d,%d\n", iParam1, iParam2, iParam3, iParam4, iParam5];
    }
    NSLog(@"LED %d, %d, %d", iParam1, iParam2, iParam3);
    return [self WriteOutputStream:_CmdStr];
}

/**
 *  WriteOutputStream
 *  add the cmd string data to WriteToPeripheralQueue
 *  edit by Jack in BlackSmith on 2015/10/16
 */
- (int)WriteOutputStream:(NSString*)value {
    NSData* data = [value dataUsingEncoding:NSUTF8StringEncoding];
    [self.WriteToPeripheralQueue addObject:data];
    return SUCCESS;
}

/**
 *  WriteToBand
 *  send CMD data to peripheral(Band) interval per queueInterval seconds
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)WriteToBand:(NSTimer *)time
{
    dispatch_async(dispatch_get_global_queue(0, 0),
                   ^{
                       while (1){
                           if(_connectPeripheral && _sendCharacteristic && _connectPeripheral.state==CBPeripheralStateConnected)
                           {
                               dispatch_async(dispatch_get_global_queue(0, 0),
                                ^{
                                    if( [self.WriteToPeripheralQueue count] == 0 )
                                        return;
                                    NSData *data = [self.WriteToPeripheralQueue firstObject];
                                    //NSLog(@"Queue left: %d", [self.WriteToPeripheralQueue count]);
                                    [_connectPeripheral writeValue:data forCharacteristic:_sendCharacteristic type:CBCharacteristicWriteWithoutResponse];
                                    [self.WriteToPeripheralQueue removeObject:data];
                                    //NSLog(@"Write to Band : %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                });
                           }
                           else
                           {
                               [self.WriteToPeripheralQueue removeAllObjects];
                           }
                           [NSThread sleepForTimeInterval:self.queueInterval];
                       }
                       
                   });
}

/**
 *  Reconnect
 *  when unnormal disconnect, try to connect to last connected peripheral(Band), and show alert(UIAlertView&Sound) to user
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)Reconnect
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if( !self.ReconnectEnable )
        return;
    NSLog(@"connect last connected device.");
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.2)
    {
        localNotification.alertTitle = MyLocalizeString(Localization_BandDisconnected);
        localNotification.alertBody = MyLocalizeString(Localization_CheckBandStatusMessage);
    }
    else
    {
        localNotification.alertBody = [NSString stringWithFormat:@"%@, %@",
                                       MyLocalizeString(Localization_BandDisconnected), MyLocalizeString(Localization_CheckBandStatusMessage)];
    }
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    
    [self registeAlertDisconnected];
    
    DisconnectUIAlert = [UIAlertController alertControllerWithTitle:MyLocalizeString(Localization_BandDisconnected) message:MyLocalizeString(Localization_CheckBandStatusMessage) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:MyLocalizeString(Localization_Dismiss)
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                               {
                                   [self unregisteAlertDisconnected];
                                   if( CONNECT_STATUS == SOCKET_CONNECTING )
                                   {
                                       if(_connectPeripheral)
                                       {
                                           [_centralManager cancelPeripheralConnection:_connectPeripheral];
                                       }
                                       [[NSNotificationCenter defaultCenter] postNotificationName:(NSString*)NotificationKey_CancelConnecting object:nil userInfo:nil];
                                       CONNECT_STATUS = SOCKET_DISCONNECTED;
                                       self.ReconnectEnable = NO;
                                   }
                                   return;
                               }];
    [DisconnectUIAlert addAction:okAction];
    
    //[getRootViewController presentViewController:DisconnectUIAlert animated:YES completion:nil];
    UIViewController *rootViewController = [AppDelegate getDisplayViewController];
    [rootViewController presentViewController:DisconnectUIAlert animated:YES completion:nil];
    
    if( ![userDefaults boolForKey:@"setting_ReconnectSwitch"] )
        return;
    if(_connectPeripheral != nil)
    {
        [self Connect:_connectPeripheral];
    }
    else
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *lastConnectedUUID  = [userDefaults stringForKey:CAVYLIFEBAND_lastConnectBand];
        if(lastConnectedUUID && [lastConnectedUUID length] > 1)
        {
            NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:lastConnectedUUID];
            NSArray *peripheralList = [_centralManager retrievePeripheralsWithIdentifiers:@[UUID]];
            if( [peripheralList count] > 0 )
            {
                id peripheral = [peripheralList firstObject];
                if( [peripheral isKindOfClass:[CBPeripheral class] ] )
                {
                    CBPeripheral * lastConnectPeripheral = (CBPeripheral*) peripheral;
                    [self Connect:lastConnectPeripheral];
                }
            }
        }
    }
    //self.ReconnectEnable = NO;
}

/**
 *  SelectOperation  param1: powerMode, param2: operationMode, param3: intervalSeconds(millisecond)
 *  change operaction mode of connected peripheral(Band)
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(int)SelectOperation:(int)iParam1 Operation:(int)iParam2 DataPerSecond:(int)iParam3 {
    [self PlayBandDebugLog:[NSString stringWithFormat:@"SelectOperation: %d,%d,%d",iParam1,iParam2,iParam3]];
    
    if (iParam1 < LOW_POWER_MODE || iParam1 > NORMAL_SAVE_POWER_MODE) {
        return ERR_INVALID_PARAMETERS;
    }
    
    if (iParam1 == NORMAL_SAVE_POWER_MODE) {
        if (iParam2 < NORMAL_SAVE_POWER_MODE_6x_COMPASS || iParam2 > NORMAL_SAVE_POWER_MODE_9x_NDOF) {
            return ERR_INVALID_PARAMETERS;
        } else {
        }
    } else if (iParam1 == NORMAL_MODE){
        if (iParam2 < NORMAL_MODE_6x_COMPASS	|| iParam2 > NORMAL_MODE_9x_NDOF) {
            return ERR_INVALID_PARAMETERS;
        }
    }else if (iParam1 == SNIFF_MODE) {
        if (iParam2 < SNIFF_MODE_NO_CHANGE || iParam2 > SNIFF_MODE_ACC_ON) {
            return ERR_INVALID_PARAMETERS;
        }
    } else if (iParam1 == LOW_POWER_MODE) {
        if (iParam2 < LOW_POWER_MODE_SLEEP || iParam2 > LOW_POWER_MODE_STANDBY) {
            return ERR_INVALID_PARAMETERS;
        } else {
        }
    }
    
    NSString *_CmdStr = [NSString stringWithFormat:@"%%OPR=%d,%d,%d\n",iParam1,iParam2,iParam3];
    NSLog(@"OPR MODE: %@", _CmdStr);
    return [self WriteOutputStream:_CmdStr];
}

/**
 *  SelectSniffOperationAfter20Sec
 *  after 20 seconds, change operationMode to sniff with operation 1
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)SelectSniffOperationAfter20Sec:(NSTimer*) timer
{
    if(self.isCalibreating)
        return;
    NSLog(@"Enter to Sniff mode, Opertion = 1");
    [self SelectOperation:2 Operation:1 DataPerSecond:500];
    self.canDoCalibreate = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE StartToRequestBatteryAndRSSI" object:nil userInfo:nil];
        //NSLog(@"aaasd");
        [self.parentTableView reloadData];
        [self.after20SecSniffMode invalidate];
        self.after20SecSniffMode = nil;
        CanRequestBatteryData = YES;
    });

}

/**
 *  DoVibrate
 *  send vibrate CMD to connected periphral(Band)
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(int)DoVibrate:(int)iParam1 Strong:(int)iParam2 OnPeriod:(int)iParam3 OffPeriod:(int)iParam4 {
    if (iParam1 < VIBRATE_OFF || iParam1 > VIBRATE_TWICE || iParam3 < 0 || iParam4 < 0) {
        return ERR_INVALID_PARAMETERS;
    }
    
    if(iParam2 < MIN_VIBRATE_POWER){
        iParam2=MIN_VIBRATE_POWER;
    }else if(iParam2 > MAX_VIBRATE_POWER){
        iParam2=MAX_VIBRATE_POWER;
    }
    
    NSString *_CmdStr;
    
    if (iParam1 == VIBRATE_ONCE) {
        _CmdStr = [NSString stringWithFormat:@"%%VIBRATE=%d,%d,%d\n",iParam1,iParam2,iParam3];
    }else if (iParam1 == VIBRATE_TWICE) {
        _CmdStr = [NSString stringWithFormat:@"%%VIBRATE=%d,%d,%d,%d\n", iParam1,iParam2,iParam3,iParam4];
    }else if (iParam1 == VIBRATE_OFF) {
        _CmdStr = [NSString stringWithFormat:@"%%VIBRATE=%d\n", iParam1];
    }
    
    return [self WriteOutputStream:_CmdStr];
}

/**
 *  onSystemData
 *  the connected peripheral(Band) update system data
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)onSystemData:(Byte*)byteData
{
    int8_t b2=byteData[2];
    int8_t b3=byteData[3];
    int8_t b4=byteData[4];
    int8_t b5=byteData[5];
    int8_t b6=byteData[6];
    
    int8_t mag_off_x = (byteData[8]<<8 | byteData[9]);
    int8_t mag_off_y = (byteData[10]<<8 | byteData[11]);
    int8_t mag_off_z = (byteData[12]<<8 | byteData[13]);
    int8_t mag_radius = (byteData[14]<<8 | byteData[15]);
    NSLog(@"magCal: X=%d,Y=%d,Z=%d,Radius=%d,b6=%d",mag_off_x, mag_off_y, mag_off_z, mag_radius,b6);
    Calibrated= (b6 == 3);
    if(Calibrated && mag_off_x != 0 && mag_off_y != 0 && mag_off_z != 0 && mag_radius >= 1 && self.isCalibreating
       && mag_off_x != -1 && mag_off_y != -1 && mag_off_z != -1){
        [self onCalibrated];
    }
    
    if(self.isCalibreating)
    {
        NSString *_CmdStr=@"?magcal\n";
        [self WriteOutputStream:_CmdStr];
    }
}

/**
 *  onCalibrated
 *  when calibration is done
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)onCalibrated{
    NSLog(@"onCalibrated!!");
    [self.WriteToPeripheralQueue removeAllObjects];
    [self WriteOutputStream:@"%store=1\n"];
    //[self performSelector:@selector(WriteOutputStream:) withObject:@"%led=2,0\n" afterDelay:0.5f];
    [self ControlLED:2 Mode:2 Ratio:30 OnPeriod:100 OffPeriod:2000];
    [self SelectOperation:3 Operation:4 DataPerSecond:50];
//    [self SelectSniffOperationAfter20Sec];
    if(self.after20SecSniffMode)
    {
        [self.after20SecSniffMode invalidate];
        self.after20SecSniffMode = nil;
    }
    self.after20SecSniffMode = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(SelectSniffOperationAfter20Sec:) userInfo: nil repeats: NO];
    InquireSystemCount = 0;
    self.isCalibreating = NO;
    _calibreatingPeripheral = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE OnCalibreated!!" object:nil userInfo:nil];
}

/**
 *  checkCalibreate
 *  deprecated
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)checkCalibreate:(NSTimer*)t
{
    //NSLog(@"magcal");
    if( ![_calibreatingPeripheral.identifier isEqual:_connectPeripheral.identifier] )
    {
        [_calibreateTimer invalidate];
        self.isCalibreating = NO;
        return;
    }
    NSString *_CmdStr=@"?magcal\n";
    [self WriteOutputStream:_CmdStr];
}

/**
 *  onBatteryData
 *  the connected peripheral(Band) battery data
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)onBatteryData:(Byte*)byteData
{
    int _BatLife = byteData[2];
    //float _Voltage = (256 * buffer[3] + buffer[4]) * 0.01f;
    //3=>60% 2=10~60% 1=<10%
    int _Status = byteData[5];
    // NSLog(@"onBatteryData: b2=%d,b3=%d,b4=%d,b5=%d",_BatLife,byteData[3],byteData[4],_Status);
    //NSString *res= [NSString stringWithFormat:@"Battery %d,%d", _BatLife,_Status];
    
    
}

/**
 *  onButtonData
 *  when receive peripheral button press, send vibrate CMD
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)onButtonData:(Byte*)byteData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE KEY_PRESS" object:nil userInfo:nil];
    [self DoVibrate:1 Strong:200 OnPeriod:100 OffPeriod:100];
}

/**
 *  InquireSystemStatus
 *  send CMD to peripheral for request peripheral system data
 *  edit by Jack in BlackSmith on 2015/10/16
 */
- (int)InquireSystemStatus{
    NSString *_CmdStr=@"?SYSTEM\n";
    InquireSystemCount++;
    return [self WriteOutputStream:_CmdStr];
}

/**
 *  InquireBatteryStatus
 *  send CMD to peripheral for request peripheral battery data
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(int)InquireBatteryStatus{
    NSString *_CmdStr=@"?BAT\n";
    if(CanRequestBatteryData)
        return [self WriteOutputStream:_CmdStr];
    
    return  -1;
}


/**
 *  ConnectPeripheralTimeOut
 *  if connect to peripheral is timeout, cancel connection
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)ConnectPeripheralTimeOut:(CBPeripheral*)peripheral
{
    [self PlayBandDebugLog:[NSString stringWithFormat:@"Connect Peripheral TimeOut!! Status: %d", CONNECT_STATUS]];
    NSDate * time = [NSDate date];
    NSTimeInterval temp = 0.0f;
    NSTimeInterval diffTime = [time timeIntervalSinceDate:disconnectTime];
    if( [time timeIntervalSinceDate:disconnectTime] < 10.0f)
    {
        return;
    }
    if( CONNECT_STATUS == SOCKET_CONNECTING )
    {
        if (peripheral != nil)
        {
            [_centralManager cancelPeripheralConnection: peripheral];
            [[NSNotificationCenter defaultCenter] postNotificationName:(NSString*)NotificationKey_CancelConnecting object:nil userInfo:nil];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:MyLocalizeString(Localization_ConnectionFailed) message:MyLocalizeString(Localization_ConnectionFailedMessage) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:MyLocalizeString(Localization_Confirm)
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                       {
                                           CONNECT_STATUS = SOCKET_DISCONNECTED;
                                           return;
                                       }];
            [alertController addAction:okAction];
            //[getRootViewController presentViewController:alertController animated:YES completion:nil];
            UIViewController *rootViewController = [AppDelegate getDisplayViewController];
            [rootViewController presentViewController:alertController animated:YES completion:nil];
        }
    }
}

/**
 *  OpenBluetoothPower
 *  when deivce's bluetooth setting is off, show this alert message to user to open bluetooth setting
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)OpenBluetoothPower
{
    BluetoothOffUIAlert = [UIAlertController alertControllerWithTitle:@"" message:MyLocalizeString(Localization_BluetoothOff) preferredStyle:UIAlertControllerStyleAlert];
        
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:MyLocalizeString(Localization_Confirm) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if( IS_OS_8_OR_LATER )
        {
            //go to setting page
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        else
        {
            //send API message to Unity, Bluetooth is Off
            //NSString *res=[NSString stringWithFormat:@"%d,%@",STATUS_CONNECT_BLUETOOTH_OFF, mCONNECT_ERROR_STRING_BluetoothOFF];
            //[self SendToUnity:UNITY_RESULT_CONNECT Status:res];
            return;
        }
    }];
    [BluetoothOffUIAlert addAction:okAction];
    UIViewController *rootViewController = [AppDelegate getDisplayViewController];
    
    [rootViewController presentViewController:BluetoothOffUIAlert animated:YES completion:nil];
}

#pragma mark - API for ViewController Part
/**
 *  StartScaning
 *  API for start centralManager scan peripherals(Bands)
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(bool)StartScaning
{
    if( _centralManager == nil )
    {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
    }
    if(!_IsScaning)
    {
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        _IsScaning =YES;
        return YES;
    }
    
    return false;
}

/**
 *  StopScaning
 *  API for stop centralManager scan peripherals(Bands)
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)StopScaning
{
    if(_IsScaning)
    {
        [_centralManager stopScan];
        _IsScaning = false;
    }
}

/**
 *  GetScanPeripheralList
 *  API for get didDiscover CacyBand peripheral list
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(NSMutableArray*) GetScanPeripheralList
{
    return _peripheralDict;
}

/**
 *  Connect
 *  API for connect to connectPeripheral(Band), the parameter
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)Connect:(CBPeripheral*) connectPeripheral
{
    NSLog(@"Connect to Band: %@", connectPeripheral);
    NSDate * connectClickTime = [NSDate date];
    NSTimeInterval temp = 0.0f;
    NSTimeInterval diffTime = [connectClickTime timeIntervalSinceDate:disconnectTime];
    NSLog(@"lastDisconnectTime: %f", diffTime);
    if(IsDisconnectRecent && [connectClickTime timeIntervalSinceDate:disconnectTime] < 5.0f && self.ReconnectEnable)
    {
        temp = 5.0f - diffTime;
    }
    IsDisconnectRecent = NO;
    if(CONNECT_STATUS == SOCKET_DISCONNECTED)
    {
        [self performSelector:@selector(Connect2:) withObject:connectPeripheral afterDelay:temp];
    }
    else if(CONNECT_STATUS == SOCKET_CONNECTED)
    {
        if( [connectPeripheral.identifier isEqual:_connectPeripheral.identifier])
            return;
        [self Disconnect];
        [self Connect:connectPeripheral];
        //self.ReconnectEnable = NO;
    }
    else
    {
        return;
    }
}

/**
 *  Connect function 2,
 *  API for connect to connectPeripheral(Band), the parameter
 *  edit by Jack in BlackSmith on 2015/10/16
 */

-(void)Connect2:(CBPeripheral*)connectPeripheral
{
    _connectPeripheral = connectPeripheral;
    connectPeripheral.delegate = self;
    [_centralManager connectPeripheral:connectPeripheral options:nil];
    float times = 10.0f;
    if( self.ReconnectEnable == YES )
    {
        times = 30.0f;
    }
    else if( self.ReconnectEnable == NO )
    {
        [self performSelector:@selector(ConnectPeripheralTimeOut:) withObject:connectPeripheral afterDelay:times];
    }
    CONNECT_STATUS = SOCKET_CONNECTING;
    //self.ReconnectEnable = NO;
}

/**
 *  Disconnect
 *  API for disconnect to connected or connecting peripheral(Band)
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)Disconnect
{
    if(CONNECT_STATUS == SOCKET_CONNECTED || CONNECT_STATUS == SOCKET_CONNECTING)
    {
        if(_connectPeripheral != nil)
        {
            if(_connectPeripheral.state == CBPeripheralStateConnected || _connectPeripheral.state == CBPeripheralStateConnecting)
            {
                [_centralManager cancelPeripheralConnection:_connectPeripheral];
                CONNECT_STATUS = SOCKET_DISCONNECTED;
                self.ReconnectEnable = NO;
            }
        }
    }
}

/**
 *  doCalibrate
 *  API for send CMD to connected peripheral(Band) for calibreation
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)doCalibrate{
    if(self.isCalibreating || CONNECT_STATUS != SOCKET_CONNECTED)
        return;
    NSLog(@"doCalibrate!!");
    self.isCalibreating = YES;
    [self.WriteToPeripheralQueue removeAllObjects];
    
    //only in %opr=3,4,50\n mode, can run calibration mode
    //[self SelectOperation:3 Operation:4 DataPerSecond:50];
    
    _calibreatingPeripheral = _connectPeripheral;
    
    //the calibreation mode cmd
    [self SelectOperation:2 Operation:0 DataPerSecond:500];
    
    [self ControlLED:2 Mode:2 Ratio:30  OnPeriod:100 OffPeriod:100];
    //[self performSelector:@selector(WriteOutputStream:) withObject:@"%led=1,0\n" afterDelay:1.0f];
    
    NSString *_CmdStr=@"?magcal\n";
    [self WriteOutputStream:_CmdStr];
    [self WriteOutputStream:_CmdStr];
}

/**
 *  IncomingCallVibrate
 *  when phone call incoming, send vibrate CMD to connected peripheral(Band)
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)IncomingCallVibrate:(NSNotification*)notificaion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if( [userDefaults boolForKey:@"setting_CbtVibrateSwitch"] )
    {
        NSLog(@"IncomingCallVibrate");
        for(int i = 0; i < 5; i++)
        {
            [self DoVibrate:1 Strong:80 OnPeriod:500+i OffPeriod:100];
        }
    }
}

/**
 *  disconnectVibrateSwitch
 *  API for changes the vibrate of disconnect alert
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)disconnectVibrateSwitch:(NSNotification*)notification
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if( ![userDefaults boolForKey:@"setting_LostVibrateSwitch"] )
    {
        //NSLog(@"Don't Vibrate on Disconnect!!");
        NSString *cmd = @"%SLL=0\n";
        [self WriteOutputStream:cmd];
    }
    else
    {
        //NSLog(@"Vibrate on Disconnect!!");
        NSString *cmd = @"%SLL=1\n";
        [self WriteOutputStream:cmd];
    }
}

/**
 *  loadBatteryData
 *  API for ask connected peripheral's battery data
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)loadBatteryData
{
    if(!self.isCalibreating)
        [self InquireBatteryStatus];
}

/**
 *  loadRSSIData
 *  API for ask connected peripheral's RSSI data
 *  edit by Jack in BlackSmith on 2015/10/16
 */
-(void)loadRSSIData
{
    if(_connectPeripheral.state == CBPeripheralStateConnected && !self.isCalibreating)
    {
        [_connectPeripheral readRSSI];
    }
}

-(void)PlayBandDebugLog:(NSString*)logMessage
{
    if(true)
    {
        NSLog(@"%@",logMessage);
    }
}

/**
 * setReconnectEnable
 * API for when connect button click
 * edit by Jack in BlackSmith on 2015/11/09
 */
-(void)SetReconnectEnable:(bool)result
{
    self.ReconnectEnable = result;
}

#pragma mark - Fouction for NSTimer Part
-(void)registeAlertDisconnected
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if( [userDefaults boolForKey:@"setting_DisconnectAlertVibrateSwitch"] )
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    if( [userDefaults boolForKey:@"setting_DisconnectAlertSoundSwitch"] )
    {
        AudioServicesPlaySystemSound (myAlertSound);
    }
    if(self.alertForDisconnectedTimer == nil)
        self.alertForDisconnectedTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(alertForDisconnected:) userInfo:nil repeats:YES];
}

-(void)unregisteAlertDisconnected
{
    if(self.alertForDisconnectedTimer)
    {
        [self.alertForDisconnectedTimer invalidate];
        self.alertForDisconnectedTimer = nil;
    }
    
}

-(void)alertForDisconnected:(NSTimer*)timer
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if( [userDefaults boolForKey:@"setting_DisconnectAlertVibrateSwitch"] )
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    if( [userDefaults boolForKey:@"setting_DisconnectAlertSoundSwitch"] )
    {
        AudioServicesPlaySystemSound (myAlertSound);
    }
}


@end