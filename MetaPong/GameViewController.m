//
//  GameViewController.m
//  MetaPong
//
//  Created by Tobias Wermuth on 14/09/14.
//  Copyright (c) 2014 tobynextdoor LLC. All rights reserved.
//

#import "GameViewController.h"
#import <MetaWear/MetaWear.h>

@interface GameViewController ()

@property (weak, nonatomic) GameScene *gameScene;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the view.
    self.gameView.showsFPS = NO; //set to YES if you do want to see frame rate on screen
    self.gameView.showsNodeCount = NO; // set to YES if you do want to see node count on scren
    
    self.gameScene = [GameScene nodeWithFileNamed:@"GameScene"];
    self.gameScene.gameSceneDelegate = self;
    
    self.gameScene.scaleMode = SKSceneScaleModeAspectFill;
        
    [self.gameView presentScene:self.gameScene];
    
    for (int i = 0; i < [self.deviceColors count]; i++) {
        [self.gameScene setColor:self.deviceColors[i] forPaddleNumber:i];
    }
    
    for (NSNumber *paddleNumber in self.kiPlayers) {
        [self.gameScene setPaddleKI:[paddleNumber intValue]];
    }
    
    for (int i = 0; i < [self.devices count]; i++) {
        if (self.devices[i] != [NSNull null]) {
            MBLMetaWear *device = self.devices[i];
            
            device.accelerometer.fullScaleRange = 0;
            device.accelerometer.sampleFrequency = 4;
            device.accelerometer.highPassFilter = 0;
            device.accelerometer.lowNoise = 1;
            device.accelerometer.autoSleep = 0;
            device.accelerometer.sleepSampleFrequency = 2;
            device.accelerometer.activePowerScheme = 0;
            
            [device.accelerometer startAccelerometerUpdatesWithHandler:^(MBLAccelerometerData *acceleration, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (i == 0) {
                        [self.gameScene movePaddleNumber:i amount:-acceleration.x * 20];
                    } else if (i == 1) {
                        [self.gameScene movePaddleNumber:i amount:acceleration.x * 20];
                    }
                });
            }];
        }
    }
    
    [self showStartControls];
}

- (void)showStartControls
{
    [UIView animateWithDuration:0.5 animations:^{ self.startButton.alpha = 1; } completion:^(BOOL success){ self.startButton.enabled = YES; }];
}

- (IBAction)startButtonPress
{
    [self.gameScene startGame];
    
    [UIView animateWithDuration:0.5 animations:^{ self.startButton.alpha = 0; } completion:^(BOOL success){ self.startButton.enabled = NO; }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

@end
