//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STITunesNowPlayingListener.h"


static NSString * const kITunesPlayerInfoNotification = @"com.apple.iTunes.playerInfo";

static NSString * const kITunesPlayerInfoArtistKey = @"Artist";
static NSString * const kITunesPlayerInfoAlbumKey = @"Album";
static NSString * const kITunesPlayerInfoNameKey = @"Name";
static NSString * const kITunesPlayerInfoPlayerStateKey = @"Player State";
static NSString * const kITunesPlayerInfoPlayerStatePlayingValue = @"Playing";


@interface STITunesNowPlayingInfo ()
+ (instancetype)nowPlayingInfoFromPlayerInfoUserInfo:(NSDictionary *)userInfo;
- (id)initWithArtist:(NSString *)artist album:(NSString *)album name:(NSString *)name;
@end
@implementation STITunesNowPlayingInfo
+ (instancetype)nowPlayingInfoFromPlayerInfoUserInfo:(NSDictionary *)userInfo {
	NSString * const playerState = userInfo[kITunesPlayerInfoPlayerStateKey];
	if (![kITunesPlayerInfoPlayerStatePlayingValue isEqualToString:playerState]) {
		return nil;
	}

	NSString * const artist = userInfo[kITunesPlayerInfoArtistKey];
	NSString * const album = userInfo[kITunesPlayerInfoAlbumKey];
	NSString * const name = userInfo[kITunesPlayerInfoNameKey];

	return [[self alloc] initWithArtist:artist album:album name:name];
}
- (id)init {
	return [self initWithArtist:nil album:nil name:nil];
}
- (id)initWithArtist:(NSString *)artist album:(NSString *)album name:(NSString *)name {
	if ((self = [super init])) {
		_artist = [artist copy];
		_album = [album copy];
		_name = [name copy];
	}
	return self;
}
- (BOOL)isEqual:(id)object {
	if (self == object) {
		return YES;
	}
	if ([object isKindOfClass:[STITunesNowPlayingInfo class]]) {
		STITunesNowPlayingInfo * const other = object;
		NSString * const otherArtist = other.artist;
		if (_artist != otherArtist && ![_artist isEqualToString:otherArtist]) {
			return NO;
		}
		NSString * const otherAlbum = other.album;
		if (_album != otherAlbum && ![_album isEqualToString:otherAlbum]) {
			return NO;
		}
		NSString * const otherName = other.name;
		if (_name != otherName && ![_name isEqualToString:otherName]) {
			return NO;
		}
		return YES;
	}
	return NO;
}
@end


@interface STITunesNowPlayingListener ()
- (void)playerInfoDidChange:(NSNotification *)note;
@end

@implementation STITunesNowPlayingListener {
@private
	NSDistributedNotificationCenter *_dnc;
	NSHashTable *_observers;

	STITunesNowPlayingInfo *_nowPlayingInfo;
}

- (id)init {
	if ((self = [super init])) {
		_dnc = [NSDistributedNotificationCenter defaultCenter];
		[_dnc addObserver:self selector:@selector(playerInfoDidChange:) name:kITunesPlayerInfoNotification object:nil suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];

		_observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsObjectPointerPersonality|NSPointerFunctionsWeakMemory capacity:0];
	}
	return self;
}

- (void)dealloc {
	[_dnc removeObserver:self name:kITunesPlayerInfoNotification object:nil];
}


- (void)playerInfoDidChange:(NSNotification *)note {
	NSDictionary * const noteUserInfo = note.userInfo;

	STITunesNowPlayingInfo *nowPlayingInfo = [STITunesNowPlayingInfo nowPlayingInfoFromPlayerInfoUserInfo:noteUserInfo];

	[self setNowPlayingInfo:nowPlayingInfo];
}


+ (BOOL)automaticallyNotifiesObserversOfNowPlayingInfo { return NO; }
- (void)setNowPlayingInfo:(STITunesNowPlayingInfo *)nowPlayingInfo {
	if (_nowPlayingInfo != nowPlayingInfo && ![_nowPlayingInfo isEqual:nowPlayingInfo]) {
		[self willChangeValueForKey:@"nowPlayingInfo"];
		_nowPlayingInfo = nowPlayingInfo;
		[self didChangeValueForKey:@"nowPlayingInfo"];
		[self notifyNowPlayingInfoDidChange:_nowPlayingInfo];
	}
}


- (void)addObserver:(id<STITunesNowPlayingObserver>)observer {
	[_observers addObject:observer];
}

- (void)removeObserver:(id<STITunesNowPlayingObserver>)observer {
	[_observers removeObject:observer];
}


- (void)notifyNowPlayingInfoDidChange:(STITunesNowPlayingInfo *)nowPlayingInfo {
	NSArray *observers = [_observers allObjects];
	for (id<STITunesNowPlayingObserver> observer in observers) {
		[observer nowPlayingListener:self nowPlayingInfoDidChange:nowPlayingInfo];
	}
}

@end
