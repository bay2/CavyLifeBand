//
//  WalkingView.h
//  CavyLifeBand
//
//  Created by xuemincai on 15/12/12.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPAbstractView.h"
#import "WalkManger.h"
@import HealthKit;

@interface WalkingView : SHPAbstractView

@property (strong, nonatomic) UILabel *todayLab;
@property (strong, nonatomic) UILabel *sevenDayLab;
@property (strong, nonatomic) UIImage *styleImg;
@property (strong, nonatomic) UIView  *chartView;
@property (strong, nonatomic) UIView  *statView;
@property (strong, nonatomic) UILabel *everyDayLab;
@property (strong, nonatomic) UILabel *distanceLab;
@property (strong, nonatomic) UILabel *activeLab;
@property (strong, nonatomic) UILabel *everyDayValueLab;
@property (strong, nonatomic) UILabel *distanceValueLab;
@property (strong, nonatomic) UILabel *activeValueLab;
@property (strong, nonatomic) UILabel *everyDayCountLab;
@property (strong, nonatomic) UILabel *dateLab;
@property (strong, nonatomic) UIImageView *sampleImg;
@property (copy, nonatomic) NSMutableArray *weekLab;
@property (copy, nonatomic) NSMutableArray *dayLabs;
@property (copy, nonatomic) NSMutableArray *sevenDayDate;
@property (copy, nonatomic) NSMutableArray *scaleImgs;
@property (strong, nonatomic) UIView         *scaleLineView;
@property (copy, nonatomic) NSMutableArray *lineViews;
@property (copy, nonatomic) NSMutableArray *barChartImgView;
@property (copy, nonatomic) NSMutableArray *barChartMaskView;
@property (copy, nonatomic) NSMutableArray *sevenDayStepLab;
@property (copy, nonatomic) NSMutableDictionary *sevenDayStepValue;
@property (strong, nonatomic) UIView         *mainView;
#define WeekLabWidth 32
#define DayTimeInterval (24*60*60)

@end
