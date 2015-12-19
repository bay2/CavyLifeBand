//
//  SerachImageView.m
//  CavyLifeBand
//
//  Created by blacksmith on 2015/10/22.
//  Copyright © 2015年 blacksmith. All rights reserved.
//

#import "SerachImageView.h"
@interface SerachImageView()
{
    bool canHighlight;
}
@end
@implementation SerachImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void) setCanHighlight:(BOOL)result
{
    canHighlight = result;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //self.alpha = 0.8;
    if( canHighlight )
        [self.pressButton setHighlighted:true];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    //The touch may be cancelled, due to scrolling etc. Restore the alpha if that is the case.
    //self.alpha = 1;
    [self.pressButton setHighlighted:false];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //Restore the alpha to its original state.
    //self.alpha = 1;
    [self.pressButton setHighlighted:false];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

@end
