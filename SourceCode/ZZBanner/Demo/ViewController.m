//
//  ViewController.m
//  ZZBanner
//
//  Created by Zhang_yD on 2017/3/17.
//  Copyright © 2017年 Z. All rights reserved.
//

#import "ViewController.h"
#import "ZZBanner.h"

@interface ViewController () <ZZBannerDelegate>

@property (nonatomic, weak) ZZBanner * banner;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    /**
     *  如果显示有问题，比如拖动时候图片会向下偏移，请在控制器中加入下面这句代码。
     */
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSArray *datas = @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1490347919&di=a21ccb4f946287bc17170f73aebbbba4&imgtype=jpg&er=1&src=http%3A%2F%2Ftupian.enterdesk.com%2F2013%2Fmxy%2F12%2F11%2F4%2F4.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1489753200405&di=1a1b2f7bd205269c99150da1c77a5a97&imgtype=0&src=http%3A%2F%2Fpic1.5442.com%3A82%2F2015%2F0409%2F01%2F15.jpg%2521960.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1489753200403&di=848fc3dacf5516593c9878408432ccab&imgtype=0&src=http%3A%2F%2Fwww.pp3.cn%2Fuploads%2F201412%2F2014123114.jpg"];
    
    ZZBanner *banner = [[ZZBanner alloc] init];
    [self.view addSubview:banner];
    _banner = banner;
    banner.delegate = self;
    banner.duration = 3;
    banner.datas = datas;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.banner.frame = CGRectMake(0, 50, self.view.frame.size.width, 200);
}


#pragma mark - ZZBannerDelegate
- (void)z_banner:(ZZBanner *)banner didClickWithIndex:(NSInteger)index {
    NSLog(@"第%ld张图片被选中了!", index);
}

@end
