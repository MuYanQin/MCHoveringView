//
//  UIView+QQFrame.h
//  QQUIKit
//
//  Created by ZhangQun on 2017/4/6.
//  Copyright © 2017年 秦慕乔. All rights reserved.
//

#import <UIKit/UIKit.h>
CGPoint CGRectGetCenter(CGRect rect);
CGRect  CGRectMoveToCenter(CGRect rect, CGPoint center);
@interface UIView (QQFrame)
@property CGPoint origin;
@property CGSize size;

@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;

@property CGFloat height;
@property CGFloat width;

@property CGFloat top;
@property CGFloat left;

@property CGFloat bottom;
@property CGFloat right;

@property CGFloat centerY;
@property CGFloat centerX;

- (void) moveBy: (CGPoint) delta;
- (void) scaleBy: (CGFloat) scaleFactor;
- (void) fitInSize: (CGSize) aSize;

- (UIViewController *)viewController;

@end
