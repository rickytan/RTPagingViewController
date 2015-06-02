RTPagingViewController
=====================

##Usage

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

##Screenshot

![screenshot](https://dl.dropboxusercontent.com/u/46239535/RPagingViewController/iOS%20%E6%A8%A1%E6%8B%9F%E5%99%A8%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%E2%80%9C2013-8-20%20%E4%B8%8A%E5%8D%8812.58.17%E2%80%9D.png "RPagingViewController")

##License

MIT
