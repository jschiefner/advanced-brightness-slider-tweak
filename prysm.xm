#import "shared.h"
#import "ABSBrightnessManager.h"

%group Prysm
%hook PrysmSliderViewController
-(void)setProgressValue:(double)arg1 animated:(BOOL)arg2 {
	%log;
	%orig;
}
%end
%end

extern "C" void initPrysm(NSDictionary* bundleDefaults) {
  %init(Prysm);
}
