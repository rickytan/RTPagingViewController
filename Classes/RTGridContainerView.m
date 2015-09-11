//
//  RTGridContainerView.m
//  RTPagingViewController
//
//  Created by ricky on 15/9/10.
//  Copyright (c) 2015年 ricky. All rights reserved.
//

#import "RTGridContainerView.h"

const CGFloat RTGridSizeDynamicSize = -1.f;

@implementation RTGridContainerView


- (void)commonInit
{
    self.gridSize = CGSizeMake(25.f, 25.f);
    self.itemMargin = 8.f;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    if (!self.gridItems.count)
        return CGSizeMake(self.contentInset.left + self.contentInset.right,
                          self.contentInset.top + self.contentInset.bottom + self.gridSize.height);

    return CGSizeMake(self.gridItems.count * (self.gridSize.width + self.itemMargin) - self.itemMargin +
                      self.contentInset.left + self.contentInset.right,
                      self.contentInset.top + self.contentInset.bottom + self.gridSize.height);
}

- (CGSize)intrinsicContentSize
{
    return [self sizeThatFits:CGSizeZero];
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize
{
    return [self sizeThatFits:targetSize];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect contentRect = UIEdgeInsetsInsetRect((CGRect){{0, 0}, self.bounds.size}, self.contentInset);
    CGFloat step = MAX(self.gridSize.width + self.itemMargin, 2.f);
    CGPoint offset = contentRect.origin;

    for (UIView *view in self.gridItems) {
        view.frame = (CGRect){offset, self.gridSize};
        offset.x += step;
    }

    self.contentSize = CGSizeMake(offset.x - self.itemMargin + self.contentInset.right, self.gridSize.height + self.contentInset.top + self.contentInset.bottom);
}

- (void)setGridItems:(NSArray *)gridItems
{
    [self.gridItems makeObjectsPerformSelector:@selector(removeFromSuperview)];

    BOOL animation = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];

    NSInteger index = 0;
    for (UIView *view in gridItems) {
        if (index < _gridItems.count) {
            view.frame = [(UIView *)_gridItems[index++] frame];
        }
        [self addSubview:view];
    }
    
    [UIView setAnimationsEnabled:animation];

    _gridItems = gridItems;

    [self setNeedsLayout];
    [self invalidateIntrinsicContentSize];
}

- (CGPoint)positionForItemAtIndex:(CGFloat)index
{
    CGRect contentRect = UIEdgeInsetsInsetRect((CGRect){{0, 0}, self.bounds.size}, self.contentInset);
    CGFloat step = MAX(self.gridSize.width + self.itemMargin, 2.f);
    CGPoint offset = contentRect.origin;
    return CGPointMake(offset.x + step * index + self.gridSize.width / 2,
                       offset.y + self.gridSize.height / 2);
}

- (void)setItemMargin:(CGFloat)itemMargin
{
    _itemMargin = itemMargin;
    [self setNeedsLayout];
    [self invalidateIntrinsicContentSize];
}

- (void)setGridSize:(CGSize)gridSize
{
    if (!CGSizeEqualToSize(_gridSize, gridSize)) {
        _gridSize = gridSize;
        [self setNeedsLayout];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(self.contentInset, contentInset)) {
        [super setContentInset:contentInset];
        [self setNeedsLayout];
        [self invalidateIntrinsicContentSize];
    }
}

#if TARGET_INTERFACE_BUILDER
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGRect contentRect = UIEdgeInsetsInsetRect(rect, self.contentInset);
    CGFloat step = MAX(self.gridSize.width + self.itemMargin, 2.f);
    NSInteger numberOfItems = MIN(6, (NSInteger)ceilf((CGRectGetWidth(contentRect) + self.itemMargin) / step));
    CGPoint offset = contentRect.origin;

    [[UIColor colorWithWhite:0.9 alpha:1.0] setFill];
    [[UIColor colorWithWhite:0.6 alpha:1.0] setStroke];

    for (NSInteger i = 0; i < numberOfItems; ++i) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:(CGRect){offset, self.gridSize}];
        [path fill];
        [path stroke];
        offset.x += step;
    }
}
#endif

@end
