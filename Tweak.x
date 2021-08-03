#import <ControlCenterUIKit/CCUICAPackageDescription.h>

@interface UIDevice (Category)
@property float _backlightLevel;
@end

@interface SBDisplayBrightnessController
-(void) setBrightnessLevel:(float) arg1;
@end

@interface CCUIContinuousSliderView : UIControl {
	CCUICAPackageDescription* _glyphPackageDescription;
	UIPanGestureRecognizer* _valueChangeGestureRecognizer;
}
-(CCUICAPackageDescription *)glyphPackageDescription;
-(void)_handleValueChangeGestureRecognizer:(id)arg1 ;
-(CGSize)size;
-(BOOL) isBrightnessSlider;
-(float) scrollMultiplier;
@end

SBDisplayBrightnessController * brightness;
float currentLevel;
float oldLevel;

%hook CCUIContinuousSliderView

-(id)initWithFrame:(CGRect)arg1 {
	id orig = %orig;
	brightness = [%c(SBDisplayBrightnessController) new];
	currentLevel = [[%c(UIDevice) currentDevice] _backlightLevel];
	oldLevel = currentLevel;
	return orig;
}

%new
-(BOOL) isBrightnessSlider {
	// TODO: implement less complex (save slider type in boolean property if possible, string comparison is expensive)
	NSString * glyphpackage = [[[self glyphPackageDescription] packageURL] absoluteString];
	return [glyphpackage rangeOfString:@"Brightness"].location != NSNotFound;
}

%new
-(float) scrollMultiplier {
	if ([self size].height > 200) {
		return 300.0f;
	} else {
		return 140.0f;
	}
}

-(void)_handleValueChangeGestureRecognizer:(id)arg1 {
	if (![self isBrightnessSlider]) return %orig;

	UIPanGestureRecognizer * recognizer = (UIPanGestureRecognizer *) arg1;
	CGPoint translation = [recognizer translationInView: self];
	float ytranslation = (float) translation.y / [self scrollMultiplier];

	if (ytranslation == 0.0f) { // TODO: when in big mode, this does not start at 0
		currentLevel = [[%c(UIDevice) currentDevice] _backlightLevel];
		oldLevel = currentLevel;
	}

	NSLog(@"ytranslation is %f", ytranslation);

	currentLevel = oldLevel - ytranslation;
	NSLog(@"setting to %f", currentLevel);
	[brightness setBrightnessLevel: currentLevel];
}

%end;
