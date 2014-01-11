//
//  YSViewerWindow.m
//  DemoApp
//
//  Created by taiki on 12/5/13.
//  Copyright (c) 2013 yashigani. All rights reserved.
//

#import "YSViewerWindow.h"

#import "YSViewController.h"
#import "YSViewer.h"

@interface YSViewerWindow ()
@property (strong, nonatomic) YSViewController *viewController;
@end

@implementation YSViewerWindow

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = UIScreen.mainScreen.bounds;
        self.windowLevel = UIWindowLevelAlert;
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
        self.rootViewController = self.viewController;
    }
    return self;
}

- (void)setViewer:(YSViewer *)viewer
{
    _viewer = viewer;
    _viewer.view.center = self.center;
    self.viewController.viewer = _viewer;
    _viewer.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                    UIViewAutoresizingFlexibleRightMargin |
                                    UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleBottomMargin;
    [self.viewController.view addSubview:_viewer.view];
}

- (YSViewController *)viewController
{
    if (!_viewController) {
        _viewController = YSViewController.new;
        _viewController.viewer = _viewer;
    }
    return _viewController;
}

@end
