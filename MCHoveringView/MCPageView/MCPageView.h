//
//  MCPageView.h
//  QQFoundation
//
//  Created by qinmuqiao on 2018/6/10.
//  Copyright © 2018年 慕纯. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MCPageView;
@protocol MCPageViewDelegate <NSObject>
- (void)MCPageView:(MCPageView *)MCPageView didSelectIndex:(NSInteger)Index;
@end

@interface MCPageView : UIView

@property (nonatomic , assign) id<MCPageViewDelegate>  delegate;

/**
 可选 默认[UIFont systemFontOfSize:14]
 */
@property (nonatomic , strong) UIFont * defaultTitleFont;

/**
 可选 默认[UIFont systemFontOfSize:14]
 */
@property (nonatomic , strong) UIFont * selectTitleFont;

/**
 可选 默认灰色
 */
@property (nonatomic , strong) UIColor * defaultTitleColor;

/**
 可选 默认黑色
 */
@property (nonatomic , strong) UIColor * selectTitleColor;

/**
 可选 默认平分整个屏幕 最小60
 */
@property (nonatomic , assign) CGFloat  titleButtonWidth;

/**
 可选 item下  横线的颜色 默认取选中字体的颜色
 */
@property (nonatomic , strong) UIColor * lineColor;


/**
 可选 item下 横线的宽度相对于item宽度的比例。0～1 默认0.5
 */
@property (nonatomic , assign) CGFloat lineWitdhScale;


/**
 可选 是否可以滑动 默认yes
 */
@property (nonatomic , assign) BOOL  canSlide;


/**
 可选 设置角标的数据
 个数须与item个数相同
 设置角标  0 消失  大于零展示 小于0 圆圈
 @param badgeArray 角标的数据
 */
- (void)setItemBadgeWithArray:(NSArray *)badgeArray;


/**
 可选 设置某个item的角标
 设置角标  0 消失  大于零展示 小于0 圆圈
 @param index item下标 0开始
 @param badge 角标数量
 */
- (void)setBadgeWithIndex:(NSInteger)index  badge:(NSInteger)badge;

/**
 可选 手动选中某个iem

 @param index item下标
 */
- (void)selectIndex:(NSInteger)index;

/**
 必选 实例化方法
 
 @param frame frame
 @param titles titleS数组
 @param controllers jiemian数组
 @return 实例
 */
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles  controllers:(NSArray *)controllers;
@end


@interface MCItem : UIButton

/**
 设置角标  0 消失, 小于0 展示圆圈 ,  大于零展示 大于999  显示999+
 */
@property (nonatomic,assign) NSInteger badge;

@end

