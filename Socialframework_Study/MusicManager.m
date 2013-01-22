//
//  MusicManager.m
//  Socialframework_Study
//
//  Created by 黒田 樹 on 2013/01/21.
//  Copyright (c) 2013年 黒田 樹. All rights reserved.
//

#import "MusicManager.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation MusicManager{
    MPMusicPlayerController *player;
}

+ (MusicManager *)sharedManager
{
    static MusicManager *sharedMusicManeger;
    static dispatch_once_t doneSharedMusicManeger;
    dispatch_once(&doneSharedMusicManeger, ^{
        sharedMusicManeger = [MusicManager new];
    });
    
    return sharedMusicManeger;
}

-(UIImage *)trackImage{
    MPMediaItem *item = [self getPlayingItem];
    MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    return [artwork imageWithSize:CGSizeMake(320, 320)];
}

-(NSString *)title{
    MPMediaItem *item = [self getPlayingItem];
    return [item valueForProperty:MPMediaItemPropertyTitle];
}

-(NSString *)album{
    MPMediaItem *item = [self getPlayingItem];
    return [item valueForProperty:MPMediaItemPropertyAlbumTitle];
}

-(NSString *)artist{
    MPMediaItem *item = [self getPlayingItem];
    return [item valueForProperty:MPMediaItemPropertyArtist];
}

-(MPMediaItem *)getPlayingItem{
    if(player == nil){
        player = [MPMusicPlayerController iPodMusicPlayer];
    }
    return [player nowPlayingItem];
}

-(NSString *)createShareMessage{
    MPMediaItem *item = [self getPlayingItem];
    return [NSString stringWithFormat:@"%@ の %@ を聴いています",[item valueForProperty:MPMediaItemPropertyArtist],[item valueForProperty:MPMediaItemPropertyTitle]];
}

@end
