//
//  PlayMusicManager.m
//  MusicSample_01
//
//  Created by lanou3g on 15/9/22.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "PlayMusicManager.h"
#import <AVFoundation/AVFoundation.h>
#import "LyricModel.h"

@interface PlayMusicManager()

@property(nonatomic, strong)AVPlayer * avplayer;

@property(nonatomic, strong)NSTimer * timer;//定时器

@property(nonatomic, strong)NSMutableArray * lyricModelArray;//存放歌词model的数组

@end

@implementation PlayMusicManager

#pragma mark ---为了保证同一个对象来播放音乐
+ (PlayMusicManager *)shareManager
{
    static PlayMusicManager * sharedManager = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        
        sharedManager = [[PlayMusicManager alloc] init];
    });
    
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始化avplayer
        self.avplayer = [[AVPlayer alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlayMusicEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

#pragma mark ---播放完成的通知
- (void)PlayMusicEnd
{
    if ([self.delegate respondsToSelector:@selector(playMusicManagerPlayMusicEnd)]) {
        
        [self.delegate playMusicManagerPlayMusicEnd];
    }
}

#pragma mark ---准备播放
- (void)preparePlayMusicWithMp3Url:(NSString *)Mp3Url
{
    //为空判断
    if (!Mp3Url) {
        
        return;
    }
    //根据Url得到item
    AVPlayerItem * item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:Mp3Url]];
    
    //监听item的播放状态
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    //判断当前的观察者，移除观察者
    if (self.avplayer.currentItem) {
        
        [self.avplayer.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    }
    //替换当前播放的item
    [self.avplayer replaceCurrentItemWithPlayerItem:item];
}

#pragma mark ---观察者触发实现的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //得到属性改变的状态
    AVPlayerItemStatus status = [change[@"new"] integerValue];
    
    switch (status) {
            
        case AVPlayerItemStatusFailed:{
            
            NSLog(@"播放失败");
            
            break;
        }
        case AVPlayerItemStatusReadyToPlay:{
            
            NSLog(@"准备播放");
            //调用播放方法
            [self playMusic];
        
            break;
        }
        case AVPlayerItemStatusUnknown:{
            
            NSLog(@"未知错误");
            
            break;
        }
        default:{
            
            break;
        }
    }
}

#pragma mark ---播放
- (void)playMusic
{
    [self.avplayer play];
    
    [self startTime];
}

#pragma mark ---开启定时器
- (void)startTime
{
    //使用NSTimer注意事项
    //1:废弃NSTimer
    //2.安全释放，置为nil
    //判断NSTimer是否被初始化
    if (self.timer) {
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(progressAction:) userInfo:nil repeats:YES];
}

#pragma mark ---关闭定时器
- (void)stopTimer
{
    //1.把NSTimer废除
    [self.timer invalidate];
    //2.把NSTimer置为nil
    self.timer = nil;
}

#pragma mark ---暂停
- (void)pauseMusic
{
    [self.avplayer pause];
    
    [self stopTimer];
}

#pragma mark ---获取当前时间
- (NSInteger)fetchCurrentTimeValue
{
    //获取当前播放时间
    CMTime time = self.avplayer.currentTime;
    
    //获取当前播放秒数  time.value / time.timeScale;
    //判断分母不能为0
    if (time.timescale == 0) {
        return 0;
    }
    //返回秒数
    return time.value / time.timescale;
}

#pragma mark ---获取总时间
- (NSInteger)fetchTotalTimeValue
{
    //获取总时间
    CMTime time = self.avplayer.currentItem.duration;
    
    if (time.timescale == 0) {
        return 0;
    }
    //返回秒数
    return time.value / time.timescale;
}

#pragma mark ---获取播放进度
- (CGFloat)fetchProgressSliderValue
{
    if ([self fetchTotalTimeValue] == 0) {
        
        return 0.0;
    }
    //当前时间除以总时间
    return (CGFloat)[self fetchCurrentTimeValue] / (CGFloat)[self fetchTotalTimeValue];
}

#pragma mark ---把秒数转换成 "类似时间格式00:00"
- (NSString *)changeSecondsToTime:(NSInteger)second
{
    return [NSString stringWithFormat:@"%.2ld:%.2ld",second / 60,second % 60];
}

#pragma mark ---定时器触发实现的方法(每0.1秒执行一次该方法)
- (void)progressAction:(NSTimer *)timer
{
    //判断是否能够响应代理方法
    if ([self.delegate respondsToSelector:@selector(playMusicManagerFetchCurrentTime:totalTime:progressValue:)]) {
        //代理传值
        [self.delegate playMusicManagerFetchCurrentTime:[self changeSecondsToTime:[self fetchCurrentTimeValue]] totalTime:[self changeSecondsToTime:[self fetchTotalTimeValue]] progressValue:[self fetchProgressSliderValue]];
    }
}

#pragma mark ---根据滑竿播放音乐
- (void)bySliderValueToPlayMusic:(CGFloat)progress
{
    //拖动时暂停音乐
    [self pauseMusic];
    //从指定时间去播放音乐
    __weak PlayMusicManager * WeakSelf = self;
    [self.avplayer seekToTime:CMTimeMake(progress*[self fetchTotalTimeValue], 1) completionHandler:^(BOOL finished) {
        if (finished) {
            
            [WeakSelf playMusic];
        }
    }];
}

#pragma mark ---通过当前播放时间获取下标
- (NSInteger)byCurrentTimeFetchIndex:(NSString *)time
{
    NSInteger index = -1;
    for (int i = 0; i < self.lyricModelArray.count - 1; i++) {
        LyricModel * model = self.lyricModelArray[i];
        if ([model.lyricTime isEqualToString:time]) {
            
            index = i;
        }
    }
    return index;
}

#pragma mark ---懒加载
- (NSMutableArray *)lyricModelArray
{
    if (!_lyricModelArray) {
        
        _lyricModelArray = [NSMutableArray array];
    }
    
    return _lyricModelArray;
}

#pragma mark ---对传过来得歌词进行分割
- (NSMutableArray *)fetchLyricSectionWithLyricStr:(NSString *)lyricStr
{
    //删除数组中所有的元素
    [self.lyricModelArray removeAllObjects];
    //拆分每段歌词
    NSArray * array = [lyricStr componentsSeparatedByString:@"\n"];
    
    for (NSString * contentString in array) {
        //存放每段歌词的数组
    NSArray * contentArray = [contentString componentsSeparatedByString:@"]"];
        //安全判断，保证firstObject里面有值
        if ([contentArray.firstObject length] < 1) {
            break;
        }
        //歌词模型
        LyricModel * model = [[LyricModel alloc] init];
        //1⃣️歌词
        model.lyricString = contentArray.lastObject;
        //2⃣️时间
//      model.lyricTime = [[contentArray.firstObject substringToIndex:6] substringFromIndex:1];
        NSString * tempString = [contentArray.firstObject substringFromIndex:1];
            
        NSArray * timeArray = [tempString componentsSeparatedByString:@"."];
        
        NSLog(@"============%@",timeArray);
            
        model.lyricTime = timeArray.firstObject;
       
        [self.lyricModelArray addObject:model];
    }
    
    return _lyricModelArray;
}

#pragma mark ---改变音量
- (void)changeVoiceSlider:(CGFloat)sliderValue
{
    self.avplayer.volume = sliderValue;
}

@end
