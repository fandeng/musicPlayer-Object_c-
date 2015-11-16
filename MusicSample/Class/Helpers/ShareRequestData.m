//
//  ShareRequestData.m
//  MusicSample
//
//  Created by lanou3g on 15/9/22.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "ShareRequestData.h"
#import "MusicModel.h"

@interface ShareRequestData ()

@property(nonatomic, strong)NSMutableArray * musicModelArray;

@end

@implementation ShareRequestData

+ (instancetype)shareManager
{
    static ShareRequestData * sharedManager = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        
        sharedManager = [[ShareRequestData alloc] init];
    });
    
    return sharedManager;
}

#pragma mark ---根据网址获取数据
- (void)fetchDataWithUrl:(NSString *)url updateUI:(musicBlock)block
{
    __weak ShareRequestData * weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSArray * array = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:url]];
        //遍历数组
        for (NSDictionary * dic in array) {
            //创建model对象
            MusicModel * model = [MusicModel new];
            
            [model setValuesForKeysWithDictionary:dic];
            //添加model对象到数组
            [weakSelf.musicModelArray addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //block回调，刷新UI
            block();
        });
    });
}

#pragma mark ---懒加载
- (NSMutableArray *)musicModelArray
{
    if (!_musicModelArray) {
        
        _musicModelArray = [NSMutableArray array];
    }
    
    return _musicModelArray;
}

#pragma mark ---获取数组元素个数
- (NSInteger)count
{
    return self.musicModelArray.count;
}

#pragma mark ---获取下标
- (MusicModel *)fetchModelWithIndex:(NSInteger)index
{
    return self.musicModelArray[index];
}

@end
