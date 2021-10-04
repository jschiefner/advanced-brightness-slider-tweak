#import "shared.h"
#import "ABSManager.h"

float oldBigSurSliderLevel;
ABSManager* bigSurManager;

%group BigSurCenter
%hook SCDisplaySliderModuleViewController

-(void)viewDidLoad {
  %orig;
  [bigSurManager setBigSurSliderController:self];
}

// TODO: better explain modify auto-brightness setting. "if you do not wish to use auto-brightness at all, toggle this off, respring and then toggle off auto-brightness in accessibility"
-(void)updateSliderValue {
  bigSurManager.whitePointShouldBeEnabled ? [self setImageForFraction:0.f] : [self setImageForFraction:1.f];

  float width;
  if ([self style] == 0) { // iOS slider
    width = self.view.frame.size.width;
  } else { // macOS Slider
    width = self.knobView.superview.superview.frame.size.width - self.knobView.frame.size.width;
  }
  float newConstraintConstant = -width + bigSurManager.currentSliderLevel * width;
  [self.sliderLeadingConstraint setConstant:newConstraintConstant];
}

-(void)sliderValueChanged:(UIPanGestureRecognizer*)recognizer {
  if ([recognizer state] == UIGestureRecognizerStateBegan) {
		oldBigSurSliderLevel = bigSurManager.currentSliderLevel;
	}

  [bigSurManager moveWithGestureRecognizer:recognizer withOldSliderLevel:oldBigSurSliderLevel withView:self.sliderView withYDirection:NO];
  [self updateSliderValue];
}

%end
%end

extern "C" void initBigSurCenter() {
  bigSurManager = [ABSManager shared];
  oldBigSurSliderLevel = bigSurManager.currentSliderLevel;
  %init(BigSurCenter);
}
