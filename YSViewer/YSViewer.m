//
//  YSViewer.m
//  DemoApp
//
//  Created by taiki on 12/5/13.
//  Copyright (c) 2013 yashigani. All rights reserved.
//

#import "YSViewer.h"
#import "YSViewerWindow.h"

@interface YSViewer ()
@property YSViewerWindow *window;
@property UIWindow *parentWindow;
@end

@implementation YSViewer
@synthesize view = _view;

- (void)show
{
    if (!_window) {
        _parentWindow = UIApplication.sharedApplication.keyWindow;
        _window = [YSViewerWindow new];
        _window.viewer = self;

        [_window setRootViewController:self.viewController];

        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(windowDidBecomeKey:)
                                                   name:UIWindowDidBecomeKeyNotification
                                                 object:_window];
        [_window makeKeyAndVisible];
    }
}

- (void)hide
{
    __weak __typeof(self) wself = self;
    [UIView transitionWithView:_window
                      duration:.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ [wself.view removeFromSuperview]; }
                    completion: ^(BOOL finished) {
                        [NSNotificationCenter.defaultCenter removeObserver:self
                                                                      name:UIWindowDidBecomeKeyNotification
                                                                    object:wself.window];
                        wself.window = nil;
                        [UIView animateWithDuration:.25
                                         animations:^{
                                             wself.parentWindow.transform = CGAffineTransformIdentity;
                                         }];
                        [wself.parentWindow makeKeyAndVisible];
                        wself.view.transform = CGAffineTransformIdentity;
                    }];
}

- (UIView *)view
{
    if (!_view) {
        UIImageView *iv = [[UIImageView alloc] initWithImage:_image];
        iv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        iv.contentMode = UIViewContentModeScaleAspectFit;
        [iv sizeToFit];
        _view = iv;
    }
    return _view;
}

- (UIViewController *)viewController
{
    if (!_viewController) {
        _viewController = ({
            YSViewController *vc = [[YSViewController alloc] init];
            [vc.view addSubview:self.view];
            self.view.frame = vc.view.bounds;
            vc;
        });
    }
    return _viewController;
}

#pragma mark - UIWindow Notifications

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    _view.alpha = 0;
    _view.transform = CGAffineTransformMakeScale(.9, .9);
    __weak __typeof(self) wself = self;
    [UIView transitionWithView:_window
                      duration:.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        wself.view.alpha = 1;
                        wself.view.transform = CGAffineTransformIdentity;
                        wself.parentWindow.transform = CGAffineTransformMakeScale(.9, .9);
                    }
                    completion:nil];
}

@end
