//
//  WalkingViewController.m
//  CavyLifeBand
//
//  Created by xuemincai on 15/12/11.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import "WalkingViewController.h"
#import "CavyLifeBandDefined.h"
#import "WalkingView.h"
#import "CavyLifeBand.h"

@implementation WalkingViewController
{
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    [self createNavgitionItem];
    [self createMainView];
    
}

/**
 *  创建导航栏
 */
- (void) createNavgitionItem {
    

    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spaceItem setWidth:10];
    
    //创建返回按钮
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    UIBarButtonItem *backBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [backBtn addTarget:self action:@selector(returnView:) forControlEvents:UIControlEventTouchUpInside];
    
    //创建计步标题
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 29)];
    [titleLab setTextAlignment:NSTextAlignmentLeft];
    [titleLab setText:MyLocalizeString(Localization_Walking)];
    [titleLab setTextColor:[UIColor whiteColor]];
    UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithCustomView:titleLab];
    
    self.navigationItem.leftBarButtonItems = [[NSArray alloc] initWithObjects:backBtnItem, spaceItem, titleItem, nil];
    
}

/**
 *  创建主视图
 */
- (void) createMainView {
    
    WalkingView *mainView = [[WalkingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    
    [self.view addSubview:mainView];
        
}

/**
 *  返回
 *
 *  @param sender
 */
- (void) returnView: (id) sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



@end

