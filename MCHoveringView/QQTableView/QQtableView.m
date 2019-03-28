//
//  QQtableView.m
//  QQNetManager
//
//  Created by 秦慕乔 on 16/4/19.
//  Copyright © 2016年 秦慕乔. All rights reserved.

#import "QQtableView.h"
#import "MJRefresh.h"
static NSString * const pageIndex = @"pageIndex";//获取第几页的根据自己的需求替换
@interface QQtableView ()
{
    /**纪录当前页数*/
    NSInteger _pageNumber;
    /**出现网络失败*/
    BOOL _hasNetError;
}
/**添加的footView*/
@property (nonatomic , strong) UIView *footerView;
@end
@implementation QQtableView
+ (void)load
{
    Method originalMethod = class_getInstanceMethod(self, @selector(reloadData));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(mc_reloadData));
    BOOL didAddMethod =
    class_addMethod(self,
                    @selector(reloadData),
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(self,
                            @selector(mc_reloadData),
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initTableView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style] ) {
        [self initTableView];
    }
    return self;
}

- (void)initTableView{
    self.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestData)];

    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.estimatedRowHeight  = 0;
    self.estimatedSectionFooterHeight  = 0;
    self.estimatedSectionFooterHeight = 0;
    self.footerView = [UIView new];
    [self setTableFooterView:self.footerView];
    _hasNetError = NO;
    self.canResponseMutiGesture = NO;
}

- (void)mc_reloadData
{
    [self mc_reloadData];
    if (self.getTotal == 0 && _hasNetError) {
        //这里是网络出错的数据为空
        self.tableFooterView = self.emptyView;
    }else if (self.getTotal == 0 ){
        //就是数据为空
        self.tableFooterView =  self.emptyView;
    }else{
        [self setTableFooterView:self.footerView];
    }
}

- (NSInteger)getTotal
{
    NSInteger sections = 0;
    sections = [self numberOfSections];
    NSInteger items = 0;
    for (NSInteger section = 0; section < sections; section++) {
        items += [self numberOfRowsInSection:section];
    }
    return items;
}

- (void)setUpWithUrl:(NSString *)url Parameters:(NSDictionary *)Parameters formController:(UIViewController *)controler
{
    _requestUrl = url;
    _TempController = controler;
    _requestParam= Parameters.mutableCopy;
    if ([Parameters.allKeys containsObject:pageIndex]) {
        self.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefresh)];
    }
    [self.mj_header beginRefreshing];
}

//**请求方法*/
- (void)SetUpNetWorkParamters:(NSDictionary *)paramters isPullDown:(BOOL)isPullDown
{
    //暂时是模仿数据请求h返回数据 替换下面的数据请求 这里就可以删除
    if ([self.RequestDelegate respondsToSelector:@selector(QQtableView:isPullDown:SuccessData:)]) {
        [self.RequestDelegate QQtableView:self isPullDown:isPullDown SuccessData:@[]];
    }
    self->_hasNetError = NO;
    [self EndRefrseh];
#warning 这里替换成自己的网络请求方法就好了 
  /**
   [[QQNetManager Instance]RTSGetWith:_requestUrl parameters:paramters from:_TempController successs:^(id responseObject) {
        //不管有没有数据都应该抛出去
        if ([self.RequestDelegate respondsToSelector:@selector(QQtableView:isPullDown:SuccessData:)]) {
            [self.RequestDelegate QQtableView:self isPullDown:isPullDown SuccessData:responseObject];
        }
        _hasNetError = NO;
        [self EndRefrseh];
    } failed:^(NSError *error) {
        _hasNetError = YES;
        if ([self.RequestDelegate respondsToSelector:@selector(QQtableView:requestFailed:)]) {
            [self.RequestDelegate QQtableView:self requestFailed:error];
        }
        [self EndRefrseh];
        if (!isPullDown) {
            [self changeIndexWithStatus:3];
        }
    }];
   */
}

- (void)setIsHasHeaderRefresh:(BOOL)isHasHeaderRefresh
{
    if (!isHasHeaderRefresh) {
        self.mj_header = nil;
    }else{
        self.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestData)];
    }
}
- (void)requestData
{
    if (_requestUrl.length ==0) {
        NSLog(@"QQTablView:请输入下载网址");
        [self.mj_header endRefreshing];
        return;
    }
    if ([_requestParam.allKeys containsObject:pageIndex]) {
        [self changeIndexWithStatus:1];
    }
    [self SetUpNetWorkParamters:_requestParam isPullDown:YES];
}

- (void)footerRefresh
{
    [self changeIndexWithStatus:2];
    [self SetUpNetWorkParamters:_requestParam isPullDown:NO];
}

- (void)changeIndexWithStatus:(NSInteger)Status//1  下拉  2上拉  3减一
{
    _pageNumber = [_requestParam[pageIndex] integerValue];
    if (Status == 1) {
        _pageNumber = 1;
    }else if (Status == 2){
        _pageNumber ++;
    }else{
        _pageNumber --;
    }
    [_requestParam setObject:[NSNumber numberWithInteger:_pageNumber] forKey:pageIndex];
}

- (void)EndRefrseh
{
    [self.mj_footer endRefreshing];
    [self.mj_header endRefreshing];
}

- (void)setRequestParam:(NSDictionary *)requestParam
{
    if (_requestParam) {
        [_requestParam addEntriesFromDictionary:requestParam];
        return;
    }
    _requestParam = requestParam.mutableCopy;
}

- (void)setRequestUrl:(NSString *)requestUrl
{
    _requestUrl = requestUrl;
}

- (EmptyView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[EmptyView alloc]init];
        _emptyView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - self.tableHeaderView.frame.size.height);
        _emptyView.backgroundColor = [UIColor colorWithRed:245/255.0f green:248/255.0f blue:250/255.0f alpha:1];
    }
    return _emptyView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return self.canResponseMutiGesture;
}
@end

/***************************  以下是空白界面的View  **************************************************/
@interface EmptyView ()
@property (nonatomic , strong) UILabel * hintLb;
@property (nonatomic , strong) UIImageView * imageView;
@end
@implementation EmptyView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initEmptyView];
    }
    return self;
}
- (void)initEmptyView
{
    self.imageView = [[UIImageView alloc]init];
    [self.imageView sizeToFit];
    [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.imageView];
    
    self.hintLb = [[UILabel alloc]init];
    self.hintLb.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    self.hintLb.textColor = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1];
    [self.hintLb setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.hintLb.textAlignment = NSTextAlignmentCenter;
    self.hintLb.numberOfLines = 0;
    [self addSubview:self.hintLb];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:0.6 constant:0]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hintLb attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hintLb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeBottom multiplier:1 constant:10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hintLb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-20]];

}
- (void)setImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0 constant:imageSize.width]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0 constant:imageSize.height]];
}
- (void)setImageName:(NSString *)imageName
{
    self.imageView.image = [UIImage imageNamed:imageName];
}
- (void)setHintText:(NSString *)hintText
{
    self.hintLb.text = hintText;
}
- (void)setHintTextFont:(UIFont *)hintTextFont
{
    self.hintLb.font = hintTextFont;
}
- (void)setHintTextColor:(UIColor *)hintTextColor
{
    self.hintLb.textColor = hintTextColor;
}
- (void)setHintAttributedText:(NSAttributedString *)hintAttributedText
{
    self.hintLb.attributedText = hintAttributedText;
}

@end
