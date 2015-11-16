//
//  MusicListTableViewCell.m
//  MusicSample
//
//  Created by lanou3g on 15/9/22.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "MusicListTableViewCell.h"

@implementation MusicListTableViewCell

#pragma mark ---重写setter方法
- (void)setModel:(MusicModel *)model
{
    //利用第三方根据网址获取对应的图片
    [_musicImageView sd_setImageWithURL:[NSURL URLWithString:model.picUrl] placeholderImage:nil];
    
    _musicName.text = model.name;
    
    _singerName.text = model.singer;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
