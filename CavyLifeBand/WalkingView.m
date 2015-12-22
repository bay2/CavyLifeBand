//
//  WalkingView.m
//  CavyLifeBand
//
//  Created by xuemincai on 15/12/12.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import "WalkingView.h"
#import "CavyLifeBand.h"
#import "Math.h"


@implementation WalkingView
{
    
}


/**
 *  创建子视图
 */
- (void)addSubviews {
    

    [self addSubview:self.mainView];
    [self.mainView addSubview:self.chartView];
    [self.mainView addSubview:self.statView];
    
    [self.chartView addSubview:self.todayLab];
    [self.chartView addSubview:self.sevenDayLab];
    [self.chartView addSubview:self.everyDayCountLab];
    [self.chartView addSubview:self.dateLab];
    [self.chartView addSubview:self.sampleImg];
    
    for (NSInteger i = 0; i < self.weekLab.count; i++) {
        
        [self.chartView addSubview:[self.weekLab objectAtIndex:i]];
        [self.chartView addSubview:[self.dayLabs objectAtIndex:i]];
        
        [self.chartView addSubview:[self.scaleImgs objectAtIndex:i]];
        
        UIView *barMaskView = [self.barChartMaskView objectAtIndex:i];
        [self.chartView addSubview:barMaskView];
        
        [barMaskView addSubview:[self.sevenDayStepLab objectAtIndex:i]];
        
        UIImageView *barImgView = [ self.barChartImgView objectAtIndex:i];
        barImgView.userInteractionEnabled = YES;
        [self.chartView addSubview:barImgView];
        [barImgView addSubview:[self.barChartMaskView objectAtIndex:i]];
        barImgView.tag = i;
        UITapGestureRecognizer *barImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBarImg:)];
        [barImgView addGestureRecognizer:barImgTap];
    }
    
    [self.chartView addSubview:self.scaleLineView];
    
    [self.statView addSubview:self.everyDayLab];
    [self.statView addSubview:self.distanceLab];
    [self.statView addSubview:self.activeLab];
    [self.statView addSubview:self.everyDayValueLab];
    [self.statView addSubview:self.distanceValueLab];
    [self.statView addSubview:self.activeValueLab];
    [self.statView addSubview:[self.lineViews objectAtIndex:0]];
    [self.statView addSubview:[self.lineViews objectAtIndex:1]];
    
    //启动刷新数值定时器
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refreshValue:) userInfo:nil repeats:YES];
    
}

/**
 *  刷新数值
 *
 *  @param timer <#timer description#>
 */
- (void)refreshValue: (NSTimer *)timer {
   
    //刷新今日步数
    [WalkManger queryTodayStepCount:^(double stepCount, BOOL succeed) {
        
        if (succeed) {
            UILabel *todayLab = [self.sevenDayStepLab objectAtIndex:6];
            [self.everyDayCountLab setText:[NSString stringWithFormat:@"%ld", (NSInteger)stepCount]];
            [todayLab setText:[NSString stringWithFormat:@"%ld", (NSInteger)stepCount]];
        }
    }];
    
    //刷新平均步数
    [WalkManger querySevenDayAvgStepCount:^(double stepCount, BOOL succeed) {
        
        if (succeed) {
            if (stepCount >= 10000) {
                [self.everyDayValueLab setText:[NSString stringWithFormat:@"%ld", (NSInteger)(stepCount / 1000)]];
            } else {
                [self.everyDayValueLab setText:[NSString stringWithFormat:@"%ld", (NSInteger)stepCount]];
            }
        }
        
    }];
    
    //刷新距离
    [WalkManger querySevenDayDistance:^(double distance, BOOL succeed) {
        if (succeed) {
            [self.distanceValueLab setText:[NSString stringWithFormat:@"%ld", (NSInteger)distance]];
            
            if (distance == 0) {
                return;
            }
            
            NSString *distanceStr =[NSString stringWithFormat:@"%f", distance];
            
            if ([distanceStr characterAtIndex:5] == '.') {
                distanceStr = [distanceStr substringToIndex:4];
            } else {
                distanceStr = [distanceStr substringToIndex:5];
            }
            
            [_distanceValueLab setText:distanceStr];
        }
    }];
    
    //刷新活跃时间
    [WalkManger querySevenDayActive:^(double min, BOOL succeed) {
        if (succeed) {
            [self.activeValueLab setText:[NSString stringWithFormat:@"%ld", (NSInteger)min]];
        }
    }];
    
}

/**
 *  点击柱状图
 *
 *  @param sender UITapGestureRecognizer
 */
-(void)tapBarImg: (UITapGestureRecognizer *)sender {
    
    UILabel *stepLab = [self.sevenDayStepLab objectAtIndex:sender.view.tag];
    
    if ([stepLab isHidden]) {
        [stepLab setHidden:NO];
    } else {
        [stepLab setHidden:YES];
    }
    
    for (NSInteger i = 0; i < 7; i++) {
        
        if (i == sender.view.tag) {
            continue;
        }
        
        [[self.sevenDayStepLab objectAtIndex:i] setHidden:YES];
    }
}

/**
 *  定义布局
 */
- (void)defineLayout {
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(@(self.mainView.cas_marginTop));
        make.bottom.equalTo(@(self.mainView.cas_marginBottom));
        make.right.equalTo(@(self.mainView.cas_marginRight));
        make.left.equalTo(@(self.mainView.cas_marginLeft));
        
    }];
    
    //定义图表背景视图布局
    [self.chartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(self.chartView.cas_marginTop));
        make.left.equalTo(@(self.chartView.cas_marginLeft));
        make.right.equalTo(@(self.chartView.cas_marginRight));
        make.bottom.equalTo(self.statView.mas_top).offset(-10);
    }];
    
    //定义统计数据背景视图布局
    [self.statView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(self.statView.cas_marginLeft));
        make.right.equalTo(@(self.statView.cas_marginRight));
        make.bottom.equalTo(@(self.statView.cas_marginBottom));
        
        make.height.equalTo(@(self.statView.cas_sizeHeight));
    }];
    
    //定义“今日步数”布局
    [self.todayLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(self.todayLab.cas_marginTop));
        make.left.equalTo(@(self.todayLab.cas_marginLeft));
    }];
    
    //定义“今天步数值“Label布局
    [self.everyDayCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.todayLab.mas_bottom).offset(5);
        make.left.equalTo(self.todayLab.mas_left);
        make.height.equalTo(@(self.everyDayCountLab.cas_sizeHeight));
        
    }];
    
    //定义“日期“Label布局
    [self.dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.everyDayCountLab.mas_bottom).offset(5);
        make.left.equalTo(self.todayLab.mas_left);
    }];
    
    //定义”最近七天“布局
    [self.sevenDayLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(self.sevenDayLab.cas_marginTop));
        make.right.equalTo(@(self.sevenDayLab.cas_marginRight));
    }];
    
    //定义样例图片布局
    [self.sampleImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(self.sampleImg.cas_marginRight));
        make.centerY.equalTo(self.sevenDayLab.mas_centerY);
    }];

    
    [self defineDayLayout];

    //定义“每天平均步数”布局
    CGFloat gap = ([UIScreen mainScreen].bounds.size.width - (self.everyDayLab.cas_sizeWidth * 3)) / 6;
    
    gap = round(gap * 10);
    gap = gap * 0.1;
    [self.everyDayLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(@(self.everyDayLab.cas_sizeWidth));
        make.top.equalTo(@(self.everyDayLab.cas_marginTop));
        make.left.equalTo(self.statView.mas_left).offset(gap);
        
    }];

    //定义统计视图分割线布局
    UIView *lineView = [self.lineViews objectAtIndex:0];

    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(lineView.cas_sizeWidth));
        make.height.equalTo(@(lineView.cas_sizeHeight));
        make.centerY.equalTo(self.statView.mas_centerY);
        make.left.equalTo(self.everyDayLab.mas_right).offset(gap);
    }];
    
    //定义“距离”布局
    [self.distanceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(@(self.distanceLab.cas_sizeWidth));
        make.top.equalTo(self.everyDayLab);
        make.left.equalTo(self.everyDayLab.mas_right).offset(2*gap);
        
    }];
    
    //定义统计视图分割线布局
    lineView = [self.lineViews objectAtIndex:1];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(lineView.cas_sizeWidth));
        make.height.equalTo(@(lineView.cas_sizeHeight));
        make.centerY.equalTo(self.statView.mas_centerY);
        make.left.equalTo(self.distanceLab.mas_right).offset(gap);
    }];
    
    //定义“活跃”布局
    [self.activeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(@(self.activeLab.cas_sizeWidth));
        make.top.equalTo(self.distanceLab.mas_top);
        make.left.equalTo(self.distanceLab.mas_right).offset(2*gap);
        
    }];
   
    //定义每天平均步数值布局
    [self.everyDayValueLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.everyDayLab);
        make.height.equalTo(@(self.everyDayValueLab.cas_sizeHeight));
        make.top.equalTo(self.everyDayLab.mas_bottom).offset(9);
        
    }];

    //定义距离数值布局
    [self.distanceValueLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.distanceLab.mas_centerX);
        make.height.equalTo(self.everyDayValueLab.mas_height);
        make.top.equalTo(self.everyDayValueLab);
    }];
   
    //定义活跃数值布局
    [self.activeValueLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.activeLab.mas_centerX);
        make.height.equalTo(self.everyDayValueLab.mas_height);
        make.top.equalTo(self.everyDayValueLab);
    }];
    
}

/**
 *  今日步数label
 *
 *  @return label
 */
-(UILabel*) todayLab {
    
    if (_todayLab == nil) {
        _todayLab = [[UILabel alloc] init];
        _todayLab.cas_styleClass = @"todayLab";
        [_todayLab setText:MyLocalizeString(Localization_TodayCount)];
    }
    
    return _todayLab;
}

/**
 *  最近七天label
 *
 *  @return label
 */
-(UILabel *)sevenDayLab {
    if (_sevenDayLab == nil) {
        _sevenDayLab = [UILabel new];
        _sevenDayLab.cas_styleClass = @"sevenDayLab";
        [_sevenDayLab setText:MyLocalizeString(Localization_SevenDay)];
    }
    
    return _sevenDayLab;
}

/**
 *  样式图片
 *
 *  @return Image
 */
-(UIImage *) styleImg {
    
    if (_styleImg == nil) {
    }
    
    return _styleImg;
}

/**
 *  图表背景
 *
 *  @return UIView
 */
-(UIView *) chartView {
    
    if (_chartView == nil) {
        _chartView = [UIView new];
        _chartView.cas_styleClass = @"chartView";
    }
    
    return _chartView;
}

/**
 *  统计数据视图背景
 *
 *  @return UIView
 */
-(UIView *) statView {
    
    if (_statView == nil) {
        _statView = [UIView new];
        _statView.cas_styleClass = @"statView";
    }
    
    return _statView;
}

/**
 *  每天平均步数label
 *
 *  @return UIlabel
 */
-(UILabel *) everyDayLab {
    
    if (_everyDayLab == nil) {
        _everyDayLab = [UILabel new];
        _everyDayLab.cas_styleClass = @"everyDayLab";
        [_everyDayLab setText:MyLocalizeString(Locatization_EveryDay)];
    }
    
    return _everyDayLab;
}

/**
 *  距离label
 *
 *  @return UILabel
 */
-(UILabel *) distanceLab {
    
    if (_distanceLab == nil) {
        _distanceLab = [UILabel new];
        _distanceLab.cas_styleClass = @"distanceLab";
        [_distanceLab setText:MyLocalizeString(Locatization_Distance)];
    }
    
    return _distanceLab;
}

/**
 *  活跃label
 *
 *  @return UILabel
 */
-(UILabel *) activeLab {
    
    if (_activeLab == nil) {
        _activeLab = [UILabel new];
        _activeLab.cas_styleClass = @"activeLab";
        [_activeLab setText:MyLocalizeString(Locatization_ActiveTime)];
    }
    
    return _activeLab;
}

/**
 *  每天平均步数值label
 *
 *  @return UILabel
 */
-(UILabel *) everyDayValueLab {
    
    if (_everyDayValueLab == nil) {
        _everyDayValueLab = [UILabel new];
        _everyDayValueLab.cas_styleClass = @"everyDayValueLab";
        [_everyDayValueLab setFont:[UIFont systemFontOfSize:40 weight:UIFontWeightThin]];
        [_everyDayValueLab setText:@"0"];
        
        [WalkManger querySevenDayAvgStepCount:^(double stepCount, BOOL succeed) {
            
            double stepCountK = stepCount / 10000;
            
            if (stepCountK >= 1) {
                [_everyDayValueLab setText:[NSString stringWithFormat:@"%ld",(NSInteger)stepCountK * 10]];
            } else  {
                [_everyDayValueLab setText:[NSString stringWithFormat:@"%ld", (NSInteger)stepCount]];
            }
            
        }];

    }
    
    return _everyDayValueLab;
}

/**
 *  距离数值label
 *
 *  @return UILabel
 */
-(UILabel *) distanceValueLab {
   
    if (_distanceValueLab == nil) {
        _distanceValueLab = [UILabel new];
        _distanceValueLab.cas_styleClass = @"distaceValueLab";
        [_distanceValueLab setFont:[UIFont systemFontOfSize:40 weight:UIFontWeightThin]];
        [_distanceValueLab setText:@"0"];
        
        [WalkManger querySevenDayDistance:^(double distance, BOOL succeed) {
            
            if (distance == 0) {
                return;
            }
            
            NSString *distanceStr =[NSString stringWithFormat:@"%f", distance];
            
            if ([distanceStr characterAtIndex:5] == '.') {
                distanceStr = [distanceStr substringToIndex:4];
            } else {
                distanceStr = [distanceStr substringToIndex:5];
            }
            
            [_distanceValueLab setText:distanceStr];
 
        }];
    }
    
    return _distanceValueLab;
}

/**
 *  活跃时间数值
 *
 *  @return UILabel
 */
-(UILabel *) activeValueLab {
    
    if (_activeValueLab == nil) {
        _activeValueLab = [UILabel new];
        _activeValueLab.cas_styleClass = @"activeValueLab";
        [_activeValueLab setFont:[UIFont systemFontOfSize:40 weight:UIFontWeightThin]];
        [_activeValueLab setText:@"0"];
        
        [WalkManger querySevenDayActive:^(double min, BOOL succeed) {
            [_activeValueLab setText:[NSString stringWithFormat:@"%d", (int)min]];
        }];
    }
    
    return _activeValueLab;
}

/**
 *  每日步数 Label
 *
 *  @return UILabel
 */
-(UILabel *) everyDayCountLab {
    
    if (_everyDayCountLab == nil) {
        _everyDayCountLab = [UILabel new];
        _everyDayCountLab.cas_styleClass = @"everyDayCountLab";
        [_everyDayCountLab setFont:[UIFont systemFontOfSize:47 weight:UIFontWeightThin]];
        [_everyDayCountLab setText:@"0"];
        [WalkManger queryTodayStepCount:^(double stepCount, BOOL succeed) {
            
            [_everyDayCountLab setText:[NSString stringWithFormat:@"%ld", (NSInteger)stepCount]];
            
        }];
    }
    
    return _everyDayCountLab;
}

/**
 *  日期 Label
 *
 *  @return UILabel
 */
-(UILabel *) dateLab {
    
    if (_dateLab == nil) {
        _dateLab = [UILabel new];
        _dateLab.cas_styleClass = @"dateLab";
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY.MM.dd"];
        
        NSDate *curDate = [NSDate date];
        
        [_dateLab setText:[formatter stringFromDate:curDate]];
        
    }
    
    return _dateLab;
}

/**
 *  样例图片
 *
 *  @return UIImageView
 */
-(UIImageView *) sampleImg {
    
    if (_sampleImg == nil) {
        
        _sampleImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"color_small"]];
        _sampleImg.cas_styleClass = @"sampleImg";
    }
    
    return _sampleImg;
}

/**
 *  星期显示的Label
 *
 *  @return NSArray
 */
-(NSMutableArray*) weekLab {
    
    if (_weekLab == nil) {
        
        _weekLab = [NSMutableArray new];
        
        for (int i = 0; i < 7; i++) {
            
            UILabel *lab = [UILabel new];
            lab.cas_styleClass = @"weekLab";
            
            [_weekLab addObject:lab];
        }
        
    }
    
    return _weekLab;
    
}

/**
 *  日期Label
 *
 *  @return UILabel
 */
-(NSMutableArray *) dayLabs {
    
    if (_dayLabs == nil) {
        _dayLabs = [NSMutableArray new];
        
        for (int i = 0; i < 7; i++) {
            
            UILabel *lab = [UILabel new];
            lab.cas_styleClass = @"dayLabs";
            
            [_dayLabs addObject:lab];
        }
    }
    
    return _dayLabs;
}

-(NSMutableArray *) barChartImgView{
    
    if (_barChartImgView == nil) {
        _barChartImgView = [NSMutableArray new];
        
        for (int i = 0; i < 7; i++) {
            
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barChart"]];
            imgView.cas_styleClass = @"barChartImgView";
            
            [_barChartImgView addObject:imgView];
        }
    }
    
    return _barChartImgView;
}


/**
 *  定义日期自动布局
 */
-(void) defineDayLayout {
   
    
    CGFloat gap = ([UIScreen mainScreen].bounds.size.width - ((30 * 2) + (6 * 7))) / 6;
    
    for (int i =0 ; i < self.dayLabs.count; i++) {
        
        UILabel *weekLabel = [self.weekLab objectAtIndex:i];
        UIImageView *scaleImg = [self.scaleImgs objectAtIndex:i];
        UILabel *dayLab = [self.dayLabs objectAtIndex:i];
        UIImageView *imgView = [self.barChartImgView objectAtIndex:i];
        UIView *maskView = [self.barChartMaskView objectAtIndex:i];
        UILabel *stepLab = [self.sevenDayStepLab objectAtIndex:i];
        
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd"];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
        
        [dayLab setText:[formatter stringFromDate:[self.sevenDayDate objectAtIndex:i]]];
        
        //定义日期布局
        [dayLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(dayLab.cas_sizeHeight));
            make.centerX.equalTo(scaleImg.mas_centerX);
            make.bottom.equalTo(weekLabel.mas_top).offset(-3);
        }];
        
        [formatter setDateFormat:@"EE"];
        
        //定义星期布局
        [weekLabel setText:[formatter stringFromDate:[self.sevenDayDate objectAtIndex:i]]];
        [weekLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(scaleImg.mas_centerX);
            make.height.equalTo(@(weekLabel.cas_sizeHeight));
            make.bottom.equalTo(@(weekLabel.cas_marginBottom));
        }];
        
        //定义柱状图布局
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(imgView.cas_marginTop));
            make.bottom.equalTo(@(imgView.cas_marginBottom));
            make.width.equalTo(@(imgView.cas_sizeWidth));
            make.centerX.equalTo(scaleImg.mas_centerX);
        }];
        
        [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imgView);
            make.bottom.equalTo(imgView);
            make.left.equalTo(imgView);
            make.right.equalTo(imgView);
        }];
        
        
        //定义圆点图片布局
        [scaleImg mas_makeConstraints:^(MASConstraintMaker *make) {
            
            if (i == 0) {
                make.left.equalTo(self.chartView.mas_left).offset(30);
            } else {
                make.left.equalTo(self.chartView.mas_left).offset(gap * i + (6 * i) + 30);
            }
            
            make.bottom.equalTo(dayLab.mas_top).offset(-10);
            
        }];
        
        if (self.sevenDayStepValue.count >= 7) {
            continue;
        }
        
        
        [WalkManger queryOneDayStepCount:[self.sevenDayDate objectAtIndex:i] tag:i complete:^(double stepCount, NSInteger tag, BOOL succeed) {
            
            //定义柱状图蒙版视图布局
//            [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(imgView);
//                make.bottom.equalTo(imgView).offset(-(imgView.frame.size.height * percent));
//                make.left.equalTo(imgView);
//                make.right.equalTo(imgView);
//            }];
            
            [stepLab setText:[NSString stringWithFormat:@"%ld", (NSInteger)stepCount]];
            
            [self.sevenDayStepValue setValue:[NSNumber numberWithDouble:stepCount] forKey:[NSString stringWithFormat:@"%ld", tag]];
            
            [stepLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(maskView).offset(-6);
                make.centerX.equalTo(maskView);
            }];
            
            if (self.sevenDayStepValue.count == 7) {
                
                [self setNeedsUpdateConstraints];
                
                [self updateConstraintsIfNeeded];
                
                [UIView animateWithDuration:0.4 animations:^{
                    
                    [self layoutIfNeeded];
                    
                }];
            }
            
        }];
        
    }
    
    UIImageView *scaleImg =  [self.scaleImgs objectAtIndex:0];
    
    NSLog(@"scale : %@", scaleImg.mas_centerY);
    
    //定义圆点间的横线布局
    [self.scaleLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(self.scaleLineView.cas_marginLeft));
        make.right.equalTo(@(self.scaleLineView.cas_marginRight));
        make.height.equalTo(@(self.scaleLineView.cas_sizeHeight));
        make.bottom.equalTo(scaleImg.mas_centerY);
    }];
    
}

/**
 *  最近7天
 *
 *  @return NSDate
 */
-(NSMutableArray *) sevenDayDate {
    
    if (_sevenDayDate == nil) {
        
        _sevenDayDate = [NSMutableArray new];
        
        for (int i = 0; i < 7; i++) {
            [_sevenDayDate addObject:[[NSDate alloc] initWithTimeIntervalSinceNow:(-DayTimeInterval *(6 - i))]];
        }
    }
    
    return _sevenDayDate;
}

/**
 *  柱状图下的分割线
 *
 *  @return UIImageView
 */
-(NSMutableArray *) scaleImgs {
    
    if (_scaleImgs == nil) {
        
        _scaleImgs = [NSMutableArray new];
        for (int i = 0; i < 7; i++) {
            
            UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scale"]];
            img.cas_styleClass = @"scaleImgView";
            
            [_scaleImgs addObject:img];
        }
        
    }
    
    return _scaleImgs;
}

/**
 *  统计视图分割线
 *
 *  @return UIView
 */
-(NSMutableArray *) lineViews {
    
    if (_lineViews == nil) {
        _lineViews =[[NSMutableArray alloc] initWithObjects:[UIView new], [UIView new], nil];
        
        UIView *lineView = [_lineViews objectAtIndex:0];
        lineView.cas_styleClass = @"lineView";
        
        lineView = [_lineViews objectAtIndex:1];
        lineView.cas_styleClass = @"lineView";
    }
    
    return _lineViews;
}

/**
 *  图表视图下分割线
 *
 *  @return UIView
 */
-(UIView *) scaleLineView {
   
    if (_scaleLineView == nil) {
        _scaleLineView = [UIView new];
        _scaleLineView.cas_styleClass = @"scaleLineView";
    }
    
    return _scaleLineView;
}

/**
 *  主视图
 *
 *  @return UIView
 */
-(UIView *) mainView {
    
    if (_mainView == nil) {
        _mainView = [UIView new];
        _mainView.cas_styleClass = @"mainView";
    }
    
    return _mainView;
    
}

/**
 *  柱状图蒙版视图
 *
 *  @return UIView
 */
-(NSMutableArray *) barChartMaskView {
   
    if (_barChartMaskView == nil) {
        _barChartMaskView = [NSMutableArray new];
        
        for (int i = 0; i < 7; i++) {
            UIView *maskView = [UIView new];
            [maskView setBackgroundColor:[UIColor whiteColor]];
            [_barChartMaskView addObject:maskView];
        }
    }
    
    return _barChartMaskView;
}

/**
 *  7天步数Label
 *
 *  @return UILabel
 */
-(NSMutableArray *) sevenDayStepLab {
    
    if (_sevenDayStepLab == nil) {
        _sevenDayStepLab = [NSMutableArray new];
        
        for (NSInteger i = 0; i < 7; i++) {
            
            UILabel *stepLab = [UILabel new];
            [stepLab setText:@"0"];
            [stepLab setHidden:YES];
            stepLab.cas_styleClass = @"stepLab";
            
            [_sevenDayStepLab addObject:stepLab];
        }
    }
    
    return _sevenDayStepLab;
}


- (void)updateConstraints {
    
    if (self.sevenDayStepValue.count < 7) {
        [super updateConstraints];
        return;
    }
    
    
    for (NSInteger i = 0; i < 7; i++) {
        
        UIView *maskView = [self.barChartMaskView objectAtIndex:i];
        UIImageView *barImage = [self.barChartImgView objectAtIndex:i];
        
        NSNumber *stepNum = [self.sevenDayStepValue valueForKey:[NSString stringWithFormat:@"%ld", i]];
        double step = stepNum.doubleValue;
        
        CGFloat percent = (CGFloat)(step / 10000);
        NSLog(@"%ld : %f: %f", i, stepNum.doubleValue, percent);
    
        [maskView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(barImage).offset(-(barImage.frame.size.height * percent));
        }];
    }
    
    [super updateConstraints];
   
}

/**
 *  近7日步数值
 *
 *  @return <#return value description#>
 */
- (NSMutableDictionary*)sevenDayStepValue {
    
    if (_sevenDayStepValue == nil) {
        _sevenDayStepValue = [NSMutableDictionary new];
    }
    
    return _sevenDayStepValue;
}

@end
