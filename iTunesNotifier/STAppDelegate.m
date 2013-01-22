//
//  STAppDelegate.m
//  iTunesNotifier
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "STAppDelegate.h"

#import "STITunesNowPlayingListener.h"


@interface STAppDelegate () <STITunesNowPlayingObserver,NSUserNotificationCenterDelegate>
@end

@implementation STAppDelegate {
@private
	STITunesNowPlayingListener *_nowPlayingListener;
	NSUserNotificationCenter *_unc;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_unc = [NSUserNotificationCenter defaultUserNotificationCenter];

	_unc.delegate  = self;

	[_unc removeAllDeliveredNotifications];

	_nowPlayingListener = [[STITunesNowPlayingListener alloc] init];
	[_nowPlayingListener addObserver:self];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
	[_nowPlayingListener removeObserver:self];
}

- (void)nowPlayingListener:(STITunesNowPlayingListener *)listener nowPlayingInfoDidChange:(STITunesNowPlayingInfo *)info {
	[_unc removeAllDeliveredNotifications];

	if (info) {
		NSUserNotification *n = [[NSUserNotification alloc] init];
		n.title = info.name;
		n.subtitle = info.artist;
		n.informativeText = info.album;
		n.hasActionButton = NO;
		n.soundName = nil;

		[_unc scheduleNotification:n];
	}
}


#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
	NSWorkspace * const workspace = [NSWorkspace sharedWorkspace];
	[workspace launchAppWithBundleIdentifier:@"com.apple.iTunes" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifier:NULL];
}


@end
