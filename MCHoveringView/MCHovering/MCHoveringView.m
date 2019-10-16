//
//  MCHoveringView.m
//  QQFoundation
//
//  Created by qinmuqiao on 2019/1/11.
//  Copyright © 2019年 慕纯. All rights reserved.
//

#import "MCHoveringView.h"
#import "QQtableView.h"
#import "MJRefresh.h"
@interface MCHoveringView ()<UIScrollViewDelegate,MCPageViewDelegate>

@property (nonatomic , assign) CGFloat  headHeight;
/**是否悬停了*/
@property (nonatomic , assign) BOOL  isHover;
/**是否时下拉了手还没送往上滑*/
@property (nonatomic , assign) BOOL  isDragNORelease;

@property (nonatomic , strong) QQtableView * visibleScrollView;
@end

@implementation MCHoveringView
- (instancetype)initWithFrame:(CGRect)frame deleaget:(id<MCHoveringListViewDelegate>)delegate
{
    self =  [self initWithFrame:frame];
    self.delegate = delegate;
    self.isHover = NO;
    self.isMidRefresh = NO;
    UIView *headView = [self.delegate headView];
    self.headHeight = headView.frame.size.height;
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:headView];
    
    [self.scrollView addSubview:self.pageView];
    self.visibleScrollView = (QQtableView * )[self.delegate listView][0];
    self.visibleScrollView.canResponseMutiGesture = YES;
    __weak typeof(self)weakSelf = self;
    self.visibleScrollView.scrollViewDidScroll = ^(UIScrollView *scrollView) {
        [weakSelf tableViewDidScroll:scrollView];
    };
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}
- (MCPageView *)pageView
{
    if (!_pageView) {
        _pageView = [[MCPageView alloc]initWithFrame:CGRectMake(0, self.headHeight, self.frame.size.width, self.frame.size.height + self.headHeight) titles:[self.delegate listTitle] controllers:[self.delegate listCtroller]];
        _pageView.delegate = self;
    }
    return _pageView;
}
-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height + self.headHeight);
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        
    }
    return _scrollView;
}
/**监听scrollView的偏移量*/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView) {
        /**设置headView的位置*/
        //向上滑动偏移量大于等于某个值悬停
        if (self.scrollView.contentOffset.y >= self.headHeight || self.isHover ) {
            self.scrollView.contentOffset = CGPointMake(0, self.headHeight);
            self.isHover = YES;
        }
        
        if (self.isMidRefresh) {
            if (self.visibleScrollView.contentOffset.y<=0 && scrollView.contentOffset.y <=0) {
                self.scrollView.contentOffset = CGPointZero;
            }else{
                [self changeTabContentOffsetToZero:YES];
            }
        }else{
            [self changeTabContentOffsetToZero:NO];
        }
    }
}
- (void)changeTabContentOffsetToZero:(BOOL)midRefresh{
    
    if (self.isDragNORelease && midRefresh) {
        self.scrollView.contentOffset = CGPointZero;
    }
    /**设置下面列表的位置*/
    if (self.scrollView.contentOffset.y < self.headHeight) {
        if (!self.isHover) {
            //列表的便宜度都设置为零
            NSArray<UIScrollView *> *tem  = [self.delegate listView];
            for (UIScrollView *subS in tem) {
                if (!self.isDragNORelease && midRefresh) {
                    subS.contentOffset = CGPointZero;
                }
            }
        }
    }

}
- (void)tableViewDidScroll:(UIScrollView *)scrollView
{

    if(self.isMidRefresh){
        if (scrollView.contentOffset.y <0 && !self.isHover  && self.scrollView.contentOffset.y<=0) {
            self.scrollView.contentOffset = CGPointZero;
            if (scrollView.contentOffset.y<-2) {
                self.isDragNORelease = YES;
            }
        }else{
            if (scrollView.contentOffset.y >=0) {
                self.isDragNORelease = NO;
            }
            if (!self.isHover && !self.isDragNORelease) {
                self.visibleScrollView.contentOffset = CGPointZero;
            }
            if (scrollView.contentOffset.y <=0 ) {
                self.isHover = NO;
            }else{
                if (!self.isDragNORelease) {
                    self.isHover = YES;
                }
            }
        }
    }else{
        if (!self.isHover) {
            self.visibleScrollView.contentOffset = CGPointZero;
        }
        if (scrollView.contentOffset.y <=0) {
            self.isHover = NO;
        }else{
            self.isHover = YES;
        }
    }
}
- (void)MCPageView:(MCPageView *)MCPageView didSelectIndex:(NSInteger)Index
{
    self.visibleScrollView =(QQtableView *)[self.delegate listView][Index];
    self.visibleScrollView.canResponseMutiGesture = YES;
    __weak typeof(self)weakSelf = self;
    self.visibleScrollView.scrollViewDidScroll = ^(UIScrollView *scrollView) {
        [weakSelf tableViewDidScroll:scrollView];
    };
}

@end
