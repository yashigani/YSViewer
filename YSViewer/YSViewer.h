//
//  YSViewer.h
//  DemoApp
//
//  Created by taiki on 12/5/13.
//  Copyright (c) 2013 yashigani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSViewer : NSObject
@property UIImage *image;
@property (nonatomic) UIView *view;
@property UIView *backgroundView;
@property (readonly) UIWindow *parentWindow;

- (void)show;
- (void)hide;

@end
