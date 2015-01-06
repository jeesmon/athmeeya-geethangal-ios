//
//  WebViewController.h
//  Malayalam Christian Songs
//
//  Created by Jacob, Jeesmon on 8/9/13.
//  Copyright (c) 2013 Jacob, Jeesmon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate> {
    
}

@property (strong, nonatomic) NSURL *url;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
