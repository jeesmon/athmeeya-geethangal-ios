//
//  DetailViewController.h
//  Malayalam Christian Songs
//
//  Created by Jacob, Jeesmon on 4/16/13.
//  Copyright (c) 2013 Jacob, Jeesmon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Song.h"


@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    UIWebView *webView;
   
}

-(void) showSong;

@property (strong, nonatomic) Song *selectedSong;

@end
