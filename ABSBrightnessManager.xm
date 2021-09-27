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
// -(void)setReduceWhitePointLevel:(float)arg1; this method does not work, see below for an alternative
@end

@implementation ABSBrightnessManager {
  Boolean _shouldModifyAutoBrightness;
  float _halfDistance;
  CCUIContinuousSliderView* _nativeSliderView;
  Boolean _autoBrightnessShouldBeEnabled;
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

+(float)clampZeroOne:(float)value {
	if (value > 1) return 1.0f;
	else if (value < 0) return 0.0f;
	else return value;
}

-(void)initWithAutoBrightnessEnabled:(BOOL)enabled andIosVersion:(int)iosVersion andThreshold:(float)threshold {
  _shouldModifyAutoBrightness = enabled;
  _iosVersion = iosVersion;
  _threshold = threshold;
  _distance = 1 - threshold;
  _currentSliderLevel = [self whitePointEnabled] ? (([self whitePointLevel] - 0.25) / 0.75) * _distance + threshold : ([self brightness] * _distance + threshold);
  _halfDistance = (1-threshold) / 2 + threshold;
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
  _whitePointShouldBeEnabled = [[AXSettings sharedInstance] reduceWhitePointEnabled];
  return _whitePointShouldBeEnabled;
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

-(void)calculateGlyphState {
  // possible glyphState values: min, mid, full, max
	if (_currentSliderLevel < _threshold) {
		_glyphState = @"min";
	} else {
		if (_currentSliderLevel == 1.0f) {
			_glyphState = @"max";
		} else if (_currentSliderLevel > _halfDistance) {
			_glyphState = @"full";
		} else {
			_glyphState = @"mid";
		}
	}
}

-(BOOL)moveWithGestureRecognizer:(UIPanGestureRecognizer*)recognizer withOldSliderLevel:(float)oldSliderLevel withView:(UIView*)view withYDirection:(BOOL)isY {
  CGPoint translationPoint = [recognizer translationInView:view];
  float translation = (float) isY ? translationPoint.y / [view frame].size.height : -translationPoint.x / [view frame].size.width;

  _currentSliderLevel = [ABSBrightnessManager clampZeroOne:oldSliderLevel-translation];
  [self calculateGlyphState];

  if (_currentSliderLevel >= _threshold) { // brightness
    float upperSectionSliderLevel = _currentSliderLevel - _threshold; // 0.7..0
	  float newBrightnessLevel = upperSectionSliderLevel / _distance; // 1..0
    [self setWhitePointEnabled:NO];
    [self setBrightness:newBrightnessLevel];
    [self setAutoBrightnessEnabled:YES];
    if (_iosVersion < 14)
      [_nativeSliderView setValue:-_currentSliderLevel];
    return YES;
  } else { // whitepoint
    float lowerSectionSliderLevel = _currentSliderLevel; // 0..0.3
		float newWhitePointLevel = lowerSectionSliderLevel / _threshold; // 0..1
		float newAdjustedWhitePointLevel = 1 - (newWhitePointLevel * 0.75f); // 1..0.25
		[self setWhitePointEnabled:YES];
		[self setWhitePointLevel:newAdjustedWhitePointLevel];
		[self setAutoBrightnessEnabled:NO];
    [_nativeSliderView setValue:-_currentSliderLevel];
    return NO;
  }
}

-(void)setCurrentSliderLevel:(float)brightnessLevel {
  // brightnessLevel 0..1 system brightness
  _currentSliderLevel = brightnessLevel * _distance + _threshold; // 1..0.3
}

-(void)setNativeSliderView:(CCUIContinuousSliderView*)view {
  _nativeSliderView = view;
}
@end
