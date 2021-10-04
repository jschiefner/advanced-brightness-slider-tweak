#import "shared.h"
#import "ABSManager.h"

float oldNativeSliderLevel; // keep track of where slider was before panning to calculate panning offset
CCUICAPackageView* brightnessTopGlyphPackageView; // stores a reference to the top glyph so it can be updated
ABSManager* nativeManager; // reference the shared manager object for the Native Group

%group Native

%hook CCUIContinuousSliderView
%property (nonatomic) BOOL isBrightnessSlider;

-(void)setGlyphPackageDescription:(CCUICAPackageDescription*)arg1 {
	%orig;
	self.isBrightnessSlider = [[[arg1 packageURL] absoluteString] isEqual:@"file:///System/Library/ControlCenter/Bundles/DisplayModule.bundle/Brightness.ca/"];
	if (self.isBrightnessSlider) [nativeManager setNativeSliderView:self];
}

-(void)_handleValueChangeGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
	if (!self.isBrightnessSlider) return %orig;

	if ([recognizer state] == UIGestureRecognizerStateBegan)
		oldNativeSliderLevel = nativeManager.currentSliderLevel;

	BOOL inBrightnessSection = [nativeManager moveWithGestureRecognizer:recognizer withOldSliderLevel:oldNativeSliderLevel withView:self withYDirection:YES];
	if (!inBrightnessSection || nativeManager.iosVersion < 14) {
		[self setGlyphState:nil]; // argument is ignored
		if (brightnessTopGlyphPackageView != nil) [brightnessTopGlyphPackageView setStateName:nil]; // argument is ignored
	}
}

-(void)setValue:(float)arg1 {
	if(!self.isBrightnessSlider) return %orig;

	if (arg1 >= 0) { // brightness, arg1 = system brightness 0..1
		if (![nativeManager whitePointShouldBeEnabled])
			[nativeManager updateCurrentSliderLevelWithSystemBrightness:arg1];
		%orig(nativeManager.currentSliderLevel);
	} else { // whitepoint arg1 = currentSliderLevel -0..1
		%orig(-arg1);
	}
}

-(void)setGlyphState:(NSString*)arg1 {
	self.isBrightnessSlider ? %orig(nativeManager.glyphState) : %orig;
}

%end

%hook CCUICAPackageView

-(void)setPackageDescription:(CCUICAPackageDescription*)arg1 {
	%orig;
	BOOL isBrightnessPackage = [[[arg1 packageURL] absoluteString] isEqual:@"file:///System/Library/ControlCenter/Bundles/DisplayModule.bundle/Brightness.ca/"];
	BOOL isTop = [[[self nextResponder] nextResponder] isKindOfClass:[%c(CCUIDisplayBackgroundViewController) class]];
	if (isBrightnessPackage && isTop) brightnessTopGlyphPackageView = self;
}

-(void)setStateName:(NSString*)arg1 {
	self == brightnessTopGlyphPackageView ? %orig(nativeManager.glyphState) :	%orig;
}

%end
%end

extern "C" void initNative() {
  nativeManager = [ABSManager shared];
	oldNativeSliderLevel = nativeManager.currentSliderLevel;
  %init(Native);
}
