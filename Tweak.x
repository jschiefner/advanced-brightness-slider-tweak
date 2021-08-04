#import <ControlCenterUIKit/CCUICAPackageDescription.h>
#import "ReduceWhitePointLevel.h"

@interface UIDevice (Category)
@property float _backlightLevel;
@end

@interface SBDisplayBrightnessController
-(void) setBrightnessLevel:(float) arg1;
@end

@interface CCUIContinuousSliderView : UIControl
-(CCUICAPackageDescription *)glyphPackageDescription;
-(void)_handleValueChangeGestureRecognizer:(id)arg1;
-(BOOL)isGlyphVisible;
-(CGSize)size;
-(void)drawDashedLine;
-(void)setValue:(float)arg1;
-(BOOL) isBrightnessSlider;
-(float) inSmallMode;
@end

@interface AXSettings
+(id)sharedInstance;
-(BOOL)reduceWhitePointEnabled;
-(void)setReduceWhitePointEnabled:(BOOL)arg1;
@end

SBDisplayBrightnessController * brightness;
float currentSliderLevel; // TODO: update this when system brightness changes from elsewhere (with listener)
float oldSliderLevel; // keep track of where slider was to calculate panning offset
float threshold = 0.3; // value where slider switches from brightness to

float clampZeroOne(float value) {
	if (value > 1) return 1.0f;
	else if (value < 0) return 0.0f;
	else return value;
}

%hook CCUIContinuousSliderView

-(id)initWithFrame:(CGRect)arg1 {
	id orig = %orig;
	if ([orig isBrightnessSlider]) {
		brightness = [%c(SBDisplayBrightnessController) new];
		currentSliderLevel = [[%c(UIDevice) currentDevice] _backlightLevel];
		oldSliderLevel = currentSliderLevel;
		[orig drawDashedLine];
	}
	return orig;
}

%new
-(BOOL)isBrightnessSlider {
	return ![self isKindOfClass: [%c(MediaControlsVolumeSliderView) class]];
}

%new
-(float)inSmallMode {
	return [self isGlyphVisible];
}

%new
-(void)drawDashedLine {
	CAShapeLayer * shapelayer = [%c(CAShapeLayer) new];
	UIBezierPath *path = [%c(UIBezierPath) bezierPath];
	//draw a line
	int y = 80;
	[path moveToPoint:CGPointMake(0,y)]; //add yourStartPoint here
	[path addLineToPoint:CGPointMake(69,y)];// add yourEndPoint here
	[path stroke];

	CGFloat dashPattern[] = {2.0f,6.0f,4.0f,2.0f}; //make your pattern here
	[path setLineDash:dashPattern count:4 phase:3];

	shapelayer.strokeStart = 0.0;
	shapelayer.strokeColor = [UIColor colorWithWhite: 0 alpha: 0.3f].CGColor;
	shapelayer.lineWidth = 1.0;
	shapelayer.lineJoin = kCALineJoinMiter;
	shapelayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:10],[NSNumber numberWithInt:7], nil];
	shapelayer.lineDashPhase = 3.0f;
	shapelayer.path = path.CGPath;

	[self.layer addSublayer:shapelayer];
}

-(BOOL)isGlyphVisible {
	%log;
	NSLog(@"%@", NSStringFromCGRect([self frame]));
	return %orig;
}

-(void)_handleValueChangeGestureRecognizer:(id)arg1 {
	if (![self isBrightnessSlider]) return %orig;

	UIPanGestureRecognizer * recognizer = (UIPanGestureRecognizer *) arg1;
	CGPoint translation = [recognizer translationInView: self];
	float ytranslation = (float) translation.y / ([self inSmallMode] ? 160.0f : 350.0f);

	if ([recognizer state] == UIGestureRecognizerStateBegan) {
		oldSliderLevel = currentSliderLevel;
	}

	currentSliderLevel = clampZeroOne(oldSliderLevel - ytranslation);
	AXSettings * axSettings = [%c(AXSettings) sharedInstance];
	if (currentSliderLevel >= threshold) {
		float distance = 1 - threshold; // 0.7
		float upperSectionSliderLevel = currentSliderLevel - threshold; // in 0.7..0
		float newBrightnessLevel = upperSectionSliderLevel / distance; // in 1..0
		if ([axSettings reduceWhitePointEnabled]) [axSettings setReduceWhitePointEnabled: NO];
		[brightness setBrightnessLevel: newBrightnessLevel];
	} else {
		float distance = threshold; // 0.3
		float lowerSectionSliderLevel = currentSliderLevel; // 0..0..3
		float newWhitePointLevel = lowerSectionSliderLevel / distance; // 0..1
		float newAdjustedWhitePointLevel = 1 - (newWhitePointLevel * 0.75f); // 1..0.25
		if (![axSettings reduceWhitePointEnabled]) [axSettings setReduceWhitePointEnabled: YES];
		MADisplayFilterPrefSetReduceWhitePointIntensity(newAdjustedWhitePointLevel);
		[self setValue: -newAdjustedWhitePointLevel];
	}
}

-(void) setValue:(float)arg1 {
	if(![self isBrightnessSlider]) return %orig;

	if (arg1 >= 0) {
		// brightness
		float distance = 1 - threshold; // 0.7
		float newSliderLevel = arg1 * distance + threshold; // 1..0.3
		%orig(newSliderLevel);
	} else {
		// arg1 -0.25..-1
		float distance = threshold; // 0.3
		float whitePointLevel = -arg1; // 1..0.25
		float levelBetween0and1 = (whitePointLevel - 0.25f) / 0.75f; // 0..1
		float newSliderLevel = distance - (levelBetween0and1 * distance); // 0.3..0
		%orig(newSliderLevel);
	}
}

%end;
