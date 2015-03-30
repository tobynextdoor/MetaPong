//
//  ViewController.h
//  MetaPong
//
//  Created by Tobias Wermuth on 13/09/14.
//  Copyright (c) 2014 tobynextdoor LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DevicesViewController.h"
#import "LaunchPlayerColorView.h"

@interface LaunchViewController : UIViewController <DevicesViewDelegate>

@property (strong, nonatomic) IBOutletCollection(UISegmentedControl) NSArray *playerTypeControls;
@property (strong, nonatomic) IBOutletCollection(LaunchPlayerColorView) NSArray *launchPlayerColorViews;

@property (weak, nonatomic) IBOutlet UIView *anchorPointView;


@end

