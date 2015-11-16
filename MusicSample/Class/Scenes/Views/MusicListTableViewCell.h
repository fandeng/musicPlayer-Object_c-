//
//  MusicListTableViewCell.h
//  MusicSample
//
//  Created by lanou3g on 15/9/22.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicModel.h"

@interface MusicListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *musicImageView;//图片相册

@property (weak, nonatomic) IBOutlet UILabel *musicName;//音乐名字

@property (weak, nonatomic) IBOutlet UILabel *singerName;//歌手名字

@property(nonatomic, strong)MusicModel * model;//model对象

@end
