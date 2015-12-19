//
//  ViewController.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/9/25.
//  Copyright (c) 2015年 blacksmith. All rights reserved.
//
#include "CavyLifeBandDefined.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "LifeBandBLE.h"
#import "LifeBandSettingTable.h"
#import "CustomCameraPhoto.h"
#import "CustomBandCell.h"
#import <QuartzCore/CADisplayLink.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CustomPopupDialogControllerViewController.h"
#import "EDColor.h"
#import "WalkingViewController.h"
#import "WalkManger.h"
@import HealthKit;

@interface ViewController ()
{
    NSMutableArray *_peripheralList;
    CustomPopupDialogControllerViewController * popupDialog;
    int SearchImageSpinCount;
}
@property (strong) NSThread *spinAnimationThread;
@property (weak) NSTimer* myTimer;
@property (weak) NSTimer* rssiTimer;
@property (weak) NSTimer* batteryTimer;
@property (strong) LifeBandBLE *lifeBand;
@property (strong) NSMutableArray *tableCellList;
@property (strong) NSMutableArray *pairedBand;
@property (nonatomic) HKHealthStore *healthStore;
@end

@implementation ViewController
-(NSMutableArray*)peripheralList
{
    if(_peripheralList == nil)
        _peripheralList = [[NSMutableArray alloc] init];
    return _peripheralList;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.ImageToMove setTransform:CGAffineTransformIdentity];
    SearchImageSpinCount = 0;
    // Do any additional setup after loading the view, typically from a nib.
    UITapGestureRecognizer *tapSearchImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToSearch)];
    [self.SearchImage addGestureRecognizer:tapSearchImage];
    _lifeBand = [[LifeBandBLE alloc] init];
    _lifeBand.parentTableView = self.TableView;
    if(self.pairedBand == nil)
    {
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:CAVYLIFEBAND_DbName];
        self.pairedBand = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    }
    self.SearchLabel.text = MyLocalizeString(Localization_SearchingDevices);
    self.TableView.separatorInset = UIEdgeInsetsMake(0,20, 0, 20);
    self.TableView.rowHeight = 88;
    [self RequestDate];

    self.SearchImage.pressButton = self.searchPresshighlightButton;
    [self createBarItem];
    //[self performSelector:@selector(tapToSearch) withObject:nil afterDelay:1.0f];
    
    [WalkManger setHealthStore:self.healthStore];
    
    [self tapToSearch];
}

- (void)createBarItem {
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer setWidth:-2];
    
    UIBarButtonItem *negativeSpacer30 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer30 setWidth:30];
    
    //创建设置按钮
    UIButton *setBtn = [[UIButton alloc] init];
    setBtn.frame = CGRectMake(0, 0, 29, 29);
    [setBtn setBackgroundImage:[UIImage imageNamed:@"site"] forState:UIControlStateNormal];
    [setBtn addTarget:self action:@selector(showSetView:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *setBtnItem = [[UIBarButtonItem alloc] initWithCustomView:setBtn];
    
    //创建计步按钮
    UIButton *walkBtn = [[UIButton alloc] init];
    walkBtn.frame = CGRectMake(0, 0, 29, 29);
    [walkBtn setBackgroundImage:[UIImage imageNamed:@"walking"] forState:UIControlStateNormal];
    UIBarButtonItem *walkBtnItem = [[UIBarButtonItem alloc] initWithCustomView: walkBtn];
    [walkBtn addTarget:self action:@selector(showWalking:) forControlEvents:UIControlEventTouchUpInside];
    
    //创建标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 33)];
    
    [titleLabel setText:MyLocalizeString(Localization_CavyBand)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    
    UIBarButtonItem *titleBtnItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    
    //创建相机按钮
    UIButton *cameraBtn = [[UIButton alloc] init];
    [cameraBtn setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    cameraBtn.frame = CGRectMake(0, 0, 29, 29);
    UIBarButtonItem *cameraBarItem = [[UIBarButtonItem alloc] initWithCustomView:cameraBtn];
    [cameraBtn addTarget:self action:@selector(showCameraPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, titleBtnItem, nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, setBtnItem,  negativeSpacer30, walkBtnItem, negativeSpacer30, cameraBarItem, nil];
}


- (void) showSetView: (id)sender {
    
    UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LifeBandSettingTable *setTableView = [mainStory instantiateViewControllerWithIdentifier:@"LifeBandSettingTable"];
    
    UINavigationController *navSetTableView = [[UINavigationController alloc] initWithRootViewController:setTableView];
    
    [self presentViewController:navSetTableView animated:YES completion:nil];

}

- (void) showCameraPhoto: (id)sender {
    
    UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustomCameraPhoto *camerView = [mainStory instantiateViewControllerWithIdentifier:@"CustomCameraPhoto"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:camerView];
    
    [self presentViewController:nav animated:YES completion:nil];
    
    
}

- (void) showWalking: (id)sender {
    
    WalkingViewController *walkingView = [[WalkingViewController alloc] init];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController: walkingView];
    
    [nav.navigationBar setTranslucent:NO];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)dealloc
{
    // be careful in this method! can't access properties! almost gone from heap
    // unregister notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.TableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.TableView.separatorColor = [UIColor clearColor];
    [self.TableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.searchPresshighlightButton.layer.masksToBounds = YES;
    self.searchPresshighlightButton.layer.cornerRadius = self.searchPresshighlightButton.frame.size.width / 2;
    [self.TableView  setLayoutMargins:UIEdgeInsetsZero];
    [self.TableView setSeparatorInset:UIEdgeInsetsZero];
    [AppDelegate setDisplayViewController:(UIViewController*)self];
    //    if( [self.ImageToMove.transform ] )    //[self searchButtonClick:nil];
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *readDataTypes =  [self dateTypesToRead];
        NSSet *writeDataTypes = [self dateTypesToWrite];
        
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"HealthStore success");
            }
        }];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.lifeBand StopScaning];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([self.TableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.TableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.TableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.TableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SavePairedPerepheral:)
                                                 name:@"BLE CONNECT SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(RequestDate)
                                                 name:@"RequestDatePerSec Change" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getDiscoverPeripheral)
                                                 name:(NSString*)NotificationKey_FoundNewBand object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DisconnectAction:)
                                                 name:(NSString*)NotificationKey_CancelConnecting object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableCell)
                                                 name:@"BLE OnCalibreated!!" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closePopupDialog)
                                                 name:@"BLE OnCalibreated!!" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterForegrounf:)
                                                 name:@"applicationDidBecomeActive" object:nil];
}

-(void) didEnterForegrounf:(NSNotification*)notification
{
    [self.ImageToMove setTransform:CGAffineTransformIdentity];
}

-(void)closePopupDialog
{
    if(popupDialog)
    {
        [popupDialog closePopup];
        popupDialog = nil;
    }
}

-(void)reloadTableCell
{
    [self.TableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//when user touch the search icon, do BLE scanPeripherals and run the search icon aniamtion
//edit by Jack in BlackSmith on 2015/10/16
-(void)tapToSearch
{
    if( ![self.lifeBand StartScaning] )
    {
        return;
    }
    self.SearchLabel.text = MyLocalizeString(Localization_SearchingDevices);
    [self spinWithOutOptions];
    [self.SearchImage setCanHighlight:false];
}

//search icon rotate animation
//edit by Jack in BlackSmith on 2015/10/16
- (void)spinWithOutOptions{
    if(SearchImageSpinCount == 0)
    {
        [self.ImageToMove setTransform:CGAffineTransformIdentity];
    }
    SearchImageSpinCount++;
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         self.ImageToMove.transform = CGAffineTransformRotate(self.ImageToMove.transform, M_PI);
                     }
                     completion: ^(BOOL finished){
                         if (finished && SearchImageSpinCount < (8.0f / 0.5f)) {
                             [self spinWithOutOptions];
                         }
                         else
                         {
                             [self.lifeBand StopScaning];
                             self.SearchLabel.text = MyLocalizeString(Localization_ClickToSearchDevices);
                             SearchImageSpinCount = 0;
                             [self.ImageToMove setTransform:CGAffineTransformIdentity];
                             [self.SearchImage setCanHighlight:true];
                         }
                     }
     ];
    
}

//when found peripheral, add new peripheral data to UITableView
//edit by Jack in BlackSmith on 2015/10/16
-(void)getDiscoverPeripheral
{
    //NSLog(@"Name");
    NSMutableArray *temp = self.lifeBand.GetScanPeripheralList;
    if(temp.count == 0)
    {
        NSLog(@"No Band Found!!");
    }
    else
    {
        for(int i = 0; i < temp.count; i++)
        {
            if( [self.peripheralList indexOfObject:[temp objectAtIndex:i]] == NSNotFound )
            {
                CBPeripheral *p = [temp objectAtIndex:i];
                [self.peripheralList addObject:p];
                [self.TableView beginUpdates];
                [self.TableView insertRowsAtIndexPaths:[NSArray arrayWithObject: [NSIndexPath indexPathForRow:[self.peripheralList count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                [self.TableView endUpdates];
                //NSLog(@"Name : %@, UUID : %@", p.name, p.identifier.UUIDString);
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.peripheralList count];//[tableData count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    // Configure the cell...
    CustomBandCell *cell = (CustomBandCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    CBPeripheral *device = [self.peripheralList objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[CustomBandCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.peripheralName.text = device.name;
    cell.calibrateButton.tag = indexPath.row;
    cell.connectButton.tag = indexPath.row;
    if(indexPath.row == 0)
        cell.separatorTopLine.hidden = YES;
    //CGRect frame = cell.speratorLine.frame;
    //frame.size.height = 1.0f;
    //[cell.speratorLine setFrame:frame];
    //NSLog(@"Line high: %f", cell.speratorLine.alpha );
    //button hidden or show
    if(device.state == CBPeripheralStateDisconnected)
    {
        cell.connectButton.hidden = NO;
        cell.disconnectButton.hidden = YES;
        cell.calibrateButton.hidden = YES;
    }
    else if(device.state == CBPeripheralStateConnected)
    {
        cell.disconnectButton.hidden = NO;
        cell.connectButton.hidden = YES;
        //if(!self.lifeBand.isCalibreating && self.lifeBand.canDoCalibreate)
        //{
        //    cell.calibrateButton.hidden = NO;
        //}
        //else
        //{
        //    cell.calibrateButton.hidden = YES;
        //}
    }
    else
    {
        cell.disconnectButton.hidden = YES;
        cell.connectButton.hidden = NO;
        cell.calibrateButton.hidden = YES;
    }
    
    NSAttributedString *attributedTitle = [cell.connectButton attributedTitleForState:UIControlStateNormal];
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithAttributedString:attributedTitle];
    [mas.mutableString setString:MyLocalizeString(Localization_Connect)];
    [mas addAttribute:NSForegroundColorAttributeName value:[CustomBandCell colorFromHexString:@"#3e76db"]  range:NSMakeRange(0, [MyLocalizeString(Localization_Connect) length])];
    [cell.connectButton setAttributedTitle:mas forState:UIControlStateNormal];
    mas = nil;
    
    attributedTitle = [cell.disconnectButton attributedTitleForState:UIControlStateNormal];
    mas = [[NSMutableAttributedString alloc] initWithAttributedString:attributedTitle];
    [mas.mutableString setString:MyLocalizeString(Localization_Disconnect)];
    [cell.disconnectButton setAttributedTitle:mas forState:UIControlStateNormal];
    mas = nil;
    
    [cell InitButtonStyle];
    //add action to buttons
    [cell.calibrateButton addTarget:self action:@selector(DoCalibreate:) forControlEvents:UIControlEventTouchUpInside];
    [cell.connectButton addTarget:self action:@selector(ConnectAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.disconnectButton addTarget:self action:@selector(DisconnectAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

//modify the UITableView's session header height to be 0, if only have one session
//edit by Jack in BlackSmith on 2015/10/16
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return CGFLOAT_MIN;
    return tableView.sectionHeaderHeight;
}

//connect to peripheral(Band), and show animation
//edit by Jack in BlackSmith on 2015/10/16
-(void)ConnectAction:(UIButton*)sender
{
    [self.lifeBand SetReconnectEnable:false];
    CBPeripheral *temp  = [self.peripheralList objectAtIndex:sender.tag];
    [self.lifeBand Connect:temp];
    //[popupDialog setTitle:@"This is Dialog!!"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    popupDialog = (CustomPopupDialogControllerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CustomPopupDailog"];
    [popupDialog setMessageText:MyLocalizeString(Localization_BandConnecting) ];
    popupDialog.isConnection = YES;
    [self.view addSubview:popupDialog.view];
    [self.TableView reloadData];
}

//do calibreation of connected peripheral(Band)
//edit by Jack in BlackSmith on 2015/10/16
-(void)DoCalibreate:(UIButton*)sender
{
    [self.lifeBand doCalibrate];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    popupDialog = (CustomPopupDialogControllerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CustomPopupDailog"];
    [popupDialog setMessageText:@"請畫8字形" ];
    [self.view addSubview:popupDialog.view];
}

//disconnect to connected or connecting peripheral(Band), and cancel the connecting animation
//edit by Jack in BlackSmith on 2015/10/16
-(void)DisconnectAction:(UIButton*)sender
{
    if(popupDialog)
    {
        [popupDialog closePopup];
        popupDialog = nil;
    }
    [self.lifeBand Disconnect];
    [self.TableView reloadData];
}

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

//save that has been connected peripheral(Band) in Core Data, it's no mean Now.
//edit by Jack in BlackSmith on 2015/10/16
-(void)SavePairedPerepheral:(NSNotification*)notification
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSDictionary *info = notification.userInfo;
    CBPeripheral *temp = [info objectForKey:CAVYLIFEBAND_lastConnectBand];
    NSManagedObject *newDevice = [self SearchPairedPeripheral:temp];
    if(newDevice == nil)
    {
        newDevice = [NSEntityDescription insertNewObjectForEntityForName:CAVYLIFEBAND_DbName inManagedObjectContext:context];
        [newDevice setValue:temp.name forKey:@"name"];
        [newDevice setValue:temp.identifier.UUIDString forKey:@"uuid"];
    }
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    [self.lifeBand disconnectVibrateSwitch:nil];
    [self.pairedBand addObject:newDevice];
    if(popupDialog)
    {
        [popupDialog closePopup];
        popupDialog = nil;
    }
    [self.TableView reloadData];
}

//load that had been connected peripheral(Band) in CoreData, return peripheral object
//edit by Jack in BlackSmith on 2015/10/16
-(NSManagedObject*)SearchPairedPeripheral:(CBPeripheral *)peripheral
{
    for(int i = 0; i < self.pairedBand.count; i++)
    {
        NSManagedObject *band = [self.pairedBand objectAtIndex:i];
        if( [[band valueForKey:@"uuid"] isEqualToString:peripheral.identifier.UUIDString] )
        {
            return band;
        }
    }
    return nil;
}

//load that had been connected peripheral(Band) in CoreData, return peripheral uuid
//edit by Jack in BlackSmith on 2015/10/16
-(BOOL)IsPairedPeripheral:(NSString *)uuid
{
    for(int i = 0; i < self.pairedBand.count; i++)
    {
        NSManagedObject *band = [self.pairedBand objectAtIndex:i];
        if( [[band valueForKey:@"uuid"] isEqualToString:uuid] )
        {
            return YES;
        }
    }
    return NO;
}

//read RSSI data from connected peripheral(Band)
//edit by Jack in BlackSmith on 2015/10/16
-(void)loadRSSI:(NSTimer*)timer
{
    [self.lifeBand loadRSSIData];
}

//read battery data from connected peripheral(Band)
//edit by Jack in BlackSmith on 2015/10/16
-(void)loadBattery:(NSTimer*)timer
{
    [self.lifeBand loadBatteryData];
}

//register the Request Timer
//edit by Jack in BlackSmith on 2015/10/16
-(void)RequestDate
{
    [self UnregisterRSSITimer];
    [self RegisterRSSITimer];
}

//set Request Timer
//edit by Jack in BlackSmith on 2015/10/16
-(void)RegisterRSSITimer
{
    float time;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if( [userDefaults floatForKey:@"setting_RequestDataPerSec"] )
    {
        time = (int)[userDefaults floatForKey:@"setting_RequestDataPerSec"];
        NSLog(@"Request per Time : %f", time);
    }
    else
    {
        time = 1.0f;
    }
    time = 3.0f;
    if(!self.rssiTimer)
    {
        self.rssiTimer = [NSTimer scheduledTimerWithTimeInterval: time target:self selector: @selector(loadRSSI:) userInfo: nil repeats: YES];
    }
    if(!self.batteryTimer)
    {
        self.batteryTimer = [NSTimer scheduledTimerWithTimeInterval: time target:self selector: @selector(loadBattery:) userInfo: nil repeats: YES];
    }
}

//unregister Request Timer
//edit by Jack in BlackSmith on 2015/10/16
-(void)UnregisterRSSITimer
{
    if(self.rssiTimer)
    {
        [self.rssiTimer invalidate];
        self.rssiTimer = nil;
    }
    if(self.batteryTimer)
    {
        [self.batteryTimer invalidate];
        self.batteryTimer = nil;
    }
}

#pragma mark -HealthKit

/**
 *  读取Health数据
 *
 *  @return <#return value description#>
 */
- (NSSet *) dateTypesToRead {
    
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    return [NSSet setWithObjects:stepType, distanceType, nil];
    
}

/**
 *  写Health数据
 *
 *  @return <#return value description#>
 */
- (NSSet *) dateTypesToWrite {
    
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    return [NSSet setWithObjects:stepType, distanceType, nil];
}

@end
