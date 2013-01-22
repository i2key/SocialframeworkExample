//
//  MusicManager.h
//  Socialframework_Study
//
//  Created by 黒田 樹 on 2013/01/21.
//  Copyright (c) 2013年 黒田 樹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicManager : NSObject

+ (MusicManager *)sharedManager;

-(UIImage *)trackImage;
-(NSString *)title;
-(NSString *)album;
-(NSString *)artist;
-(NSString *)createShareMessage;

@end
