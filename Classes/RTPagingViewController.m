//
//  ZJUInfoViewController.m
//  iZJU
//
//  Created by ricky on 13-6-7.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "RTPagingViewController.h"

@interface RTPagingViewController ()
<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) RTGridContainerView *titleView;

@property (nonatomic, assign) BOOL scrollingStarted;
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

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.automaticallyAdjustsScrollViewInsets = YES;

    self.titleView.gridSize = CGSizeMake(RTGridSizeDynamicSize, self.titleViewHeight);

    [self.view addSubview:self.contentView];
    [self.view addSubview:self.titleView];

    [self.titleView addSubview:self.titleIndicatorView];
    [self.contentView addSubview:self.scrollView];

    [self loadTitles];
    [self loadControllers];

    //[UIView setAnimationsEnabled:NO];
    [self updateTitleSelection];
    //[UIView setAnimationsEnabled:YES];
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

    self.contentView.frame = [self frameForContentView];

    CGFloat itemWidth = floorf((self.titleView.bounds.size.width + self.titleView.itemMargin) / self.titleView.gridItems.count - self.titleView.itemMargin);
    self.titleView.gridSize = CGSizeMake(itemWidth, self.titleViewHeight);

    [self updateContentSize];
    [self updateOffset];
    // must after  offset is updated!!
    [self updateTitleIndicator];


    CGFloat width = self.scrollView.bounds.size.width;
    CGRect frame = self.scrollView.bounds;
    frame.origin.x = width * self.currentControllerIndex;

    self.currentViewController.view.frame = frame;
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
    return NO;
}

#pragma mark - Methods

- (void)scrollDidEnd
{
    self.scrollingStarted = NO;

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
    [self.scrollView setContentOffset:CGPointMake(width * _currentControllerIndex, 0)
                             animated:NO];
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
    /*
     [self.titleArray makeObjectsPerformSelector:@selector(setSelected:)
     withObject:@NO];

     if (0 <= self.currentControllerIndex && self.currentControllerIndex < self.controllers.count) {
     ((UIButton*)[self.titleArray objectAtIndex:self.currentControllerIndex]).selected = YES;
     }
     */
}

- (void)updateTitleIndicator
{
    if (self.controllers.count > 0) {
        CGFloat halfHeight = self.titleView.bounds.size.height - self.titleIndicatorView.bounds.size.height / 2.0;
        CGFloat width = self.titleView.bounds.size.width / self.controllers.count;
        CGFloat halfWidth = width / 2.0;

        CGFloat offset = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;

        self.titleIndicatorView.center = CGPointMake(width * offset + halfWidth + self.indicatorOffset.x,
                                                     halfHeight + self.indicatorOffset.y);
    }
}

- (UIView *)titleLabelForController:(UIViewController *)controller
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = self.titleFont;
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn.titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
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
    }
}

- (void)loadControllers
{
    if (self.controllers.count > 0) {
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.scrollView.contentSize = CGSizeZero;
        self.titleIndicatorView.hidden = NO;

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
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _titleView.autoresizesSubviews = YES;
    }
    return _titleView;
}

- (CGRect)frameForContentView
{
    return CGRectMake(0, self.titleViewHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.titleViewHeight);
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    CGFloat statusHeight = statusBarFrame.size.height;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        statusHeight = statusBarFrame.size.width;
    }
    CGRect frame = self.view.bounds;
    frame.origin.y = self.titleViewHeight;
    frame.size.height -= self.titleViewHeight;
    if (self.navigationController.navigationBar.isTranslucent) {
        frame.origin.y += self.navigationController.navigationBar.bounds.size.height;
        frame.size.height -= self.navigationController.navigationBar.bounds.size.height;
        if (!self.wantsFullScreenLayout) {
            frame.origin.y += statusHeight;
            frame.size.height -= statusHeight;
        }
    }
    return frame;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:[self frameForContentView]];
        _contentView.backgroundColor = [UIColor clearColor];
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

- (void)setControllers:(NSArray *)controllers
{
    if ([_controllers isEqualToArray:controllers])
        return;

    _currentControllerIndex = 0;

    NSMutableSet *set = [NSMutableSet setWithArray:_controllers];
    [set minusSet:[NSSet setWithArray:controllers]];
    NSArray *controllersToRemove = [set allObjects];

    set = [NSMutableSet setWithArray:controllers];
    [set minusSet:[NSSet setWithArray:_controllers]];
    NSArray *controllersToAdd = [set allObjects];

    _controllers = controllers;

    [controllersToRemove makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    if (self.isViewLoaded) {
        [self loadTitles];
        [self loadControllers];
        [self updateTitleSelection];
    }
}

- (void)setTitleIndicatorView:(UIView *)titleIndicatorView
{
    if (_titleIndicatorView != titleIndicatorView) {
        _titleIndicatorView = titleIndicatorView;
        _titleIndicatorView.hidden = YES;
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

        CGFloat width = self.scrollView.bounds.size.width;
        UIViewController *newCurrent = [self loadControllerAtIndex:_currentControllerIndex];
        [newCurrent beginAppearanceTransition:YES
                                     animated:NO];

        [self.scrollView setContentOffset:CGPointMake(width * _currentControllerIndex, 0)
                                 animated:NO];
        [_controllerToRemove.view removeFromSuperview];
        [_controllerToRemove endAppearanceTransition];
        _controllerToRemove = nil;

        [newCurrent endAppearanceTransition];

        [self updateTitleSelection];

        [UIView animateWithDuration:0.25
                         animations:^{
                             [self updateTitleIndicator];
                         }];
    }
}

#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.isDragging) {

        if (!self.scrollingStarted) {
            [self.currentViewController beginAppearanceTransition:NO
                                                         animated:YES];
        }
        self.scrollingStarted = YES;

        CGFloat width = self.scrollView.bounds.size.width;
        CGFloat halfWidth = width / 2.0;

        CGFloat currentIndex = self.currentControllerIndex;// floorf((scrollView.contentOffset.x + halfWidth) / width);

        CGFloat offsetIndex = scrollView.contentOffset.x / width;

        // scroll to right
        if (offsetIndex > currentIndex) {
            if ((NSInteger)currentIndex + 1 < self.controllers.count) {
                if (![self isControllerVisible:_previousController]) {
                    [_previousController endAppearanceTransition];
                    [_previousController.view removeFromSuperview];
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
                    [_nextController.view removeFromSuperview];
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

    if (scrollView.isDecelerating || scrollView.isDragging) {
        [self updateTitleSelection];
        [self updateTitleIndicator];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSInteger index = (NSInteger)floorf((*targetContentOffset).x / self.scrollView.bounds.size.width);
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
    
    if (!decelerate) {
        [self scrollDidEnd];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollDidEnd];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self scrollDidEnd];
}

@end
