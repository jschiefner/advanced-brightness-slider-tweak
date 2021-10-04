#ifndef ADVANCED_BRIGHTNESS_SLIDER_MANAGER_H
#define ADVANCED_BRIGHTNESS_SLIDER_MANAGER_H

#import "shared.h"

@interface ABSManager : NSObject
@property (nonatomic) float currentSliderLevel; // stores the current level the brightness slider is set to
@property (readonly,nonatomic) float threshold; // value where slider switches from brightness to white point
@property (readonly,nonatomic) float distance; // will be set to 1 - threshold
@property (readonly,nonatomic) BOOL whitePointShouldBeEnabled; // stores whether the white point setting should be enabled (to avoid syscalls)
@property (readonly,nonatomic) float iosVersion; // stores the major ios version
+(ABSManager*)shared;
+(float)clampZeroOne:(float)value;
-(void)initWithAutoBrightnessEnabled:(BOOL)enabled andIosVersion:(int)iosVersion andThreshold:(float)threshold;
-(void)setBrightness:(float)amount;
-(float)brightness;
-(BOOL)whitePointEnabled;
-(void)setWhitePointEnabled:(BOOL)enabled;
-(void)setWhitePointLevel:(float)amount;
-(float)whitePointLevel;
-(void)setAutoBrightnessEnabled:(BOOL)enabled;
-(void)calculateGlyphState;
-(NSString*)glyphState;
-(BOOL)moveWithGestureRecognizer:(UIPanGestureRecognizer*)recognizer withOldSliderLevel:(float)oldSliderLevel withView:(UIView*)view withYDirection:(BOOL)isY;
-(void)updateCurrentSliderLevelWithSystemBrightness:(float)brightnessLevel;
-(void)setNativeSliderView:(CCUIContinuousSliderView*)view;
-(void)setBigSurSliderController:(SCDisplaySliderModuleViewController*)controller;
@end

#endif // ADVANCED_BRIGHTNESS_SLIDER_MANAGER_H
