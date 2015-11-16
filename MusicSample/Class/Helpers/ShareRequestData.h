//
//  ShareRequestData.h
//  MusicSample
//
//  Created by lanou3g on 15/9/22.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MusicModel;

typedef void(^musicBlock)();

@interface ShareRequestData : NSObject

@property(nonatomic, assign)NSInteger count;

+ (instancetype)shareManager;

#pragma mark ---根据网址获取数据
- (void)fetchDataWithUrl:(NSString *)url updateUI:(musicBlock)block;

#pragma mark ---获取下标，取出对应的model
- (MusicModel *)fetchModelWithIndex:(NSInteger)index;

@end
