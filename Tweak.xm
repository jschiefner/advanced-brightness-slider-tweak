#import "shared.h"
#import "ABSBrightnessManager.h"

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
	NSDictionary* bundleDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.jschiefner.advancedbrightnesssliderpreferences"];
	if (bundleDefaults == nil) bundleDefaults = @{@"enabled":@YES, @"threshold":@30.0f,@"modifyAutoBrightness":@YES};
	BOOL enabled = [bundleDefaults objectForKey:@"enabled"] == nil ? YES : [[bundleDefaults objectForKey:@"enabled"] boolValue];
	if (!enabled) return;

	BOOL shouldModifyAutoBrightness = [bundleDefaults objectForKey:@"modifyAutoBrightness"] == nil ? YES : [[bundleDefaults objectForKey:@"modifyAutoBrightness"] boolValue];
	int iosVersion = [[[%c(UIDevice) currentDevice] systemVersion] intValue];
	[[ABSBrightnessManager shared] initWithAutoBrightnessEnabled:shouldModifyAutoBrightness andIosVersion:iosVersion];

	if (NSClassFromString(@"PrysmSliderViewController")) initPrysm(bundleDefaults);
	initNative(bundleDefaults);
}

__attribute__((constructor)) static void initialize() {
  CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDrop);
}
