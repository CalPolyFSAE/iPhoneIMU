//
//  WaveFormView.h
//  WaveFormTest
//
//  Created by Gyetván András on 7/11/12.
// This software is free.
//

#import <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>

@interface WaveFormViewIOS : UIControl
{
	UIActivityIndicatorView *progress;
	CGPoint* sampleData;
	int sampleLength;
//	WaveSampleProvider *wsp;
	AVPlayer *player;
	float playProgress;
	NSString *infoString;
	NSString *timeString;
	UIColor *green;
	UIColor *gray;
	UIColor *lightgray;
	UIColor *darkgray;
	UIColor *white;
	UIColor *marker;
}

//- (void) openAudio:(NSString *)path;
- (void) openAudioURL:(NSURL *)url;
- (void)playerItemDidReachEnd:(NSNotification *)notification;
- (void) setSampleData:(float *)theSampleData length:(int)length;

@end
