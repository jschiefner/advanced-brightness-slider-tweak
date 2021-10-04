#import <Foundation/Foundation.h>
#import "ABSRootListController.h"
#import <spawn.h>

@implementation ABSRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

// credits: https://github.com/Muirey03/PowerModule/blob/364b91400152f6c2a319dffe136948dec53f1ad6/Source/RespringButtonController.m#L30-L37
// see https://github.com/hbang/libcephei/blob/master/HBRespringController.x for possible alternative on how to respring. maybe just use cephei for prefs as well, and use that function from my code
-(void)respring {
	pid_t pid;
	int status;
	const char* args[] = {"sbreload", NULL};
	posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
	waitpid(pid, &status, WEXITED);
}

-(void)openGithub {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/jschiefner/advanced-brightness-slider-tweak/"] options:@{} completionHandler:nil];
}

-(void)openPaypal {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/JonasSchiefner"] options:@{} completionHandler:nil];
}

@end
