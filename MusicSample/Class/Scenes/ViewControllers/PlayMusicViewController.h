//
//  PlayMusicViewController.h
//  MusicSample
//
//  Created by lanou3g on 15/9/22.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicModel.h"

@interface PlayMusicViewController : UIViewController

@property(nonatomic, assign)NSInteger indexRow;//申明下标属性，接收上级传过来的值

+ (instancetype)ShareManager;

@end
