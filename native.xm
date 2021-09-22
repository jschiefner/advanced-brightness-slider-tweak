#import "shared.h"
#import "ABSBrightnessManager.h"

@interface CCUIContinuousSliderView : UIControl
@property (nonatomic) BOOL isBrightnessSlider;
-(void)_handleValueChangeGestureRecognizer:(id)arg1;
-(void)setGlyphState:(NSString*)arg1;
-(void)setValue:(float)arg1;
@end

@interface CCUICAPackageDescription : NSObject
-(NSURL *)packageURL;
@end

@interface CCUICAPackageView : UIView
@property (nonatomic) BOOL isBrightnessTopGlyph;
-(void)setPackageDescription:(CCUICAPackageDescription*)arg1;
-(void)setStateName:(NSString*)arg1;
@end

float currentSliderLevel; // stores the current level the brightness slider is set to
float threshold; // value where slider switches from brightness to white point
float oldSliderLevel; // keep track of where slider was to calculate panning offset
float distance; // will be set to 1 - threshold
float halfDistance; // half between threshold and 1
NSString* glyphState; // stores current state of the glyph
CCUICAPackageView* brightnessTopGlyphPackageView; // stores a reference to the top glyph so it can be updated
int iosVersion; // stores the major iOS version

float clampZeroOne(float value) {
	if (value > 1) return 1.0f;
	else if (value < 0) return 0.0f;
	else return value;
}

void calculateGlyphState() {
	// possible glyphState values: min, mid, full, max
	if (currentSliderLevel < threshold) {
		glyphState = @"min";
	} else {
		if (currentSliderLevel == 1.0f) {
			glyphState = @"max";
		} else if (currentSliderLevel > halfDistance) {
			glyphState = @"full";
		} else {
			glyphState = @"mid";
		}
	}
}

%group Native

%hook CCUIContinuousSliderView
%property (nonatomic) BOOL isBrightnessSlider;

-(void)setGlyphPackageDescription:(CCUICAPackageDescription*)arg1 {
	%orig;
	self.isBrightnessSlider = [[[arg1 packageURL] absoluteString] isEqual:@"file:///System/Library/ControlCenter/Bundles/DisplayModule.bundle/Brightness.ca/"];
}

// example values and ranges assuming threshold == 0.3
-(void)_handleValueChangeGestureRecognizer:(id)arg1 {
	if (!self.isBrightnessSlider) return %orig;

	UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *) arg1;
	CGPoint translation = [recognizer translationInView:self];
	float ytranslation = (float) translation.y / [self frame].size.height;

	if ([recognizer state] == UIGestureRecognizerStateBegan) {
		oldSliderLevel = currentSliderLevel;
	}

	currentSliderLevel = clampZeroOne(oldSliderLevel - ytranslation);
	calculateGlyphState();
	if (currentSliderLevel >= threshold) { // brightness
		float upperSectionSliderLevel = currentSliderLevel - threshold; // 0.7..0
		float newBrightnessLevel = upperSectionSliderLevel / distance; // 1..0
		[[ABSBrightnessManager shared] setWhitePointEnabled:NO];
		[[ABSBrightnessManager shared] setBrightness:newBrightnessLevel];
		[[ABSBrightnessManager shared] setAutoBrightnessEnabled:YES];
		if (iosVersion < 14) [self setValue:newBrightnessLevel]; // called automatically on iOS 14
	} else { // whitepoint
		float lowerSectionSliderLevel = currentSliderLevel; // 0..0.3
		float newWhitePointLevel = lowerSectionSliderLevel / threshold; // 0..1
		float newAdjustedWhitePointLevel = 1 - (newWhitePointLevel * 0.75f); // 1..0.25
		[[ABSBrightnessManager shared] setWhitePointEnabled:YES];
		[[ABSBrightnessManager shared] setWhitePointLevel:newAdjustedWhitePointLevel];
		[self setValue:-newAdjustedWhitePointLevel];
		[[ABSBrightnessManager shared] setAutoBrightnessEnabled:NO];
		[self setGlyphState:nil]; // argument is ignored
		if (brightnessTopGlyphPackageView != nil)
			[brightnessTopGlyphPackageView setStateName:nil]; // argument is ignored
	}
}

// example values and ranges assuming threshold == 0.3
-(void)setValue:(float)arg1 {
	if(!self.isBrightnessSlider) return %orig;

	if (arg1 >= 0) {
		// brightness, arg1 0..1
		if (currentSliderLevel < threshold) return;
		currentSliderLevel = arg1 * distance + threshold; // 1..0.3
		%orig(currentSliderLevel);
	} else {
		// white point, arg1 -0.25..-1
		float whitePointLevel = -arg1; // 1..0.25
		float levelBetween0and1 = (whitePointLevel - 0.25f) / 0.75f; // 0..1
		currentSliderLevel = threshold - (levelBetween0and1 * threshold); // 0.3..0
		%orig(currentSliderLevel);
	}
}

-(void)setGlyphState:(NSString*)arg1 {
	self.isBrightnessSlider ? %orig(glyphState) : %orig;
}

%end

%hook CCUICAPackageView
%property (nonatomic) BOOL isBrightnessTopGlyph;

-(void)setPackageDescription:(CCUICAPackageDescription*)arg1 {
	%orig;
	BOOL isBrightnessPackage = [[[arg1 packageURL] absoluteString] isEqual:@"file:///System/Library/ControlCenter/Bundles/DisplayModule.bundle/Brightness.ca/"];
	BOOL isTop = ![[self superview] isKindOfClass:[%c(CCUIContinuousSliderView) class]];
	if (isBrightnessPackage && isTop) {
		self.isBrightnessTopGlyph = YES;
		brightnessTopGlyphPackageView = self;
	} else {
		self.isBrightnessTopGlyph = NO;
	}
}

-(void)setStateName:(NSString*)arg1 {
	self.isBrightnessTopGlyph ? %orig(glyphState) :	%orig;
}

%end
%end

extern "C" void initNative(NSDictionary* bundleDefaults) {
	threshold = [bundleDefaults objectForKey:@"threshold"] == nil ? 0.3f : [[bundleDefaults objectForKey:@"threshold"] floatValue] / 100.0f;
	distance = 1 - threshold;
	halfDistance = distance / 2 + threshold;
	currentSliderLevel = [[ABSBrightnessManager shared] brightness] * distance + threshold;
	oldSliderLevel = currentSliderLevel;
  %init(Native);
}