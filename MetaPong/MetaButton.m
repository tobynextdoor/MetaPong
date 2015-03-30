//
//  MetaButton.m
//  MetaPong
//
//  Created by Tobias Wermuth on 13/09/14.
//  Copyright (c) 2014 tobynextdoor LLC. All rights reserved.
//

#import "MetaButton.h"

@implementation MetaButton

- (void)drawRect:(CGRect)rect {
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:self.frame.size.height / 2];
    
    if (self.highlightState) {
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
    }
    
    self.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = self.bounds;

    [MetaView drawFrame:frame];
    
    if (self.highlightState) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor blackColor] set];
        CGContextFillRect(context, frame);
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [self setNeedsDisplay];
    
    self.highlightState = highlighted;
}


@end
