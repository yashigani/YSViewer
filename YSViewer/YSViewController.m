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
@property UITapGestureRecognizer *doubleTap;
@property UIPinchGestureRecognizer *twoFingerPinch;
@property float lastScale;
@end

@implementation YSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(handleAttachmentGesture:)];
    [self.view addGestureRecognizer:_panGesture];
    
    _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [_doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:_doubleTap];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(handleTapGesture:)];
    [_tapGesture requireGestureRecognizerToFail:_doubleTap];
    [_tapGesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:_tapGesture];
    
    _twoFingerPinch = [[UIPinchGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(handleTwoFingerPinch:)];
    [self.view addGestureRecognizer:_twoFingerPinch];

    self.lastScale = 1.0; // Initialize scale
    
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

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer {
    
    CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
    
    if ( currentScale != 1.0 ){
        
        // Double tap, return to original position
        [UIView animateWithDuration:.25
                         animations:^{
                             CGAffineTransform transform = CGAffineTransformIdentity;
                             [gestureRecognizer view].transform = transform;
                         }
                         completion:nil];
        
    }else{
        
        [UIView animateWithDuration:.25
                         animations:^{
                             CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], 4.0, 4.0);
                             [gestureRecognizer view].transform = transform;
                         }
                         completion:nil];
        
    }
    
}

- (void)handleTwoFingerPinch:(UIPinchGestureRecognizer *)gestureRecognizer
{

    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        _lastScale = [gestureRecognizer scale];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 4.0;
        const CGFloat kMinScale = 0.75;
        
        CGFloat newScale = 1 -  (_lastScale - [gestureRecognizer scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        [gestureRecognizer view].transform = transform;
        
        _lastScale = [gestureRecognizer scale];
    }
    
}

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
        velocity = CGPointMake(velocity.x / 15, velocity.y / 15);
        CGFloat magnitude = (CGFloat)sqrt(pow((double)velocity.x, 2.0) + pow((double)velocity.y, 2.0));
        if (magnitude > 50) {
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

- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    [UIView animateWithDuration:.35
                     animations:^{
                         CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], 0.0, 0.0);
                         [gestureRecognizer view].transform = transform;
                     }
                     completion:nil];
    
    
    [self performSelector:@selector(closeViewAfterAnimation) withObject:nil afterDelay:0.35];
    
}

-(void)closeViewAfterAnimation{
    [_viewer hide];
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
