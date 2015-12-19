//
//  SerachImageView.h
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/22.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PressHighlightButton.h"
@interface SerachImageView : UIImageView

@property PressHighlightButton * pressButton;

-(void) setCanHighlight:(BOOL) result;
@end
