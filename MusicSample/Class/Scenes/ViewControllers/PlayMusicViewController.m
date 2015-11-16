//
//  PlayMusicViewController.m
//  MusicSample
//
//  Created by lanou3g on 15/9/22.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "PlayMusicViewController.h"
#import "PlayMusicManager.h"
#import "ShareRequestData.h"
#import "LyricModel.h"

@interface PlayMusicViewController ()<PlayMusicManagerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *playMusicImageView;//图片

@property (weak, nonatomic) IBOutlet UITableView *lyricTableView;//歌词显示视图

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;//当前播放时间

@property (weak, nonatomic) IBOutlet UISlider *progressSlider;//滑动杆

@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;//总时间

@property(nonatomic, assign)NSInteger currentIndex;//当前下标

@property (weak, nonatomic) IBOutlet UIButton *playMusicButton;//播放音乐按钮

@property(nonatomic, assign)NSInteger  currentCount;//计数点击播放方式按钮的次数 为了实现播放方式

@property (weak, nonatomic) IBOutlet UIButton *playStyle;//播放样式按钮设置为属性，为了修改按钮上图片

@property(nonatomic, strong)MusicModel * model;//申明model属性

@property (weak, nonatomic) IBOutlet UISlider *musicSound;


@end

@implementation PlayMusicViewController
//创建视图控制器单例
+ (instancetype)ShareManager
{
    static PlayMusicViewController * sharedManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        
        sharedManager = [[UIStoryboard  storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"playMusic_id"];
    });
    return sharedManager;
    
}

#pragma mark ---视图将要出现
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //判断当前下标和传进来的下标是否相同 重新播放同一首歌的时候,不从头开始播放
    if (self.currentIndex == self.indexRow) {
        [[PlayMusicManager shareManager] startTime];
        return;
    }
    //播放音乐
    [self playMusic];
    [self changeButtonPhoto];//切换按钮图片
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //给定初始值,数组下标不能为负值.
    self.currentIndex = -1;
    //给定初始值，让音乐默认播放方式是全部循环方式
    self.currentCount = 0;
    
    //设置图片圆角
    [self.playMusicImageView layoutIfNeeded];
    self.playMusicImageView.layer.masksToBounds = YES;
    self.playMusicImageView.layer.cornerRadius = self.playMusicImageView.frame.size.width / 2;
    
    //设置代理
    [PlayMusicManager shareManager].delegate = self;
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.lyricTableView.separatorStyle = UITableViewCellSeparatorStyleNone;//设置表视图的分割线不显示
}

#pragma mark ---视图将要消失
- (void)viewWillDisappear:(BOOL)animated
{
    [[PlayMusicManager shareManager] stopTimer];//让定时器失效
}

#pragma mark ---实现PlayMusicManagerDelegate协议方法
//获取当前时间、总时间、滑竿的移动长度
- (void)playMusicManagerFetchCurrentTime:(NSString *)currentTime totalTime:(NSString *)totalTime progressValue:(CGFloat)progress
{
    self.currentTimeLabel.text = currentTime;//当前时间
    
    self.totalTimeLabel.text = totalTime;//总时间
    
    self.progressSlider.value = progress;//滑竿移动长度
    //图片旋转
    self.playMusicImageView.transform = CGAffineTransformRotate(self.playMusicImageView.transform, 0.01);
    //表视图中的cell滚动
    NSInteger index = [[PlayMusicManager shareManager]byCurrentTimeFetchIndex:currentTime];
    if (index == -1) {
        return;
    }
    [self.lyricTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}
#pragma mark ---播放结束,自动下一首
- (void)playMusicManagerPlayMusicEnd
{
    //判断当前时间和总时间不等于"00:00"
    if (![_currentTimeLabel.text isEqualToString:@"00:00"] && ![_totalTimeLabel.text isEqualToString:@"00:00"]) {
        //判断当前时间和总时间是否相等，相等进入下一首
        if ([_currentTimeLabel.text isEqualToString:_totalTimeLabel.text]) {
            
            [self realizeStyle];//调用进入下一首的顺序(按列表顺序还是随机)
        }
    }
}
#pragma mark ---实现播放样式的方法
- (void)realizeStyle
{
    //根据计数变量 来判断全部循环、单曲循环、随机循环(0:全部顺序 1:单曲循环  2:随机循环)
    switch (_currentCount) {
        case 0:{
            [self nextMusic:nil];
            break;
        }
        case 1:{
            [self playMusic];
            break;
        }
        case 2:{
            //随机获取下标，实现随机播放
            _indexRow = arc4random()%([ShareRequestData shareManager].count+1);
            if (_indexRow == [ShareRequestData shareManager].count) {
                _indexRow = 0;
            }
            [self playMusic];
            break;
        }
        default:
            break;
    }
}

#pragma mark ---播放音乐
- (void)playMusic
{
    self.currentIndex = self.indexRow;//将传入的下标赋值给当前的下标变量
    //根据传入的下标获取当前model
    self.model = [[ShareRequestData shareManager] fetchModelWithIndex:self.indexRow];
    
    //根据Mp3Url播放音乐
    [[PlayMusicManager shareManager] preparePlayMusicWithMp3Url:self.model.mp3Url];
    //设置导航栏标题
    self.title = self.model.name;
    //设置图片
    [self.playMusicImageView sd_setImageWithURL:[NSURL URLWithString:self.model.picUrl] placeholderImage:nil];
    
    //刷新歌词
    [self.lyricTableView reloadData];
}
#pragma mark ---播放音乐或暂停音乐
- (IBAction)playOrPauseMusic:(UIButton *)sender {
    //判断按钮选中状态，默认是NO
    if (sender.selected) {
        [sender setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];//修改按钮上的图片
        
        [[PlayMusicManager shareManager] playMusic];//利用单例调用播放音乐方法
        
        sender.selected = !sender.selected;//修改sender.selected的布尔值(选中状态)
        
    } else{
        [sender setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
        [[PlayMusicManager shareManager] pauseMusic];//利用单例调用暂停音乐方法
        
        sender.selected = !sender.selected;
    }
}
#pragma mark ---更改按钮图片方法(为了给上下调换歌曲时，调用该方法)
- (void)changeButtonPhoto
{
    if (self.playMusicButton.selected) {
        [self.playMusicButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];//修改按钮上的图片
        
        _playMusicButton.selected = !_playMusicButton.selected;//修改播放按钮选中状态
    }
}
#pragma mark ---切换下一首歌曲
- (IBAction)nextMusic:(id)sender {
  //判断currentCount的值不等2时，说明播放模式不是全部循环就单曲循环，此时下一首还是按照列表顺序走
    if (_currentCount != 2) {
        
        if (_indexRow == [ShareRequestData shareManager].count-1) {
            
            _indexRow = -1;
        }
        _indexRow++;
    } else {
         //当currentCount值为2时，说明当前播放模式是随机模式，下一首也是随机播放
        _indexRow = arc4random()%([ShareRequestData shareManager].count+1);
        if (_indexRow == [ShareRequestData shareManager].count) {
            _indexRow = 0;
        }
    }
    [self playMusic];//调用播放方法
    [self changeButtonPhoto];//修改播放按钮图片
}
#pragma mark ---切换上一首歌曲
- (IBAction)lastMusic:(id)sender {
    //判断currentCount的值不等2时，说明播放模式不是全部循环就单曲循环，此时上一首还是按照列表顺序走
    if (_currentCount != 2) {
        if (_indexRow == 0) {
            
            _indexRow = [ShareRequestData shareManager].count;
        }
        _indexRow--;
    } else {
        //当currentCount值为2时，说明当前播放模式是随机模式，上一首也是随机播放
        _indexRow = arc4random()%([ShareRequestData shareManager].count+1);
        if (_indexRow == [ShareRequestData shareManager].count) {
            _indexRow = 0;
        }
    }
    [self playMusic];
    [self changeButtonPhoto];
}
#pragma mark ---播放方式:全部循环、单曲循环、随机播放
- (IBAction)playMusicStyle:(id)sender {
    self.currentCount++;
    
    if (_currentCount >= 3) {
        
        _currentCount = 0;
    }
    if (_currentCount == 1) {
        
        [self.playStyle setImage:[UIImage imageNamed:@"singlecycle.png"] forState:UIControlStateNormal];
        
    } else if (_currentCount == 2) {
        
        [self.playStyle setImage:[UIImage imageNamed:@"random.png"] forState:UIControlStateNormal];
        
    } else {
        
        [self.playStyle setImage:[UIImage imageNamed:@"allcycle.png"] forState:UIControlStateNormal];
    }
}
#pragma mark ---实现tableView的数据源代理和tableView代理协议方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[PlayMusicManager shareManager] fetchLyricSectionWithLyricStr:self.model.lyric].count;
}
//设置cell显示内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"lyric_cell" forIndexPath:indexPath];
    
    LyricModel * model = [[PlayMusicManager shareManager] fetchLyricSectionWithLyricStr:self.model.lyric][indexPath.row];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;//字居中
    
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];//字体大小
    
    cell.textLabel.numberOfLines = 0;//行数为0，自动换行
    
    cell.textLabel.textColor = [UIColor redColor];//字体颜色

    cell.textLabel.text = model.lyricString;//显示歌词
    
    [cell.textLabel setHighlightedTextColor:[UIColor magentaColor]];//选中的歌词字体显示
    
    cell.selectedBackgroundView = ({
        
        UIView * backColorView = [[UIView alloc] init];
        
        backColorView.backgroundColor = [UIColor clearColor];
        
        backColorView;
    });//语法糖 让选中的cell背景颜色为无色
    return cell;
}
#pragma mark ---slider拖动事件
- (IBAction)sliderAction:(UISlider *)sender {
    
    [[PlayMusicManager shareManager] bySliderValueToPlayMusic:sender.value];
}
#pragma mark ---返回列表界面
- (IBAction)didBack:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ---改变音量
- (IBAction)musicSoundSlider:(UISlider *)sender {
    
    [[PlayMusicManager shareManager]changeVoiceSlider:self.musicSound.value];
}



@end
