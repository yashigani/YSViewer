//
//  YSViewController.m
//  DemoApp
//
//  Created by taiki on 1/11/14.
//  Copyright (c) 2014 yashigani. All rights reserved.
//

#import "YSViewController.h"

#import "YSViewer.h"

@interface YSViewController () <UICollisionBehaviorDelegate>
@property UIDynamicAnimator *animator;
@property UICollisionBehavior *collisionBehavior;
@property UIAttachmentBehavior *attachBehavior;
@property UIPushBehavior *pushBehavior;
@property UIPanGestureRecognizer *panGesture;
@property UITapGestureRecognizer *tapGesture;
@end

@implementation YSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(handleAttachmentGesture:)];
    [self.view addGestureRecognizer:_panGesture];
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:_tapGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return _viewer.parentWindow.rootViewController.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return _viewer.parentWindow.rootViewController.prefersStatusBarHidden;
}

- (void)setViewer:(YSViewer *)viewer
{
    if (_viewer) {
        [_viewer.view removeFromSuperview];
    }
    _viewer = viewer;
}

#pragma mark - handle gesture

- (void)handleAttachmentGesture:(id)sender
{
    CGPoint p = [_panGesture locationInView:self.view];
    if (_panGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint center = _viewer.view.center;
        UIOffset offset = UIOffsetMake(p.x - center.x, p.y - center.y);
        _attachBehavior = [[UIAttachmentBehavior alloc] initWithItem:_viewer.view
                                                    offsetFromCenter:offset
                                                    attachedToAnchor:p];
        [_animator addBehavior:_attachBehavior];
    }
    else if (_panGesture.state == UIGestureRecognizerStateChanged) {
        _attachBehavior.anchorPoint = p;
    }
    else if ((_panGesture.state == UIGestureRecognizerStateEnded ||
             _panGesture.state == UIGestureRecognizerStateCancelled) &&
            _attachBehavior) {
        [_animator removeBehavior:_attachBehavior];
        _attachBehavior = nil;

        CGPoint velocity = [_panGesture velocityInView:self.view];
        velocity = CGPointMake(velocity.x / 30, velocity.y / 30);
        CGFloat magnitude = (CGFloat)sqrt(pow((double)velocity.x, 2.0) + pow((double)velocity.y, 2.0));
        if (magnitude > 30) {
            _collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[_viewer.view]];
            _collisionBehavior.collisionDelegate = self;
            CGFloat diagonal = -sqrt(pow(CGRectGetWidth(_viewer.view.frame), 2.0) +
                                     pow(CGRectGetHeight(_viewer.view.frame), 2.0));
            UIEdgeInsets insets = UIEdgeInsetsMake(diagonal, diagonal, diagonal, diagonal);
            [_collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:insets];
            [_animator addBehavior:_collisionBehavior];

            _pushBehavior =
                [[UIPushBehavior alloc] initWithItems:@[_viewer.view]
                                                 mode:UIPushBehaviorModeInstantaneous];
            CGPoint center = _viewer.view.center;
            UIOffset offset = UIOffsetMake((p.x - center.x) / 2.0, (p.y - center.y) / 2.0);
            [_pushBehavior setTargetOffsetFromCenter:offset forItem:_viewer.view];
            _pushBehavior.pushDirection = CGVectorMake(velocity.x, velocity.y);
            [_animator addBehavior:_pushBehavior];

            _panGesture.enabled = NO;
        }
        else {
            __weak __typeof(self) wself = self;
            [UIView animateWithDuration:.25
                             animations:^{
                                 _viewer.view.center = wself.view.center;
                                 _viewer.view.transform = CGAffineTransformIdentity;
                             }
                             completion:nil];
        }
    }
}

- (void)handleTapGesture:(id)sendr
{
    CGPoint p = [_viewer.view convertPoint:[_tapGesture locationInView:_viewer.view]
                                    toView:self.view];
    if (!CGRectContainsPoint(_viewer.view.frame, p)) {
        [_viewer hide];
    }
}

#pragma mark - UICollisionBehaviorDelegate

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    [_animator removeAllBehaviors];
    _pushBehavior = nil;
    _collisionBehavior = nil;
    [_viewer hide];
}

@end
