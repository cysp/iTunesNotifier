//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STAppDelegate.h"

#import "STITunesNowPlayingListener.h"


@interface STAppDelegate () <STITunesNowPlayingObserver>
@end

@implementation STAppDelegate {
@private
	STITunesNowPlayingListener *_nowPlayingListener;
	NSDistributedNotificationCenter *_dnc;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_dnc = [NSDistributedNotificationCenter notificationCenterForType:NSLocalNotificationCenterType];

	_nowPlayingListener = [[STITunesNowPlayingListener alloc] init];
	[_nowPlayingListener addObserver:self];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
	[_nowPlayingListener removeObserver:self];
}

- (void)nowPlayingListener:(STITunesNowPlayingListener *)listener nowPlayingInfoDidChange:(STITunesNowPlayingInfo *)info {
	if (info) {
        NSMutableArray * const statusComponents = [[NSMutableArray alloc] init];
        if (info.artist.length) {
            [statusComponents addObject:info.artist];
        }
        if (info.name.length) {
            [statusComponents addObject:info.name];
        }
        NSString * const status = [statusComponents componentsJoinedByString:@" - "];
        [_dnc postNotificationName:@"STHipChatStatusUpdate" object:nil userInfo:@{ @"status": status } options:NSNotificationDeliverImmediately];
	}
}

@end
