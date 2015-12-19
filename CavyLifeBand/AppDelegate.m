//
//  AppDelegate.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/9/25.
//  Copyright (c) 2015年 blacksmith. All rights reserved.
//

#import "AppDelegate.h"
#import <AudioToolbox/AudioServices.h>
#import "CavyLifeBandDefined.h"
#import <sys/sysctl.h>
#import "EDColor.h"
#import "Classy/Classy.h"
@import HealthKit;
@interface AppDelegate ()
@property (nonatomic) HKHealthStore *healthStore;
@end

@implementation AppDelegate
static UIViewController *displayViewController;

+(UIViewController*)getDisplayViewController
{
    return displayViewController;
}

+(void)setDisplayViewController:(UIViewController*)controller
{
    displayViewController = controller;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
#if TARGET_IPHONE_SIMULATOR
    NSString *absoluteFilePath = CASAbsoluteFilePath(@"Styles/stylesheet.cas");
    [CASStyler defaultStyler].watchFilePath = absoluteFilePath;
#endif
    
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    self.healthStore =[[HKHealthStore alloc] init];
    
    [[UINavigationBar appearance] setTranslucent:NO];
    
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"#3e76db"]];
    // Override point for customization after application launch.
    // initialize defaults
    
    //load user's defaults data, if load nil then create default data for LifeBand settings
    NSString *dateKey    = @"CavyLifeBandData";
    NSDate *lastRead    = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:dateKey];
    if (lastRead == nil)     // App first run: set up user defaults.
    {
        NSDictionary *cavyLifeBandData  = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], dateKey, nil];
        
        // do any other initialization you want to do here - e.g. the starting default values.
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"setting_CbtVibrateSwitch"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"setting_LostVibrateSwitch"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"setting_ReconnectSwitch"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"setting_DisconnectAlertSoundSwitch"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"setting_DisconnectAlertVibrateSwitch"];
        [[NSUserDefaults standardUserDefaults] setFloat:1.0f forKey:@"setting_RequestDataPerSec"];
        
        // sync the defaults to disk
        [[NSUserDefaults standardUserDefaults] registerDefaults:cavyLifeBandData];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateKey];
    
    // CTCallCenter setup, it's for phone call reminder
    if (!self.callCenter)
    {
        NSLog(@"CtCall Init!!");
        self.callCenter = [[CTCallCenter alloc] init];
        [self.callCenter setCallEventHandler:^(CTCall *call)
         {
             NSLog(@"Event handler called");
             if ([call.callState isEqualToString: CTCallStateConnected])
             {
                 NSLog(@"Connected");
             }
             else if ([call.callState isEqualToString: CTCallStateDialing])
             {
                 NSLog(@"Dialing");
             }
             else if ([call.callState isEqualToString: CTCallStateDisconnected])
             {
                 NSLog(@"Disconnected");
                 
             } else if ([call.callState isEqualToString: CTCallStateIncoming])
             {
                 NSLog(@"Incomming");
                 //NSDictionary *userInfo = [NSDictionary dictionaryWithObject:_connectPeripheral forKey:CAVYLIFEBAND_lastConnectBand];
                 [[NSNotificationCenter defaultCenter] postNotificationName:CTCALLCENTER_IncomingPhoneCall object:nil userInfo:nil];
             }
         }];
    }
    
    if ([[self.window rootViewController] respondsToSelector:@selector(setHealthStore:)]) {
        id rootView = [self.window rootViewController];
        [rootView setHealthStore:self.healthStore];
    }

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidBecomeActive" object:nil userInfo:nil];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "blacksmith.CavyLifeBand" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CavyLifeBand" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CavyLifeBand.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
