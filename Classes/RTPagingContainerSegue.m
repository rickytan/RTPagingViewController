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

- (void)perform
{
    RTPagingViewController *pagingController = self.sourceViewController;
    UIViewController *controller = self.destinationViewController;
    [pagingController addChildViewController:controller];
}

@end
