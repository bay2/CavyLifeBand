//
//  ViewController.h
//  CavyLifeBand
//
//  Created by blacksmith on 2015/9/25.
//  Copyright (c) 2015年 blacksmith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PressHighlightButton.h"
#import "SerachImageView.h"
@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UIView *SearchPressImageView;
@property (weak, nonatomic) IBOutlet UIView *speratorLine;
@property IBOutlet UITableView *TableView;
@property IBOutlet UIImageView *ImageToMove;
@property (weak, nonatomic) IBOutlet SerachImageView *SearchImage;
@property (weak, nonatomic) IBOutlet UILabel *SearchLabel;
@property (weak, nonatomic) IBOutlet PressHighlightButton *searchPresshighlightButton;
-(void)ConnectAction:(UIButton*)sender;
@end

