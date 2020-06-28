//
//  MCHoveringView.h
//  QQFoundation
//
//  Created by qinmuqiao on 2019/1/11.
//  Copyright © 2019年 慕纯. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCPageView.h"

NS_ASSUME_NONNULL_BEGIN
/*
 本篇是根据自己的框架情况高度集成的。
 本功能中用的tableView是自己封装好的 QQTableView 里面集成了一些刷新 、空白页、数据请求
 @property (nonatomic , copy) void(^scrollViewDidScroll)(UIScrollView * scrollView);
 是配合获取 偏移量的
 
 本功能中用的分页功能是自己封装好的MCPageView
 
 
 如想使用自己写的tableView 的话
 1、 要把@property (nonatomic , copy) void(^scrollViewDidScroll)(UIScrollView * scrollView);
 属性加上 并在tableView的代理ScrollViewDidScroll:代理中调用次block
 2、tableView中shouldRecognizeSimultaneouslyWithGestureRecognizer方法返回YES 允许同时相应多个手势
 
 */
@protocol MCHoveringListViewDelegate <NSObject>
@required
/**返回展示列表的tableView*/
- (NSArray<UIScrollView *> *)listView;

//**必须设置的头部View*/
- (UIView *)headView;

//下面是配合使用MCPageView需要的俩个数据

/**返回子列表所在的controller*/
- (NSArray<UIViewController *> *)listCtroller;

/**返回子列表的title*/
- (NSArray<NSString *> *)listTitle;


@optional



@end

@interface MCHoveringView : UIView
@property (nonatomic , assign) id <MCHoveringListViewDelegate>  delegate;
- (instancetype)initWithFrame:(CGRect)frame deleaget:(id<MCHoveringListViewDelegate>)delegate;
//**是否在视图中间刷新 默认NO*/
@property (nonatomic , assign) BOOL  isMidRefresh;

//**整体的scrollView  用于添加刷新控件*/
@property (nonatomic , strong) UIScrollView * scrollView;

//**分页View*/
@property (nonatomic , strong) MCPageView * pageView;

@end

NS_ASSUME_NONNULL_END
