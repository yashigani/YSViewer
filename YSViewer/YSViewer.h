//
//  YSViewer.h
//  DemoApp
//
//  Created by taiki on 12/5/13.
//  Copyright (c) 2013 yashigani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSViewController.h"

@interface YSViewer : NSObject
@property UIImage *image;
@property (nonatomic) UIView *view;
@property (nonatomic) YSViewController *viewController;
@property UIView *backgroundView;

- (void)show;
- (void)hide;

@end
