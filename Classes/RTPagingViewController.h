//
//  ZJUInfoViewController.h
//  iZJU
//
//  Created by ricky on 13-6-7.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RTGridContainerView.h"


IB_DESIGNABLE
@interface RTPagingViewController : UIViewController <UIScrollViewDelegate>
{
@private
    UIViewController            * _controllerToRemove;
    UIViewController            * _previousController;
    UIViewController            * _nextController;
    //NSInteger                     _possibleIndex;
}
@property (nonatomic, strong, readonly) RTGridContainerView *titleView;
@property (nonatomic, strong) UIView *titleIndicatorView;
@property (nonatomic, assign) CGPoint indicatorOffset;

@property (nonatomic, strong) NSArray *controllers;
@property (weak, nonatomic, readonly) UIViewController *currentViewController;
@property (nonatomic, assign) NSInteger currentControllerIndex;

@property (nonatomic, strong) IBInspectable UIColor *titleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) IBInspectable UIColor *selectedTitleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) IBInspectable UIFont *titleFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) IBInspectable CGFloat titleViewHeight;

- (instancetype)initWithController:(NSArray *)controllers;

@end