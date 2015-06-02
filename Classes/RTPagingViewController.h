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
    UIViewController            * _controllerToRemove;
    UIViewController            * _previousController;
    UIViewController            * _nextController;
    //NSInteger                     _possibleIndex;
}
@property (nonatomic, strong, readonly) UIView *titleView;
@property (nonatomic, strong) UIView *titleIndicatorView;
@property (nonatomic, assign) CGPoint indicatorOffset;

@property (nonatomic, strong) NSArray *controllers;
@property (weak, nonatomic, readonly) UIViewController *currentViewController;
@property (nonatomic, assign) NSInteger currentControllerIndex;

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *selectedTitleColor;
@property (nonatomic, strong) UIFont *titleFont;
@end