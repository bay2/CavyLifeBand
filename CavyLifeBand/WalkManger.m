//
//  WalkManger.m
//  CavyLifeBand
//
//  Created by xuemincai on 15/12/16.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import "WalkManger.h"
@import HealthKit;

@interface WalkManger()
//@property (nonatomic) HKHealthStore *healthStore;
@end

@implementation WalkManger

static HKHealthStore *healthStore;

/**
 *  查询今日步数
 *
 *  @param complete 回调
 */
+(void)queryTodayStepCount:(void(^)(double stepCount, BOOL succeed)) complete {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *now =[NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:now];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate   = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:now options:0];
    
    [self queryStepCount:startDate endDate:endDate complete:^(double stepCount, BOOL succeed) {
        
        complete(stepCount, succeed);
        
    }];
    
    
}

/**
 *  查询一天的时间
 *
 *  @param queryDate 查询的时间
 *  @param complete  回调
 */
+(void)queryOneDayStepCount:(NSDate *)queryDate tag:(NSInteger) tag complete: (void (^)(double stepCount, NSInteger tag, BOOL succeed))complete {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:queryDate];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    [self queryStepCount:startDate endDate:endDate complete:^(double stepCount, BOOL succeed) {
        complete(stepCount, tag, succeed);
    }];
    
}

/**
 *  查询步数
 *
 *  @param startDate 开始时间
 *  @param endDate   结束时间
 *  @param complete  回调
 */
+(void)queryStepCount:(NSDate *)startDate endDate:(NSDate *)endDate complete: (void (^)(double stepCount, BOOL succeed))complete {
    
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        if (!results) {
            complete(0, NO);
            return;
        }
        
        double stepCount = 0;
        
        for(HKQuantitySample *stepSample in results) {
            
            HKQuantity *step = [stepSample quantity];
            stepCount += [step doubleValueForUnit:[HKUnit countUnit]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(stepCount, YES);
        });
        
    }];
    
//    [self.healthStore executeQuery:query];
    [healthStore executeQuery:query];
}

/**
 *  查询近7天的平均步数
 *
 *  @param complete 回调
 */
+(void)querySevenDayAvgStepCount:(void(^)(double stepCount, BOOL succeed))complete {
    
    NSDate *sevenDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-(24 * 60 * 60 * 7)];
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:sevenDate];
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate   = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:nowDate options:0];
    
    [self queryStepCount:startDate endDate:endDate complete:^(double stepCount, BOOL succeed) {
        double avgStep = stepCount / 7;
        complete(avgStep, succeed);
    }];
}

/**
 *  查询距离
 *
 *  @param startDate 开始时间
 *  @param endDate   结束时间
 *  @param complete  回调
 */
+(void)queryDistance:(NSDate *)startDate endDate:(NSDate *)endDate complete: (void (^)(double distance, BOOL succeed))complete {
    
    HKQuantityType *walkDistance = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:walkDistance predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        if (!results) {
            complete(0, NO);
            return;
        }
        
        double distance = 0;
        
        for (HKQuantitySample *distanceSample in results) {
            
            HKQuantity *distanceQue =[distanceSample quantity];
            
            distance += [distanceQue doubleValueForUnit:[HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo]];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(distance, YES);
        });
        
    }];
    
//    [self.healthStore executeQuery:query];
    
    [healthStore executeQuery:query];
    
    
}

/**
 *  查询活跃时间
 *
 *  @param startDate 开始时间
 *  @param endDate   结束时间
 *  @param complete  回调
 */
+(void)queryActiveTime:(NSDate *)startDate endDate:(NSDate *)endDate complete:(void (^)(double min, BOOL succeed))complete {
    
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        if (!results) {
            complete(0, NO);
            return;
        }
        
        NSTimeInterval totalDate = 0;
        
        for(HKQuantitySample *stepSample in results) {
            
            totalDate += [[stepSample endDate] timeIntervalSinceDate:[stepSample startDate]];
        }
        
        totalDate = totalDate / 60;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(totalDate, YES);
        });
        
    }];
    
//    [self.healthStore executeQuery:query];
    [healthStore executeQuery:query];
    
}

/**
 *  查询近7天的活跃时间
 *
 *  @param complete 回调
 */
+(void)querySevenDayActive:(void (^)(double min, BOOL succeed))complete {
    
    
    NSDate *sevenDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-(24 * 60 * 60 * 7)];
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:sevenDate];
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate   = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:nowDate options:0];
    
    [self queryActiveTime:startDate endDate:endDate complete:^(double min, BOOL succeed) {
        complete(min, succeed);
    }];
    
}

/**
 *  查询7天总距离
 *
 *  @param complete 回调
 */
+(void)querySevenDayDistance:(void (^)(double distance, BOOL succeed))complete {
    
    
    NSDate *sevenDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-(24 * 60 * 60 * 7)];
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:sevenDate];
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate   = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:nowDate options:0];
    
    [self queryDistance:startDate endDate:endDate complete:^(double distance, BOOL succeed) {
        complete(distance, succeed);
    }];
    
}

/**
 *  设置HealthStore
 *
 *  @param health HKHealthStore
 */
+(void)setHealthStore:(HKHealthStore *) health {
    
    healthStore = health;
    
}


@end
