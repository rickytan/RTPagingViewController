//
//  AppDelegate.m
//  RTPagingViewController
//
//  Created by ricky on 13-8-6.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "AppDelegate.h"
#import "RTPagingViewController.h"
#import "BaseTableViewController.h"
#import "BaseViewController.h"
#import "NavigationController.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // return YES;

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    RTPagingViewController *pagingViewController = [[RTPagingViewController alloc] init];
    pagingViewController.title = @"RTPagingViewController";
    
    UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(0, 34, 320, 2)];
    shadow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    shadow.backgroundColor = [UIColor blueColor];
    //[pagingViewController.titleView addSubview:shadow];
    
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 64, 4)];
    indicator.backgroundColor = [UIColor blueColor];
    indicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    pagingViewController.titleIndicatorView = indicator;
    
    UIViewController *c0 = [[BaseViewController alloc] init];
    c0.title = @"View0";
    c0.view.backgroundColor = [UIColor orangeColor];
    UIViewController *c1 = [[BaseViewController alloc] init];
    c1.title = @"View1";
    c1.view.backgroundColor = [UIColor grayColor];
    UIViewController *c2 = [[BaseTableViewController alloc] init];
    c2.title = @"View2";
    c2.view.backgroundColor = [UIColor greenColor];
    UIViewController *c3 = [[BaseViewController alloc] init];
    c3.title = @"View3";
    c3.view.backgroundColor = [UIColor redColor];
    
    pagingViewController.titleColor = [UIColor blackColor];
    pagingViewController.selectedTitleColor = [UIColor blueColor];
    
    pagingViewController.controllers = [NSArray arrayWithObjects:c0, c1, c2, c3, nil];
    pagingViewController.currentControllerIndex = 2;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pagingViewController setControllers:@[c0, c2, c3] animated:NO];
        pagingViewController.currentControllerIndex = 0;
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pagingViewController appendPage:c1];
    });

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pagingViewController];
    nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    nav.navigationBar.translucent = YES;
    
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
