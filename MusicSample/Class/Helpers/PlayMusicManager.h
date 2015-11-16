//
//  PlayMusicManager.h
//  MusicSample_01
//
//  Created by lanou3g on 15/9/22.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayMusicManagerDelegate <NSObject>

#pragma mark ---获取当前播放时间、持续时间、播放进度,代理方法
- (void)playMusicManagerFetchCurrentTime:(NSString *)currentTime totalTime:(NSString *)totalTime progressValue:(CGFloat)progress;

#pragma mark ---音乐播放结束代理方法
- (void)playMusicManagerPlayMusicEnd;

@end

@interface PlayMusicManager : NSObject

@property(nonatomic, weak)id<PlayMusicManagerDelegate> delegate;


+ (PlayMusicManager *)shareManager;

#pragma mark ---准备播放
- (void)preparePlayMusicWithMp3Url:(NSString *)Mp3Url;

#pragma mark ---播放
- (void)playMusic;

#pragma mark ---暂停
- (void)pauseMusic;

#pragma mark ---暂停定时器方法
- (void)stopTimer;

#pragma mark ---开启定时器
- (void)startTime;

#pragma mark ---根据滑竿播放音乐
- (void)bySliderValueToPlayMusic:(CGFloat)progress;

#pragma mark ---对传过来得歌词进行分割
- (NSMutableArray *)fetchLyricSectionWithLyricStr:(NSString *)lyricStr;

#pragma mark ---通过当前播放时间获取下标
- (NSInteger)byCurrentTimeFetchIndex:(NSString *)time;

#pragma mark ---改变音量
- (void)changeVoiceSlider:(CGFloat)sliderValue;

@end
