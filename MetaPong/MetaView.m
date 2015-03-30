//
//  MetaView.m
//  MetaPong
//
//  Created by Tobias Wermuth on 14/09/14.
//  Copyright (c) 2014 tobynextdoor LLC. All rights reserved.
//

#import "MetaView.h"

@implementation MetaView


- (void)drawRect:(CGRect)rect {
    CGRect frame = self.bounds;
    
    [MetaView drawFrame:frame];
}

+ (void)drawFrame:(CGRect)frame
{
    UIBezierPath *roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:10];
    [roundedRectPath addClip];
    
    roundedRectPath.lineWidth = 2.0;
    
    [[UIColor blackColor] setFill];
    
    [roundedRectPath stroke];
}

@end
