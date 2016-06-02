//
//  FirstViewController.h
//  CPFEDashboard
//
//  Created by Thomas Willson on 3/6/15.
//  Copyright (c) 2015 Thomas Willson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "WaveFormViewIOS.h"

#include <stdint.h>


#pragma pack(8)
typedef struct LocationPacket {
   uint8_t type;
   double time;
   double lattitude;
   double longitude;
   double speed;
} LocationPacket;

typedef struct AccelPacket {
   uint8_t type;
   double time;
   double xAccel;
   double yAccel;
   double zAccel;
} AccelPacket;

typedef struct GyroPacket {
   uint8_t type;
   double time;
   double xRotation;
   double yRotation;
   double zRotation;
} GyroPacket;

@interface FirstViewController : UIViewController <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *xAccel;
@property (weak, nonatomic) IBOutlet UILabel *yAccel;
@property (weak, nonatomic) IBOutlet UILabel *zAccel;
@property (weak, nonatomic) IBOutlet WaveFormViewIOS *waveform;
@property (weak, nonatomic) IBOutlet WaveFormViewIOS *yWaveform;
@property (weak, nonatomic) IBOutlet WaveFormViewIOS *zWaveform;


- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;

@end

