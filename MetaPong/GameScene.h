//
//  SKPMyScene.h
//  Sprite Kit Pong
//

//  Copyright (c) 2014 Božidar Ševo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol GameSceneDelegate

- (void)showStartControls;

@end

@interface GameScene : SKScene<SKPhysicsContactDelegate>

- (void)startGame;

- (void)setColor:(UIColor *)color forPaddleNumber:(int)paddleNumber;
- (void)setPaddleKI:(int)paddleNumber;

- (void)movePaddleNumber:(int)number amount:(float)amount;

@property (nonatomic) id<GameSceneDelegate> gameSceneDelegate;
@property (nonatomic) BOOL running;

@end
