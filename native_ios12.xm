#import "shared.h"
#import "ABSManager.h"

float oldNativeiOS12SliderLevel;
ABSManager* nativeIOS12Manager;
UIPanGestureRecognizer* theGestureRecognizer;

%group NativeIOS12

%hook CCUIDisplayModuleViewController

// -(void)setSliderView:(CCUIModuleSliderView *)arg1; {
//   %orig;
// }

-(void)_sliderEditingDidBegin:(id)arg1 {
  oldNativeiOS12SliderLevel = nativeIOS12Manager.currentSliderLevel;
}

-(void)_sliderValueDidChange:(CCUIModuleSliderView*)view {
  if (theGestureRecognizer == nil) {
    [view setIsBrightnessSlider:YES];
    [nativeIOS12Manager setNativeIOS12SliderView:view];
    theGestureRecognizer = (UIPanGestureRecognizer*) [view gestureRecognizers][0];
  }

  BOOL inBrightnessSection = [nativeIOS12Manager moveWithGestureRecognizer:theGestureRecognizer withOldSliderLevel:oldNativeiOS12SliderLevel withView:view withYDirection:YES];
  if (!inBrightnessSection) [self setGlyphState:nil]; // argument is ignored
}

-(void)setGlyphState:(NSString*)arg1 {
  %orig(nativeIOS12Manager.glyphState);
}



%end

%hook CCUIModuleSliderView
%property (nonatomic) BOOL isBrightnessSlider;

-(void)setValue:(float)arg1 {
  if (!self.isBrightnessSlider) return %orig;

  if (arg1 >= 0) { // brightness, arg1 = system brightness 0..1
    // TODO: comment back in?
    // if (![nativeIOS12Manager whitePointShouldBeEnabled])
    //   [nativeIOS12Manager updateCurrentSliderLevelWithSystemBrightness:arg1];
    // %orig(nativeIOS12Manager.currentSliderLevel);
  } else { // arg1 = -currentSliderLevel -0..1
    %orig(-arg1);
  }
}

%end

%end

extern "C" void initNativeIOS12() {
  nativeIOS12Manager = [ABSManager shared];
	oldNativeiOS12SliderLevel = nativeIOS12Manager.currentSliderLevel;
  %init(NativeIOS12);
}
