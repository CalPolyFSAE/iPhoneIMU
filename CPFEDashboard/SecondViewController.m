//
//  SecondViewController.m
//  CPFEDashboard
//
//  Created by Thomas Willson on 3/6/15.
//  Copyright (c) 2015 Thomas Willson. All rights reserved.
//

#import "SecondViewController.h"
#import "JSONModel.h"

@interface SecondViewController ()
   @property (readwrite) NSTimer *throttleVoltageRequestTimer;
@end

@implementation SecondViewController

- (void)viewDidLoad {
   [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
   _throttleVoltageRequestTimer = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
   _throttleVoltageRequestTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sendThrottleVoltageUpdateRequest) userInfo:nil repeats:YES];
}

- (void)sendThrottleVoltageUpdateRequest
{
   NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://10.0.1.50:3580/nivariable/VariableValues('ni.var.psp://10.0.1.50/RemoteCalibrationVariables/ThrottleVoltages')/Value?$format=json"]];
   [NSURLConnection sendAsynchronousRequest:request
                                      queue:[NSOperationQueue mainQueue]
                          completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
   {
      [self processThrottleVoltageResponse:(NSHTTPURLResponse *)response withData:data andError:connectionError];
   }];
}

- (void)processThrottleVoltageResponse:(NSHTTPURLResponse *)response withData:(NSData *)data andError:(NSError *)error
{
   if (response.statusCode == 200) {
      @try {
         JSONModel *model = [[JSONModel alloc] initWithData:data error:nil];
         NSDictionary *dictionary = [model toDictionary];
         _throttle1Voltage.text = dictionary[@"Throttle 1"];
         _throttle2Voltage.text = dictionary[@"Throttle 2"];
      }
      @catch (NSException *exception) {
         NSLog(@"Could not parse throttle update response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
      }
   }
   else {
      NSLog(@"Throttle Update Response Error Status Code: %ld, Explanation: %@", (long)response.statusCode, error);
   }
}

@end
