//
//  WebViewController.m
//  Malayalam Christian Songs
//
//  Created by Jacob, Jeesmon on 8/9/13.
//  Copyright (c) 2013 Jacob, Jeesmon. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

- (void)configureView
{
    NSLog(@"configureView");
    self.navigationController.toolbarHidden = YES;
    if(self.url) {
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
        [self.webView loadRequest:requestObj];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}
@end
