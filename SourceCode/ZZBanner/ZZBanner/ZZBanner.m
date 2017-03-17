//
//  ZZBanner.m
//  ZZBanner
//
//  Created by Zhang_yD on 2017/3/17.
//  Copyright © 2017年 Z. All rights reserved.
//

#import "ZZBanner.h"
#import "UIImageView+WebCache.h"

static const NSInteger kDefaultScrollInterval = 6.0f;

typedef NS_ENUM(NSUInteger, ZZBannerScrollType) {
    ZZBannerScrollTypeStatic, // 非滑动状态
    ZZBannerScrollTypeLeft,
    ZZBannerScrollTypeRight
};

@interface ZZBanner ()
{
    struct {
        unsigned int clickFlg : 1;
        unsigned int urlFlg : 1;
    } _delegateFlg;
}

@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, weak) UIScrollView *scrollView;

// 滚动时复用
@property (nonatomic, weak) UIImageView *reuseView;
// 静止时显示
@property (nonatomic, weak) UIImageView *displayView;

@end

@interface ZZBanner (Private)
- (void)zp_setup;
- (void)zp_startTimer;
- (void)zp_stopTimer;
- (void)zp_scrollBanner;
- (BOOL)zp_isDisplayViewInScreen;
- (void)zp_updateCurrentIndex;
- (NSInteger)zp_formatIndexWithIndex:(NSInteger)idx;
- (void)zp_loadDisplayImage;
- (NSURL *)zp_urlWithDataIndex:(NSInteger)index;
- (void)zp_loadReuseImage;
- (void)zp_imageClick;
@end

@interface ZZBanner (UIScrollView) <UIScrollViewDelegate>
@end

@implementation ZZBanner
{
    NSInteger _currentBannerIndex;
    ZZBannerScrollType _scrollType;
    NSTimer *_timer;
}

- (void)removeFromSuperview {
    [self zp_stopTimer];
    [super removeFromSuperview];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self zp_setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self zp_setup];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _scrollView.frame = self.bounds;
    _pageControl.center = CGPointMake(self.center.x, CGRectGetMaxY(_scrollView.frame) - 20);
    _scrollView.contentSize = CGSizeMake(self.frame.size.width * 3, 0);
    CGFloat vWidth = _scrollView.frame.size.width;
    CGFloat vHeight = _scrollView.frame.size.height;
    _displayView.frame = CGRectMake(vWidth, 0, vWidth, vHeight);
    _reuseView.frame = CGRectMake(0, 0, vWidth, vHeight);
    [self zp_loadDisplayImage];
}

- (void)setNormalDotColor:(UIColor *)normalDotColor {
    _normalDotColor = normalDotColor;
    _pageControl.pageIndicatorTintColor = normalDotColor;
}
- (void)setCurrentDotColor:(UIColor *)currentDotColor {
    _currentDotColor = currentDotColor;
    _pageControl.currentPageIndicatorTintColor = currentDotColor;
}
- (void)setDelegate:(id<ZZBannerDelegate>)delegate {
    _delegate = delegate;
    _delegateFlg.clickFlg = [delegate respondsToSelector:@selector(z_banner:didClickWithIndex:)];
    _delegateFlg.urlFlg = [delegate respondsToSelector:@selector(z_banner:urlWithdata:)];
}
- (void)setDatas:(NSArray *)datas {
    _datas = datas;
    
    _pageControl.numberOfPages = datas.count;
    [self zp_loadDisplayImage];
    [self zp_startTimer];
}
- (void)setDuration:(float)duration {
    _duration = duration;
    [self zp_startTimer];
}

@end

@implementation ZZBanner (Private)

- (void)zp_setup {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self addSubview:scrollView];
    _scrollView = scrollView;
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    [self addSubview:pageControl];
    _pageControl = pageControl;
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    
    UIImageView * displayView = [[UIImageView alloc] init];
    [scrollView addSubview:displayView];
    _displayView = displayView;
    displayView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zp_imageClick)];
    [displayView addGestureRecognizer:tgr];
    
    UIImageView *reuseView = [[UIImageView alloc] init];
    [scrollView addSubview:reuseView];
    _reuseView = reuseView;
}

- (void)zp_startTimer {
    if (_timer) {
        [self zp_stopTimer];
    }
    NSInteger duration = _duration > 0 ? _duration : kDefaultScrollInterval;
    _timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(zp_scrollBanner) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)zp_stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)zp_scrollBanner {
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * 2, 0) animated:YES];
}

- (BOOL)zp_isDisplayViewInScreen {
    return (CGRectGetMaxX(_displayView.frame) > self.scrollView.contentOffset.x) &&
    (CGRectGetMinX(_displayView.frame) < self.scrollView.contentOffset.x + self.scrollView.bounds.size.width);
}

- (void)zp_updateCurrentIndex {
    if (_scrollType == ZZBannerScrollTypeLeft) {
        _currentBannerIndex = [self zp_formatIndexWithIndex:_currentBannerIndex - 1];
    } else {
        _currentBannerIndex = [self zp_formatIndexWithIndex:_currentBannerIndex + 1];
    }
}

- (NSInteger)zp_formatIndexWithIndex:(NSInteger)idx {
    NSInteger resultIdx = idx;
    if (resultIdx < 0) {
        resultIdx = _datas.count - 1;
    } else if (resultIdx == _datas.count) {
        resultIdx = 0;
    }
    return resultIdx;
}

- (void)zp_loadDisplayImage {
    UIImage *placeholderImage = _placeholderImageName ? [UIImage imageNamed:_placeholderImageName] : nil;
    [self.displayView sd_setImageWithURL:[self zp_urlWithDataIndex:_currentBannerIndex] placeholderImage:placeholderImage];
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    _pageControl.currentPage = _currentBannerIndex;
}

- (void)zp_loadReuseImage {
    CGRect frame = _reuseView.frame;
    NSInteger reuseIndex = _currentBannerIndex;
    if (_scrollType == ZZBannerScrollTypeLeft) {
        frame.origin.x = 0;
        reuseIndex = [self zp_formatIndexWithIndex:reuseIndex - 1];
    } else {
        frame.origin.x = self.scrollView.frame.size.width * 2;
        reuseIndex = [self zp_formatIndexWithIndex:reuseIndex + 1];
    }
    
    UIImage *placeholderImage = _placeholderImageName ? [UIImage imageNamed:_placeholderImageName] : nil;
    [self.reuseView sd_setImageWithURL:[self zp_urlWithDataIndex:reuseIndex] placeholderImage:placeholderImage];
    self.reuseView.frame = frame;
}

- (NSURL *)zp_urlWithDataIndex:(NSInteger)index {
    NSString *urlStr;
    if (_delegateFlg.urlFlg) {
        urlStr = [_delegate z_banner:self urlWithdata:_datas[index]];
    } else {
        urlStr = _datas[index];
    }
    return [NSURL URLWithString:urlStr];
}

- (void)zp_imageClick {
    if (_delegateFlg.clickFlg) {
        [_delegate z_banner:self didClickWithIndex:_currentBannerIndex];
    }
}
@end


@implementation ZZBanner (UIScrollView)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self zp_stopTimer];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self zp_startTimer];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat cosX = scrollView.contentOffset.x;
    // 当显示页面消失在屏幕时立刻更新Display Image
    if (![self zp_isDisplayViewInScreen]) {
        // 更新Current Index
        [self zp_updateCurrentIndex];
        // 还原滚动方向
        _scrollType = ZZBannerScrollTypeStatic;
        // 更新Display Image
        [self zp_loadDisplayImage];
        
        // 判断滚动方向
    } else if (cosX > self.frame.size.width) {
        // 右
        if (_scrollType != ZZBannerScrollTypeRight) {
            _scrollType = ZZBannerScrollTypeRight;
            [self zp_loadReuseImage];
        }
    } else {
        // 左
        if (_scrollType != ZZBannerScrollTypeLeft) {
            _scrollType = ZZBannerScrollTypeLeft;
            [self zp_loadReuseImage];
        }
    }
}
@end
