//
//  STAppDelegate.m
//  iTunesNotifier
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "STAppDelegate.h"

#import "STITunesNowPlayingListener.h"


@interface STAppDelegate () <STITunesNowPlayingObserver>
@end

@implementation STAppDelegate {
@private
	STITunesNowPlayingListener *_nowPlayingListener;
	NSUserNotificationCenter *_unc;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_unc = [NSUserNotificationCenter defaultUserNotificationCenter];
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

@end
