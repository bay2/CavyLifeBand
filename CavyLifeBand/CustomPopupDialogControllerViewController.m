//
//  CustomPopupDialogControllerViewController.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/14.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import "CustomPopupDialogControllerViewController.h"
#import "CavyLifeBandDefined.h"
@interface CustomPopupDialogControllerViewController ()

@end
NSString* tempText;
@implementation CustomPopupDialogControllerViewController

-(void)setMessageText:(NSString *)title
{
    self.MessageLabel.text = title;
    tempText = title;
}

- (void)viewDidLoad {
    self.view.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.0f];
    self.DialogView.layer.cornerRadius = 5;
    self.DialogView.layer.shadowOpacity = 0.8;
    self.DialogView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.MessageLabel.text = tempText;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAnimate
{
    self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.view.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        self.view.alpha = 1;
        self.view.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)removeAnimate
{
    [UIView animateWithDuration:.25 animations:^{
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.view removeFromSuperview];
        }
    }];
    NSLog(@"Remove Animate");
}

-(void)closePopup
{
    [self removeAnimate];
}

- (IBAction)closePopupAndDisconnect:(id)sender {
    if( self.isConnection )
    {
        [self removeAnimate];
        [[NSNotificationCenter defaultCenter] postNotificationName:(NSString*)NotificationKey_CancelConnecting object:nil userInfo:nil];
    }
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self.view];
    if (animated) {
        [self showAnimate];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
