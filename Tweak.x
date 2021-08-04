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
-(float) inSmallMode;
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
-(float) inSmallMode {
	return [self size].height <= 200;
}

-(void)_handleValueChangeGestureRecognizer:(id)arg1 {
	if (![self isBrightnessSlider]) return %orig;

	UIPanGestureRecognizer * recognizer = (UIPanGestureRecognizer *) arg1;
	CGPoint translation = [recognizer translationInView: self];
	float ytranslation = (float) translation.y / ([self inSmallMode] ? 160.0f : 350.0f);

	if ([recognizer state] == UIGestureRecognizerStateBegan) {
		currentLevel = [[%c(UIDevice) currentDevice] _backlightLevel];
		oldLevel = currentLevel;
	}

	currentLevel = oldLevel - ytranslation;
	[brightness setBrightnessLevel: currentLevel];
}

%end;
