#import "ABSBrightnessManager.h"
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

@implementation ABSBrightnessManager {
  Boolean _shouldModifyAutoBrightness;
  int _iosVersion;
  Boolean _autoBrightnessShouldBeEnabled;
  SBDisplayBrightnessController* _brightnessController;
}

-(id)initWithAutoBrightnessEnabled:(BOOL)enabled andIosVersion:(int)iosVersion {
  _shouldModifyAutoBrightness = enabled;
  _iosVersion = iosVersion;
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
  // credits: https://github.com/opa334/WhitePointModule/blob/944087e67d1bed03282240e16d7e78294f59e865/WhitePointModule.m#L105
  MADisplayFilterPrefSetReduceWhitePointIntensity(amount);
}

-(float)whitePointLevel {
  // credits: https://github.com/opa334/WhitePointModule/blob/944087e67d1bed03282240e16d7e78294f59e865/WhitePointModule.m#L79
  return MADisplayFilterPrefGetReduceWhitePointIntensity();
}

-(void)setAutoBrightnessEnabled:(BOOL)enabled {
  if (!_shouldModifyAutoBrightness) return;
  if (enabled && _autoBrightnessShouldBeEnabled) return;
  if (!enabled && !_autoBrightnessShouldBeEnabled) return;

  // credits: https://github.com/a3tweaks/Flipswitch/blob/c1fe70e25d843c1c55b1df954b256ca5850910af/Switches/AutoBrightness.x#L28-L30
  CFPreferencesSetAppValue(kABSAutoBrightnessKey, enabled ? kCFBooleanTrue : kCFBooleanFalse, kABSBackboard);
  CFPreferencesAppSynchronize(kABSBackboard);
  _autoBrightnessShouldBeEnabled = enabled;
}
@end
