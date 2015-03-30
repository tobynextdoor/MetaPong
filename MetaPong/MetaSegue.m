//
//  LaunchToGameSegue.m
//  MetaPong
//
//  Created by Tobias Wermuth on 14/09/14.
//  Copyright (c) 2014 tobynextdoor LLC. All rights reserved.
//

#import "MetaSegue.h"

@implementation MetaSegue

- (void)perform
{
    [self hideSourceViewController];
}

- (void)hideSourceViewController
{
    UIViewController *sourceViewController = self.sourceViewController;
    NSMutableArray *sourceViews = [self getAllSubviewsOfView:sourceViewController.view views:nil];
    
    [sourceViews sortUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        return view1.frame.origin.y < view2.frame.origin.y;
    }];
    
    [self hideAllViews:sourceViews count:(int)[sourceViews count] - 1];
}

- (void)showDestinationViewController
{
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    
    destinationViewController.view.alpha = 0.0;
    
    [sourceViewController.view addSubview:destinationViewController.view];
    
    [UIView animateWithDuration:1.0 animations:^{
        destinationViewController.view.alpha = 1.0;
    } completion:^(BOOL finished){
        [sourceViewController presentViewController:destinationViewController animated:NO completion:NULL];
    }];
}

#define SECONDS_PER_VIEW 0.2

- (void)hideAllViews:(NSArray *)views count:(int)count
{
    UIView *view = views[count];
    
    if (view.hidden || view.alpha == 0) {
        count--;
        
        if (count >= 0) {
            [self hideAllViews:views count:count];
        } else {
            [self showDestinationViewController];
        }
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (SECONDS_PER_VIEW / 2) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (count - 1 >= 0) {
                [self hideAllViews:views count:count - 1];
            } else {
                [self showDestinationViewController];
            }
        });
        
        [UIView animateWithDuration:SECONDS_PER_VIEW animations:^{
            view.alpha = 0;
        } completion:NULL];
    }
}

- (NSMutableArray *)getAllSubviewsOfView:(UIView *)rootView views:(NSMutableArray *)views
{
    if (!views) {
        views = [NSMutableArray new];
        
        [self getAllSubviewsOfView:[rootView subviews][0] views:views];
    } else {
        for (UIView *view in rootView.subviews) {
            [views addObject:view];
            
            if (![view isKindOfClass:[UIButton class]] && ![view isKindOfClass:[UILabel class]] && ![view isKindOfClass:[UISegmentedControl class]]) {
                [self getAllSubviewsOfView:view views:views];
            }
        }
    }
    
    return views;
}

@end
