//
//  MusicModel.h
//  MusicSample
//
//  Created by lanou3g on 15/9/22.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicModel : NSObject

@property(nonatomic, strong)NSString * name;//歌曲名

@property(nonatomic, strong)NSString * lyric;//歌词

@property(nonatomic, strong)NSString * picUrl;//图片网址

@property(nonatomic, strong)NSString * mp3Url;//歌曲网址

@property(nonatomic, strong)NSString * singer;//歌手名

@end
