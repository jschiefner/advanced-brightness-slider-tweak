#import "ABSManager.h"
#import "ReduceWhitePointLevel.h"

@interface UIDevice (Category)
@property float _backlightLevel;
@end

@interface AXSettings
+(id)sharedInstance;
-(BOOL)reduceWhitePointEnabled;
-(void)setReduceWhitePointEnabled:(BOOL)arg1;
// -(void)setReduceWhitePointLevel:(float)arg1; this method does not work, see below for an alternative
@end

NSArray<NSString*> *glyphStates = @[@"min", @"mid", @"full", @"max"];

@implementation ABSManager {
  float _halfDistance;
  int _glyphState;
  CCUIContinuousSliderView* _nativeSliderView;
  CCUIModuleSliderView* _nativeIOS12SliderView;
  SCDisplaySliderModuleViewController* _bigSurSliderController;
  Boolean _autoBrightnessShouldBeEnabled;
}

+(ABSManager*)shared {
  static ABSManager *sharedABSManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedABSManager = [self alloc];
  });
  return sharedABSManager;
}

+(float)clampZeroOne:(float)value {
	if (value > 1) return 1.0f;
	else if (value < 0) return 0.0f;
	else return value;
}

-(void)initWithAutoBrightnessEnabled:(BOOL)modifyAutoBrightness andIosVersion:(int)iosVersion andThreshold:(float)threshold {
  _modifyAutoBrightness = modifyAutoBrightness;
  _iosVersion = iosVersion;
  _threshold = threshold;
  _distance = 1 - threshold;
  _halfDistance = (1-threshold) / 2 + threshold;
  [self reCalculateCurrentSliderLevel];
  [self calculateGlyphState];
}

-(void)reCalculateCurrentSliderLevel {
  if ([self whitePointEnabled]) {
    _currentSliderLevel = _threshold - (([self whitePointLevel] - 0.25) / 0.75) * _threshold;
  } else {
    _currentSliderLevel = [self brightness] * _distance + _threshold;
  }
}

-(void)setThreshold:(float)threshold {
  _threshold = threshold;
  _distance = 1-threshold;
  _halfDistance = (1-threshold) / 2 + threshold;
  [self reCalculateCurrentSliderLevel];

  _iosVersion >= 13 ? [_nativeSliderView setValue:-_currentSliderLevel] : [_nativeIOS12SliderView setValue:-_currentSliderLevel];

  if (_bigSurSliderController != nil) [_bigSurSliderController updateSliderValue];
}

-(void)setBrightness:(float)amount {
  // credits: https://github.com/davidmurray/ios-reversed-headers/blob/master/BackBoardServices/BackBoardServices.h
  // if we create a brightness transaction here, it will be called too many times causing lag
  BKSDisplayBrightnessSet(amount, 1);
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
  if (!_modifyAutoBrightness) return;
  if (enabled && _autoBrightnessShouldBeEnabled) return;
  if (!enabled && !_autoBrightnessShouldBeEnabled) return;

  // credits: https://github.com/a3tweaks/Flipswitch/blob/c1fe70e25d843c1c55b1df954b256ca5850910af/Switches/AutoBrightness.x#L28-L30
  CFPreferencesSetAppValue(kABSAutoBrightnessKey, enabled ? kCFBooleanTrue : kCFBooleanFalse, kABSBackboard);
  CFPreferencesAppSynchronize(kABSBackboard);
  _autoBrightnessShouldBeEnabled = enabled;
}

-(void)calculateGlyphState {
  // possible glyphState values: 0: min, 1: mid, 2: full, 3: max
	if (_currentSliderLevel < _threshold) {
		_glyphState = 0;
	} else {
		if (_currentSliderLevel == 1.0f) {
			_glyphState = 3;
		} else if (_currentSliderLevel > _halfDistance) {
			_glyphState = 2;
		} else {
			_glyphState = 1;
		}
	}
}

-(NSString*)glyphState {
  return glyphStates[_glyphState];
}

-(BOOL)moveWithGestureRecognizer:(UIPanGestureRecognizer*)recognizer withOldSliderLevel:(float)oldSliderLevel withView:(UIView*)view withYDirection:(BOOL)isY {
  CGPoint translationPoint = [recognizer translationInView:view];
  float translation = (float) isY ? translationPoint.y / [view frame].size.height : -translationPoint.x / [view frame].size.width;

  _currentSliderLevel = [ABSManager clampZeroOne:oldSliderLevel-translation];
  [self calculateGlyphState];

  if (_currentSliderLevel >= _threshold) { // brightness
    float upperSectionSliderLevel = _currentSliderLevel - _threshold; // 0.7..0
	  float newBrightnessLevel = upperSectionSliderLevel / _distance; // 1..0
    [self setWhitePointEnabled:NO];
    [self setBrightness:newBrightnessLevel];
    [self setAutoBrightnessEnabled:YES];

    _iosVersion >= 13 ? [_nativeSliderView setValue:-_currentSliderLevel] : [_nativeIOS12SliderView setValue:-_currentSliderLevel];
    return YES;
  } else { // whitepoint
    float lowerSectionSliderLevel = _currentSliderLevel; // 0..0.3
		float newWhitePointLevel = lowerSectionSliderLevel / _threshold; // 0..1
		float newAdjustedWhitePointLevel = 1 - (newWhitePointLevel * 0.75f); // 1..0.25
		[self setWhitePointEnabled:YES];
		[self setWhitePointLevel:newAdjustedWhitePointLevel];
		[self setAutoBrightnessEnabled:NO];

    _iosVersion >= 13 ? [_nativeSliderView setValue:-_currentSliderLevel] : [_nativeIOS12SliderView setValue:-_currentSliderLevel];
    if (_bigSurSliderController != nil) [_bigSurSliderController updateSliderValue];
    return NO;
  }
}

-(void)updateCurrentSliderLevelWithSystemBrightness:(float)brightnessLevel {
  // brightnessLevel 0..1 system brightness
  _currentSliderLevel = brightnessLevel * _distance + _threshold; // 1..0.3
}

-(void)setNativeIOS12SliderView:(CCUIModuleSliderView*)view {
  if (_nativeIOS12SliderView == nil) _nativeIOS12SliderView = view;
}

-(void)setNativeSliderView:(CCUIContinuousSliderView*)view {
  if (_nativeSliderView == nil) _nativeSliderView = view;
}

-(void)setBigSurSliderController:(SCDisplaySliderModuleViewController*)controller {
  if (_bigSurSliderController == nil) _bigSurSliderController = controller;
}
@end
