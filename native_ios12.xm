#import "shared.h"
#import "ABSManager.h"

float oldNativeiOS12SliderLevel;
ABSManager* nativeIOS12Manager;
UIPanGestureRecognizer* gestureRecognizer;

%group NativeIOS12

%hook CCUIDisplayModuleViewController

-(void)_sliderEditingDidBegin:(id)arg1 {
  oldNativeiOS12SliderLevel = nativeIOS12Manager.currentSliderLevel;
}

-(void)_sliderValueDidChange:(CCUIModuleSliderView*)view {
  if (gestureRecognizer == nil) {
    [view setIsBrightnessSlider:YES];
    [nativeIOS12Manager setNativeIOS12SliderView:view];
    gestureRecognizer = (UIPanGestureRecognizer*) [view gestureRecognizers][0];
  }

  BOOL inBrightnessSection = [nativeIOS12Manager moveWithGestureRecognizer:gestureRecognizer withOldSliderLevel:oldNativeiOS12SliderLevel withView:view withYDirection:YES];
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

  // updating with system brightness not working correctly
  if (arg1 < 0) %orig(-arg1); // brightness, arg1 = manager brightness -1..0
}

%end
%end

extern "C" void initNativeIOS12() {
  nativeIOS12Manager = [ABSManager shared];
	oldNativeiOS12SliderLevel = nativeIOS12Manager.currentSliderLevel;
  %init(NativeIOS12);
}
