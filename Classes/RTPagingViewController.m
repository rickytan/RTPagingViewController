//
//  ZJUInfoViewController.m
//  iZJU
//
//  Created by ricky on 13-6-7.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <objc/runtime.h>

#import "RTPagingViewController.h"

@implementation UIViewController (RTPagingViewController)

- (RTPagingViewController *)rt_pagingViewController
{
    UIViewController *vc = self.parentViewController;
    while (![vc isKindOfClass:[RTPagingViewController class]]) {
        vc = vc.parentViewController;
    }
    return (RTPagingViewController *)vc;
}

/*
 - (RTPagingBarItem *)rt_pagingBarItem
 {
 RTPagingBarItem *item = objc_getAssociatedObject(self, (__bridge void *)NSStringFromClass([RTPagingBarItem class]));
 if (!item) {
 item = [[RTPagingBarItem alloc] init];
 item.title = self.title;
 }
 return item;
 }

 - (void)setRt_pagingBarItem:(RTPagingBarItem *)rt_pagingBarItem
 {
 objc_setAssociatedObject(self, (__bridge void *)NSStringFromClass([RTPagingBarItem class]), rt_pagingBarItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
 }

 @end


 @interface RTPagingBarItem ()
 @property (nonatomic, strong) UIButton *button;
 @end

 @implementation RTPagingBarItem

 - (UIButton *)button
 {
 if (!_button) {
 _button = [UIButton buttonWithType:UIButtonTypeCustom];
 }
 return _button;
 }

 - (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state
 {
 [super setTitleTextAttributes:attributes forState:state];

 if (attributes[NSForegroundColorAttributeName]) {
 [self.button setTitleColor:attributes[NSForegroundColorAttributeName]
 forState:state];
 }
 if (attributes[NSFontAttributeName]) {
 self.button.titleLabel.font = attributes[NSFontAttributeName];
 }
 if (attributes[NSShadowAttributeName]) {
 NSShadow *shadow = attributes[NSShadowAttributeName];
 self.button.titleLabel.shadowOffset = shadow.shadowOffset;
 self.button.titleLabel.layer.shadowRadius = shadow.shadowBlurRadius;
 [self.button setTitleShadowColor:shadow.shadowColor
 forState:state];
 }
 }
 */

@end


@interface RTPagingViewController ()
<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) RTGridContainerView *titleView;

@property (nonatomic, assign) BOOL scrollingStarted;
@property (nonatomic, assign) BOOL scrollMoved;

- (void)loadTitles;
- (void)loadControllers;
- (void)scrollDidEnd;
- (void)updateTitleSelection;
- (void)updateTitleIndicator;
- (void)onTitleSelected:(UIButton*)button;
- (UIViewController*)loadControllerAtIndex:(NSInteger)index;
- (BOOL)isControllerVisible:(UIViewController*)controller;
- (BOOL)isControllerVisibleAtIndex:(NSInteger)index;
@end

@implementation RTPagingViewController
@synthesize controllers = _controllers;

- (void)commonInit
{
    _currentControllerIndex = -1;
    self.titleColor = [UIColor colorWithWhite:184.0/255
                                        alpha:1.0];
    self.selectedTitleColor = [UIColor colorWithWhite:124.0/255
                                                alpha:1.0];
    self.titleFont = [UIFont systemFontOfSize:14.f];

    self.titleViewHeight = 36.f;
    self.indicatorOffset = CGPointZero;

    /*
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(onBeginRotate:)
     name:UIApplicationWillChangeStatusBarOrientationNotification
     object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(onEndRotate:)
     name:UIApplicationDidChangeStatusBarOrientationNotification
     object:nil];
     */
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithController:(NSArray *)controllers
{
    self = [super initWithNibName:nil
                           bundle:nil];
    if (self) {
        [self commonInit];
        self.controllers = controllers;
    }
    return self;
}

- (void)loadView
{
    UIScrollView *view = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.scrollsToTop = NO;
    view.autoresizesSubviews = YES;
    view.backgroundColor = [UIColor whiteColor];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.titleView.gridSize = CGSizeMake(RTGridSizeDynamicSize, self.titleViewHeight);

    [self.view addSubview:self.contentView];
    [self.view addSubview:self.titleView];

    self.titleView.itemMargin = 8.f;
    [self.titleView addSubview:self.titleIndicatorView];
    [self.contentView addSubview:self.scrollView];

    [self loadTitles];
    [self loadControllerAtIndex:self.currentControllerIndex];
    [self updateTitleSelection];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.currentViewController beginAppearanceTransition:YES
                                                 animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.currentViewController endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.currentViewController beginAppearanceTransition:NO
                                                 animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.currentViewController endAppearanceTransition];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGRect slice, remainder;
    CGRectDivide((CGRect){{0, 0}, self.view.bounds.size}, &slice, &remainder, self.titleViewHeight, CGRectMinYEdge);
    self.titleView.frame = slice;
    self.contentView.frame = remainder;
    self.scrollView.frame = self.contentView.bounds;

    CGFloat itemWidth = (self.titleView.bounds.size.width + self.titleView.itemMargin) / self.titleView.gridItems.count - self.titleView.itemMargin;
    self.titleView.gridSize = CGSizeMake(MAX(itemWidth, 60), self.titleViewHeight);

    [self updateContentSize];
    [self updateOffset];
    // must after  offset is updated!!
    [self updateTitleIndicator];

    [self loadControllerAtIndex:self.currentControllerIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [self.currentViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return [self.currentViewController shouldAutorotate];
}

/*
 - (void)onBeginRotate:(NSNotification *)notification
 {
 self.scrollView.scrollEnabled = NO;
 [self updateOffset];
 [self updateTitleIndicator];
 }

 - (void)onEndRotate:(NSNotification *)notification
 {
 self.scrollView.scrollEnabled = YES;
 [self updateOffset];
 [self updateTitleIndicator];
 }
 */

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    self.scrollingStarted = NO;
    self.scrollView.scrollEnabled = NO;
    [UIView animateWithDuration:duration
                     animations:^{
                         [self updateOffset];
                         [self updateTitleIndicator];
                     }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.scrollView.scrollEnabled = YES;
    self.scrollMoved = NO;
    [self updateOffset];
    [self updateTitleIndicator];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.scrollingStarted = NO;
    self.scrollView.scrollEnabled = NO;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self updateOffset];
        [self updateTitleIndicator];
    }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     self.scrollView.scrollEnabled = YES;
                                     self.scrollMoved = NO;
                                 }];
}



- (NSUInteger)supportedInterfaceOrientations
{
    return [self.currentViewController supportedInterfaceOrientations];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.currentViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    return [self.currentViewController prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return [self.currentViewController preferredStatusBarUpdateAnimation];
}

#pragma mark - Methods

- (void)setTitleViewHeight:(CGFloat)titleViewHeight
{
    _titleViewHeight = titleViewHeight;
    if (self.isViewLoaded) {
        [self.view setNeedsLayout];
    }
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    if (self.isViewLoaded) {

    }
}

- (void)scrollDidEnd
{
    self.scrollingStarted = NO;
    self.scrollMoved = NO;

    UIViewController *currentVC = self.currentViewController;
    [currentVC endAppearanceTransition];

    [_previousController endAppearanceTransition];
    [_nextController endAppearanceTransition];

    NSInteger index = (NSInteger)floorf(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width);
    if (index != self.currentControllerIndex) {
        _currentControllerIndex = index;
        [currentVC.view removeFromSuperview];
        [self updateTitleSelection];
    }
    else {
        [_previousController.view removeFromSuperview];
        [_nextController.view removeFromSuperview];
    }
    _previousController = nil;
    _nextController = nil;

}

- (void)updateOffset
{
    CGFloat width = self.scrollView.bounds.size.width;
    //    self.scrollView.contentOffset = CGPointMake(width * _currentControllerIndex, 0);
    self.scrollView.delegate = nil;
    [self.scrollView setContentOffset:CGPointMake(width * _currentControllerIndex, 0)
                             animated:NO];
    self.scrollView.delegate = self;
}

- (void)updateContentSize
{
    CGSize size = self.scrollView.bounds.size;
    size.width = self.controllers.count * size.width;
    size.height = 0;
    self.scrollView.contentSize = size;
}

- (void)updateTitleSelection
{
    [self.titleView.gridItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((UIButton *)obj).selected = NO;
    }];

    if (0 <= self.currentControllerIndex && self.currentControllerIndex < self.controllers.count) {
        ((UIButton*)[self.titleView.gridItems objectAtIndex:self.currentControllerIndex]).selected = YES;
    }

}

- (void)updateTitleIndicator
{
    if (self.controllers.count > 0) {
        CGFloat halfHeight = self.titleViewHeight - self.titleIndicatorView.bounds.size.height / 2.0;

        CGFloat offset = [self.titleView positionForItemAtIndex:self.scrollView.contentOffset.x / self.scrollView.bounds.size.width].x;

        self.titleIndicatorView.center = CGPointMake(offset + self.indicatorOffset.x,
                                                     halfHeight + self.indicatorOffset.y);
    }
}

- (UIView *)titleLabelForController:(UIViewController *)controller
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = self.titleFont;
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    btn.titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
#else
    btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
#endif
    [btn setTitle:controller.title
         forState:UIControlStateNormal];
    [btn setTitleColor:self.titleColor
              forState:UIControlStateNormal];
    [btn setTitleColor:self.selectedTitleColor
              forState:UIControlStateSelected];
    [btn addTarget:self
            action:@selector(onTitleSelected:)
  forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

- (void)loadTitles
{
    if (self.controllers.count > 0) {

        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.controllers.count];
        NSInteger tag = 0;
        for (UIViewController *c in self.controllers) {
            UIView *view = [self titleLabelForController:c];
            view.tag = tag++;
            [arr addObject:view];
        }
        self.titleView.gridItems = [NSArray arrayWithArray:arr];
        [self.titleView bringSubviewToFront:self.titleIndicatorView];
    }
}

- (void)loadControllers
{
    if (self.controllers.count > 0) {
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.scrollView.contentSize = CGSizeZero;

        [self updateOffset];
        [self loadControllerAtIndex:self.currentControllerIndex];
        [self updateTitleSelection];
        [self updateTitleIndicator];

        NSInteger i = 0;
        for (UIViewController *controller in self.controllers) {
            [self addChildViewController:controller];
            [controller didMoveToParentViewController:self];

            if (i++ == self.currentControllerIndex) {

                CGFloat width = self.scrollView.bounds.size.width;
                CGRect frame = self.scrollView.bounds;
                frame.origin.x = width * self.currentControllerIndex;
                controller.view.frame = frame;
                controller.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                [self.scrollView addSubview:controller.view];

                [self updateTitleSelection];
                [self updateTitleIndicator];
            }
        }
    }
}

- (UIViewController *)loadControllerAtIndex:(NSInteger)index
{
    CGFloat width = self.scrollView.bounds.size.width;

    UIViewController *controller = [self.controllers objectAtIndex:index];
    CGRect frame = self.scrollView.bounds;
    frame.origin.x = index * width;
    controller.view.frame = frame;
    controller.view.hidden = NO;
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.scrollView addSubview:controller.view];
    return controller;
}

- (BOOL)isControllerVisible:(UIViewController *)controller
{
    if (!controller.isViewLoaded)
        return NO;

    CGFloat width = self.scrollView.bounds.size.width;

    CGFloat minX = controller.view.frame.origin.x;
    CGFloat maxX = minX + width;

    CGFloat offset = self.scrollView.contentOffset.x;
    return (offset + width > minX && offset < maxX);
}

- (BOOL)isControllerVisibleAtIndex:(NSInteger)index
{
    CGFloat width = self.scrollView.bounds.size.width;

    CGFloat minX = width * index;
    CGFloat maxX = width * (index + 1);

    CGFloat offset = self.scrollView.contentOffset.x;
    return (offset + width > minX && offset < maxX);
}

- (RTGridContainerView *)titleView
{
    if (!_titleView) {
        CGRect frame = self.view.bounds;
        frame.size.height = self.titleViewHeight;

        _titleView = [[RTGridContainerView alloc] initWithFrame:frame];
        _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _titleView.autoresizesSubviews = YES;
    }
    return _titleView;
}

- (CGRect)frameForContentView
{
    return CGRectMake(0, self.titleViewHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.titleViewHeight);
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:[self frameForContentView]];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _contentView.autoresizesSubviews = YES;
    }
    return _contentView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
        _scrollView.delegate = self;
        _scrollView.directionalLockEnabled = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.bounces = NO;
        _scrollView.autoresizesSubviews = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _scrollView;
}

- (void)onTitleSelected:(UIButton *)button
{
    self.currentControllerIndex = button.tag;
}

- (NSArray *)controllers
{
    [self view];
    return _controllers;
}

- (void)setControllers:(NSArray *)controllers
{
    [self setControllers:controllers
                animated:NO];
}

- (void)setControllers:(NSArray *)controllers animated:(BOOL)animated
{
    if ([_controllers isEqualToArray:controllers])
        return;

    NSMutableSet *set = [NSMutableSet setWithArray:_controllers];
    [set minusSet:[NSSet setWithArray:controllers]];
    NSArray *controllersToRemove = [set allObjects];

    set = [NSMutableSet setWithArray:controllers];
    [set minusSet:[NSSet setWithArray:_controllers]];
    NSArray *controllersToAdd = [set allObjects];

    [controllersToRemove makeObjectsPerformSelector:@selector(willMoveToParentViewController:)
                                         withObject:nil];


    for (UIViewController *vc in controllersToAdd) {
        [self addChildViewController:vc];
    }

    UIViewController *oldCurrentController = _currentControllerIndex >= 0 ? _controllers[_currentControllerIndex] : nil;

    NSInteger newCurrent = MAX(0, MIN(controllers.count - 1, _currentControllerIndex));
    UIViewController *newCurrentController = controllers[newCurrent];


    if (_previousController != newCurrentController) {
        [_previousController endAppearanceTransition];
    }

    if (_nextController != newCurrentController) {
        [_nextController endAppearanceTransition];
    }

    if (oldCurrentController != newCurrentController) {
        if (oldCurrentController) {
            if (!self.scrollMoved) {
                [oldCurrentController beginAppearanceTransition:NO
                                                       animated:animated];

            }
            if (newCurrentController != _previousController && newCurrentController != _nextController) {
                [newCurrentController beginAppearanceTransition:YES
                                                       animated:animated];
                [_previousController beginAppearanceTransition:NO
                                                      animated:animated];
                [_nextController beginAppearanceTransition:NO
                                                  animated:animated];
            }

            [UIView transitionFromView:oldCurrentController.view
                                toView:newCurrentController.view
                              duration:animated ? 0.25 : 0
                               options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionLayoutSubviews
                            completion:^(BOOL finished) {
                                [newCurrentController endAppearanceTransition];
                                [oldCurrentController endAppearanceTransition];

                                if (_previousController != newCurrentController)
                                    [_previousController endAppearanceTransition];
                                if (_nextController != newCurrentController)
                                    [_nextController endAppearanceTransition];
                                _previousController = nil;
                                _nextController = nil;

                                [controllersToRemove makeObjectsPerformSelector:@selector(removeFromParentViewController)];
                                [controllersToAdd makeObjectsPerformSelector:@selector(didMoveToParentViewController:) withObject:self];
                            }];
        }
        else {
            [controllersToRemove makeObjectsPerformSelector:@selector(removeFromParentViewController)];
            [controllersToAdd makeObjectsPerformSelector:@selector(didMoveToParentViewController:) withObject:self];
        }
    }
    else {
        if (self.scrollMoved) {
            [oldCurrentController endAppearanceTransition];
        }

        if (newCurrentController != _previousController && newCurrentController != _nextController) {
            if (self.scrollMoved)
                [newCurrentController beginAppearanceTransition:YES
                                                       animated:animated];
            [_previousController beginAppearanceTransition:NO
                                                  animated:animated];
            [_nextController beginAppearanceTransition:NO
                                              animated:animated];
        }
        if (self.scrollMoved)
            [newCurrentController endAppearanceTransition];

        if (_previousController != newCurrentController)
            [_previousController endAppearanceTransition];
        if (_nextController != newCurrentController)
            [_nextController endAppearanceTransition];

        _previousController = nil;
        _nextController = nil;

        [controllersToRemove makeObjectsPerformSelector:@selector(removeFromParentViewController)];
        [controllersToAdd makeObjectsPerformSelector:@selector(didMoveToParentViewController:) withObject:self];
    }


    _currentControllerIndex = newCurrent;
    _controllers = controllers;

    if (self.isViewLoaded) {
        self.scrollingStarted = NO;     // IMPORTANT !!!
        self.scrollMoved = NO;
        self.scrollView.scrollEnabled = NO;

        [UIView animateWithDuration:animated ? 0.25 : 0
                         animations:^{
                             self.scrollView.scrollEnabled = YES;
                             [self loadTitles];
                             [self updateTitleSelection];
                             [self.view setNeedsLayout];
                         }];
    }
}

- (void)appendPage:(UIViewController *)controller
{
    self.controllers = [_controllers arrayByAddingObject:controller];
}

- (void)removePage:(UIViewController *)controller
{
    NSMutableArray *arr = [self.childViewControllers mutableCopy];
    [arr removeObject:controller];
    self.controllers = [NSArray arrayWithArray:arr];
}

- (void)removePageAtIndex:(NSInteger)index
{
    [self removePage:self.childViewControllers[index]];
}

- (void)setTitleIndicatorView:(UIView *)titleIndicatorView
{
    if (_titleIndicatorView != titleIndicatorView) {
        _titleIndicatorView = titleIndicatorView;
        _titleIndicatorView.autoresizingMask = UIViewAutoresizingNone;
        if (self.isViewLoaded) {
            [self.titleView addSubview:titleIndicatorView];
        }
    }
}

- (UIViewController*)currentViewController
{
    if (self.currentControllerIndex == -1)
        return nil;
    return [self.controllers objectAtIndex:self.currentControllerIndex];
}

- (void)setCurrentControllerIndex:(NSInteger)currentControllerIndex
{
    if (!self.isViewLoaded) {
        _currentControllerIndex = currentControllerIndex;
        return;
    }
    if (_currentControllerIndex != currentControllerIndex) {
        _controllerToRemove = self.currentViewController;
        [_controllerToRemove beginAppearanceTransition:NO
                                              animated:NO];

        _currentControllerIndex = currentControllerIndex;

        UIViewController *newCurrent = [self loadControllerAtIndex:_currentControllerIndex];
        [newCurrent beginAppearanceTransition:YES
                                     animated:NO];

        [_controllerToRemove.view removeFromSuperview];
        [_controllerToRemove endAppearanceTransition];
        _controllerToRemove = nil;

        [newCurrent endAppearanceTransition];

        [self updateTitleSelection];
        [self updateOffset];

        [UIView animateWithDuration:0.25
                         animations:^{
                             [self updateTitleIndicator];
                         }];
    }
}

#pragma mark UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.scrollingStarted = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateTitleSelection];
    [self updateTitleIndicator];


    if (self.scrollingStarted) {

        CGFloat width = self.scrollView.bounds.size.width;
        CGFloat offsetIndex = scrollView.contentOffset.x / width;
        if (offsetIndex - self.currentControllerIndex > 1.f) {
            [_nextController endAppearanceTransition];
            _nextController = nil;
            _previousController = self.currentViewController;
            ++_currentControllerIndex;
            [self.currentViewController beginAppearanceTransition:NO
                                                         animated:YES];
        }
        else if (offsetIndex - self.currentControllerIndex < -1.f) {
            [_previousController endAppearanceTransition];
            _previousController = nil;
            _nextController = self.currentViewController;
            --_currentControllerIndex;
            [self.currentViewController beginAppearanceTransition:NO
                                                         animated:YES];
        }



        if (!self.scrollMoved) {
            [self.currentViewController beginAppearanceTransition:NO
                                                         animated:YES];
        }

        self.scrollMoved = YES;


        CGFloat currentIndex = self.currentControllerIndex;

        // scroll to right
        if (offsetIndex > currentIndex) {
            if ((NSInteger)currentIndex + 1 < self.controllers.count) {
                if (![self isControllerVisible:_previousController]) {
                    [_previousController endAppearanceTransition];
                    //[_previousController.view removeFromSuperview];
                    _previousController = nil;
                }
                if (!_nextController) {
                    _nextController = [self loadControllerAtIndex:(int)currentIndex + 1];
                    [_nextController beginAppearanceTransition:YES
                                                      animated:YES];
                }
            }
        }
        // scroll to left
        else if (offsetIndex < currentIndex) {
            if ((NSInteger)currentIndex - 1 >= 0) {
                if (![self isControllerVisible:_nextController]) {
                    [_nextController endAppearanceTransition];
                    //[_nextController.view removeFromSuperview];
                    _nextController = nil;
                }
                if (!_previousController) {
                    _previousController = [self loadControllerAtIndex:(int)currentIndex - 1];
                    [_previousController beginAppearanceTransition:YES
                                                          animated:YES];
                }
            }
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (!self.scrollMoved)
        return;

    NSInteger index = (NSInteger)floorf(targetContentOffset->x / self.scrollView.bounds.size.width);
    if (index == self.currentControllerIndex) {
        [self.currentViewController beginAppearanceTransition:YES
                                                     animated:YES];
        [_previousController beginAppearanceTransition:NO
                                              animated:YES];
        [_nextController beginAppearanceTransition:NO
                                          animated:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{

    if (!self.scrollMoved)
        return;

    if (!decelerate) {
        [self scrollDidEnd];
    }
    else {
        if ([UIDevice currentDevice].systemVersion.floatValue > 6.f)
            return;

        CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:self.view];
        CGFloat width = scrollView.bounds.size.width;
        CGFloat halfWidth = width / 2.f;
        NSInteger currPage = (NSInteger)floor((scrollView.contentOffset.x + halfWidth) / width);
        if (velocity.x > 240.f) {
            --currPage;
        }
        else if (velocity.x < -240.f) {
            ++currPage;
        }
        if (currPage == self.currentControllerIndex) {
            [self.currentViewController beginAppearanceTransition:YES
                                                         animated:YES];
            [_previousController beginAppearanceTransition:NO
                                                  animated:YES];
            [_nextController beginAppearanceTransition:NO
                                              animated:YES];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollMoved)
        [self scrollDidEnd];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self scrollDidEnd];
}

@end
