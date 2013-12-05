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
@property UIView *view;

- (void)show;
- (void)hide;

@end
