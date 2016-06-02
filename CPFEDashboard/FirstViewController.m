//
//  FirstViewController.m
//  CPFEDashboard
//
//  Created by Thomas Willson on 3/6/15.
//  Copyright (c) 2015 Thomas Willson. All rights reserved.
//

#import "FirstViewController.h"
#import "GCDAsyncUdpSocket.h"

const uint8_t ACCEL_TYPE = 0;
const uint8_t GYRO_TYPE = 1;
const uint8_t LOCATION_TYPE = 2;

const double UPDATE_FREQUENCY = .05;
const double WAVEFORM_DURATION = 5;
const int NUM_POINTS = 1/UPDATE_FREQUENCY * WAVEFORM_DURATION;

float xWaveformData[NUM_POINTS];
float yWaveformData[NUM_POINTS];
float zWaveformData[NUM_POINTS];

@interface FirstViewController ()
@property (readwrite) CLLocationManager *locationManager;
@property (readwrite) CMMotionManager *motionManager;
@property (readwrite) GCDAsyncUdpSocket *socket;
@end

@implementation FirstViewController

- (void)viewDidLoad {
   [super viewDidLoad];
   
   _socket = [[GCDAsyncUdpSocket alloc] init];
   _socket.delegateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   _socket.delegate = self;
   
   NSError *error;
   [_socket enableBroadcast:YES error:&error];
   NSLog(@"Enable Broadcast Error: %@", error);
   
   _locationManager = [[CLLocationManager alloc] init];
   _locationManager.delegate = self;
   
   _motionManager = [[CMMotionManager alloc] init];

}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

- (IBAction)start:(id)sender {
   [self startLocationUpdates];
   [self startMotionUpdates];
   
}
- (IBAction)stop:(id)sender {
   [self stopLocationUpdates];
   [self stopMotionUpdates];
}

- (void) startLocationUpdates
{
   NSLog(@"Start Location Updates");
   CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
   
   
   if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied)
   {
      NSLog(@"Not Authorized");
      //Popup
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Unavailable" message:@"Please make sure location services are enabled for this app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alertView show];
      return;
   }
   if (status == kCLAuthorizationStatusNotDetermined)
   {
      if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
      {
         [_locationManager requestAlwaysAuthorization];
         NSLog(@"Requesting Authorization");
      }
   }
   
   _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
   _locationManager.distanceFilter = kCLDistanceFilterNone;
   _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
   
   [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
   NSLog(@"Location Update recieved");
   CLLocation *location = locations.lastObject;
   
   LocationPacket packet;
   packet.type = LOCATION_TYPE;
   packet.lattitude = swap(location.coordinate.latitude);
   packet.longitude = swap(location.coordinate.longitude);
   packet.speed = swap(location.speed);
   packet.time = swap([self getTime]);
   
   NSData *data = [NSData dataWithBytes:&packet length:sizeof(packet)];
   [_socket sendData:data toHost:@"10.0.1.255" port:2056 withTimeout:-1 tag:1];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
   NSLog(@"Location Error: %@", error);
   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Unavailable" message:@"Please make sure location services are enabled for this app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
   [alertView show];
}

- (void) stopLocationUpdates
{
   NSLog(@"Stop Location Updates");
   [_locationManager stopUpdatingLocation];
}

- (double)getTime
{
   return [[NSDate date] timeIntervalSince1970];
}

- (void)startMotionUpdates
{
   _motionManager.accelerometerUpdateInterval = UPDATE_FREQUENCY;
   _motionManager.gyroUpdateInterval = UPDATE_FREQUENCY;
   [_motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
      [self accelUpdate:accelerometerData];
   }];
   [_motionManager startGyroUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMGyroData *gyroData, NSError *error) {
      [self gyroUpdate:gyroData];
   }];
}

- (void)stopMotionUpdates
{
   [_motionManager stopAccelerometerUpdates];
   [_motionManager stopGyroUpdates];
}

- (void)gyroUpdate:(CMGyroData *)data
{
   GyroPacket packet;
   packet.type = GYRO_TYPE;
   packet.xRotation = swap(data.rotationRate.x);
   packet.yRotation = swap(data.rotationRate.y);
   packet.zRotation = swap(data.rotationRate.z);
   packet.time = swap([self getTime]);
   
   NSData *packetData = [NSData dataWithBytes:&packet length:sizeof(packet)];
   
   [_socket sendData:packetData toHost:@"10.0.1.255" port:2056 withTimeout:-1 tag:1];
}

- (void)accelUpdate:(CMAccelerometerData *)data
{
   AccelPacket packet;
   packet.type = ACCEL_TYPE;
   packet.xAccel = swap(data.acceleration.x);
   packet.yAccel = swap(data.acceleration.y);
   packet.zAccel = swap(data.acceleration.z);
   packet.time = swap([self getTime]);
   
   NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
      _xAccel.text = [NSString stringWithFormat:@"X: %.3f", data.acceleration.x];
      _yAccel.text = [NSString stringWithFormat:@"Y: %.3f", data.acceleration.y];
      _zAccel.text = [NSString stringWithFormat:@"Z: %.3f", data.acceleration.z];
      shiftArray(xWaveformData);
      shiftArray(yWaveformData);
      shiftArray(zWaveformData);
      xWaveformData[NUM_POINTS-1] = data.acceleration.x / 2.0;
      yWaveformData[NUM_POINTS-1] = data.acceleration.y / 2.0;
      zWaveformData[NUM_POINTS-1] = data.acceleration.z / 2.0;
      [_waveform setSampleData:xWaveformData length:NUM_POINTS];
      [_yWaveform setSampleData:yWaveformData length:NUM_POINTS];
      [_zWaveform setSampleData:zWaveformData length:NUM_POINTS];
   }];
   [[NSOperationQueue mainQueue] addOperation:operation];
   
   NSData *packetData = [NSData dataWithBytes:&packet length:sizeof(packet)];
   
   [_socket sendData:packetData toHost:@"10.0.1.255" port:2056 withTimeout:-1 tag:1];
   
}

double swap(double d)
{
   double a;
   unsigned char *dst = (unsigned char *)&a;
   unsigned char *src = (unsigned char *)&d;
   dst[0] = src[7];
   dst[1] = src[6];
   dst[2] = src[5];
   dst[3] = src[4];
   dst[4] = src[3];
   dst[5] = src[2];
   dst[6] = src[1];
   dst[7] = src[0];
   return a;
}

void shiftArray(float *waveformData)
{
   for (int i=1; i < NUM_POINTS; ++i) {
      waveformData[i] = waveformData[i+1];
   }
}

@end
