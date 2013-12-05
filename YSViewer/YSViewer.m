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

- (void)show
{
    if (!_window) {
        _parentWindow = UIApplication.sharedApplication.keyWindow;
        _window = [YSViewerWindow new];
        _window.viewer = self;
        if (!_view) {
            UIImageView *iv = [[UIImageView alloc] initWithImage:_image];
            [iv sizeToFit];
            if (!CGRectContainsRect(_window.bounds, iv.bounds)) {
                iv.frame = _window.bounds;
                iv.contentMode = UIViewContentModeScaleAspectFit;
            }
            _view = iv;
        }
        _view.center = _window.center;
        [_window addSubview:_view];
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

#pragma mark - UIWindow Notifications

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    _view.alpha = 0;
    __weak __typeof(self) wself = self;
    [UIView transitionWithView:_window
                      duration:.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        wself.view.alpha = 1;
                        wself.parentWindow.transform = CGAffineTransformMakeScale(0.8, 0.8);
                    }
                    completion:nil];
}

@end
