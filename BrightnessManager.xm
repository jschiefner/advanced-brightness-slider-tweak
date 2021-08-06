#import "BrightnessManager.h"
#import "ReduceWhitePointLevel.h"

#define kABSBackboard CFSTR("com.apple.backboardd")
#define kABSAutoBrightnessKey CFSTR("BKEnableALS")

@interface UIDevice (Category)
@property float _backlightLevel;
@end

@interface SBDisplayBrightnessController : NSObject
-(void) setBrightnessLevel:(float) arg1;
@end

@interface AXSettings
+(id)sharedInstance;
-(BOOL)reduceWhitePointEnabled;
-(void)setReduceWhitePointEnabled:(BOOL)arg1;
@end

@implementation BrightnessManager {
  Boolean _autoBrightnessShouldBeEnabled;
  SBDisplayBrightnessController* _brightnessController;
}

-(id)init {
  _brightnessController = [%c(SBDisplayBrightnessController) new];
  return self;
}

-(void)setBrightness:(float)amount {
  [_brightnessController setBrightnessLevel:amount];
}

-(float)brightness {
  return [[%c(UIDevice) currentDevice] _backlightLevel];
}

-(BOOL)whitePointEnabled {
  return [[AXSettings sharedInstance] reduceWhitePointEnabled];
}

-(void)setWhitePointEnabled:(BOOL)enabled {
  [[AXSettings sharedInstance] setReduceWhitePointEnabled: enabled];
}

-(void)setWhitePointLevel:(float)amount {
  MADisplayFilterPrefSetReduceWhitePointIntensity(amount);
}

-(float)whitePointLevel {
  return MADisplayFilterPrefGetReduceWhitePointIntensity();
}

-(void)setAutoBrightnessEnabled:(BOOL)enabled {
  if (enabled && _autoBrightnessShouldBeEnabled) return;
	if (!enabled && !_autoBrightnessShouldBeEnabled) return;

	CFPreferencesSetAppValue(kABSAutoBrightnessKey, enabled ? kCFBooleanTrue : kCFBooleanFalse, kABSBackboard);
	CFPreferencesAppSynchronize(kABSBackboard);
	_autoBrightnessShouldBeEnabled = enabled;
}
@end
