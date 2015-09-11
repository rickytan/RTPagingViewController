RTPagingViewController
=====================

## Description

**This is a iOS implementation for Android ViewPager.** Most existing third party container view controllers didn't manage children view controllers' view appearence life cycle properly.

In a normal case, a controller's view appearence method should be called in following order:

- `viewDidLoad:`
- `viewWillAppear:`
- `viewDidAppear:`
- `viewWillDisappear:`
- `viewDidDisappear:`
- ~~`viewDidUnload:`~~

So I decided to build my own Container Controller, which handles view appearence correcttly, and it takes time...

Finally, I have got the right result:

![](./ScreenShot/ss0.png)

## Features

- Handle view appearence properly
- screen rotation support

## Usage

    FirstViewController *vc1 = ...;
    vc1.title = "View1";
    SecondViewController *vc2 = ...;
    vc2.title = "View2";
    ...
    
    RTPagingViewController *paging = [[RTPagingViewController alloc] init];
    paging.controllers = @[vc1, vc2, ...];
    paging.titleFont = ...;
    paging.titleColor = ...;
    paging.selectedTitleColor = ...;
    paging.titleIndicatorView = ...;

## Screenshot

![screenshot](https://dl.dropboxusercontent.com/u/46239535/RPagingViewController/iOS%20%E6%A8%A1%E6%8B%9F%E5%99%A8%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%E2%80%9C2013-8-20%20%E4%B8%8A%E5%8D%8812.58.17%E2%80%9D.png "RPagingViewController")

## License

MIT
