//
//  YSViewerWindow.m
//  DemoApp
//
//  Created by taiki on 12/5/13.
//  Copyright (c) 2013 yashigani. All rights reserved.
//

#import "YSViewerWindow.h"

#import "YSViewer.h"

@interface YSViewerWindow () <UICollisionBehaviorDelegate>
@property UIDynamicAnimator *animator;
@property UICollisionBehavior *collisionBehavior;
@property UIAttachmentBehavior *attachBehavior;
@property UIPushBehavior *pushBehavior;
@property UIPanGestureRecognizer *panGesture;
@property UITapGestureRecognizer *tapGesture;
@end

@implementation YSViewerWindow

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = UIScreen.mainScreen.bounds;
        self.windowLevel = UIWindowLevelAlert;
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];

        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(handleAttachmentGesture:)];
        [self addGestureRecognizer:_panGesture];
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(handleTapGesture:)];
        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}

#pragma mark - handle gesture

- (void)handleAttachmentGesture:(id)sender
{
    CGPoint p = [_panGesture locationInView:self];
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

        CGPoint velocity = [_panGesture velocityInView:self];
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
                                 _viewer.view.center = wself.center;
                                 _viewer.view.transform = CGAffineTransformIdentity;
                             }
                             completion:nil];
        }
    }
}

- (void)handleTapGesture:(id)sendr
{
    CGPoint p = [_viewer.view convertPoint:[_tapGesture locationInView:_viewer.view]
                                    toView:self];
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
