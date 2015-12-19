//
//  OnlineLog.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/11/19.
//  Copyright © 2015年 blacksmith. All rights reserved.
//
#import "OnlineLog.h"
#import <UIKit/UIKit.h>
#import <sys/sysctl.h>

NSString* deviceUUID()
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

NSString* platformRawString()
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}
NSString* platformNiceString()
{
    NSString *platform = platformRawString();
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon_iPhone4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone5";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPodTouch1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPodTouch2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPodTouch3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPodTouch4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad1";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad2(WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad2(GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad3(CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad3(WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad3(4G,2)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad3(4G,3)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([platform isEqualToString:@"iPad5,3"])          return @"iPadAir2";
    if ([platform isEqualToString:@"iPhone5,3"] ||
        [platform isEqualToString:@"iPhone5,4"])        return @"iPhone5C";
    if ([platform isEqualToString:@"iPhone6,1"] ||
        [platform isEqualToString:@"iPhone6,2"])        return @"iPhone5S";
    if ([platform isEqualToString:@"iPhone7,2"] )       return @"iPhone6";
    if ([platform isEqualToString:@"iPhone7,1"])        return @"iPhone6Plus";
    if ([platform isEqualToString:@"iPhone8,1"] )       return @"iPhone6S";
    if ([platform isEqualToString:@"iPhone8,2"])        return @"iPhone6SPlus";
    return platform;
}

NSString* onlineFailureLog(NSString* bandinfo, NSString* errorCode, NSString* errorMsg, NSString* LBS)
{
    NSString* ac = @"onlineFailureLog";
    NSString* serial = deviceUUID();
    NSString* deviceInfo = [NSString stringWithFormat:@"%@,%@,iOS%@",
                            [UIDevice currentDevice].model,
                            platformNiceString(),
                            [[UIDevice currentDevice] systemVersion] ];

    NSString* log = [NSString stringWithFormat:@"http://game.tunshu.com/common/index?ac=%@&serial=%@&devinfo=%@&bandinfo=%@&errorcode=%@&errormsg=%@&LBS=%@"
                     , ac
                     , serial
                     , deviceInfo
                     , bandinfo
                     , errorCode
                     , errorMsg
                     , LBS];
    
    return log;
}