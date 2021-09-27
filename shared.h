#ifndef ADVANCED_BRIGHTNESS_SLIDER_SHARED_H
#define ADVANCED_BRIGHTNESS_SLIDER_SHARED_H

extern "C" {
  void initNative();
  void initPrysm();
}

@interface CCUIContinuousSliderView : UIControl
@property (nonatomic) BOOL isBrightnessSlider;
-(void)_handleValueChangeGestureRecognizer:(UIPanGestureRecognizer*)recognizer;
-(void)setGlyphState:(NSString*)arg1;
-(void)setValue:(float)arg1;
@end

@interface CCUICAPackageDescription : NSObject
-(NSURL *)packageURL;
@end

@interface CCUICAPackageView : UIView
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

#endif // ADVANCED_BRIGHTNESS_SLIDER_SHARED_H
