//
//  RTPagingContainerSegue.m
//  RTPagingViewController
//
//  Created by ricky on 15/9/10.
//  Copyright (c) 2015年 ricky. All rights reserved.
//

#import "RTPagingContainerSegue.h"
#import "RTPagingViewController.h"

@implementation RTPagingContainerSegue

- (instancetype)initWithIdentifier:(NSString *)identifier
                            source:(UIViewController *)source
                       destination:(UIViewController *)destination
{
    self = [super initWithIdentifier:identifier source:source destination:destination];
    if (self) {
        [self perform];
    }
    return self;
}

- (void)perform
{
    RTPagingViewController *pagingController = self.sourceViewController;
    UIViewController *controller = self.destinationViewController;
    [pagingController appendPage:controller];
}

@end
