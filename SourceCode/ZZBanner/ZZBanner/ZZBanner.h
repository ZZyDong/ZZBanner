//
//  ZZBanner.h
//  ZZBanner
//
//  Created by Zhang_yD on 2017/3/17.
//  Copyright © 2017年 Z. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZZBanner;

@protocol ZZBannerDelegate <NSObject>
@optional
- (void)z_banner:(ZZBanner *)banner didClickWithIndex:(NSInteger)index;
- (NSString *)z_banner:(ZZBanner *)banner urlWithdata:(id)data;
@end

@interface ZZBanner : UIView

@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, copy) NSString *placeholderImageName;
@property (nonatomic, assign) float duration;  // 间隔时间
@property (nonatomic, weak) id<ZZBannerDelegate> delegate;

@property (nonatomic, strong) UIColor *currentDotColor;
@property (nonatomic, strong) UIColor *normalDotColor;

@end
