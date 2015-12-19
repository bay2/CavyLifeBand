//
//  AppDelegate.h
//  CavyLifeBand
//
//  Created by blacksmith on 2015/9/25.
//  Copyright (c) 2015年 blacksmith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CoreTelephony/CTCallCenter.h"
#import "CoreTelephony/CTCall.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) CTCallCenter *callCenter;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (UIViewController*)getDisplayViewController;
+ (void)setDisplayViewController:(UIViewController*)controller;
@end

