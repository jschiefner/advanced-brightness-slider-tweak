#ifndef ADVANCED_BRIGHTNESS_SLIDER_SHARED_H
#define ADVANCED_BRIGHTNESS_SLIDER_SHARED_H

#import <UIKit/UIKit.h>

extern "C" {
  void initNative();
  void initPrysm();
  void initBigSurCenter();
}

@interface BKSLocalDefaults
-(BOOL)isALSEnabled;
@end

@interface CCUICAPackageDescription : NSObject
-(NSURL *)packageURL;
@end

@interface CCUIContinuousSliderView : UIControl // iOS 13+
@property (nonatomic) BOOL isBrightnessSlider;
-(void)_handleValueChangeGestureRecognizer:(UIPanGestureRecognizer*)recognizer;
-(void)setGlyphState:(NSString*)arg1;
-(void)setValue:(float)arg1;
@end

@interface CCUIModuleSliderView : UIControl // iOS 12
@property (nonatomic,retain) CCUICAPackageDescription* glyphPackageDescription;
-(void)_handleValueChangeGestureRecognizer:(UIPanGestureRecognizer*)recognizer;
-(void)setGlyphState:(NSString*)arg1;
-(void)setValue:(float)arg1;
@end

@interface CCUIDisplayModuleViewController : UIViewController
@property (nonatomic,retain) CCUIModuleSliderView* sliderView;
-(void)setGlyphState:(NSString*)arg1;
@end

@interface CCUICAPackageView : UIView {
  BOOL isBrightnessPackage;
}
@property CCUICAPackageDescription* packageDescription;
-(void)setPackageDescription:(CCUICAPackageDescription*)arg1;
-(void)setStateName:(NSString*)arg1;
@end

@interface PrysmSliderViewController : UIViewController
@property (nonatomic,retain) CCUICAPackageView * packageView;
@property (assign,nonatomic) int style;
-(BOOL)isBrightnessSlider;
-(void)setProgressValue:(double)arg1 animated:(BOOL)arg2;
-(void)setPackageOverlayView:(CCUICAPackageView *)arg1;
-(void)move:(UIPanGestureRecognizer*)recognizer;
@end

@interface SCDisplaySliderModuleViewController : UIViewController
@property (nonatomic,retain) UIView * sliderView;
@property (nonatomic,retain) NSLayoutConstraint * sliderLeadingConstraint;
@property (nonatomic,retain) UIView * knobView;
-(void)setImageForFraction:(double)arg1;
-(void)updateSliderValue;
-(long long)style; // 0: iOS style, 1: macOS style (with knobView)
@end

#endif // ADVANCED_BRIGHTNESS_SLIDER_SHARED_H
