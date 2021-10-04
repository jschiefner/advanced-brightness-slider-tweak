#import "shared.h"
#import "ABSManager.h"

float oldPrysmSliderLevel; // keep track of where slider was before panning to calculate panning offset
float previousPrysmSliderLevel; // store slider level in the previous call to calculate when haptic feedback should be performed
BOOL sliderHaptic; // store whether the sliders should perform haptic feedback
UIImpactFeedbackGenerator* feedbackGenerator; // store a feedback generator when necessary
ABSManager* prysmManager; // reference the shared manager object for the Prysm Group

%group Prysm
%hook PrysmSliderViewController

%new
-(BOOL)isBrightnessSlider {
	return self.style == 1;
}

-(void)move:(UIPanGestureRecognizer*)recognizer {
	if (![self isBrightnessSlider]) return %orig;

	if ([recognizer state] == UIGestureRecognizerStateBegan)
		oldPrysmSliderLevel = prysmManager.currentSliderLevel;

	[prysmManager moveWithGestureRecognizer:recognizer withOldSliderLevel:oldPrysmSliderLevel withView:self.view withYDirection:NO]; // ignore return value
	[self setProgressValue:-prysmManager.currentSliderLevel animated:NO];
	[self.packageView setStateName:prysmManager.glyphState];
	if (sliderHaptic && previousPrysmSliderLevel != prysmManager.currentSliderLevel && (prysmManager.currentSliderLevel == 0 || prysmManager.currentSliderLevel == 1))
		[feedbackGenerator impactOccurred];
	previousPrysmSliderLevel = prysmManager.currentSliderLevel;
}

-(void)setProgressValue:(double)arg1 animated:(BOOL)arg2 {
	if (![self isBrightnessSlider]) return %orig;

	if (arg1 >= 0) { // called by prysm tweak / system, arg1 0..1
		if (![prysmManager whitePointShouldBeEnabled])
			[prysmManager updateCurrentSliderLevelWithSystemBrightness:arg1];
		%orig(prysmManager.currentSliderLevel, arg2);
	} else { // called my my tweak, arg1 -1..0
		%orig(-arg1, arg2);
	}
}

%end
%end

extern "C" void initPrysm() {
	NSDictionary* bundleDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.laughingquoll.prysmprefs"];
	if (bundleDefaults == nil) sliderHaptic = YES;
	else sliderHaptic = [bundleDefaults objectForKey:@"sliderHaptic"] == nil ? YES : [[bundleDefaults objectForKey:@"sliderHaptic"] boolValue];
	prysmManager = [ABSManager shared];
	oldPrysmSliderLevel = prysmManager.currentSliderLevel;
	previousPrysmSliderLevel = oldPrysmSliderLevel;
	if (sliderHaptic) feedbackGenerator = [[%c(UIImpactFeedbackGenerator) alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
  %init(Prysm);
}
