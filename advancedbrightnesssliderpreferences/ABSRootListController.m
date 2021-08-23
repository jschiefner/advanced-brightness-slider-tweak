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

// credits: https://github.com/Muirey03/PowerModule/blob/master/Source/RespringButtonController.m
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
