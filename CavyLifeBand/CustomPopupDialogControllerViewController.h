//
//  CustomPopupDialogControllerViewController.h
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/14.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPopupDialogControllerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *DialogView;
@property (weak, nonatomic) IBOutlet UILabel *MessageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *LoadingActivity;
@property (weak, nonatomic) IBOutlet UIImageView *Icon;
@property bool isConnection;
- (void)closePopup;
-(void)setMessageText:(NSString *)title;

@end
