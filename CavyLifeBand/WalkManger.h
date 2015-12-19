//
//  WalkManger.h
//  CavyLifeBand
//
//  Created by xuemincai on 15/12/16.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import <Foundation/Foundation.h>
@import HealthKit;

@interface WalkManger : NSObject


+(void)queryTodayStepCount:(void(^)(double stepCount, BOOL succeed)) complete;
+(void)querySevenDayAvgStepCount:(void(^)(double stepCount, BOOL succeed))complete;
+(void)querySevenDayDistance:(void (^)(double distance, BOOL succeed))complete;
+(void)setHealthStore:(HKHealthStore *) health;
+(void)querySevenDayActive:(void (^)(double min, BOOL succeed))complete;
+(void)queryOneDayStepCount:(NSDate *)queryDate tag:(NSInteger) tag complete: (void (^)(double stepCount, NSInteger tag, BOOL succeed))complete;
@end
