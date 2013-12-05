//
//  ViewController.m
//  DemoApp
//
//  Created by taiki on 12/5/13.
//  Copyright (c) 2013 yashigani. All rights reserved.
//

#import "ViewController.h"

#import "YSViewer.h"

@interface ViewController ()
@property (strong, nonatomic) YSViewer *viewer;
@end

@implementation ViewController

- (IBAction)tapped:(id)sender
{
    [self.viewer show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewer = YSViewer.new;
    self.viewer.image = [UIImage imageNamed:@"Image"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
