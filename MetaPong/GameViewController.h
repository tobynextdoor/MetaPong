//
//  GameViewController.h
//  MetaPong
//
//  Created by Tobias Wermuth on 14/09/14.
//  Copyright (c) 2014 tobynextdoor LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

#import "MetaView.h"
#import "GameScene.h"

@interface GameViewController : UIViewController <GameSceneDelegate>

@property (weak, nonatomic) IBOutlet MetaView *metaView;
@property (weak, nonatomic) IBOutlet SKView *gameView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) NSMutableArray *deviceColors;
@property (strong, nonatomic) NSMutableArray *kiPlayers;

@end
