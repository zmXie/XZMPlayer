//
//  ViewController.m
//  XZMPlayer
//
//  Created by xiezhimin on 15/12/18.
//  Copyright © 2015年 ypwl. All rights reserved.
//

#import "ViewController.h"
#import "XZMPlayerView.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tabView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT-20) style:UITableViewStylePlain];
    
    [tabView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    tabView.rowHeight = 250;
    
    tabView.delegate = self;
    
    tabView.dataSource = self;
    
    [self.view addSubview:tabView];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.selectionStyle = 0;
    
    XZMPlayerView *playerView = [cell.contentView viewWithTag:100];
    
    if (!playerView) {
        
        playerView = [[XZMPlayerView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 200) supView:cell.contentView];
        playerView.tag = 100;
    }
    
    NSString *urlStr;
    
    if (indexPath.row % 2 == 0) {
        
        urlStr = @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4";
        
    }else{
        
        urlStr = @"http://baobab.cdn.wandoujia.com/14463059939521445330477778425364388_x264.mp4";
        
    }
    
    AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:4]]];
    
    playerView.currentItem = item;
        
    [cell.contentView addSubview:playerView];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
