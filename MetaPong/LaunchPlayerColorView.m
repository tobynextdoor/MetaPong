//
//  LaunchPlayerColorView.m
//  MetaPong
//
//  Created by Tobias Wermuth on 14/09/14.
//  Copyright (c) 2014 tobynextdoor LLC. All rights reserved.
//

#import "LaunchPlayerColorView.h"

@implementation LaunchPlayerColorView

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    self.backgroundColor = [UIColor clearColor]; // else background gets black
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGRect frame = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [self.color CGColor]);
    
    CGContextFillEllipseInRect(context, frame);
}

@end
