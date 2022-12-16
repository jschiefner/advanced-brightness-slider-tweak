#import "shared.h"
#import "ABSManager.h"

#define bundlePath @"/Library/PreferenceBundles/AdvancedBrightnessSliderPreferences.bundle"

// TODO: do i even need this reference here?
ABSManager* abbManager;


%group AutoBrightnessButton
%hook CCUIDisplayBackgroundViewController

-(void)viewDidLoad {
    // %log;
    %orig;
    // CCUILabeledRoundButtonViewController* autoBrightnessButton = [[CCUILabeledRoundButtonViewController alloc]
}

%end

%hook CCUILabeledRoundButtonViewController

-(id)initWithGlyphImage:(id)arg1 highlightColor:(id)arg2 {
    // %log;
    //NSBundle* bundle = [NSBundle bundleWithPath:bundlePath];
    //NSString* path = [bundle pathForResource:@"github" ofType:@"png"];
    //UIImage* image = [UIImage imageWithContentsOfFile:path];

    //return %orig(image, arg2);
    return %orig;
}

-(id)initWithGlyphImage:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3 {
    // %log;

    //NSBundle* bundle = [NSBundle bundleWithPath:bundlePath];
    //NSString* path = [bundle pathForResource:@"github" ofType:@"png"];
    //UIImage* image = [UIImage imageWithContentsOfFile:path];

    return %orig;//(image, arg2, arg3);
}

-(id)initWithGlyphPackageDescription:(id)arg1 highlightColor:(id)arg2 {
    // %log;
    return %orig;
}

-(id)initWithGlyphPackageDescription:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3 {
    // %log;
    return %orig;
}

-(void)setTitle:(NSString *)arg1 {
    // %log;
    if ([arg1 isEqualToString:@"True Tone"]) {
        abbManager.trueToneButton = self;
    }
    %orig;
}

-(void)setGlyphPackageDescription:(CCUICAPackageDescription *)arg1 {
    // %log;
    %orig;
}



%end

%end


extern "C" void initAutoBrightnessButton() {
    abbManager = [ABSManager shared];
    %init(AutoBrightnessButton);
}
