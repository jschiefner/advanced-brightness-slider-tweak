#import <Foundation/Foundation.h>
#import "ABSRootListController.h"
#import <Cephei/HBRespringController.h>

@implementation ABSRootListController

- (NSArray*)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

-(void)respring {
	[HBRespringController respring];
}

-(void)openGithub {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/jschiefner/advanced-brightness-slider-tweak/"] options:@{} completionHandler:nil];
}

-(void)openPaypal {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/JonasSchiefner"] options:@{} completionHandler:nil];
}

@end
