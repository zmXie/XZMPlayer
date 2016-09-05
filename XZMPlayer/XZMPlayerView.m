//
//  XZMPlayerView.m
//  XZMPlayer
//
//  Created by xiezhimin on 15/12/18.
//  Copyright © 2015年 ypwl. All rights reserved.
//

#import "XZMPlayerView.h"
#import "UISlider+UISlider_touch.h"

@interface XZMPlayerView ()<UIGestureRecognizerDelegate>{
    
    AVPlayerLayer *_playerLayer;
    
    CGPoint beginPoint; //手指触碰位置
    
    CGFloat beginValue; //手指触碰是的进度
    
    BOOL touchSlider; //是否正在操作进度条
    
    BOOL horizator; //是否横着
    
    CGRect horizatorFrame; //初始化坐标
    
    CGRect horizatorCorverFrame; //在屏幕坐标系上的坐标
    
}

@property (nonatomic,strong)AVPlayer *player;

@property (strong, nonatomic) UIView *horizatorSupView; //父视图

@property (strong, nonatomic) UIView *bottomView; //下方操作视图

@property (strong, nonatomic) UISlider *slider;

@property (strong, nonatomic) UIButton *playBtn;

@property (strong, nonatomic) UIButton *bigBtn;

@end

@implementation XZMPlayerView

-(instancetype)initWithFrame:(CGRect)frame supView:(UIView *)supView{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //保存在父视图上的坐标
        horizatorFrame = frame;
        
        _horizatorSupView = supView;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showHiddenBottom)];
        
        tap.delegate = self;
        
        [self addGestureRecognizer:tap];

        [self setUpUI];
        
    }
    
    return self;
}

#pragma mark -- UI布局
-(void)setUpUI{
    
    self.backgroundColor = [UIColor blackColor];
    
    self.clipsToBounds = YES;
    
    //下方操作栏
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height-40, self.width, 40)];
    
    _bottomView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    
    _playBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 50, _bottomView.height)];
    
    [_playBtn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_playBtn setTitle:@"播放" forState:UIControlStateNormal];
    
    [_playBtn setTitle:@"暂停" forState:UIControlStateSelected];
    
    [_bottomView addSubview:_playBtn];
    
    _slider = [[UISlider alloc]initWithFrame:CGRectMake(_playBtn.right+10, 0, _bottomView.width - _playBtn.width*2-40, _bottomView.height)];
    
    [_slider addTapGestureWithTarget:self action:@selector(resetSlider)];
    
    [_slider addTarget:self action:@selector(valueChange: event:) forControlEvents:UIControlEventValueChanged];
    
    _slider.maximumValue = 1.0;
    
    _slider.minimumValue = 0.0;
    
    [_bottomView addSubview:_slider];
    
    _bigBtn = [[UIButton alloc]initWithFrame:CGRectMake(_slider.right+10, _playBtn.top, _playBtn.width, _playBtn.height)];
    
    [_bigBtn addTarget:self action:@selector(bigAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_bigBtn setTitle:@"放大" forState:UIControlStateNormal];
    
    [_bigBtn setTitle:@"缩小" forState:UIControlStateSelected];
    
    [_bottomView addSubview:_bigBtn];
    
    //初始化播放器
    
    self.player = [[AVPlayer alloc]init];
    
    //初始化视频承载界面
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    _playerLayer.frame = self.bounds;
    
    //视频填充模式
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.layer insertSublayer:_playerLayer atIndex:0];
    
    [self addSubview:_bottomView];
    
}

#pragma mark -- 布局下方操作视图
-(void)layoutBottomViews{
    
    _bottomView.frame = CGRectMake(0, horizator == NO ? self.height-49:self.width-49, horizator == NO ? self.width : self.height, 49);
    
    _playBtn.frame = CGRectMake(10, 0, 50, _bottomView.height);
    
    _slider.frame = CGRectMake(_playBtn.right+10, 0, _bottomView.width - _playBtn.width*2-40, _bottomView.height);
    
    _bigBtn.frame = CGRectMake(_slider.right+10, _playBtn.top, _playBtn.width, _playBtn.height);
    
    _playerLayer.frame = self.bounds;
}

#pragma mark -- 显示隐藏操作视图

-(void)showHiddenBottom{
    
    CGFloat height = horizator == NO?self.height:self.width;
    
    if (_bottomView.top == height) {
        
        [self showBottom];
        
    }else{
        
        [self dismissBottom];
    }
}

-(void)showBottom{
    
    CGFloat height = horizator == NO?self.height:self.width;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _bottomView.bottom = height;

    }];
    
}

-(void)dismissBottom{
    
    CGFloat height = horizator == NO?self.height:self.width;
    
    [UIView animateWithDuration:0.3 animations:^{

        _bottomView.top = height;
        
    }];
}

#pragma mark -- 设置数据源
-(void)setCurrentItem:(AVPlayerItem *)currentItem{
    
    [self removeObsercersWithPlayerItem:_currentItem];
    
    _currentItem = currentItem;
    
    [_player replaceCurrentItemWithPlayerItem:_currentItem];
    
    [self addObserversForPlayerItem:_currentItem];
    
}

#pragma  mark -- slider点击方法(指定时间播放)
-(void)resetSlider{
    
    CMTime currentTime = CMTimeMake(self.slider.value*CMTimeGetSeconds(_currentItem.duration),1);
    
    [self.player pause];
    
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        
        [self playAction];
    }];
}

#pragma mark -- 拖拽slider
-(void)valueChange:(UISlider *)slider event:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    
    switch (touch.phase) {
        case UITouchPhaseBegan:{
            
            [self.player pause];
            
            _playBtn.selected = NO;
            
            touchSlider = YES;
        }
            
            break;
            
        case UITouchPhaseMoved:{
            
            CMTime currentTime = CMTimeMake(self.slider.value*CMTimeGetSeconds(_currentItem.duration),1);
            
            [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
                
            }];

        }
            
            break;
            
        case UITouchPhaseEnded:{
            
            touchSlider = NO;
            
            [self resetSlider];
        }
            
            break;
            
        case UITouchPhaseCancelled:{
            
            touchSlider = NO;
            
            [self resetSlider];
        }
            
            break;
            
        default:
            break;
    }
}

#pragma mark -- 刷新进度条
-(void)refreshProgressValue{
    
    AVPlayerItem *playItem = _currentItem;
    
    UISlider *slider = _slider;
    
    //获得播放进度，这个方法会在设定的时间间隔内定时更新播放进度
    
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        
        CGFloat total = CMTimeGetSeconds([playItem duration]);
        
        CGFloat currentTime = CMTimeGetSeconds(time);
        
        [slider setValue:currentTime/total animated:YES];
        
    }];
    
}

#pragma mark -- 监听播放及加载状态
-(void)addObserversForPlayerItem:(AVPlayerItem *)item{
    
    //监听播放状态
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    //监听加载状态
    [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark -- 移除观察者
-(void)removeObsercersWithPlayerItem:(AVPlayerItem *)item{
    
    [item removeObserver:self forKeyPath:@"status"];
    
    [item removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

#pragma mark -- 观察回调
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context{
    
    AVPlayerItem *playItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        
        //获取监听内容,播放失败、准备播放.
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        
//        NSLog(@"status====%ld",(long)status);
        
        
        
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        
        NSArray *array = playItem.loadedTimeRanges;
        
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        
        CGFloat start = CMTimeGetSeconds(timeRange.start);
        
        CGFloat length = CMTimeGetSeconds(timeRange.duration);
        
//        NSLog(@"缓冲总长度=====%f",start+length);
//        
//        NSLog(@"loadedTimeRanges=====%@",[change objectForKey:@"loadedTimeRanges"]);
    }
}

#pragma mark -- 播放暂停
- (void)playAction{
    
    //从播放到暂停
    if (self.player.rate == 1) {
        
        _playBtn.selected = NO;
        
        [_player pause];
        
        [self showBottom];
        
    }else{ //从暂停到播放
        
        _playBtn.selected = YES;
        
        [self refreshProgressValue];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (!touchSlider) {
                
                [self dismissBottom];
            }
            
        });

        [_player play];
    }
    
}

#pragma mark -- 全拼切换
- (void)bigAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (self.BigAction) {
        
        _BigAction(sender.selected);
    }
    
    if (sender.selected) {
        
        [UIApplication sharedApplication].statusBarHidden = YES;
        
        //获取在window上的坐标，加到window上
        
        CGRect rect = CGRectMake(self.frame.origin.x, self.frame.origin.y-20, self.frame.size.width, self.frame.size.height);
        horizatorCorverFrame = [self convertRect:rect toView:nil];
        
        horizator = YES;
        
        self.frame = horizatorCorverFrame;
        
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
    }else{
        
        [UIApplication sharedApplication].statusBarHidden = NO;
        
        horizator = NO;
        
    }
    
    [UIView transitionWithView:self duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        if (sender.selected) {
            
            CGAffineTransform transform1 = CGAffineTransformMakeRotation(M_PI_2);
            
            self.transform = transform1;
            
            CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            //
            self.frame = rect;
 
        }else{
            
            self.transform = CGAffineTransformIdentity;
            
            self.frame = horizatorCorverFrame;
            
        }
        
        [self layoutBottomViews];
        
    } completion:^(BOOL finished) {
        
        if (sender.selected == NO) {
            
            self.frame = horizatorFrame;
            
            [_horizatorSupView addSubview:self];
            
            NSLog(@"%lu",(unsigned long)_horizatorSupView.subviews.count);
            
        }
        
    }];

}

#pragma mark -- 手势代理
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizer.view == _bottomView) {
        
        return NO;
    }
    
    return YES;
}

#pragma mark -- 处理Touch开始
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    
    beginPoint = [touch locationInView:self];
    
    beginValue = _slider.value;
    
    touchSlider = YES;

}

#pragma mark -- 处理Touch移动
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (_player.rate == 1) {
        
        [self playAction];
        
    }
    
    CGFloat width = horizator == NO ? self.width : self.height;
    
    UITouch *touch = [[event allTouches] anyObject];
    
    CGPoint MovePoint = [touch locationInView:self];
    
    CGFloat hValue = MovePoint.x-beginPoint.x;
    
    CGFloat persent = hValue/width;
    
    NSLog(@"persent=== %f",persent);
    
    CGFloat ABSPersent  = ABS(persent);
    
    CGFloat total = CMTimeGetSeconds([_currentItem duration]);
    
    if (persent < 0) {
        
        CGFloat played = total*beginValue;
        
        [_slider setValue:played*(1-ABSPersent)/total animated:YES];
        
    }else{
        
        CGFloat left = total*(1-beginValue);
        
        [_slider setValue:beginValue + ABSPersent*left/total animated:YES];
    }
    
    CMTime currentTime = CMTimeMake(self.slider.value*CMTimeGetSeconds(_currentItem.duration),1);
    
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        
    }];
    
//    self.player.currentTime
    
}

#pragma mark -- 处理Touch结束
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self playAction];
    
    touchSlider = NO;
}

@end
