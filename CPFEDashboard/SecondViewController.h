//
//  SecondViewController.h
//  CPFEDashboard
//
//  Created by Thomas Willson on 3/6/15.
//  Copyright (c) 2015 Thomas Willson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *throttle1Voltage;
@property (weak, nonatomic) IBOutlet UILabel *throttle2Voltage;
@property (weak, nonatomic) IBOutlet UITextField *throttle1Min;
@property (weak, nonatomic) IBOutlet UITextField *throttle1Max;
@property (weak, nonatomic) IBOutlet UITextField *throttle2Min;
@property (weak, nonatomic) IBOutlet UITextField *throttle2Max;

@property (weak, nonatomic) IBOutlet UIButton *loadCurrentCalibration;
@property (weak, nonatomic) IBOutlet UIButton *sendCalibration;

@end

