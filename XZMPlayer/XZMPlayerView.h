//
//  XZMPlayerView.h
//  XZMPlayer
//
//  Created by xiezhimin on 15/12/18.
//  Copyright © 2015年 ypwl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIViewExt.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface XZMPlayerView : UIView

-(instancetype)initWithFrame:(CGRect)frame supView:(UIView *)supView;

@property (nonatomic,copy)void (^ BigAction)(BOOL isSelect);

@property (nonatomic,strong)AVPlayerItem *currentItem;

@end
