//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>


@interface STITunesNowPlayingInfo : NSObject
@property (nonatomic,copy,readonly) NSString *artist;
@property (nonatomic,copy,readonly) NSString *album;
@property (nonatomic,copy,readonly) NSString *name;
@end


@class STITunesNowPlayingListener;

@protocol STITunesNowPlayingObserver <NSObject>
- (void)nowPlayingListener:(STITunesNowPlayingListener *)listener nowPlayingInfoDidChange:(STITunesNowPlayingInfo *)info;
@end


@interface STITunesNowPlayingListener : NSObject

@property (nonatomic,strong,readonly) STITunesNowPlayingInfo *nowPlayingInfo;

- (void)addObserver:(id<STITunesNowPlayingObserver>)observer;
- (void)removeObserver:(id<STITunesNowPlayingObserver>)observer;

@end
