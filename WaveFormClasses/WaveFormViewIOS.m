//
//  WaveFormView.m
//  WaveFormTest
//
//  Created by Gyetván András on 7/11/12.
// This software is free.
//

#import "WaveFormViewIOS.h"

@interface WaveFormViewIOS (Private)
- (void) initView;
- (void) drawRoundRect:(CGRect)bounds fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor radius:(CGFloat)radius lineWidht:(CGFloat)lineWidth;
- (CGRect) playRect;
- (CGRect) progressRect;
- (CGRect) waveRect;
- (CGRect) statusRect;
- (void) setSampleData:(float *)theSampleData length:(int)length;
- (void) startAudio;
- (void) pauseAudio;
- (void) drawTextRigth:(NSString *)text inRect:(CGRect)rect color:(UIColor *)color;
- (void) drawTextCentered:(NSString *)text inRect:(CGRect)rect color:(UIColor *)color;
- (void) drawText:(NSString *)text inRect:(CGRect)rect color:(UIColor *)color;
- (void) drawPlay;
- (void) drawPause;
- (void) releaseSample;
@end

@implementation WaveFormViewIOS

#pragma mark -
#pragma mark Chrome
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(self) {
		[self initView];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self initView];
    }
    return self;
}

- (void) initView
{
	playProgress = 0.0;
	progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	progress.frame = [self progressRect];
	[self addSubview:progress];
	[progress setHidden:TRUE];
	CGRect sr = [self statusRect];
	sr.origin.x += 2;
	sr.origin.y -= 2;
	green = [UIColor colorWithRed:143.0/255.0 green:196.0/255.0 blue:72.0/255.0 alpha:1.0];
	gray = [UIColor colorWithRed:64.0/255.0 green:63.0/255.0 blue:65.0/255.0 alpha:1.0];
	lightgray = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1.0];
	darkgray = [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:48.0/255.0 alpha:1.0];
	white = [UIColor whiteColor];
	marker = [UIColor colorWithRed:242.0/255.0 green:147.0/255.0 blue:0.0/255.0 alpha:1.0];
}

- (void)setFrame:(CGRect)frameRect
{
	[super setFrame:frameRect];
	[progress setFrame:[self progressRect]];
}





#pragma mark -
#pragma mark Text Drawing
- (void) drawTextCentered:(NSString *)text inRect:(CGRect)rect color:(UIColor *)color
{
	if(text == nil) return;
	CGContextRef cx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(cx);
	CGContextClipToRect(cx, rect);
	CGPoint center = CGPointMake(rect.origin.x + (rect.size.width / 2.0), rect.origin.y + (rect.size.height / 2.0));
	UIFont *font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
	
	CGSize stringSize = [text sizeWithFont:font];
	CGRect stringRect = CGRectMake(center.x-stringSize.width/2, center.y-stringSize.height/2, stringSize.width, stringSize.height);
	
	[color set];
	[text drawInRect:stringRect withFont:font];
	CGContextRestoreGState(cx);
}

- (void) drawTextRight:(NSString *)text inRect:(CGRect)rect color:(UIColor *)color
{
	if(text == nil) return;
	CGContextRef cx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(cx);
	CGContextClipToRect(cx, rect);
	CGPoint center = CGPointMake(rect.origin.x + (rect.size.width / 2.0), rect.origin.y + (rect.size.height / 2.0));
	UIFont *font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
	
	CGSize stringSize = [text sizeWithFont:font];
	CGRect stringRect = CGRectMake(rect.origin.x + rect.size.width - stringSize.width, center.y-stringSize.height/2, stringSize.width, stringSize.height);
	
	[color set];
	[text drawInRect:stringRect withFont:font];
	CGContextRestoreGState(cx);
}

- (void) drawText:(NSString *)text inRect:(CGRect)rect color:(UIColor *)color
{
	if(text == nil) return;
	CGContextRef cx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(cx);
	CGContextClipToRect(cx, rect);
	CGPoint center = CGPointMake(rect.origin.x + (rect.size.width / 2.0), rect.origin.y + (rect.size.height / 2.0));
	UIFont *font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
	
	CGSize stringSize = [text sizeWithFont:font];
	CGRect stringRect = CGRectMake(rect.origin.x, center.y-stringSize.height/2, stringSize.width, stringSize.height);
	
	[color set];
	[text drawInRect:stringRect withFont:font];
	CGContextRestoreGState(cx);
}

#pragma mark -
#pragma mark Drawing
- (BOOL) isOpaque
{
	return NO;
}

- (CGRect) playRect
{
	return CGRectMake(6, 6, self.bounds.size.height - 12, self.bounds.size.height - 12);	
}

- (CGRect) progressRect
{
	return CGRectMake(10, 10, self.bounds.size.height - 20, self.bounds.size.height - 20);	
}

- (CGRect) waveRect
{
	CGRect sr = [self statusRect];
	CGFloat y = 6;//sr.origin.y + sr.size.height + 2;
	return CGRectMake(6, y, self.bounds.size.width-12, self.bounds.size.height - 12);
}

- (CGRect) statusRect
{
	return CGRectMake(self.bounds.size.height, self.bounds.size.height - 12, self.bounds.size.width - 9 - self.bounds.size.height, 16);
//	return CGRectMake(self.bounds.size.height, 6, self.bounds.size.width - 9 - self.bounds.size.height, 16);
}

- (void) drawRoundRect:(CGRect)bounds fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor radius:(CGFloat)radius lineWidht:(CGFloat)lineWidth
{
	CGRect rrect = CGRectMake(bounds.origin.x+(lineWidth/2), bounds.origin.y+(lineWidth/2), bounds.size.width - lineWidth, bounds.size.height - lineWidth);
	
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	CGContextRef cx = UIGraphicsGetCurrentContext();
	
	CGContextMoveToPoint(cx, minx, midy);
	CGContextAddArcToPoint(cx, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(cx, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(cx, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(cx, minx, maxy, minx, midy, radius);
	CGContextClosePath(cx);
	
	CGContextSetStrokeColorWithColor(cx, strokeColor.CGColor);
	CGContextSetFillColorWithColor(cx, fillColor.CGColor);
	CGContextDrawPath(cx, kCGPathFillStroke);
}

- (void) drawPlay
{
//	CGRect playRect = [self playRect];
//	CGContextRef cx = UIGraphicsGetCurrentContext();
//	CGFloat tb = playRect.size.width * 0.22;
//	tb = fmax(tb, 6);
//	CGContextMoveToPoint(cx, playRect.origin.x + tb, playRect.origin.y + tb);
//	CGContextAddLineToPoint(cx,playRect.origin.x + playRect.size.width - tb, playRect.origin.y + (playRect.size.height/2));
//	CGContextAddLineToPoint(cx,playRect.origin.x + tb, playRect.origin.y + playRect.size.height - tb);
//	CGContextClosePath(cx);
//	CGContextSetStrokeColorWithColor(cx, darkgray.CGColor);
//	CGContextSetFillColorWithColor(cx, green.CGColor);
//	CGContextDrawPath(cx, kCGPathFillStroke);
}

- (void) drawPause
{
//	CGRect pr = [self playRect];
//	CGFloat w = pr.size.width;
//	CGFloat w2 = w / 2.0;
//	CGFloat tb = w * 0.22;
//	CGFloat ww =  w2 - tb;
//	CGContextRef cx = UIGraphicsGetCurrentContext();
//	CGContextSetStrokeColorWithColor(cx, darkgray.CGColor);
//	CGContextSetFillColorWithColor(cx, green.CGColor);
//	CGContextAddRect(cx,CGRectMake(pr.origin.x + w2 - ww - (tb/3), tb+2, ww, pr.origin.y + pr.size.height - (tb * 2)));
//	CGContextAddRect(cx,CGRectMake(pr.origin.x + w2 + (tb/3), tb+2, ww, pr.origin.y + pr.size.height - (tb * 2)));
//	CGContextAddRect(cx,CGRectMake(pr.origin.x + w2 - ww - (tb/3), tb+2, ww, pr.origin.y + pr.size.height - (tb * 2)));
//	CGContextAddRect(cx,CGRectMake(pr.origin.x + w2 + (tb/3), tb+2, ww, pr.origin.y + pr.size.height - (tb * 2)));
//	CGContextDrawPath(cx, kCGPathFillStroke);
}

- (void)drawRect:(CGRect)dirtyRect
{
	CGContextRef cx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(cx);
	
	CGContextSetFillColorWithColor(cx, [UIColor clearColor].CGColor);
	CGContextFillRect(cx, self.bounds);
	
	[self drawRoundRect:self.bounds fillColor:gray strokeColor:green radius:8.0 lineWidht:2.0];
	
	//CGRect playRect = [self playRect];
	//[self drawRoundRect:playRect fillColor:white strokeColor:darkgray radius:4.0 lineWidht:2.0];
	
	CGRect waveRect = [self waveRect];
	[self drawRoundRect:waveRect fillColor:lightgray strokeColor:darkgray radius:4.0 lineWidht:2.0];
	
	//CGRect statusRect = [self statusRect];
	//[self drawRoundRect:statusRect fillColor:lightgray strokeColor:darkgray radius:4.0 lineWidht:2.0];
	
	if(sampleLength > 0) {
		if(player.rate == 0.0) {
			[self drawPlay];
		} else {
			[self drawPause];
		}
		CGMutablePathRef halfPath = CGPathCreateMutable();
		CGPathAddLines( halfPath, NULL,sampleData, sampleLength); // magic!
		
		CGMutablePathRef path = CGPathCreateMutable();
		
		double xscale = (CGRectGetWidth(waveRect)-12.0) / (float)sampleLength;
		// Transform to fit the waveform ([0,1] range) into the vertical space 
		// ([halfHeight,height] range)
		double halfHeight = floor( CGRectGetHeight(waveRect) / 2.0 );//waveRect.size.height / 2.0;
		CGAffineTransform xf = CGAffineTransformIdentity;
		xf = CGAffineTransformTranslate( xf, waveRect.origin.x+6, halfHeight + waveRect.origin.y);
		xf = CGAffineTransformScale( xf, xscale, -(halfHeight-6) );
		CGPathAddPath( path, &xf, halfPath );
		
		// Transform to fit the waveform ([0,1] range) into the vertical space
		// ([0,halfHeight] range), flipping the Y axis
		xf = CGAffineTransformIdentity;
		xf = CGAffineTransformTranslate( xf, waveRect.origin.x+6, halfHeight + waveRect.origin.y);
		xf = CGAffineTransformScale( xf, xscale, (halfHeight-6));
		CGPathAddPath( path, &xf, halfPath );
		
		CGPathRelease( halfPath ); // clean up!
		// Now, path contains the full waveform path.		
		CGContextRef cx = UIGraphicsGetCurrentContext();
		
		[darkgray set];
		CGContextAddPath(cx, path);
		CGContextStrokePath(cx);
		
		// gauge draw
		if(playProgress > 0.0) {
			CGRect clipRect = waveRect;
			clipRect.size.width = (clipRect.size.width - 12) * playProgress;
			clipRect.origin.x = clipRect.origin.x + 6;
			CGContextClipToRect(cx,clipRect);
			
			[marker setFill];
			CGContextAddPath(cx, path);
			CGContextFillPath(cx);
			CGContextClipToRect(cx,waveRect);
			[darkgray set];
			CGContextAddPath(cx, path);
			CGContextStrokePath(cx);
		}		
		CGPathRelease(path); // clean up!
	}
	[[UIColor clearColor] setFill];
	CGContextRestoreGState(cx);
	CGRect infoRect = [self statusRect];
	infoRect.origin.x += 4;
	//	infoRect.origin.y -= 2;
	infoRect.size.width -= 65;
	[self drawText:infoString inRect:infoRect color:[UIColor greenColor]];
	CGRect timeRect = [self statusRect];
	timeRect.origin.x = timeRect.origin.x + timeRect.size.width - 65;
	//	timeRect.origin.y -= 2;
	timeRect.size.width = 60;
	[self drawTextRight:timeString inRect:timeRect color:[UIColor greenColor]];
	
}

- (void) setSampleData:(float *)theSampleData length:(int)length
{
	[progress setHidden:FALSE];
   player.rate = 1;
   playProgress = 1;
   
	[progress startAnimating];
	sampleLength = 0;
	
	length += 2;
	CGPoint *tempData = (CGPoint *)calloc(sizeof(CGPoint),length);
	tempData[0] = CGPointMake(0.0,0.0);
	tempData[length-1] = CGPointMake(length-1,0.0);
	for(int i = 1; i < length-1;i++) {
		tempData[i] = CGPointMake(i, theSampleData[i]);
	}
	
	sampleData = tempData;
	sampleLength = length;

	
	[progress setHidden:TRUE];
	[progress stopAnimating];
	[self setNeedsDisplay];
}

@end
