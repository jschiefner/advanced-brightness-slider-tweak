#import "BrightnessManager.h"

@interface CCUIContinuousSliderView : UIControl
-(void)_handleValueChangeGestureRecognizer:(id)arg1;
-(BOOL)isGlyphVisible;
-(void)setGlyphState:(NSString *)arg1;
-(void)setValue:(float)arg1;
-(BOOL)isBrightnessSlider;
@end

@interface CCUICAPackageDescription : NSObject
-(NSURL *)packageURL;
@end

@interface CCUICAPackageView : UIView
-(CCUICAPackageDescription*)packageDescription;
-(void)setStateName:(NSString*)arg1;
-(BOOL)isBrightnessTopGlyph;
@end

BrightnessManager *manager;

// TODO: keep track in NSDefaults or whatever to persist after respring
// TODO: observe external brightness changes and adjust this variable accordingly (if issues with jumping value keeps happening)
float currentSliderLevel;

float threshold = 0.3; // value where slider switches from brightness to
float oldSliderLevel; // keep track of where slider was to calculate panning offset
float distance;

CCUICAPackageView* topBrightnessGlyphPackage;
NSString* glyphState;

float clampZeroOne(float value) {
	if (value > 1) return 1.0f;
	else if (value < 0) return 0.0f;
	else return value;
}

void calculateGlyphState() {
	// possible arg1 values: min, mid, full, max
	if (currentSliderLevel < threshold) {
		glyphState = @"min";
	} else {
		float brightness = [manager brightness];
		if (currentSliderLevel == 1.0f) {
			glyphState = @"max";
		} else if (brightness > 0.5f) {
			glyphState = @"full";
		} else {
			glyphState = @"mid";
		}
	}
}

%hook CCUIContinuousSliderView

-(id)initWithFrame:(CGRect)arg1 {
	id orig = %orig;
	if ([orig isBrightnessSlider]) {
		manager = [[%c(BrightnessManager) alloc] init];
		currentSliderLevel = [manager brightness] * (1-threshold) + threshold;
		oldSliderLevel = currentSliderLevel;
		distance = 1 - threshold;
	}
	return orig;
}

%new
-(BOOL)isBrightnessSlider {
	return ![self isKindOfClass:[%c(MediaControlsVolumeSliderView) class]];
}

// example values and ranges assuming threshold == 0.3
-(void)_handleValueChangeGestureRecognizer:(id)arg1 {
	if (![self isBrightnessSlider]) return %orig;

	UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *) arg1;
	CGPoint translation = [recognizer translationInView: self];
	float ytranslation = (float) translation.y / [self frame].size.height;

	if ([recognizer state] == UIGestureRecognizerStateBegan) {
		oldSliderLevel = currentSliderLevel;
	}

	currentSliderLevel = clampZeroOne(oldSliderLevel - ytranslation);
	calculateGlyphState();
	if (currentSliderLevel >= threshold) { // brightness
		float upperSectionSliderLevel = currentSliderLevel - threshold; // in 0.7..0
		float newBrightnessLevel = upperSectionSliderLevel / distance; // in 1..0
		if ([manager whitePointEnabled]) [manager setWhitePointEnabled:NO];
		[manager setBrightness:newBrightnessLevel];
		[manager setAutoBrightnessEnabled:YES];
	} else { // whitepoint
		float lowerSectionSliderLevel = currentSliderLevel; // 0..0.3
		float newWhitePointLevel = lowerSectionSliderLevel / threshold; // 0..1
		float newAdjustedWhitePointLevel = 1 - (newWhitePointLevel * 0.75f); // 1..0.25
		if (![manager whitePointEnabled]) [manager setWhitePointEnabled:YES];
		[manager setWhitePointLevel:newAdjustedWhitePointLevel];
		[self setValue:-newAdjustedWhitePointLevel];
		[manager setAutoBrightnessEnabled:NO];
		[self setGlyphState:nil]; // argument is ignored
		if (topBrightnessGlyphPackage != nil) {
			[topBrightnessGlyphPackage setStateName:nil]; // argument is ignored
		}
	}
}

// example values and ranges assuming threshold == 0.3
-(void)setValue:(float)arg1 {
	if(![self isBrightnessSlider]) return %orig;

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

-(void)setGlyphState:(NSString *)arg1 {
	if (![self isBrightnessSlider]) {
		%orig(arg1);
	} else {
		%orig(glyphState);
	}
}

%end

%hook CCUICAPackageView

%new
-(BOOL)isBrightnessTopGlyph {
	NSString* packageName = [[[self packageDescription] packageURL] absoluteString];
	BOOL isBrightnessPackage = [packageName isEqual:@"file:///System/Library/ControlCenter/Bundles/DisplayModule.bundle/Brightness.ca/"];
	BOOL isTop = ![[self superview] isKindOfClass:[%c(CCUIContinuousSliderView) class]];
	return isBrightnessPackage && isTop;
}

-(void)setStateName:(NSString*)arg1 {
	if ([self isBrightnessTopGlyph]) {
		topBrightnessGlyphPackage = self;
		%orig(glyphState);
	} else {
		%orig;
	}
}

%end
