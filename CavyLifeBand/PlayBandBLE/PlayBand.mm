#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <math.h>

#import "PlayBand.h"

#define IS_OS_8_OR_LATER ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 )
#define IS_UI_ALERT_CONTROLLER_CAN_NOT_USE ( NSClassFromString(@"UIAlertController") == nil )

//================================
//
//================================
//const float DIVDE_16=0.0625;
const float DIVDE_1k=0.001;
const float DIVDE_180_PI=57.2958;
const float DIVDE_180_PI_N=-57.2958;
const float DIVDE_PI_180=0.01745;
const float DIVDE_PI_360N=-0.00873;
const float LOW_PASS_FACTOR = 0.2;
const float Error_Tolerence = 0.07;
//const float radiansToDegrees = 57.2958;
//const float degreesToRadians = 0.017453;
//const float degreesToRadiansHalf=-0.008727f;
const int MaxDataPerSecond=20;

const int SystemStatusDuration = 2;
//------------------------------
//
//------------------------------
NSString *const serviceUUID = @"14839AC4-7D7E-415C-9A42-167340CF2339";
NSString *const sendCommandCharacteristicUUID = @"8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3";
NSString *const getResultCharacteristicUUID = @"0734594A-A8E7-4B1A-A6B1-CD5243059A57";
//------------------------------
//
//------------------------------
const int16_t PACKET_DATA_BNO055 = 0xA1;
const int16_t PACKET_DATA_BATTERY =0xB1;
const int16_t PACKET_DATA_SYSTEM =0xC1;
const int16_t PACKET_DATA_BUTTON =0xD1;
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
//
//------------------------------
//NSString *const UNITY_CLASS = @"PlayBand";
const char* UNITY_CLASS = "PlayBand";
const char* UNITY_RESULT_CONNECT = "OnJniConnectResult";
const char* UNITY_RESULT_BATTERY = "OnJniBatteryStatus";
const char* UNITY_RESULT_BUTTON = "OnJniButtonClicked";
const char* UNITY_RESULT_CALIBRATED = "OnJniMagnetCalibrated";
const char* UNITY_RESULT_SENSOR = "OnJniSensorStatus";
//NSString *const UNITY_RESULT_SENSOR = @"ReceiveData";
const int STATUS_CONNECT_SUCCESS        = 0;
const int STATUS_CONNECT_CONNECTING     = 1;
const int STATUS_CONNECT_FAILED         = 2;
const int STATUS_CONNECT_DEVICE_FAILED  = 3;
const int STATUS_CONNECT_BLUETOOTH_OFF  = 4;
const int STATUS_CONNECT_NO_BRACELET    = 5;
const int STATUS_CONNECT_DISCONNECT     = 6;
//------------------------------
//
//------------------------------
const int CONNECT_MODE_NO_DATA = 0;
const int CONNECT_MODE_SAVE_POWER = 1;
const int CONNECT_MODE_NORMAL = 2;
const int CONNECT_MODE_FULL_POWER = 3;
//------------------------------
//
//------------------------------
const int LOW_POWER_MODE = 1;
const int LOW_POWER_MODE_SLEEP = 0;// default
//const int LOW_POWER_MODE_IDLE = 1;
const int LOW_POWER_MODE_STANDBY = 2;

const int SNIFF_MODE = 2;
const int SNIFF_MODE_NO_CHANGE = 0;// default
const int SNIFF_MODE_ACC_ON = 1;
//const int SNIFF_MODE_MAG_ON = 2;
//const int SNIFF_MODE_ACC_MAG_ON = 3;

const int NORMAL_MODE = 3;
const int NORMAL_MODE_6x_COMPASS = 1;
//const int NORMAL_MODE_6x_M4G = 2;
//const int NORMAL_MODE_9x_NDOF_FMC_OFF = 3;
const int NORMAL_MODE_9x_NDOF = 4;// default

const int NORMAL_SAVE_POWER_MODE = 4;
const int NORMAL_SAVE_POWER_MODE_6x_COMPASS = 1;
const int NORMAL_SAVE_POWER_MODE_6x_M4G = 2;
//const int NORMAL_SAVE_POWER_MODE_9x_NDOF_FMC_OFF = 3;
const int NORMAL_SAVE_POWER_MODE_9x_NDOF = 4;// default
//------------------------------
//
//------------------------------
const int SOCKET_DISCONNECTED = 0;
const int SOCKET_CONNECTING = 1;
const int SOCKET_CONNECTED = 2;
const int SOCKET_UNITY_CONNECT = 3;
//------------------------------
//
//------------------------------
const int MAGNETIC_MODE = 0;
const int GYRO_MODE = 1;
const int NO_MOVE_MODE = 2;
//================================
//
//================================
const int UI_ALERT_VIEW_SHOW_ERROR_ALERT = 0;
const int UI_ALERT_VIEW_SHOW_DEVICE_LIST = 1;
const int UI_ALERT_VIEW_SHOW_NO_DEVICE = 2;
const int UI_ALERT_VIEW_OPEN_BLE_POWER = 3;

//================================
//
//================================
NSString *MyLocalizedString(NSString* key, NSString* comment)
{
    static NSBundle* bundle = nil;
    if (!bundle)
    {
        NSString *libraryBundlePath = [[NSBundle mainBundle] pathForResource:@"PlayBandResources"
                                                                      ofType:@"bundle"];
        
        NSBundle *libraryBundle = [NSBundle bundleWithPath:libraryBundlePath];
        NSString *langID        = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSString *path          = [libraryBundle pathForResource:langID ofType:@"lproj"];
        bundle                  = [NSBundle bundleWithPath:path];
        
    }
    return [bundle localizedStringForKey:key value:@"" table:nil];
}


@interface PlayBand ()
{
    int             noDeviceFoundCounting;
    UIAlertView      *mUIAlertView;
    CBCentralManager *centralManager;
    CBPeripheral     *connectPeripheral;
    CBCharacteristic *writeCharacteristic;
    //
    //CBCentralManager *manager;
    //CBPeripheral *peripheral;
    CBCharacteristic *sendCommand;
    CBCharacteristic *getResult;
    NSMutableDictionary *peripheralDict;
    // NSMutableDictionary *bandNameDict;
    
    NSString *selectDevice;
    NSString *savedDevice;
    // NSString *bandData;
    
    //float *Global_q;
    float Global_euler[3];
    float Global_accel[3];
    float newAccel[3];
    float prevAccel[3];
    float deviceEulerZ;
    //
    bool Calibrated;
    //
    //int TargetPowerMode;
    //int TargetOpMode;
    // int CurPowerMode;
    // int CurOpMode;
    int SelectPowerMode;
    int SelectOpMode;
    int SelectDataPerSecond;
    //
    int SocketStatus;
    //int BandDataPerSecond;
    //float BandDataRateHZ;
    float DeviceGameRotZ;
    float BandFixedRotZ;
    //float TotalGameRotZ;
    //
    int MagneticMode;
    //
    CMMotionManager *MotionManager;
    CLLocationManager *LocalManager;
    //
    UIDeviceOrientation lastOrientation;
    
    //==================================
    //languages
    //==================================
    NSString *mReminderString;
    NSString *mBluetoothOffMessageString;
    NSString *mConfirmString;
    NSString *mNoDeviceFoundString;
    NSString *mCancelString;
    NSString *mRetryString;
    NSString *mBraceletListString;
    NSString *mSeletDeviceString;
    NSString *mRefreshString;
    NSString *mFailedToConnectString;
    NSString *mFailedToConnectMessageString;
    
    NSString *mCONNECT_ERROR_STRING_BluetoothOFF;
    NSString *mCONNECT_ERROR_STRING_NotBLE;
    NSString *mCONNECT_ERROR_STRING_NoBracelet;
    NSString *mCONNECT_ERROR_STRING_Connecting;
    NSString *mCONNECT_ERROR_STRING_ConnectFail;
    NSString *mCONNECT_ERROR_STRING_Disconnect;
    bool BeDebugMode;

}

@property(nonatomic, retain) NSString *selectDevice;
@property(nonatomic, retain) NSString *savedDevice;

@end
//================================
//
//================================
@implementation PlayBand;
@synthesize bandData;
@synthesize selectDevice;
@synthesize savedDevice;
//================================
//
//================================
- (void)initialize
{
    noDeviceFoundCounting = 0;
    mUIAlertView = nil;
    [self PlayBandDebugLog:[NSString stringWithFormat:@"initialize"]];
    BeDebugMode = false;
    centralManager=nil;
    connectPeripheral=nil;
    //connectPeripheral = [[CBPeripheral alloc] init];
    peripheralDict = [[NSMutableDictionary alloc] init];
    //selectDevice=@"";
    bandData=@"0,0,0,0,0,0,0,0,0,0,0,0,0,0";
    
    Global_euler[0]=0;
    Global_euler[1]=0;
    Global_euler[2]=0;
    Global_accel[0]=0;
    Global_accel[1]=0;
    Global_accel[2]=0;
    newAccel[0]=0;
    newAccel[1]=0;
    newAccel[2]=0;
    prevAccel[0]=0;
    prevAccel[1]=0;
    prevAccel[2]=0;
    deviceEulerZ=0;
    Calibrated=false;
    SelectPowerMode=0;
    SelectOpMode=0;
    SelectDataPerSecond=0;
    //
    SocketStatus=SOCKET_DISCONNECTED;
    DeviceGameRotZ=0;
    BandFixedRotZ=0;
    //
    MagneticMode=MAGNETIC_MODE;
    //
    MotionManager=[[CMMotionManager alloc]init];
    
    LocalManager = [[CLLocationManager alloc] init];
    //LocalManager.delegate=self;
    [LocalManager setDelegate:self];
    
    //
    lastOrientation=UIDeviceOrientationUnknown;
    
    //==================================
    //languages
    //==================================
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    [self PlayBandDebugLog:[NSString stringWithFormat:@"Language : %@", language]];
    mReminderString                 = MyLocalizedString(@"Reminder", nil);
    mBluetoothOffMessageString      = MyLocalizedString(@"BluetoothOffMessage", nil);
    mConfirmString                  = MyLocalizedString(@"Confirm", nil);
    mNoDeviceFoundString            = MyLocalizedString(@"NoDeviceFound", nil);
    mCancelString                   = MyLocalizedString(@"Cancel", nil);
    mRetryString                    = MyLocalizedString(@"Retry", nil);
    mBraceletListString             = MyLocalizedString(@"BraceletList", nil);
    mSeletDeviceString              = MyLocalizedString(@"SeletDevice", nil);
    mRefreshString                  = MyLocalizedString(@"Refresh", nil);
    mFailedToConnectString          = MyLocalizedString(@"FailedToConnect", nil);
    mFailedToConnectMessageString   = MyLocalizedString(@"FailedToConnectMessage", nil);
    
    mCONNECT_ERROR_STRING_BluetoothOFF      = MyLocalizedString(@"mCONNECT_ERROR_STRING_BluetoothOFF", nil);
    mCONNECT_ERROR_STRING_NotBLE            = MyLocalizedString(@"mCONNECT_ERROR_STRING_NotBLE", nil);
    mCONNECT_ERROR_STRING_NoBracelet        = MyLocalizedString(@"mCONNECT_ERROR_STRING_NoBracelet", nil);
    mCONNECT_ERROR_STRING_Connecting        = MyLocalizedString(@"mCONNECT_ERROR_STRING_Connecting", nil);
    mCONNECT_ERROR_STRING_ConnectFail       = MyLocalizedString(@"mCONNECT_ERROR_STRING_ConnectFail", nil);
    mCONNECT_ERROR_STRING_Disconnect        = MyLocalizedString(@"mCONNECT_ERROR_STRING_Disconnect", nil);
    
    
    if( mReminderString == nil )
    {
        mReminderString = @"提示";
        mBluetoothOffMessageString = @"蓝牙未开启，请前往iOS设置页面开启蓝牙";
        mConfirmString = @"确认";
        mNoDeviceFoundString = @"未找到豚鼠手环，请检查手环电源是否开启";
        mCancelString = @"取消";
        mRetryString = @"重试";
        mBraceletListString = @"手环列表";
        mSeletDeviceString = @"请选择您的手环进行连线";
        mRefreshString = @"刷新";
        mFailedToConnectString = @"手环连线失败";
        mFailedToConnectMessageString = @"请检查系统蓝牙及手环状态";
        
        mCONNECT_ERROR_STRING_BluetoothOFF      = @"蓝芽系统未开启";
        mCONNECT_ERROR_STRING_NotBLE            = @"此装置不支援BLE蓝芽";
        mCONNECT_ERROR_STRING_NoBracelet        = @"未找到豚鼠手环，且使用者取消重新discover";
        mCONNECT_ERROR_STRING_Connecting        = @"正在连结豚鼠手环";
        mCONNECT_ERROR_STRING_ConnectFail       = @"连结豚鼠手环失败， 请检查您的豚鼠手环状态";
        mCONNECT_ERROR_STRING_Disconnect        = @"豚鼠手环连接断线";
        
    }
    NSLog(@"IS_UI_ALERT_CONTROLLER_CAN_NOT_USE : %d", IS_UI_ALERT_CONTROLLER_CAN_NOT_USE );
    if(BeDebugMode)
    {
        NSLog(@"Device iOS version %d", IS_OS_8_OR_LATER);
        NSLog(@"Remider = %@", mReminderString);
        NSLog(@"BluetoothOffMessage = %@", mBluetoothOffMessageString);
        NSLog(@"Confirm = %@", mConfirmString);
        NSLog(@"NoDeviceFound = %@", mNoDeviceFoundString);
        NSLog(@"Cancel = %@", mCancelString);
        NSLog(@"Retry = %@", mRetryString);
        NSLog(@"BraceletList = %@", mBraceletListString);
        NSLog(@"SeletDevice = %@", mSeletDeviceString);
        NSLog(@"Refresh = %@", mRefreshString);
        NSLog(@"FailedToConnect = %@", mFailedToConnectString);
        NSLog(@"FailedToConnectMessage = %@", mFailedToConnectMessageString);
        
        NSLog(@"mCONNECT_ERROR_STRING_BluetoothOFF = %@", mCONNECT_ERROR_STRING_BluetoothOFF);
        NSLog(@"mCONNECT_ERROR_STRING_NotBLE = %@", mCONNECT_ERROR_STRING_NotBLE);
        NSLog(@"mCONNECT_ERROR_STRING_NoBracelet = %@", mCONNECT_ERROR_STRING_NoBracelet);
        NSLog(@"mCONNECT_ERROR_STRING_Connecting = %@", mCONNECT_ERROR_STRING_Connecting);
        NSLog(@"mCONNECT_ERROR_STRING_ConnectFail = %@", mCONNECT_ERROR_STRING_ConnectFail);
        NSLog(@"mCONNECT_ERROR_STRING_Disconnect = %@", mCONNECT_ERROR_STRING_Disconnect);
    }
    
    // 將觸發 1號 method
    //centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil ];
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];  //No default dialog if bluetooth doesn't open;
    [self SensorStatus];
}

-(void)SensorStatus
{
    int haveMag=[CLLocationManager headingAvailable]?1:0;
    int haveAcc=MotionManager.deviceMotionAvailable?1:0;
    int haveGyro=haveAcc;
    NSString *res=[NSString stringWithFormat:@"%d,%d,%d",haveMag,haveAcc,haveGyro];
    [self SendToUnity:UNITY_RESULT_SENSOR Status:res];
    
    [self PlayBandDebugLog:[NSString stringWithFormat:@"SensorStatus:Mag=%d,Acc=%d,Gyro=%d",haveMag,haveAcc,haveGyro]];
}

#pragma mark - CBCentralManager centeralManagerDidUpdateState
// 1號 method
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self PlayBandDebugLog:[NSString stringWithFormat:@"centralManagerDidUpdateState"]];
    //
    // 此 method 如果沒有實作，app 會 runtime crash
    // 先判斷藍牙是否開啟，如果不是藍牙4.x ，也會傳回電源未開啟
    
    if([self isBLECapableHardware:central.state]){
        // 將觸發 2號 method
        noDeviceFoundCounting = 0;
        [peripheralDict removeAllObjects];
        [centralManager scanForPeripheralsWithServices:nil options:nil];
        
        [self performSelector:@selector(ShowDevicesList:) withObject:savedDevice afterDelay:1];
    }
    
}

- (bool) isBLECapableHardware:(CBCentralManagerState)centralState
{
    NSString * state = nil;
    /**
     * 加上break; 使switch case正常運作. by BlackSmith
     */
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
    
    [self PlayBandDebugLog:[NSString stringWithFormat:@"Central manager state: %@", state]];
    
    [self ShowErrorAlert:state];
    
    SocketStatus=SOCKET_DISCONNECTED;
    NSString *res=[NSString stringWithFormat:@"%d,%@",STATUS_CONNECT_DEVICE_FAILED, mCONNECT_ERROR_STRING_NotBLE];
    [self SendToUnity:UNITY_RESULT_CONNECT Status:res];
    
    return false;
}

#pragma mark - CBCentralManagerDelegate didDiscoverPeripheral
// 2號 method
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    /**
     * 新增判斷peripheral.name使否為nil，避免程式Crash. by BlackSmith
     */
    if(peripheral.name == nil)
        return;
    noDeviceFoundCounting = 0;
    if ([peripheral.name rangeOfString:@"Cavy"].location == NSNotFound) {
        [self PlayBandDebugLog:[NSString stringWithFormat:@"not band"]];
    } else {
        [self PlayBandDebugLog:[NSString stringWithFormat:@"is band %@", peripheral]];
        
        if ([peripheralDict objectForKey:selectDevice] == nil){
            [peripheralDict setObject:peripheral forKey:peripheral.name];
        }
    }
}


-(int)ConnectTo{
    [self PlayBandDebugLog:[NSString stringWithFormat:@"ConnectTo: %@", selectDevice]];
    [self PlayBandDebugLog:[NSString stringWithFormat:@"SocketStatus: %d", SocketStatus]];
    [centralManager stopScan];
    CBPeripheral *peripheral = [peripheralDict objectForKey:selectDevice];
    if (peripheral != nil){
        SocketStatus=SOCKET_CONNECTING;
        connectPeripheral = peripheral;
        //if(peripheral.state!=CBPeripheralStateConnected){
        connectPeripheral.delegate = self;
        [centralManager connectPeripheral:connectPeripheral options:nil];
        [self performSelector:@selector(ConnectPeripheralTimeOut:) withObject:connectPeripheral afterDelay:10];
        // }
        
        return SUCCESS;
    }else{
        [self PlayBandDebugLog:[NSString stringWithFormat:@"peripheral is nil"]];
        [self ShowErrorAlert:@"peripheral is nil"];
        //TODO
        SocketStatus=SOCKET_DISCONNECTED;
        NSString *res=[NSString stringWithFormat:@"%d,%@",STATUS_CONNECT_FAILED, mCONNECT_ERROR_STRING_Connecting];
        [self SendToUnity:UNITY_RESULT_CONNECT Status:res];
        //
        return FAIL;
    }
}

-(int)Reconnect{
    //modify by BlackSmith Jack, 20150717
    if(SocketStatus!=SOCKET_DISCONNECTED){
        return FAIL;
    }
    [self PlayBandDebugLog:[NSString stringWithFormat:@"Reconnect:%@",selectDevice]];
    savedDevice=[selectDevice copy];
    
    NSString *res=[NSString stringWithFormat:@"%d,%@",STATUS_CONNECT_CONNECTING, mCONNECT_ERROR_STRING_Connecting];
    [self SendToUnity:UNITY_RESULT_CONNECT Status:res];
    
    //[self initialize];
    //centralManager=nil;
    /**
     * 新增判斷centralManager是否init過，避免重複alloc centralManager. by BlackSmith
     */
    if( centralManager != nil)
    {
//        [centralManager scanForPeripheralsWithServices:nil options:nil];
        
//        [self performSelector:@selector(ShowDevicesList:) withObject:savedDevice afterDelay:1];
        //[self centralManagerDidUpdateState:centralManager];
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
    }
    else
    {
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
    }

    return SUCCESS;
}

#pragma mark - CBCentralManagerDelegate didConnectPeripheral
// 3號 method
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //NSLog(@"%@ is connected.", peripheral.name);
    [self PlayBandDebugLog:[NSString stringWithFormat:@"didConnectPeripheral"]];
    /*
     NSArray *arr = [[NSArray alloc] initWithObjects: [CBUUID UUIDWithString:@"A001"], nil];
     // 如果 arr 為 nil，4號 method 將會收到所有的 service
     // 將觸發 4號 method
     [peripheral discoverServices:arr];
     */
    [peripheral discoverServices:nil];
}
#pragma mark - CBCentralManagerDelegate didFailToConnectPeripheral
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self PlayBandDebugLog:[NSString stringWithFormat:@"didFailToConnectPeripheral: called"]];
    if (error)
    {
        //NSString *message = [NSString stringWithFormat:@"Error~%@", error.description];
        [self PlayBandDebugLog:[NSString stringWithFormat:@"didFailToConnectPeripheral:%@", error.description]];
        [self ShowErrorAlert:error.description];
        SocketStatus=SOCKET_DISCONNECTED;
        NSString *res=[NSString stringWithFormat:@"%d,%@",STATUS_CONNECT_FAILED, mCONNECT_ERROR_STRING_ConnectFail];
        [self SendToUnity:UNITY_RESULT_CONNECT Status:res];
    }
}
#pragma mark - CBCentralManagerDelegate didDisconnectPeripheral
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self PlayBandDebugLog:[NSString stringWithFormat:@"%@ Disconnected", peripheral.name]];
    NSString *res=[NSString stringWithFormat:@"%d,%@",STATUS_CONNECT_DISCONNECT, mCONNECT_ERROR_STRING_Disconnect];
    [self SendToUnity:UNITY_RESULT_CONNECT Status:res];
    //self.discoveredPeripheral = nil;
    
    // We're disconnected, so start scanning again
    //[self scan];
}
#pragma mark - CBPeripheralDelegate didDiscoverServices
// 4號 method
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    [self PlayBandDebugLog:[NSString stringWithFormat:@"%@ didDiscoverServices",peripheral.name]];
    // 列出所有的 service
    for (CBService *service in peripheral.services) {
        // NSArray *arr = [[NSArray alloc] initWithObjects: [CBUUID UUIDWithString:@"CC01"], nil];
        // 如果 arr 為 nil，5號 method 將會收到所有的 characteristic
        // 將觸發 5號 method
        //[connectPeripheral discoverCharacteristics:nil forService:service];

        [self PlayBandDebugLog:[NSString stringWithFormat:@"Discovered service with UUID: %@", service.UUID]];
        
        //if ([service.UUID isEqual:[CBUUID UUIDWithString:@"14839AC4-7D7E-415C-9A42-167340CF2339"]])
        if ([service.UUID isEqual:[CBUUID UUIDWithString:serviceUUID]])
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }
        
    }
}
/*
 //CBCharacteristicWriteWithResponse
 - (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
 {
 if (error)
 {
 //NSString *message = [NSString stringWithFormat:@"WriteValue Error:%@", error.description];
 NSLog(@"WriteValue Error:%@", error.description);
 }
 else
 {
 //NSString *message = [NSString stringWithFormat:@"WriteValue Sucess%@", characteristic.UUID];
 NSLog(@"WriteValue Sucess%@", characteristic.UUID);
 }
 
 }
 */
/*
 - (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
 {
 if (error) {
 NSLog(@"Error changing notification state: %@", error.localizedDescription);
 }
 
 // Exit if it's not the transfer characteristic
 if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:getResultCharacteristicUUID]]) {
 return;
 }
 
 // Notification has started
 if (characteristic.isNotifying) {
 NSLog(@"Notification began on %@", characteristic);
 }
 // Notification has stopped
 else {
 // so disconnect from the peripheral
 NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
 [centralManager cancelPeripheralConnection:peripheral];
 }
 }
 */
#pragma mark - CBPeripheralDelegate didDiscoverCharacteristicsForService
// 5號 method
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    [self PlayBandDebugLog:[NSString stringWithFormat:@"%@ didDiscoverCharacteristicsForService",peripheral.name]];
    // 列出所有的 characteristic
    for (CBCharacteristic *characteristic in service.characteristics) {
        // if ((characteristic.properties & CBCharacteristicPropertyNotify) == CBCharacteristicPropertyNotify) {
        // 如果收到 peripheral 送過來的資料的話，將觸發 6號 method
        //[peripheral setNotifyValue:YES forCharacteristic:characteristic];
        //  }
        
        if ((characteristic.properties & CBCharacteristicPropertyWrite) == CBCharacteristicPropertyWrite) {
            // CC02 是可以讓 central 寫資料到 peripheral
            writeCharacteristic = characteristic;
            // 如果要寫資料到 peripheral，可呼叫 7號 method，例如下行
            // [self sendData:[@"hello world" dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:serviceUUID]])
    {
        for (CBCharacteristic *achar in service.characteristics) {
            if ([achar.UUID isEqual:[CBUUID UUIDWithString:sendCommandCharacteristicUUID]])
            {
                [self PlayBandDebugLog:[NSString stringWithFormat:@"found SEND COMMAND characteristic"]];
                sendCommand = achar;
                
                // send command to 9x BLE
                //[self WriteOutputStream:@"%LED=2,2,30,100,2000,\n"];
                // [self WriteOutputStream:@"%VIBRATE=1,50,1000\n"];
                //[self WriteOutputStream:@"%OPR=4,4,20\n"];
                //[self DoVibrate:1 Strong:50 OnPeriod:1000 OffPeriod:0];
                //[self ControlLED:2 Mode:2 Ratio:30 OnPeriod:100 OffPeriod:200];
                
                /*
                 [self ControlLED:1 Mode:1 Ratio:30  OnPeriod:0 OffPeriod:0];
                 [self WriteOutputStream:@"%OPR=4,4,20\n"];
                 */
                //
            } else if ([achar.UUID isEqual:[CBUUID UUIDWithString:getResultCharacteristicUUID]])
            {
                [self PlayBandDebugLog:[NSString stringWithFormat:@"found GET RESULT characteristic"]];
                getResult = achar;
                
                [self RegisterNotifyForData];
            }
        }
        //[self OnConnectBluetooth];
        [self performSelector:@selector(OnConnectBluetooth) withObject:nil afterDelay:1];
    }
    
    //NSString *res=@"0,";
    //UnitySendMessage ("PlayBand", "OnJniConnectResult", [res UTF8String] );
    //UnitySendMessage ("PlayBand", "OnJniConnectResult", "0," );
}


-(void)OnConnectBluetooth
{
    [self PlayBandDebugLog:[NSString stringWithFormat:@"OnConnectBluetooth"]];
    [self ControlLED:1 Mode:2 Ratio:50 OnPeriod:100 OffPeriod:100];
    [self SelectOperation:SelectPowerMode Operation:SelectOpMode DataPerSecond:SelectDataPerSecond];
    [self SetMagneticMode:MagneticMode];
    
    //
    //[self InquireSystemStatus];
    [self performSelector:@selector(InquireSystemStatus) withObject:self afterDelay:1];
    //[self performSelector:@selector(InquireSystemStatus) withObject:nil afterDelay:1];
    //
    //NSLog(@"%d",STATUS_CONNECT_SUCCESS);
    //NSLog(@"%@",(NSString *)selectDevice);
    //selectDevice=(NSString *)selectDevice;
    
    NSString *res=[NSString stringWithFormat:@"%d,%@",STATUS_CONNECT_SUCCESS,selectDevice];
    [self SendToUnity:UNITY_RESULT_CONNECT Status:res];
    //紀錄的device 等於 使用者選擇的device, 以便Reconnect使用. by BlackSmith
    savedDevice = [selectDevice copy];
    SocketStatus=SOCKET_CONNECTED;
    
    [self PlayBandDebugLog:[NSString stringWithFormat:@"%@ is connected. Connection accomplished!!", connectPeripheral.name]];
    //
}

#pragma mark - CBPeripheralDelegate didUpdateValueForCharacteristic
// 6號 method
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (error)
    {
        //NSString *message = [NSString stringWithFormat:@"didUpdateValueForCharacteristic Error~%@", error.description];
        //UnitySendMessage ("BluetoothLEReceiver", "OnBluetoothMessage", [message UTF8String] );
        return;
    }
    
    //NSLog(@"didUpdateValueForCharacteristic");
    //NSString *str = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    //NSLog(@"receive: %@", str);
    
    NSData *data=characteristic.value;
    int len = 17;
    
    if(data.length!=len){
        //F
        [self PlayBandDebugLog:[NSString stringWithFormat:@"data.length error: %d",(int)data.length]];
        return;
    }
    
    Byte byteData[len];
    [data getBytes:&byteData length:len];
    //================================
    //
    //================================
    //int16_t b0=(int16_t)byteData[0];
    //uint8_t b0=byteData[0];
    int16_t b0=byteData[0];
    if(b0!=36){
        //NSLog(@"data[0] != $");
        [self PlayBandDebugLog:[NSString stringWithFormat:@"data[0] error"]];
        return;
    }
    //
    //int16_t b1=(int16_t)byteData[1];
    int16_t b1=byteData[1];
    
    //NSLog(@"b0:%c",(int16_t) byteData[0]);
    //NSLog(@"b0:%d",(int16_t) byteData[0]);
    //NSLog(@"b1:%x",(int16_t) byteData[1]);
    //if(b1==0xA1){
    if(b1==PACKET_DATA_BNO055){
        [self onSensorData:byteData];
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
    
    //If you want an empty buffer:
    //[data setLength:0];
    //If you want to keep its size but set all the bytes to zero:
    //[data resetBytesInRange:NSMakeRange(0, [data length])];
    
    return;
    
    /*
     how to calculate BLE respond checksum
     uint8_t checksum = 0;
     For(i=0; i<=15; i++) checksum=checksum ^ B[i]
     */
}
/*
 // 7號 method
 -(void)sendData: (NSData *) data
 {
 NSLog(@"sendData: %@", data);
 // 將資料寫入 peripheral 端 CC02 這個 characteristic
 [connectPeripheral writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithResponse];
 }
 */

/*
 - (void)didReceiveMemoryWarning {
 [super didReceiveMemoryWarning];
 // Dispose of any resources that can be recreated.
 }
 */
//================================
//9x BLE
//================================
//data:[NSData dataWithBytes:data length:length]
//NSData* data =[NSData dataWithBytes:value length:value.length];
//[NSString stringWithUTF8String:[theData bytes]];

- (int)WriteOutputStream:(NSString*)value {
    //NSLog(@"WriteOutputStream: [%@]", value);
    
    // if(SocketStatus==SOCKET_CONNECTED){
    
    NSData* data = [value dataUsingEncoding:NSUTF8StringEncoding];
    
    CBPeripheral *peripheral = [peripheralDict objectForKey:selectDevice];
    connectPeripheral=peripheral;
    
    if (connectPeripheral && sendCommand) {
        //NSLog(@"WriteOutputStream: %@", value);
        if(connectPeripheral.state==CBPeripheralStateConnected){
            [self PlayBandDebugLog:[NSString stringWithFormat:@"write char: %@", data]];
            [connectPeripheral writeValue:data forCharacteristic:sendCommand type:CBCharacteristicWriteWithoutResponse];
            //[connectPeripheral writeValue:data forCharacteristic:sendCommand type:CBCharacteristicWriteWithResponse];
            return SUCCESS;
        }
    }
    return ERR_SEND_COMMAND_EXCEPTION;
    // }
    // return ERR_NOT_CONNECTED;
    
}

- (void)RegisterNotifyForData
{
    CBPeripheral *peripheral = [peripheralDict objectForKey:selectDevice];
    connectPeripheral=peripheral;
    
    if (connectPeripheral && getResult) {
        [connectPeripheral setNotifyValue:YES forCharacteristic:getResult];
    }
}
//
typedef union twobytes
{
    char a[2];
    int16_t b;
} TB_DATA;

- (int16_t)short_from_char0:(char)a0 andChar1:(char)a1
{
    TB_DATA temp;
    temp.a[0] = a1;
    temp.a[1] = a0;
    return temp.b;
}
//================================
//Reader
//================================
-(void)onSystemData:(Byte*)byteData
{
    int8_t b2=byteData[2];
    int8_t b3=byteData[3];
    int8_t b4=byteData[4];
    int8_t b5=byteData[5];
    int8_t b6=byteData[6];
    /*
     if (TargetPowerMode == b2 && TargetOpMode == b3) {
     CurPowerMode = b2;
     CurOpMode = b3;
     TargetPowerMode = 0;
     TargetOpMode = 0;
     }
     */
    //
    Calibrated= (b6 >= 3);
    if(Calibrated){
        [self onCalibrated];
    }else{
        [self performSelector:@selector(InquireSystemStatus) withObject:self afterDelay:SystemStatusDuration];
        //[self performSelector:@selector(InquireSystemStatus) withObject:nil afterDelay:SystemStatusDuration];
    }
    
   // NSLog(@"onSystemData: b2=%d,b3=%d,b4=%d,b5=%d,b6=%d",b2,b3,b4,b5,b6);
}


-(void)onCalibrated{
    [self ControlLED:1 Mode:1 Ratio:50  OnPeriod:0 OffPeriod:0];
    NSString *res=@"1";
    [self SendToUnity:UNITY_RESULT_CALIBRATED Status:res];
}

-(void)onBatteryData:(Byte*)byteData
{
    int _BatLife = byteData[2];
    //float _Voltage = (256 * buffer[3] + buffer[4]) * 0.01f;
    //3=>60% 2=10~60% 1=<10%
    int _Status = byteData[5];
    
   // NSLog(@"onBatteryData: b2=%d,b3=%d,b4=%d,b5=%d",_BatLife,byteData[3],byteData[4],_Status);
    
    NSString *res= [NSString stringWithFormat:@"%d,%d", _BatLife,_Status];
    [self SendToUnity:UNITY_RESULT_BATTERY Status:res];
    
    
}

-(void)onButtonData:(Byte*)byteData
{
    //[instance SetMagneticMode:2];
    //return;
    
    NSString *res=@"1";
    [self SendToUnity:UNITY_RESULT_BUTTON Status:res];
}


-(void)onSensorData:(Byte*)byteData
{
    //================================
    //
    //================================
    int qW = [self short_from_char0:byteData[2] andChar1:byteData[3]];
    int qX = [self short_from_char0:byteData[4] andChar1:byteData[5]];
    int qY = [self short_from_char0:byteData[6] andChar1:byteData[7]];
    int qZ = [self short_from_char0:byteData[8] andChar1:byteData[9]];
    float accelX = [self short_from_char0:byteData[10] andChar1:byteData[11]] * DIVDE_1k;
    float accelY = [self short_from_char0:byteData[12] andChar1:byteData[13]] * DIVDE_1k;
    float accelZ = [self short_from_char0:byteData[14] andChar1:byteData[15]] * DIVDE_1k;
    
    Global_accel[0]=accelX;
    Global_accel[1]=accelY;
    Global_accel[2]=accelZ;
    //================================
    //normalize Quaternion
    //================================
    float mag =sqrt((qW * qW)+ (qX* qX) + (qY * qY) + (qZ * qZ));
    if (mag < 0.000001) {
        mag=0.000001;
    }
    //float divMag=1.0/mag;
    mag=1.0/mag;
    
    float qW2=qW*mag;
    float qX2=qX*mag;
    float qY2=qY*mag;
    float qZ2=qZ*mag;
    //
    //Global_q[0]=qW2;
    //Global_q[1]=qX2;
    //Global_q[2]=qY2;
    //Global_q[3]=qZ2;
    //================================
    //Euler from Q
    //================================
    //180 / Math.PI=57.29578
    //pitch
    Global_euler[1] =atan2(2 * (qW2 * qX2 + qY2* qZ2),1 - 2 * (qX2 * qX2 + qY2* qY2)) * DIVDE_180_PI_N;
    //yaw
    Global_euler[2] =atan2(2 * (qW2* qZ2 + qX2* qY2),1 - 2 * (qY2 * qY2 + qZ2* qZ2)) *  DIVDE_180_PI_N;
    //roll
    Global_euler[0] = asin(2 * (qW2* qY2 - qZ2 * qX2)) *  DIVDE_180_PI;
    //roll360
    float roll360 =atan2(2 * (qX2 * qZ2 - qW2* qY2),1 - 2 * (qX2 * qX2 +qY2* qY2)) * DIVDE_180_PI;
    
    //================================
    //
    //================================
    deviceEulerZ=[self getDeviceEulerZ];
    float _DeltaAngle = deviceEulerZ * DIVDE_PI_360N;
    
    float _QXDevice = 0.0;
    float _QYDevice = 0.0;
    float _QZDevice = sin(_DeltaAngle);
    float _QWDevice = cos(_DeltaAngle);
    //
    float _QXCombined = _QWDevice * qX2 + _QXDevice * qW2+ _QYDevice * qZ2- _QZDevice * qY2;
    float _QYCombined = _QWDevice * qY2- _QXDevice * qZ2+ _QYDevice * qW2 + _QZDevice * qX2;
    float _QZCombined = _QWDevice * qZ2+ _QXDevice * qY2- _QYDevice * qX2 + _QZDevice * qW2;
    float _QWCombined = _QWDevice * qW2- _QXDevice * qX2- _QYDevice * qY2- _QZDevice * qZ2;
    //
    float _A11 = 1.0 - (2.0 * _QYCombined * _QYCombined)- (2.0 * _QZCombined * _QZCombined);
    float _A12 = (2.0 * _QXCombined * _QYCombined)- (2.0 * _QWCombined * _QZCombined);
    float _A13 = (2.0 * _QWCombined * _QYCombined)+ (2.0 * _QXCombined * _QZCombined);
    float _A21 = (2.0 * _QXCombined * _QYCombined)+ (2.0 * _QWCombined * _QZCombined);
    float _A22 = 1.0 - (2.0 * _QXCombined * _QXCombined)- (2.0 * _QZCombined * _QZCombined);
    float _A23 = (2.0 * _QYCombined * _QZCombined)- (2.0 * _QWCombined * _QXCombined);
    float _A31 = (2.0 * _QXCombined * _QZCombined)- (2.0 * _QWCombined * _QYCombined);
    float _A32 = (2.0 * _QWCombined * _QXCombined)+ (2.0 * _QYCombined * _QZCombined);
    float _A33 = 1.0 - (2.0 * _QXCombined * _QXCombined)- (2.0 * _QYCombined * _QYCombined);
    //
    newAccel[0] = _A11 * accelX + _A12 * accelY + _A13* accelZ;
    newAccel[1] = _A21 * accelX + _A22 * accelY + _A23* accelZ;
    newAccel[2] = _A31 * accelX + _A32 * accelY + _A33* accelZ;
    //================================
    //low-pass filter
    //================================
    //newAccel[0]=accelX;
    //newAccel[1]=accelY;
    //newAccel[2]=accelZ;
    
    for (int i = 0; i < 3; ++i) {
        newAccel[i] = prevAccel[i] * (1.0 - LOW_PASS_FACTOR) + newAccel[i]* LOW_PASS_FACTOR;
        /*
         if (newAccel[i] < Error_Tolerence && newAccel[i] > -Error_Tolerence) {
         newAccel[i] = 0.0;
         }
         */
        
        if (fabsf(newAccel[i]) < Error_Tolerence) {
            newAccel[i] = 0.0;
        }
        
        
        prevAccel[i] = newAccel[i];
        
    }
    //================================
    //low-pass filter
    //================================
    
    /*
     newAccel[0] = _A11 * Global.Accel[0] + _A12 * Global.Accel[1] + _A13* Global.Accel[2];
     newAccel[1] = _A21 * Global.Accel[0] + _A22 * Global.Accel[1] + _A23* Global.Accel[2];
     newAccel[2] = _A31 * Global.Accel[0] + _A32 * Global.Accel[1] + _A33* Global.Accel[2];
     */
    //================================
    //v1
    //self.bandData=[NSString stringWithFormat:@"%d,%d,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f", qW,qX,qY,qZ,Global_euler[1],Global_euler[2],Global_euler[0],Global_accel[0],Global_accel[1],Global_accel[2],newAccel[0],newAccel[1],newAccel[2],roll360];
    //v2
    /*
     if (MagneticMode == MAGNETIC_MODE) {
     Global_euler[2]+=deviceEulerZ;
     while (Global_euler[2]<0) {
     Global_euler[2]+=360;
     }
     }*/
    //v3
    //Global_euler[2] =atan2(2 * (_QWCombined* _QZCombined + _QXCombined* _QYCombined),1 - 2 * (_QYCombined * _QYCombined + _QZCombined* _QZCombined)) *  DIVDE_180_PI*-1;
    //
    
    //v4
    /*
     float fixEulerY= 0;
     if (MagneticMode == MAGNETIC_MODE) {
     fixEulerY= Global_euler[2]+deviceEulerZ;
     }
     */
    float fixEulerY=Global_euler[2]+deviceEulerZ;
    while (fixEulerY<0) {
        fixEulerY+=360;
    }
    
    
    self.bandData=[NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f", _QWCombined,_QXCombined,_QYCombined,_QZCombined,Global_euler[1],fixEulerY,Global_euler[0],Global_accel[0],Global_accel[1],Global_accel[2],newAccel[0],newAccel[1],newAccel[2],roll360];
}

-(float) getDeviceEulerZ {
    if (MagneticMode == MAGNETIC_MODE) {
        deviceEulerZ=-DeviceGameRotZ+[self getOrientationZ];
        // NSLog(@"MAGNETIC_MODE %f",DeviceGameRotZ);
    } else if (MagneticMode == GYRO_MODE) {
        deviceEulerZ=-DeviceGameRotZ+[self getOrientationZ];
        //NSLog(@"GYRO_MODE %f",DeviceGameRotZ);
    } else if (MagneticMode == NO_MOVE_MODE) {
        // NSLog(@"NO_MOVE_MODE %f",BandFixedRotZ);
        deviceEulerZ = BandFixedRotZ;
    }
    
    while (deviceEulerZ>360) {
        deviceEulerZ-=360;
    }
    
    while (deviceEulerZ<0) {
        deviceEulerZ+=360;
    }
    
    return deviceEulerZ;
}

-(float) getOrientationZ {
    float oz=0;
    UIDeviceOrientation orientation=[[UIDevice currentDevice]orientation];
    // NSLog(@"orientation=%d",orientation);
    if (orientation == UIDeviceOrientationPortrait){
        lastOrientation=orientation;
    }else if (orientation == UIDeviceOrientationPortraitUpsideDown){
        lastOrientation=orientation;
        oz= 180.0;
    }else if (orientation ==UIDeviceOrientationLandscapeRight ){
        lastOrientation=orientation;
        oz= 90.0;
    }else if (orientation ==UIDeviceOrientationLandscapeLeft ){
        lastOrientation=orientation;
        oz= -90.0;
    }else if (orientation ==UIDeviceOrientationFaceUp ){
        if(lastOrientation==UIDeviceOrientationPortraitUpsideDown){
            oz= 180.0;
        }else if(lastOrientation==UIDeviceOrientationLandscapeRight){
            oz= 90.0;
        }else if(lastOrientation==UIDeviceOrientationLandscapeLeft){
            oz= -90.0;
        }
    }else if (orientation ==UIDeviceOrientationFaceDown ){
        
    }
    
    
    return oz;
}

//================================
//Writer
//================================
- (int)Connect:(NSString*)deviceName Mode:(int)mode DataPerSecond:(int)rate
{
    /*
     if (SocketStatus != SOCKET_DISCONNECTED)
     {
     return ERR_STILL_CONNECTING;
     }*/
    
    savedDevice=[deviceName copy];
    
    SocketStatus=SOCKET_CONNECTING;
    [self PlayBandDebugLog:[NSString stringWithFormat:@"SocketStatus: %d", SocketStatus]];
    NSString *res=[NSString stringWithFormat:@"%d,%@",STATUS_CONNECT_CONNECTING, mCONNECT_ERROR_STRING_Connecting];
    [self SendToUnity:UNITY_RESULT_CONNECT Status:res];
    //
    [self initialize];
    [self SetPowerMode:mode DataPerSecond:rate DoSend:false];
    
    return SUCCESS;
    /*
     NSLog(@"Connect %@", selectDevice);
     [centralManager stopScan];
     CBPeripheral *peripheral = [peripheralDict objectForKey:selectDevice];
     if (peripheral != nil){
     [centralManager connectPeripheral:peripheral options:nil];
     return SUCCESS;
     }
     return FAIL;*/
    
    /*
     if (Global.SocketStatus != SOCKET_DISCONNECTED)
     {
     return Global.ERR_STILL_CONNECTING;
     }
     
     Global.SocketStatus=SOCKET_UNITY_CONNECT;
     
     connectAddress = iDeviceAddress;
     setPowerMode(iMode,iDataPerSecond,false);
     
     m_BluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
     
     if (m_BluetoothAdapter != null) {
     StartBluetooth();
     }else{
     Global.SocketStatus = SOCKET_DISCONNECTED;
     return Global.ERR_BLUETOOTH_DEVICE_ERROR;
     }
     
     return Global.SUCCESS;
     */
    
}

- (int)InquireSystemStatus{
    NSString *_CmdStr=@"?SYSTEM\n";
    return [self WriteOutputStream:_CmdStr];
}

-(int)InquireBatteryStatus{
    NSString *_CmdStr=@"?BAT\n";
    return [self WriteOutputStream:_CmdStr];
}

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
    
    return [self WriteOutputStream:_CmdStr];
}

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
    //
    if (iParam1 == VIBRATE_ONCE) {
        _CmdStr = [NSString stringWithFormat:@"%%VIBRATE=%d,%d,%d\n",iParam1,iParam2,iParam3];
    }else if (iParam1 == VIBRATE_TWICE) {
        _CmdStr = [NSString stringWithFormat:@"%%VIBRATE=%d,%d,%d,%d\n", iParam1,iParam2,iParam3,iParam4];
        //_CmdStr = [NSString stringWithFormat:@"%%VIBRATE=%d,%d,%d\n", iParam1,iParam2,iParam3];
    }else if (iParam1 == VIBRATE_OFF) {
        _CmdStr = [NSString stringWithFormat:@"%%VIBRATE=%d\n", iParam1];
    }
    
    return [self WriteOutputStream:_CmdStr];
}

- (int)Disconnect
{
    /**
     //modify by BlackSmith Jack, 20150717
     * 加上判斷，避免當手環第一次跟iOS連線時，iOS彈出的配對許可Dialog導致已連線的手環斷線。 by BlackSmith
     */
    if(![savedDevice isEqualToString:selectDevice] || SocketStatus != SOCKET_CONNECTED)
    {
        savedDevice = selectDevice;
        [self PlayBandDebugLog:[NSString stringWithFormat:@"Disconnect: Failed."]];
        return FAIL;
    }
    
    SocketStatus=SOCKET_DISCONNECTED;
    
    [LocalManager stopUpdatingHeading];
    /**
     * 加上selectDeivce的判斷，避免在selectDevice = nil時，執行[peripheralDict removeObjectForKey:selectDevice]，導致Crash. by BalckSmith
     */
    CBPeripheral *peripheral = [peripheralDict objectForKey:selectDevice];
    if( selectDevice != nil )
        [peripheralDict removeObjectForKey:selectDevice];
    if (peripheral != nil){
        if(peripheral.state==CBPeripheralStateConnected){
            [centralManager cancelPeripheralConnection:peripheral];
            peripheral=nil;
            [self PlayBandDebugLog:[NSString stringWithFormat:@"Disconnect:%@", selectDevice]];
            return SUCCESS;
        }
    }
    return FAIL;
}

-(int)SetPowerMode:(int)iMode DataPerSecond:(int)iDataPerSecond DoSend:(bool)send{
    
    /*
     if (SocketStatus != SOCKET_CONNECTED) {
     return ERR_NOT_CONNECTED;
     }*/
    
    if(iDataPerSecond>MaxDataPerSecond){
        iDataPerSecond=MaxDataPerSecond;
    }
    //int _DataRate = 1000 / iDataPerSecond;
    
    int _PowerMode = 0;
    int _OpMode = 0;
    
    if (iMode == CONNECT_MODE_NO_DATA) {
        _PowerMode = SNIFF_MODE;
        _OpMode = SNIFF_MODE_NO_CHANGE;
    } else if (iMode == CONNECT_MODE_SAVE_POWER) {
        _PowerMode = NORMAL_SAVE_POWER_MODE;
        _OpMode = NORMAL_SAVE_POWER_MODE_6x_M4G;
    } else if (iMode == CONNECT_MODE_NORMAL) {
        _PowerMode = NORMAL_SAVE_POWER_MODE;
        _OpMode = NORMAL_SAVE_POWER_MODE_9x_NDOF;
    } else if (iMode == CONNECT_MODE_FULL_POWER) {
        _PowerMode = NORMAL_MODE;
        _OpMode = NORMAL_MODE_9x_NDOF;
    } else {
        _PowerMode = NORMAL_SAVE_POWER_MODE;
        _OpMode = NORMAL_SAVE_POWER_MODE_9x_NDOF;
    }
    
    if(send){
        // if (Global.SocketStatus == SOCKET_CONNECTED) {
        [self SelectOperation:_PowerMode Operation:_OpMode DataPerSecond:iDataPerSecond];
        // }
    }else{
        SelectPowerMode = _PowerMode;
        SelectOpMode = _OpMode;
        SelectDataPerSecond = iDataPerSecond;
    }
    
    return SUCCESS;
}

-(int)SelectOperation:(int)iParam1 Operation:(int)iParam2 DataPerSecond:(int)iParam3 {
    [self PlayBandDebugLog:[NSString stringWithFormat:@"SelectOperation: %d,%d,%d",iParam1,iParam2,iParam3]];
    
    if (iParam1 < LOW_POWER_MODE || iParam1 > NORMAL_SAVE_POWER_MODE) {
        return ERR_INVALID_PARAMETERS;
    }
    //
    if (iParam1 == NORMAL_SAVE_POWER_MODE) {
        if (iParam2 < NORMAL_SAVE_POWER_MODE_6x_COMPASS || iParam2 > NORMAL_SAVE_POWER_MODE_9x_NDOF) {
            return ERR_INVALID_PARAMETERS;
        } else {
            //Global.BandDataPerSecond=RATE_NORMAL_25HZ;
        }
    } else if (iParam1 == NORMAL_MODE){
        if (iParam2 < NORMAL_MODE_6x_COMPASS	|| iParam2 > NORMAL_MODE_9x_NDOF) {
            return ERR_INVALID_PARAMETERS;
        }
        //Global.BandDataPerSecond=RATE_NORMAL_31HZ;
    }else if (iParam1 == SNIFF_MODE) {
        if (iParam2 < SNIFF_MODE_NO_CHANGE || iParam2 > SNIFF_MODE_ACC_ON) {
            return ERR_INVALID_PARAMETERS;
        }
        //_CmdStr = String.format("%%OPR=%d,%d,%d\n", iParam1, iParam2,RATE_LOW_20HZ);
        //Global.BandDataPerSecond=RATE_LOW_20HZ;
    } else if (iParam1 == LOW_POWER_MODE) {
        if (iParam2 < LOW_POWER_MODE_SLEEP || iParam2 > LOW_POWER_MODE_STANDBY) {
            return ERR_INVALID_PARAMETERS;
        } else {
            //_CmdStr = String.format("%%OPR=%d,%d\n", iParam1, iParam2);
            //Global.BandDataPerSecond=RATE_LOW_10HZ;
        }
    }
    //
    //BandDataPerSecond=iParam3;
    // BandDataRateHZ=(float)1/iParam3;
    //
    NSString *_CmdStr = [NSString stringWithFormat:@"%%OPR=%d,%d,%d\n",iParam1,iParam2,iParam3];
    return [self WriteOutputStream:_CmdStr];
    //return SUCCESS;
}
//
-(int)SetMagneticMode:(int)mode{
    [self PlayBandDebugLog:[NSString stringWithFormat:@"SetMagneticMode:%d", mode]];
    
    /*
     if (SocketStatus != SOCKET_CONNECTED) {
     return ERR_NOT_CONNECTED;
     }
     */
    
    //[MotionManager stopAccelerometerUpdates];
    //[MotionManager stopGyroUpdates];
    /*
     if (MotionManager.magnetometerActive){
     [MotionManager stopMagnetometerUpdates];
     }
     if (MotionManager.deviceMotionActive){
     [MotionManager stopDeviceMotionUpdates];
     }
     //[MotionManager release];
     //MotionManager=nil;
     */
    
    //self.localManager = [[CLLocationManager alloc] init];
    //localManager.delegate = self;
    
    
    /*
     if (MotionManager.magnetometerActive){
     [MotionManager stopMagnetometerUpdates];
     }
     
     if (MotionManager.magnetometerAvailable)
     [MotionManager
     startMagnetometerUpdatesToQueue:[NSOperationQueue currentQueue]
     withHandler: ^(CMMagnetometerData *magData, NSError *error) {
     // magData.magneticField.x;
     // magData.magneticField.y;
     //  magData.magneticField.z;
     NSLog(@"CMMagnetometerData: x=%f,y=%f,z=%f",magData.magneticField.x,magData.magneticField.y,magData.magneticField.z);
     //NSLog(@"CMMagnetometerData:");
     }];
     */
    
    /*
     if (MotionManager.deviceMotionActive){
     [MotionManager stopDeviceMotionUpdates];
     }
     //MotionManager=[[CMMotionManager alloc]init];
     NSLog(@"magnetometerActive=%d", MotionManager.magnetometerActive);
     if (MotionManager.deviceMotionAvailable)
     [MotionManager
     startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
     withHandler: ^(CMDeviceMotion *motion, NSError *error) {
     //motion.attitude.pitch;
     //motion.attitude.roll;
     //motion.attitude.yaw;
     NSLog(@"CMDeviceMotion: pitch=%f,roll=%f,yaw=%f",motion.attitude.pitch,motion.attitude.roll,motion.attitude.yaw);
     // NSLog(@"deviceMotionActive=%d", MotionManager.deviceMotionActive);
     }];
     */
    MagneticMode = mode;
    
    // NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    
    
    if(mode==MAGNETIC_MODE){
        
        [MotionManager stopDeviceMotionUpdates];
        //[MotionManager stopGyroUpdates];
        
        
        if([CLLocationManager headingAvailable]){
            [LocalManager startUpdatingHeading];
        }
        
    }else if(mode==	GYRO_MODE){
        [LocalManager stopUpdatingHeading];
        [self FixedEulerZ];
        /*
         if (MotionManager.gyroAvailable){
         CMGyroHandler handler = ^(CMGyroData *gyroData, NSError *error) {
         NSLog(@"CMDeviceMotion: pitch=%f,roll=%f,yaw=%f",gyroData.rotationRate.x*DIVDE_180_PI,gyroData.rotationRate.y*DIVDE_180_PI,gyroData.rotationRate.z*DIVDE_180_PI);
         //DeviceGameRotZ=gyroData.rotationRate.y;
         // NSLog(@"CMDeviceMotion: roll=%f",DeviceGameRotZ);
         };
         
         [MotionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
         }
         */
        
        
        if (MotionManager.deviceMotionAvailable){
            CMDeviceMotionHandler handler = ^(CMDeviceMotion *motion, NSError *error) {
                // NSLog(@"CMDeviceMotion: pitch=%f,roll=%f,yaw=%f",motion.attitude.pitch*DIVDE_180_PI,motion.attitude.roll*DIVDE_180_PI,motion.attitude.yaw*DIVDE_180_PI);
                // DeviceGameRotZ=360-(motion.attitude.roll*DIVDE_180_PI);
                
                DeviceGameRotZ=atan2(2 * (motion.attitude.quaternion.w * motion.attitude.quaternion.z + motion.attitude.quaternion.x * motion.attitude.quaternion.y),1 - 2 * (motion.attitude.quaternion.y * motion.attitude.quaternion.y + motion.attitude.quaternion.z * motion.attitude.quaternion.z )) *  DIVDE_180_PI_N;
                
                //NSLog(@"CMDeviceMotion: roll=%f",DeviceGameRotZ);
                DeviceGameRotZ-=BandFixedRotZ;
                
                
            };
            [MotionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
        }
        //
        
    }else if(mode==	NO_MOVE_MODE){
        [MotionManager stopDeviceMotionUpdates];
        //[MotionManager stopGyroUpdates];
        [LocalManager stopUpdatingHeading];
        [self FixedEulerZ];
    }
    
    //[self DoVibrate:2 Strong:100 OnPeriod:100 OffPeriod:100];
    return SUCCESS;
}

//
-(void)FixedEulerZ {
    DeviceGameRotZ = 0;
    BandFixedRotZ =360-Global_euler[2];
    
    return;
}

//
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [self PlayBandDebugLog:[NSString stringWithFormat:@"didUpdateHeading: %f",newHeading.trueHeading]];
    DeviceGameRotZ=newHeading.trueHeading;
}

//================================
//
//================================
-(void)SendToUnity:(const char *)methodName Status:(NSString*)status {
    [self PlayBandDebugLog:[NSString stringWithFormat:@"SendToUnity %@:%@",[NSString stringWithUTF8String:methodName],status]];
    //#F
    //UnitySendMessage(UNITY_CLASS, methodName, [status UTF8String]);
}

//================================
//
//================================
-(void)ShowErrorAlert:(NSString*)message{
    if( IS_UI_ALERT_CONTROLLER_CAN_NOT_USE )
    {
        if( mUIAlertView == nil )
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:mFailedToConnectString
                                                            message:mFailedToConnectMessageString
                                                           delegate:self cancelButtonTitle:mCancelString
                                                                        otherButtonTitles:mRetryString, nil];
            alertView.tag = UI_ALERT_VIEW_SHOW_ERROR_ALERT;
            mUIAlertView = alertView;
            [alertView show];
        }
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:mFailedToConnectString message:mFailedToConnectMessageString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:mCancelString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            return;
        }];
        [alertController addAction:cancelAction];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:mRetryString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            SocketStatus = SOCKET_DISCONNECTED;
            [self Reconnect];
        }];
        [alertController addAction:okAction];
        [getRootViewController presentViewController:alertController animated:YES completion:nil];
    }
}


-(void)ShowDevicesList:(NSString*)targetDevice{
    [self PlayBandDebugLog:[NSString stringWithFormat:@"targetDevice:%@",targetDevice]];
    
    if(peripheralDict.count==0){
        [self ShowNoDeviceAlert];
        SocketStatus=SOCKET_DISCONNECTED;
        return;
    }
    else if (peripheralDict.count == 1)
    {
        for (id key in peripheralDict) {
            NSString* deviceName=[NSString stringWithFormat:@"%@",key];
            
            selectDevice=[deviceName copy];
            [self ConnectTo];
        }
        
    }
    else
    {
        
        if( IS_UI_ALERT_CONTROLLER_CAN_NOT_USE )
        {
            NSLog(@"Use UIAlertView!!!!!!");
            NSLog(@"UI_ALERT_VIEW_SHOW_DEVICE_LIST");
            if( mUIAlertView == nil )
                {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:mBraceletListString
                                                                message:mSeletDeviceString
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:nil];
                alertView.tag = UI_ALERT_VIEW_SHOW_DEVICE_LIST;
                for (id key in peripheralDict) {
                    NSString* deviceName=[NSString stringWithFormat:@"%@",key];
                    if([deviceName isEqualToString:targetDevice])
                    {
                        [self PlayBandDebugLog:[NSString stringWithFormat:@"Unity Select:%@",targetDevice]];
                        selectDevice=[deviceName copy];
                        [self ConnectTo];
                        return;
                    }
                    [alertView addButtonWithTitle:deviceName];
                }
                [alertView addButtonWithTitle:mRefreshString];
                mUIAlertView = alertView;
                [alertView show];
            }
        }
        else
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:mBraceletListString message:mSeletDeviceString preferredStyle:UIAlertControllerStyleAlert];
            for (id key in peripheralDict) {
                NSString* deviceName=[NSString stringWithFormat:@"%@",key];
                if([deviceName isEqualToString:targetDevice])
                {
                    [self PlayBandDebugLog:[NSString stringWithFormat:@"Unity Select:%@",targetDevice]];
                    selectDevice=[deviceName copy];
                    [self ConnectTo];
                    return;
                }
                
                UIAlertAction *buttonAction = [UIAlertAction actionWithTitle:deviceName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self PlayBandDebugLog:[NSString stringWithFormat:@"User Select:%@",deviceName]];
                    selectDevice=[deviceName copy];
                    [self ConnectTo];
                    
                }];
                [alertController addAction:buttonAction];
            }
            
            UIAlertAction *refreshAction = [UIAlertAction actionWithTitle:mRefreshString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                SocketStatus = SOCKET_DISCONNECTED;
                [self Reconnect];
            }];
            [alertController addAction:refreshAction];
            [getRootViewController presentViewController:alertController animated:YES completion:nil];
        }
    }
}

-(void)ScanPeripheralAgain
{
    if(centralManager)
    {
        [centralManager scanForPeripheralsWithServices:nil options:nil];
        [self performSelector:@selector(ShowDevicesList:) withObject:savedDevice afterDelay:1];
    }
}

-(void)ShowNoDeviceAlert{
    if(noDeviceFoundCounting < 5)
    {
        noDeviceFoundCounting += 1;
        [self performSelector:@selector(ScanPeripheralAgain) withObject:nil afterDelay:1];
        return;
    }
    noDeviceFoundCounting = 0;
    if( IS_UI_ALERT_CONTROLLER_CAN_NOT_USE )
    {
        NSLog(@"UI_ALERT_VIEW_SHOW_NO_DEVICE");
        if( mUIAlertView == nil )
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:mReminderString
                                                            message:mNoDeviceFoundString
                                                           delegate:self
                                                  cancelButtonTitle:mCancelString
                                                  otherButtonTitles:mRetryString,nil];
            alertView.tag = UI_ALERT_VIEW_SHOW_NO_DEVICE;
            mUIAlertView = alertView;
            [alertView show];
        }
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:mReminderString message:mNoDeviceFoundString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:mCancelString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //send a API message to Unity, User cancel Bluetooth connecting process
            NSString *res=[NSString stringWithFormat:@"%d,%@",STATUS_CONNECT_NO_BRACELET, mCONNECT_ERROR_STRING_NoBracelet];
            [self SendToUnity:UNITY_RESULT_CONNECT Status:res];
            return;
        }];
        [alertController addAction:cancelAction];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:mRetryString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            SocketStatus = SOCKET_DISCONNECTED;
            [self Reconnect];
        }];
        [alertController addAction:okAction];
        
        [getRootViewController presentViewController:alertController animated:YES completion:nil];
    }
}

//Add by BlackSmith Jack, 20150717
-(void)OpenBluetoothPower
{
    if( IS_UI_ALERT_CONTROLLER_CAN_NOT_USE )
    {
        NSLog(@"Use UIAlertView!!!!!!");
        if( mUIAlertView == nil )
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:mReminderString
                                                            message:mBluetoothOffMessageString
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:mConfirmString,nil];
            alertView.tag = UI_ALERT_VIEW_OPEN_BLE_POWER;
            mUIAlertView = alertView;
            [alertView show];
        }
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self->mReminderString message:self->mBluetoothOffMessageString preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:self->mConfirmString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if( IS_OS_8_OR_LATER )
            {
                //go to setting page
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
            else
            {
                //send API message to Unity, Bluetooth is Off
                NSString *res=[NSString stringWithFormat:@"%d,%@",STATUS_CONNECT_BLUETOOTH_OFF, mCONNECT_ERROR_STRING_BluetoothOFF];
                [self SendToUnity:UNITY_RESULT_CONNECT Status:res];
                return;
            }
        }];
        [alertController addAction:okAction];
        [getRootViewController presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)ConnectPeripheralTimeOut:(CBPeripheral*)peripheral
{
    [self PlayBandDebugLog:[NSString stringWithFormat:@"Connect Peripheral TimeOut!! Status: %d", SocketStatus]];
    if( SocketStatus == SOCKET_CONNECTING )
    {
        if (peripheral != nil){
            [centralManager cancelPeripheralConnection: peripheral];
            if( selectDevice != nil )
                [peripheralDict removeObjectForKey:selectDevice];
            selectDevice = @"";
            [peripheralDict removeAllObjects];
            if( mUIAlertView == nil )
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:mFailedToConnectString
                                                                message:mFailedToConnectMessageString
                                                               delegate:self
                                                      cancelButtonTitle:mCancelString
                                                      otherButtonTitles:mRetryString, nil];
                alertView.tag = UI_ALERT_VIEW_SHOW_ERROR_ALERT;
                mUIAlertView = alertView;
                [alertView show];
            }
        }
    }
}

-(void)PlayBandDebugLog:(NSString*)logMessage
{
    if(BeDebugMode)
    {
        NSLog(@"%@",logMessage);
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == UI_ALERT_VIEW_SHOW_ERROR_ALERT)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:mCancelString])
        {
            NSString *res=[NSString stringWithFormat:@"%d,%@",STATUS_CONNECT_FAILED, mFailedToConnectMessageString];
            [self SendToUnity:UNITY_RESULT_CONNECT Status:res];
            [alertView dismissWithClickedButtonIndex:-1 animated:NO];
            mUIAlertView = nil;
        }
        else if([title isEqualToString:mRetryString])
        {
            SocketStatus = SOCKET_DISCONNECTED;
            [alertView dismissWithClickedButtonIndex:-1 animated:NO];
            mUIAlertView = nil;
            [self Reconnect];
        }
    }
    else if (alertView.tag == UI_ALERT_VIEW_SHOW_DEVICE_LIST)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:mRefreshString])
        {
            [peripheralDict removeAllObjects];
            SocketStatus = SOCKET_DISCONNECTED;
            [alertView dismissWithClickedButtonIndex:-1 animated:NO];
            mUIAlertView = nil;
            [self Reconnect];
        }
        else
        {
            [self PlayBandDebugLog:[NSString stringWithFormat:@"User Select:%@",title]];
            selectDevice=[title copy];
            [self PlayBandDebugLog:[NSString stringWithFormat:@"SelectDevice:%@",selectDevice]];
            [alertView dismissWithClickedButtonIndex:-1 animated:NO];
            mUIAlertView = nil;
            [self ConnectTo];
        }
        
    }
    else if (alertView.tag == UI_ALERT_VIEW_SHOW_NO_DEVICE)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:mCancelString])
        {
            //send a API message to Unity, User cancel Bluetooth connecting process
            NSString *res=[NSString stringWithFormat:@"%d,%@",STATUS_CONNECT_NO_BRACELET, mCONNECT_ERROR_STRING_NoBracelet];
            [self SendToUnity:UNITY_RESULT_CONNECT Status:res];
            [alertView dismissWithClickedButtonIndex:-1 animated:NO];
            mUIAlertView = nil;
        }
        else if([title isEqualToString:mRetryString])
        {
            SocketStatus = SOCKET_DISCONNECTED;
            [alertView dismissWithClickedButtonIndex:-1 animated:NO];
            mUIAlertView = nil;
            [self Reconnect];
        }
    }
    else if (alertView.tag == UI_ALERT_VIEW_OPEN_BLE_POWER)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:mConfirmString])
        {
            if( IS_OS_8_OR_LATER )
            {
                //go to setting page
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                [alertView dismissWithClickedButtonIndex:-1 animated:NO];
                mUIAlertView = nil;
            }
            else
            {
                //send API message to Unity, Bluetooth is Off
                NSString *res=[NSString stringWithFormat:@"%d,%@",STATUS_CONNECT_BLUETOOTH_OFF, mCONNECT_ERROR_STRING_BluetoothOFF];
                [self SendToUnity:UNITY_RESULT_CONNECT Status:res];
                [alertView dismissWithClickedButtonIndex:-1 animated:NO];
                mUIAlertView = nil;
            }
        }
    }
    
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    NSLog(@"AlertView cancel!!");
     mUIAlertView = nil;
}


@end
