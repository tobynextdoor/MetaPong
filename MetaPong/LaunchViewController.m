//
//  ViewController.m
//  MetaPong
//
//  Created by Tobias Wermuth on 13/09/14.
//  Copyright (c) 2014 tobynextdoor LLC. All rights reserved.
//

#import "LaunchViewController.h"
#import "GameViewController.h"

@interface LaunchViewController ()

@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) NSMutableArray *deviceColors;
//@property (strong, nonatomic) UIPopoverController *devicesPopoverController;

@property (nonatomic) int currentConnectingToMetawearPlayerNumber;

@end

@implementation LaunchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.devices = [NSMutableArray arrayWithCapacity:[self.playerTypeControls count]];
    self.deviceColors = [NSMutableArray arrayWithCapacity:[self.playerTypeControls count]];

    for (int i = 0; i < [self.playerTypeControls count]; ++i) {
        [self.devices setObject:[NSNull null] atIndexedSubscript:i];
        [self.deviceColors setObject:[NSNull null] atIndexedSubscript:i];
    }

    self.anchorPointView.hidden = YES;
}

- (IBAction)changePlayerType:(UISegmentedControl *)sender
{
    int playerNumber = (int)[self.playerTypeControls indexOfObject:sender];

    if ([sender selectedSegmentIndex] == 0) {
        [self disconnectAndResetDeviceForPlayerNumber:playerNumber];
        [UIView animateWithDuration:0.5 animations:^{
            ((LaunchPlayerColorView *)self.launchPlayerColorViews[playerNumber]).alpha = 0.0;
        } completion:NULL];
    } else if ([sender selectedSegmentIndex] == 1) {
        self.currentConnectingToMetawearPlayerNumber = playerNumber;
        [self performSegueWithIdentifier:@"Show Metawear Devices" sender:sender];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *viewController = segue.destinationViewController;
    
    if ([viewController isKindOfClass:[DevicesViewController class]]) {
        ((DevicesViewController *)viewController).delegate = self;
        ((DevicesViewController *)viewController).playerNumber = self.currentConnectingToMetawearPlayerNumber;
        ((DevicesViewController *)viewController).connectedDevices = self.devices;
        ((DevicesViewController *)viewController).usedColors = self.deviceColors;

        UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
        self.anchorPointView.frame = CGRectMake(segmentControl.frame.origin.x + segmentControl.frame.size.width,
                                                segmentControl.frame.origin.y + segmentControl.frame.size.height / 2,
                                                1,
                                                1
                                                );
    } else if ([viewController isKindOfClass:[GameViewController class]]) {
        NSArray *colors = [NSArray arrayWithObjects:[UIColor greenColor], [UIColor redColor], [UIColor blueColor], [UIColor purpleColor], [UIColor yellowColor], [UIColor cyanColor], [UIColor orangeColor], [UIColor grayColor], nil];
        NSMutableArray *kiPaddles = [NSMutableArray new];
        
        for (int i = 0; i < [self.devices count]; i++) {
            if (((UISegmentedControl *)self.playerTypeControls[i]).selectedSegmentIndex == 0) {
                [kiPaddles addObject:[NSNumber numberWithInt:i]];
            }
            
            if (self.deviceColors[i] == [NSNull null]) {
                int colorCount = 0;
                
                int g = 0;
                while ([self.deviceColors containsObject:colors[colorCount]]) {
                    colorCount = (colorCount + 1) % [colors count];
                    
                    g++;
                    
                    if (g > [colors count]) {
                        break;
                    }
                }
                
                self.deviceColors[i] = colors[colorCount];
            }
        }
        
        ((GameViewController *)viewController).devices = self.devices;
        ((GameViewController *)viewController).deviceColors = self.deviceColors;
        ((GameViewController *)viewController).kiPlayers = kiPaddles;
    }
}

#define VIBRATION_TIME 500
#define VIBRATION_STRENGTH 1.0

- (void)setDevice:(MBLMetaWear *)device withColor:(UIColor *)color forPlayerNumber:(int)playerNumber;
{
    if (device) {
        if (self.devices[playerNumber] != [NSNull null] &&
            ![((MBLMetaWear *)self.devices[playerNumber]).peripheral.identifier.UUIDString isEqualToString:device.peripheral.identifier.UUIDString]) {
            [self disconnectAndResetDeviceForPlayerNumber:playerNumber];
        }
        
        [UIView animateWithDuration:1.0 animations:^{
            ((LaunchPlayerColorView *)self.launchPlayerColorViews[playerNumber]).alpha = 1.0;
        } completion:NULL];
        ((LaunchPlayerColorView *)self.launchPlayerColorViews[playerNumber]).color = color;
        
        [self.devices setObject:device atIndexedSubscript:playerNumber];
        [self.deviceColors setObject:color atIndexedSubscript:playerNumber];
        
        [device.led setLEDOn:NO withOptions:1];
        
        [device.hapticBuzzer startHapticWithDutyCycle:80 + 168 * VIBRATION_STRENGTH pulseWidth:VIBRATION_TIME completion:^{
            [device.led setLEDColor:color withIntensity:1.0];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [device.led setLEDOn:NO withOptions:1];
                
                [device.hapticBuzzer startHapticWithDutyCycle:80 + 168 * VIBRATION_STRENGTH pulseWidth:VIBRATION_TIME completion:^{
                    [device.led setLEDColor:color withIntensity:1.0];
                }];
            });
        }];
    } else {
        UISegmentedControl *segmentControl = [self.playerTypeControls objectAtIndex:playerNumber];
        [segmentControl setSelectedSegmentIndex:0];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //[self.devicesPopoverController dismissPopoverAnimated:YES];
}

- (void)disconnectAndResetDeviceForPlayerNumber:(int)playerNumber
{
    if (self.devices[playerNumber] != [NSNull null]) {
        MBLMetaWear *device = [self.devices objectAtIndex:playerNumber];
    
        [device.led setLEDOn:NO withOptions:1];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self disconnectDeviceForPlayerNumber:playerNumber];
        });
    }
}

- (void)disconnectDeviceForPlayerNumber:(int)playerNumber
{
    if (self.devices[playerNumber] != [NSNull null]) {
        MBLMetaWear *device = [self.devices objectAtIndex:playerNumber];
    
        //NSLog(@"Disconnecting...");

        [[MBLMetaWearManager sharedManager] cancelMetaWearConnection:device withHandler:^(NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //NSLog(@"Disconnected.");
                [self.devices setObject:[NSNull null] atIndexedSubscript:playerNumber];
                [self.deviceColors setObject:[NSNull null] atIndexedSubscript:playerNumber];

                if (error) {
                } else {
                }
            }];
        }];
    }
}

@end
