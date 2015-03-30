//
//  DevicesViewController.m
//  Metawear-TestGame
//
//  Created by Tobias Wermuth on 30/08/14.
//  Copyright (c) 2014 tobynextdoor. All rights reserved.
//

#import "DevicesViewController.h"

@interface DevicesViewController ()

@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, strong) NSMutableArray *deviceColors;
@property (nonatomic, strong) MBLMetaWear *selectedDevice;

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic) int colorCount;

@end

@implementation DevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.devices = [NSMutableArray new];
    self.deviceColors = [NSMutableArray new];
    self.colors = [NSArray arrayWithObjects:[UIColor greenColor], [UIColor redColor], [UIColor blueColor], [UIColor purpleColor], [UIColor yellowColor], [UIColor cyanColor], [UIColor orangeColor], [UIColor grayColor], nil];
    self.colorCount = -1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self nextColor];
    
    [self startScanning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!self.selectedDevice) {
        [self.delegate setDevice:nil withColor:nil forPlayerNumber:self.playerNumber];
    }
    
    for (MBLMetaWear *device in self.devices) {
        if (![device.peripheral.identifier.UUIDString isEqualToString:self.selectedDevice.peripheral.identifier.UUIDString]) {
            [device.led setLEDOn:NO withOptions:1];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                //NSLog(@"Disconnecting...");
                
                [[MBLMetaWearManager sharedManager] cancelMetaWearConnection:device withHandler:^(NSError *error) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        //NSLog(@"Disconnected.");
                    }];
                }];
            });
        }
    }
}

- (void)startScanning
{
    [[MBLMetaWearManager sharedManager] stopScanForMetaWears];
    [[MBLMetaWearManager sharedManager] startScanForMetaWearsAllowDuplicates:YES handler:^(NSArray *array) {
        for (MBLMetaWear *device in array) {
            BOOL alreadyConnected = NO;
            
            for (id alreadyConnectedDevice in self.connectedDevices) {
                if (alreadyConnectedDevice != [NSNull null] && [device.peripheral.identifier.UUIDString isEqualToString:((MBLMetaWear *)alreadyConnectedDevice).peripheral.identifier.UUIDString]) {
                    alreadyConnected = YES;
                    break;
                }
            }
            
            if (!alreadyConnected && ![self.devices containsObject:device]) {
                [[MBLMetaWearManager sharedManager] connectMetaWear:device withHandler:^(NSError *error) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        if (error) {

                        } else {
                            [device.led setLEDColor:[self.colors objectAtIndex:self.colorCount] withIntensity:1.0];
                            
                            [self.devices addObject:device];
                            [self.deviceColors addObject:[self.colors objectAtIndex:self.colorCount]];
                            
                            [self nextColor];
                            
                            [self.devices sortUsingComparator:^NSComparisonResult(MBLMetaWear *device1, MBLMetaWear *device2) {
                                return [device1.peripheral.RSSI compare:device2.peripheral.RSSI];
                            }];
                            
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                //CGSize contentSize = CGSizeMake(300, 37 + [self.devices count] * 53);
                                //[self.popoverPresentationController setPopoverContentSize:contentSize animated:YES];
                                
                                [self.tableView reloadData];
                            }];
                        }
                    }];
                }];
            }
        }
    }];
}

- (void)nextColor
{
    self.colorCount = (self.colorCount + 1) % [self.colors count];
    
    //NSLog(@"%@ - %@", self.usedColors, self.colors[self.colorCount]);
    
    int i = 0;
    while ([self.usedColors containsObject:self.colors[self.colorCount]]) {
        self.colorCount = (self.colorCount + 1) % [self.colors count];
        
        i++;
        
        if (i > [self.colors count]) {
            break;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    [self.view setNeedsDisplay];
    
    return [self.devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Device Cell" forIndexPath:indexPath];
    MBLMetaWear *device = self.devices[indexPath.row];
    
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    name.text = [NSString stringWithFormat:@"%@", device.peripheral.name];
    
    UILabel *color = (UILabel *)[cell viewWithTag:2];
    color.text = @"●";
    color.textColor = [self.deviceColors objectAtIndex:indexPath.row];
    
    UILabel *uuid = (UILabel *)[cell viewWithTag:3];
    uuid.text = [NSString stringWithFormat:@"UUID: %@", device.peripheral.identifier.UUIDString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    self.selectedDevice = self.devices[indexPath.row];
    UIColor *deviceColor = [self.deviceColors objectAtIndex:indexPath.row];
    self.view.alpha = 0.5;
    self.view.userInteractionEnabled = NO;
    
    
    [[MBLMetaWearManager sharedManager] connectMetaWear:self.selectedDevice withHandler:^(NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (error) {
                self.view.alpha = 1.0;
                self.view.userInteractionEnabled = YES;
            } else {
                [self.delegate setDevice:self.selectedDevice withColor:deviceColor forPlayerNumber:self.playerNumber];
            }
        }];
    }];
}

@end
