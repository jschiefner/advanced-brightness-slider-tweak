#import "ABSBrightnessManager.h"
#import "ReduceWhitePointLevel.h"

#define kABSBackboard CFSTR("com.apple.backboardd")
#define kABSAutoBrightnessKey CFSTR("BKEnableALS")

@interface UIDevice (Category)
@property float _backlightLevel;
@end

// used in iOS 14
@interface SBDisplayBrightnessController : NSObject
-(void)setBrightnessLevel:(float)arg1;
@end

// used in iOS 13
@interface SBBrightnessController
+(id)sharedBrightnessController;
-(void)setBrightnessLevel:(float)arg1;
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
  Boolean _whitePointShouldBeEnabled;
  SBDisplayBrightnessController* _brightnessController;
}

+(ABSBrightnessManager*)shared {
  static ABSBrightnessManager *sharedABSBrightnessManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedABSBrightnessManager = [self alloc];
  });
  return sharedABSBrightnessManager;
}

-(void)initWithAutoBrightnessEnabled:(BOOL)enabled andIosVersion:(int)iosVersion {
  _shouldModifyAutoBrightness = enabled;
  _iosVersion = iosVersion;
  if (iosVersion >= 14) _brightnessController = [%c(SBDisplayBrightnessController) new];
}

-(void)setBrightness:(float)amount {
  if (_iosVersion >= 14) [_brightnessController setBrightnessLevel:amount];
  else [[%c(SBBrightnessController) sharedBrightnessController] setBrightnessLevel:amount];
}

-(float)brightness {
  return [[%c(UIDevice) currentDevice] _backlightLevel];
}

-(BOOL)whitePointEnabled {
  return [[AXSettings sharedInstance] reduceWhitePointEnabled];
}

-(void)setWhitePointEnabled:(BOOL)enabled {
  if (enabled && _whitePointShouldBeEnabled) return;
  if (!enabled && !_whitePointShouldBeEnabled) return;

  if (enabled) [self setBrightness:0.0f];
  [[AXSettings sharedInstance] setReduceWhitePointEnabled: enabled];
  _whitePointShouldBeEnabled = enabled;
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
