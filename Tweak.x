#import <ControlCenterUIKit/CCUICAPackageDescription.h>

@interface CCUIContinuousSliderView : UIControl {
	CCUICAPackageDescription* _glyphPackageDescription;
}
@property (nonatomic,readonly) NSArray * topLevelBlockingGestureRecognizers;
-(CCUICAPackageDescription *)glyphPackageDescription;
-(NSArray *)topLevelBlockingGestureRecognizers;
-(BOOL) isBrightnessSlider;
@end

%hook CCUIContinuousSliderView

%new
-(BOOL) isBrightnessSlider {
	NSString * glyphpackage = [[[self glyphPackageDescription] packageURL] absoluteString];
	return [glyphpackage rangeOfString:@"Brightness"].location != NSNotFound;
}

%end;
