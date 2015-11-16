//
//  MusicListTableViewController.m
//  MusicSample
//
//  Created by lanou3g on 15/9/22.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "MusicListTableViewController.h"
#import "MusicListTableViewCell.h"
#import "ShareRequestData.h"
#import "MusicModel.h"
#import "PlayMusicManager.h"
#import "PlayMusicViewController.h"

@interface MusicListTableViewController ()

@end

@implementation MusicListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //注册自定义cell
    UINib * nib = [UINib nibWithNibName:@"MusicListTableViewCell" bundle:nil];
    
    [self.tableView registerNib:nib forCellReuseIdentifier:@"musicList_cell"];
    
    //block函数实现部分，传值，回调函数在ShareRequestData类中
    __weak MusicListTableViewController * weakSelf = self;
    [[ShareRequestData shareManager] fetchDataWithUrl:kMusicUrl updateUI:^{
        
        [weakSelf.tableView reloadData];
    }];
    
}

#pragma mark - Table view data source
//区
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [ShareRequestData shareManager].count;
}
//设置cell，并显示cell上内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"musicList_cell" forIndexPath:indexPath];
    //根据下标获取model对象
    MusicModel * model = [[ShareRequestData shareManager] fetchModelWithIndex:indexPath.row];
    
    cell.model = model;
    
    return cell;
}
//点击事件，推出播放界面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //利用单例推出下级界面
    PlayMusicViewController * playMusicVC = [PlayMusicViewController ShareManager];

    playMusicVC.indexRow = indexPath.row;//利用属性传值将下标传到下级界面
    
    [self.navigationController showViewController:playMusicVC sender:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
//    PlayMusicViewController * PlayMusicVC = (PlayMusicViewController *)segue.destinationViewController;
    
    PlayMusicViewController * pv = [segue destinationViewController];
//    pv.indexRow = sender;
    [self performSegueWithIdentifier:@"PlayMusicVC" sender:@"nihaoma"];
}
*/
@end
