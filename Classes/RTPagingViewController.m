//
//  ZJUInfoViewController.m
//  iZJU
//
//  Created by ricky on 13-6-7.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "RTPagingViewController.h"

#define TITLE_VIEW_HEIGHT 36.0

@interface RTPagingViewController ()
{
    //BOOL                      _shouldLoadController;
}
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UIView *titleView;
@property (nonatomic, retain) NSArray *titleArray;
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
@synthesize scrollView = _scrollView;
@synthesize contentView = _contentView;
@synthesize titleView = _titleView;
@synthesize titleIndicatorView = _titleIndicatorView;

- (void)dealloc
{
    self.titleView = nil;
    self.contentView = nil;
    self.scrollView = nil;
    self.controllers = nil;
    self.titleIndicatorView = nil;
    self.titleColor = nil;
    self.selectedTitleColor = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _currentControllerIndex = -1;
        self.titleColor = [UIColor colorWithWhite:184.0/255
                                            alpha:1.0];
        self.selectedTitleColor = [UIColor colorWithWhite:124.0/255
                                                    alpha:1.0];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view.autoresizesSubviews = YES;    

    [self.view addSubview:self.titleView];
    
    [self.titleView addSubview:self.titleIndicatorView];
    
    CGRect frame = self.view.bounds;
    frame.origin.y = TITLE_VIEW_HEIGHT;
    frame.size.height -= TITLE_VIEW_HEIGHT;
    _contentView = [[UIView alloc] initWithFrame:frame];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_contentView];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    _scrollView.delegate = self;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.bounces = YES;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:_scrollView];
    
    [self.view bringSubviewToFront:self.titleView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self loadTitles];
    [self loadControllers];
    [self updateTitleSelection];
    [self updateTitleIndicator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)scrollDidEnd
{
    int index = (int)floorf(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width);
    if (index != self.currentControllerIndex) {
        //        _controllerToRemove = self.currentViewController;
        _currentControllerIndex = index;
        [self updateTitleSelection];
    }
    
    //    [_controllerToRemove.view removeFromSuperview];
    //    _controllerToRemove = nil;
    [_previousController.view removeFromSuperview];
    _previousController = nil;
    [_nextController.view removeFromSuperview];
    _nextController = nil;
}

- (void)updateTitleSelection
{
    [self.titleArray makeObjectsPerformSelector:@selector(setSelected:)
                                     withObject:@NO];
    
    if (0 <= self.currentControllerIndex && self.currentControllerIndex < self.controllers.count) {
        ((UIButton*)[self.titleArray objectAtIndex:self.currentControllerIndex]).selected = YES;
    }
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

- (void)loadTitles
{
    if (self.controllers.count > 0) {
        [self.titleArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        CGFloat halfHeight = self.titleView.bounds.size.height / 2.0;
        CGFloat width = self.titleView.bounds.size.width / self.controllers.count;
        CGFloat halfWidth = width / 2.0;
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.controllers.count];
        int i = 0;
        for (UIViewController *c in self.controllers) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
            btn.titleLabel.textAlignment = UITextAlignmentCenter;
            btn.titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
            //btn.titleLabel.shadowOffset = CGSizeMake(1, 1);
            //btn.titleLabel.shadowColor = [UIColor lightTextColor];
            [btn setTitle:c.title
                 forState:UIControlStateNormal];
            [btn setTitleColor:self.titleColor
                      forState:UIControlStateNormal];
            [btn setTitleColor:self.selectedTitleColor
                      forState:UIControlStateSelected];
            [btn addTarget:self
                    action:@selector(onTitleSelected:)
          forControlEvents:UIControlEventTouchUpInside];
            [btn sizeToFit];
            btn.bounds = CGRectMake(0, 0, 0.8 * width, 2 * halfHeight);
            btn.center = CGPointMake(width * i + halfWidth, halfHeight);
            btn.tag = i;
            [self.titleView addSubview:btn];
            [arr addObject:btn];
            
            ++i;
        }
        //        [self.titleView sendSubviewToBack:self.titleIndicatorView];
        self.titleArray = [NSArray arrayWithArray:arr];
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
            
            if (i++ == self.currentControllerIndex) {
                CGSize size = self.scrollView.bounds.size;
                size.width = self.controllers.count * size.width;
                size.height = 0;
                self.scrollView.contentSize = size;
                
                UIViewController *controller = [self.controllers objectAtIndex:self.currentControllerIndex];
                CGRect frame = self.scrollView.bounds;
                frame.origin.x = self.scrollView.bounds.size.width * self.currentControllerIndex;
                controller.view.frame = frame;
                [self.scrollView addSubview:controller.view];
            }
        }
    }
}

- (UIViewController*)loadControllerAtIndex:(NSInteger)index
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

- (UIView*)titleView
{
    if (!_titleView) {
        CGRect frame = [UIScreen mainScreen].bounds;
        frame.size.height = TITLE_VIEW_HEIGHT;
        
        _titleView = [[UIView alloc] initWithFrame:frame];
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _titleView.autoresizesSubviews = YES;
    }
    return _titleView;
}

- (void)onTitleSelected:(UIButton *)button
{
    self.currentControllerIndex = button.tag;
}

- (void)setControllers:(NSArray *)controllers
{
    if (_controllers == controllers)
        return;
    
    _currentControllerIndex = 0;
    
    [_controllers release];
    _controllers = [controllers retain];
    
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    if (self.isViewLoaded) {
        [self loadTitles];
        [self loadControllers];
        [self updateTitleSelection];
    }
}

- (void)setTitleIndicatorView:(UIView *)titleIndicatorView
{
    if (_titleIndicatorView != titleIndicatorView) {
        [_titleIndicatorView release];
        _titleIndicatorView = [titleIndicatorView retain];
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
    if (_currentControllerIndex != currentControllerIndex) {
        _controllerToRemove = self.currentViewController;
        
        _currentControllerIndex = currentControllerIndex;
        
        CGFloat width = self.scrollView.bounds.size.width;
        [self loadControllerAtIndex:_currentControllerIndex];
        [self.scrollView setContentOffset:CGPointMake(width * _currentControllerIndex, 0)
                                 animated:NO];
        [_controllerToRemove.view removeFromSuperview];
        _controllerToRemove = nil;
        
        [self updateTitleSelection];
    }
}

#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = self.scrollView.bounds.size.width;
    CGFloat halfWidth = width / 2.0;
    
    CGFloat currentIndex = floorf((scrollView.contentOffset.x + halfWidth) / width);
    
    CGFloat offsetIndex = scrollView.contentOffset.x / width;
    
    if (offsetIndex > currentIndex) {
        if ((int)currentIndex + 1 < self.controllers.count) {
            if (![self isControllerVisible:_previousController])
                [_previousController.view removeFromSuperview];
            _previousController = _nextController;
            _nextController = [self loadControllerAtIndex:(int)currentIndex + 1];
        }
    }
    else if (offsetIndex < currentIndex) {
        if ((int)currentIndex - 1 >= 0) {
            if (![self isControllerVisible:_nextController])
                [_nextController.view removeFromSuperview];
            _nextController = _previousController;
            _previousController = [self loadControllerAtIndex:(int)currentIndex - 1];
        }
    }
    [self updateTitleSelection];
    [self updateTitleIndicator];
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
