//
//  DevicesViewController.h
//  Metawear-TestGame
//
//  Created by Tobias Wermuth on 30/08/14.
//  Copyright (c) 2014 tobynextdoor. All rights reserved.
//

#import <MetaWear/MetaWear.h>

@protocol DevicesViewDelegate

- (void)setDevice:(MBLMetaWear *)device withColor:(UIColor *)color forPlayerNumber:(int)playerNumber;

@end

@interface DevicesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

//@property (strong, nonatomic) UIPopoverController *aPopoverController;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) id<DevicesViewDelegate> delegate;

@property (nonatomic) int playerNumber;
@property (strong, nonatomic) NSMutableArray *connectedDevices;
@property (strong, nonatomic) NSMutableArray *usedColors;

@end
