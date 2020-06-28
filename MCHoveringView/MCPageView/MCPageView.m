//
//  MCPageView.m
//  QQFoundation
//
//  Created by qinmuqiao on 2018/6/10.
//  Copyright © 2018年 慕纯. All rights reserved.
//

#import "MCPageView.h"
#import "UIView+QQFrame.h"
#define kwidth          [UIScreen mainScreen].bounds.size.width
#define kheight        [UIScreen mainScreen].bounds.size.height
@interface MCPageView ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic , strong) NSArray * contentCtrollers;
@property (nonatomic , strong) NSArray * contentTitles;
@property (nonatomic , strong) UIScrollView * titleScroll;
@property (nonatomic , strong) UICollectionView * contentCollection;
@property (nonatomic , strong) NSMutableArray * itemArray;
@property (nonatomic , strong) MCItem * lastItem;
@property (nonatomic , strong) UIView  * lineView;
//记录外面传进来的RGB的值
@property (nonatomic , assign) CGFloat  defaultR,defaultG,defaultB,defaultA,selectedR,selectedG,selectedB,selectedA;
@property (nonatomic , strong) UIColor *netxColor ;
@property (nonatomic , assign) BOOL  isClick;

@property (nonatomic , assign) NSInteger  lastIndex;

@end

static const NSInteger itemTag = 100;
@implementation MCPageView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles controllers:(NSArray *)controllers
{
    if (self = [super initWithFrame:frame]) {
        self.contentTitles = [NSArray arrayWithArray:titles];
        _contentCtrollers = [NSArray arrayWithArray:controllers];
        _titleButtonWidth = (self.frame.size.width)/titles.count;
        [self buidParamAndUI];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles  views:(NSArray *)views{
    if (self = [super initWithFrame:frame]) {
        self.contentTitles = [NSArray arrayWithArray:titles];
        _contentCtrollers = [NSArray arrayWithArray:views];
        _titleButtonWidth = (self.frame.size.width)/titles.count;
        [self buidParamAndUI];
    }
    return self;
}
- (void)buidParamAndUI{
    self.itemArray = [NSMutableArray array];
    _defaultTitleColor = [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1];
    _selectTitleColor = [UIColor blackColor];
    _defaultTitleFont = [UIFont systemFontOfSize:14];
    _selectTitleFont = [UIFont systemFontOfSize:14];
    //titleView 的初始化高度
    _titleViewHeight = 50;
    _fontScale = 0.2;
    //初始化横线的宽度是title的一半
    _lineWitdhScale = 0.5;
    self.isClick = NO;
    [self addSubview:self.titleScroll];
    [self addSubview:self.contentCollection];
    [self.titleScroll addSubview:self.lineView];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.contentCtrollers.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MCContent" forIndexPath:indexPath];
    cell.highlighted = NO;
    return cell;
}
//将要加载某个Item时调用的方法
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.contentCtrollers[indexPath.item] isKindOfClass:[UIViewController class]]) {
        UIViewController *childVC = self.contentCtrollers[indexPath.item];
        childVC.view.frame = cell.contentView.bounds;
        [cell.contentView addSubview:childVC.view];
    }else{
        UIView *childV = self.contentCtrollers[indexPath.item];
        childV.frame = cell.contentView.bounds;
        [cell.contentView addSubview:childV];
    }
    
}
//将要加载头尾视图时调用的方法
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(kwidth, self.height -self.titleScroll.bottom);
}
#pragma mark - UIScrollViewDelegate
// 滑动视图，当手指离开屏幕那一霎那，调用该方法。一次有效滑动，只执行一次。
// decelerate,指代，当我们手指离开那一瞬后，视图是否还将继续向前滚动（一段距离），经过测试，decelerate=YES
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([self.delegate respondsToSelector:@selector(endGestureRecognizer)]) {
        [self.delegate endGestureRecognizer];
    }
}
// 当开始滚动视图时，执行该方法。一次有效滑动（开始滑动，滑动一小段距离，只要手指不松开，只算一次滑动），只执行一次。
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(startGestureRecognizer)]) {
        [self.delegate startGestureRecognizer];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.contentCollection) {
        NSInteger index = (int)scrollView.contentOffset.x/kwidth;
        CGFloat percent =  (scrollView.contentOffset.x - kwidth *index)/kwidth;
        percent = fabs(percent);
        if (scrollView.contentOffset.x - kwidth *(index) == 0) {
            NSInteger index = (int)scrollView.contentOffset.x/kwidth;
            [self changeItemStatus:index];
            return;
        }
        //点击头部按钮的时候不走下面的动画
        if (self.isClick) {
            return;
        }
        //横线的动画
        self.lineView.centerX = self.titleButtonWidth *(0.5 + index + percent);
        
        if (index <self.lastIndex) {
            [self animationItem:YES percent:percent index:index];
        }else{
            [self animationItem:NO percent:percent index:index];
        }
    }
}
//MARK: 设置动画
- (void)animationItem:(BOOL)isleft percent:(CGFloat)percent index:(NSInteger)index{
    MCItem *nextItem = nil;
    MCItem *lastItem = nil;
    if (isleft ) {
        nextItem = self.itemArray[index];
        lastItem = self.itemArray[index+1];
    }else if(!isleft && index + 1 < self.itemArray.count){
        nextItem = self.itemArray[index +1];
        lastItem = self.itemArray[index];
    }
    if (!nextItem) {
        return;
    }
    if (!self.netxColor) {
        [self getColorRGB:self.defaultTitleColor isSelected:NO];
        [self getColorRGB:self.selectTitleColor isSelected:YES];
    }
    self.netxColor =[UIColor colorWithRed:self.defaultR + (self.selectedR - self.defaultR)*percent green:self.defaultG + (self.selectedG - self.defaultG)*percent blue:self.defaultB + (self.selectedB - self.defaultB)*percent alpha:self.defaultA + (self.selectedA - self.defaultA)*percent];
    
    UIColor *lastColor = [UIColor colorWithRed:self.selectedR - (self.selectedR - self.defaultR)*percent green:self.selectedG - (self.selectedG - self.defaultG)*percent blue:self.selectedB - (self.selectedB - self.defaultB)*percent alpha: self.selectedA - (self.selectedA - self.defaultA)*percent];
    
    if (isleft) {
        if (lastItem) {
            [lastItem setTitleColor:self.netxColor forState:UIControlStateNormal];
            lastItem.transform = CGAffineTransformMakeScale(1 + (_fontScale *percent),1 + (_fontScale *percent));
        }
        [nextItem setTitleColor:lastColor forState:UIControlStateNormal];
        nextItem.transform = CGAffineTransformMakeScale(1 + (1-percent)*_fontScale,1 + (1-percent)*_fontScale);
    }else{
        if (lastItem) {
            [lastItem setTitleColor:lastColor forState:UIControlStateNormal];
            lastItem.transform = CGAffineTransformMakeScale((1+ _fontScale) - (_fontScale * percent),(1+ _fontScale) - (_fontScale * percent));
        }
        [nextItem setTitleColor:self.netxColor forState:UIControlStateNormal];
        /* 在原来的基础上缩放（只缩放一次） */
        nextItem.transform = CGAffineTransformMakeScale(1 + percent *_fontScale,1 + percent *_fontScale);
    }
}
- (void)getColorRGB:(UIColor *)color isSelected:(BOOL)isSelected

{
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    if (isSelected) {
        self.selectedA = alpha;
        self.selectedR = red;
        self.selectedG = green;
        self.selectedB = blue;
    }else{
        self.defaultA = alpha;
        self.defaultR = red;
        self.defaultG = green;
        self.defaultB = blue;
    }
    
}
/**item 点击事件*/
- (void)selectItem:(MCItem *)btn
{
    [self selectIndex:btn.tag - itemTag];
}
- (void)selectIndex:(NSInteger)index
{
    if (index <0 || index >self.contentCtrollers.count) {
        NSLog(@"滚动的位置大于条目数");
        return;
    }
    self.isClick = YES;
    [self changeItemStatus:index];
    [self.contentCollection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:labs(index) inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [self scrollToItemCenter:self.itemArray[index]];
}
- (void)setBadgeWithIndex:(NSInteger)index badge:(NSInteger)badge
{
    if (index <0 || index >= self.itemArray.count) {
        NSLog(@"设置下标错误");
        return;
    }
    MCItem *item =  self.itemArray[index];
    item.badge = badge;
}
- (void)setItemBadgeWithArray:(NSArray *)badgeArray
{
    if (badgeArray.count > self.itemArray.count || badgeArray.count ==0) {
        NSLog(@"设置下标错误");
        return;
    }
    __weak __typeof(&*self)weakSelf = self;
    [badgeArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MCItem *item =  weakSelf.itemArray[idx];
        item.badge = obj.integerValue;
    }];
}
- (void)changeItemStatus:(NSInteger)index
{
    MCItem * Item = self.itemArray[index];
    if (Item == self.lastItem) {
        return;
    }
    [self menuScrollToCenter:index];
    if (self.lastItem) {
        self.lastItem.titleLabel.font = self.defaultTitleFont;
        [self.lastItem setTitleColor:self.defaultTitleColor forState:UIControlStateNormal];
        self.lastItem.transform = CGAffineTransformMakeScale(1,1);
        
    }
    Item.transform = CGAffineTransformMakeScale(1+ _fontScale,1+ _fontScale);
    
    self.lastIndex = index;
    self.lastItem = Item;
    Item.titleLabel.font = self.selectTitleFont;
    [Item setTitleColor:self.selectTitleColor forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(MCPageView:didSelectIndex:)]) {
        [self.delegate MCPageView:self didSelectIndex:index];
    }
}

/**
 顶部菜单滑动到中间
 @param index 第几个item
 */
- (void)menuScrollToCenter:(NSInteger)index{
    
    MCItem *Button = self.itemArray[index];
    CGFloat titleScroWidth = kwidth- self.marginToLfet - self.marginToRight;
    CGFloat left = Button.center.x -  titleScroWidth / 2.0;
    left = left <= 0 ? 0 : left;
    CGFloat maxLeft = _titleButtonWidth * self.contentTitles.count - titleScroWidth;
    if (maxLeft <=0) {
        maxLeft = 0;
    }
    left = left >= maxLeft ? maxLeft : left;
    [self.titleScroll setContentOffset:CGPointMake(left, 0) animated:YES];
}

/**
 title底部横线滑动
 @param item 滑动到那个item下
 */
- (void)scrollToItemCenter:(MCItem *)item
{
    if (!item) {
        return;
    }
    self.isClick = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.lineView.centerX = self.titleButtonWidth *(0.5 + (item.tag -itemTag));
    }];
}

- (void)setMarginToLfet:(CGFloat)marginToLfet
{
    _marginToLfet = marginToLfet;
    CGFloat width =  self.width  - _marginToRight - _marginToLfet;
    self.titleScroll.frame = CGRectMake(_marginToLfet, 0,width, self.titleViewHeight);
}
- (void)setMarginToRight:(CGFloat)marginToRight
{
    _marginToRight = marginToRight;
    CGFloat width =  self.width  - _marginToRight - _marginToLfet;
    self.titleScroll.frame = CGRectMake(_marginToLfet, 0, width, self.titleViewHeight);
}
/**设置选中title字体*/
- (void)setSelectTitleFont:(UIFont *)selectTitleFont
{
    _selectTitleFont = selectTitleFont;
    self.lastItem.titleLabel.font = _selectTitleFont;
}
/**设置选中title颜色*/
- (void)setSelectTitleColor:(UIColor *)selectTitleColor
{
    _selectTitleColor = selectTitleColor;
    [self.lastItem setTitleColor:_selectTitleColor forState:UIControlStateNormal];
    
    _lineColor = selectTitleColor;
    self.lineView.backgroundColor = selectTitleColor;
}
- (void)setDefaultTitleFont:(UIFont *)defaultTitleFont
{
    _defaultTitleFont = defaultTitleFont;
    __weak __typeof(&*self)weakSelf = self;
    [self.itemArray enumerateObjectsUsingBlock:^(MCItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![item isEqual:weakSelf.lastItem]) {
            item.titleLabel.font = weakSelf.defaultTitleFont;
        }
    }];
}
- (void)setDefaultTitleColor:(UIColor *)defaultTitleColor
{
    _defaultTitleColor = defaultTitleColor;
    __weak __typeof(&*self)weakSelf = self;
    [self.itemArray enumerateObjectsUsingBlock:^(MCItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![item isEqual:weakSelf.lastItem]) {
            [item setTitleColor:weakSelf.defaultTitleColor forState:UIControlStateNormal];
        }
    }];
}
/**设置横线颜色*/
- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    self.lineView.backgroundColor = lineColor;
}
- (void)setLineHeight:(CGFloat)lineHeight
{
    _lineHeight  = lineHeight;
    CGRect rect =  self.lineView.frame;
    rect.origin.y = self.titleViewHeight  - lineHeight;
    rect.size.height = lineHeight;
    self.lineView.frame = rect;
}
/**设置横下相对于titleBtn款低的比例*/
- (void)setLineWitdhScale:(CGFloat)lineWitdhScale
{
    if (lineWitdhScale > 1) {
        NSLog(@"长度不可大与一");
        return;
    }
    _lineWitdhScale = lineWitdhScale;
    CGRect rect = self.lineView.frame;
    rect.origin.x = rect.origin.x + ( rect.size.width  - _titleButtonWidth*lineWitdhScale)/2;
    rect.size.width = _titleButtonWidth*lineWitdhScale;
    self.lineView.frame = rect;
}
/**是否允许页面滑动*/
- (void)setCanSlide:(BOOL)canSlide
{
    _canSlide = canSlide;
    self.contentCollection.scrollEnabled = canSlide;
}
- (void)setTitleViewHeight:(CGFloat)titleViewHeight
{
    _titleViewHeight = titleViewHeight;
    [self setNeedsLayout];
}
- (void)layoutSubviews
{
    self.titleScroll.frame = CGRectMake(_marginToLfet, 0, self.width  - _marginToRight - _marginToLfet, self.titleViewHeight);
    self.contentCollection.frame =  CGRectMake(0, self.titleScroll.bottom, kwidth, self.height - self.titleScroll.bottom);
}
/**设置选中titlebtn的宽度*/
- (void)setTitleButtonWidth:(CGFloat)titleButtonWidth
{
    if (titleButtonWidth < 10) {
        NSLog(@"**设置的宽度太小，请重新设置**");
        return;
    }
    _titleButtonWidth = titleButtonWidth;
    
    //如果给的宽度与title个数乘积小于屏幕宽度
    if ((_titleButtonWidth *_contentTitles.count) >kwidth) {
        self.titleScroll.contentSize = CGSizeMake((_titleButtonWidth *_contentTitles.count), self.titleViewHeight);
    }else{
        self.titleScroll.contentSize = CGSizeMake(kwidth, self.titleViewHeight);
    }
    __weak __typeof(&*self)weakSelf = self;
    [weakSelf.titleScroll.constraints enumerateObjectsWithOptions: NSEnumerationReverse usingBlock: ^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.firstAttribute == NSLayoutAttributeLeft ) {
            obj.active = NO;
        }
    }];
    [self.itemArray enumerateObjectsUsingBlock:^(MCItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        [item.constraints enumerateObjectsWithOptions: NSEnumerationReverse usingBlock: ^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.firstAttribute == NSLayoutAttributeWidth ) {
                obj.active = NO;
            }
        }];
        
        [item addConstraint:[NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:weakSelf.titleButtonWidth]];
        
        [weakSelf.titleScroll addConstraint:[NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:weakSelf.titleScroll attribute:NSLayoutAttributeLeft multiplier:1 constant:idx *weakSelf.titleButtonWidth]];
    }];
    
    CGRect lineRect = self.lineView.frame;
    lineRect.size.width = _titleButtonWidth*_lineWitdhScale;
    self.lineView.frame = lineRect;
    [self scrollToItemCenter:self.lastItem];
}
- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(_titleButtonWidth/4, self.titleViewHeight - 1, _titleButtonWidth/2, 1)];
        _lineView.backgroundColor = self.selectTitleColor;
    }
    return _lineView;
}
- (NSArray *)contentTitles
{
    if (!_contentTitles) {
        _contentTitles = [NSArray array];
    }
    return  _contentTitles;
}
- (UICollectionView *)contentCollection
{
    if (!_contentCollection) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _contentCollection= [[UICollectionView alloc]initWithFrame:CGRectMake(0, self.titleScroll.bottom, kwidth, self.height - self.titleScroll.bottom) collectionViewLayout:flowLayout];
        _contentCollection.showsHorizontalScrollIndicator = NO;
        _contentCollection.pagingEnabled = YES;
        _contentCollection.bounces = NO;
        _contentCollection.delegate = self;
        _contentCollection.dataSource = self;
        [_contentCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MCContent"];
    }
    return _contentCollection;
}
- (UIScrollView *)titleScroll
{
    if (!_titleScroll) {
        _titleScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kwidth, self.titleViewHeight)];
        _titleScroll.delegate = self;
        _titleScroll.showsVerticalScrollIndicator = NO;
        _titleScroll.showsHorizontalScrollIndicator = NO;
        
        //最小值与个数乘积还大与屏幕的话 就按60宽度算
        if (_contentTitles.count * self.titleButtonWidth > kwidth) {
            self.titleScroll.contentSize = CGSizeMake((self.titleButtonWidth *_contentTitles.count), self.titleViewHeight);
        }else{
            self.titleScroll.contentSize = CGSizeMake(kwidth, self.titleViewHeight);
        }
        __weak __typeof(&*self)weakSelf = self;
        [_contentTitles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @autoreleasepool{
                MCItem *item = [[MCItem alloc]init];
                [item setTranslatesAutoresizingMaskIntoConstraints:NO];
                item.tag = idx + itemTag;
                [item setTitleColor:self.defaultTitleColor forState:UIControlStateNormal];
                [item setTitle:obj forState:UIControlStateNormal];
                [item.titleLabel setFont:self.defaultTitleFont];
                [item addTarget:weakSelf action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];
                item.titleLabel.textAlignment = NSTextAlignmentCenter;
                if (idx ==0) {
                    weakSelf.lastItem = item;
                    item.transform = CGAffineTransformMakeScale(1+_fontScale,1+_fontScale);
                    [item setTitleColor:self.selectTitleColor forState:UIControlStateNormal];
                    [item.titleLabel setFont:self.selectTitleFont];
                }
                [weakSelf.itemArray addObject:item];
                [weakSelf.titleScroll addSubview:item];
                
                
                [weakSelf.titleScroll addConstraint:[NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:weakSelf.titleScroll attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
                [weakSelf.titleScroll addConstraint:[NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:weakSelf.titleScroll attribute:NSLayoutAttributeLeft multiplier:1 constant:idx *weakSelf.titleButtonWidth]];
                
                [item addConstraint:[NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:weakSelf.titleButtonWidth]];
            }
        }];
    }
    return _titleScroll;
}
@end

@interface MCItem()
@property (nonatomic,strong) UILabel *badgeLb;

@end
@implementation MCItem
{
    CGRect originRect;
}
- (void)setBadge:(NSInteger)badge
{
    _badge = badge;
    NSString *badgeText = [NSString string];
    if (badge > 99) {
        badgeText = @"99+";
    }else if(badge >0){
        badgeText = [NSString stringWithFormat:@"%lu",(long)badge];
    }else{
        self.badgeLb.text = @"";
    }
    self.badgeLb.text = badgeText;
    [self.badgeLb sizeToFit];
    originRect = self.badgeLb.frame;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect rect = originRect;
    if (_badge < 0) {
        rect.size.width = 10;
        rect.size.height = 10;
    }else if(_badge == 0){
        rect.size.width = 0;
    }else{
        rect.size.width =  originRect.size.width + 5;
    }
    self.badgeLb.frame  = rect;
    
    CGPoint point = self.badgeLb.center;
    point.x = self.frame.size.width/2 + (self.titleLabel.frame.size.width/2);
    point.y = self.frame.size.height/2 - self.titleLabel.frame.size.height/2 - 5;
    self.badgeLb.center = point;
    self.badgeLb.layer.cornerRadius = self.badgeLb.frame.size.height/2;
}
- (UILabel *)badgeLb
{
    if (!_badgeLb) {
        _badgeLb = [[UILabel alloc]init];
        _badgeLb.textColor = [UIColor whiteColor];
        _badgeLb.backgroundColor = [UIColor redColor];
        _badgeLb.font = [UIFont systemFontOfSize:10];
        _badgeLb.textAlignment = NSTextAlignmentCenter;
        _badgeLb.layer.masksToBounds = YES;
        [self addSubview:_badgeLb];
    }
    return _badgeLb;
}

@end
