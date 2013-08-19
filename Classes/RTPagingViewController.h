//
//  ZJUInfoViewController.h
//  iZJU
//
//  Created by ricky on 13-6-7.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface RTPagingViewController : UIViewController <UIScrollViewDelegate>
{
@private
    UIScrollView                * _scrollView;
    UIView                      * _contentView;
    UIView                      * _titleView;
    UIViewController            * _controllerToRemove;
    UIViewController            * _previousController;
    UIViewController            * _nextController;
    //NSInteger                     _possibleIndex;
}
@property (nonatomic, readonly) UIView *titleView;
@property (nonatomic, retain) UIView *titleIndicatorView;
@property (nonatomic, assign) CGPoint indicatorOffset;

@property (nonatomic, retain) NSArray *controllers;
@property (nonatomic, readonly) UIViewController *currentViewController;
@property (nonatomic, assign) NSInteger currentControllerIndex;

@property (nonatomic, retain) UIColor *titleColor;
@property (nonatomic, retain) UIColor *selectedTitleColor;
@property (nonatomic, retain) UIFont *titleFont;
@end