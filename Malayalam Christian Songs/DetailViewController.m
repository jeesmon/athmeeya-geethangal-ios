//
//  DetailViewController.m
//  Malayalam Christian Songs
//
//  Created by Jacob, Jeesmon on 4/16/13.
//  Copyright (c) 2013 Jacob, Jeesmon. All rights reserved.
//

#import "DetailViewController.h"
#import "WebViewController.h"
#import "Toast+UIView.h"
#import "SongLangType.h"
#import "SongDao.h"
#import "AudioStreamer.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

UIBarButtonItem *langDetailButton;
UIBarButtonItem *audioButton;
SongLangType currentDetailLangType;
int scrollOffset = 0;
bool playing = NO;

#pragma mark - Managing the detail item

- (void)setSelectedSong:(Song *)selectedSong
{
    currentDetailLangType = selectedSong.langType;
    
    if (_selectedSong != selectedSong) {
        _selectedSong = selectedSong;
        
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    if (self) {
        NSString *langButtonTitle = currentDetailLangType == SongLangTypeMalayalam ? @"ENG" : @"MAL";
        
        langDetailButton = [[UIBarButtonItem alloc] initWithTitle:langButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(toggleLang)];
        self.navigationItem.rightBarButtonItem = langDetailButton;
        
        [self showSong];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self setupWebView];
    if(self.selectedSong) {
        [self configureView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Songs", @"Songs");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *minusButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"minus.png"] style:UIBarButtonItemStylePlain target:self action:@selector(decreaseTextSize)];
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus.png"] style:UIBarButtonItemStylePlain target:self action:@selector(increaseTextSize)];
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions)];
    
    audioButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"play.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleSong)];
    
    //UIBarButtonItem *youtubeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"youtube.png"] style:UIBarButtonItemStylePlain target:self action:@selector(youtubeSearch)];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.navigationController.toolbar.tintColor = [UIColor blackColor];
        self.navigationController.toolbarHidden = NO;
    }
    
    self.navigationController.toolbar.barTintColor = [UIColor whiteColor];
    self.navigationController.toolbar.tintColor = [UIColor blackColor];
    self.navigationController.toolbar.barStyle = UIBarStyleDefault;
    [self.navigationController.toolbar setItems:@[actionButton, flexSpace, minusButton, flexSpace, plusButton] animated:YES];
}

-(void) showActions {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    for (NSString *fruit in @[@"Email"]) {
        [actionSheet addButtonWithTitle:fruit];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:self.view];
}

-(void) toggleSong {
   
    if(playing) {
        if(streamer) {
            [streamer pause];
            audioButton.image = [UIImage imageNamed: @"play.png"];
            playing = NO;
        }
    }
    else {
        if(!streamer) {
            [self createStreamer];            
        }
        [streamer start];
        playing = YES;
        audioButton.image = [UIImage imageNamed: @"pause.png"];
    }
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"Bookmark"]) {
       
        SongDao *songDao = [[SongDao alloc] init];
        BOOL status = [songDao addBookmark:self.selectedSong];
        if(status) {
            [self.view makeToast:@"Song bookmarked" duration:2.0 position:@"center"];
        }
        else {
            [self.view makeToast:@"Song already bookmarked" duration:2.0 position:@"center"];
        }
    }
    else if([buttonTitle isEqualToString:@"Email"]) {
       
        [self composeEmail:self.selectedSong];
    }
}

- (void) setupWebView
{
  
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [webView sizeToFit];
    webView.autoresizesSubviews = YES;
    webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    webView.delegate = self;
    webView.scrollView.delegate = self;
    
    [[self view] addSubview:webView];
    
    scrollOffset = webView.scrollView.contentOffset.y;
}

-(void) increaseTextSize {
  
    
    [webView stringByEvaluatingJavaScriptFromString:@"resizeText(1);"];
}

-(void) youtubeSearch {
    
    WebViewController *webViewController = [[WebViewController alloc] init];
    webViewController.title = @"YouTube";
    NSString *urlString = [NSString stringWithFormat:@"http://youtube.com/results?search_query=%@", [self.selectedSong.titleEn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    webViewController.url = [NSURL URLWithString:urlString];
    [self.navigationController pushViewController:webViewController animated:YES];
}

-(void) decreaseTextSize {
   
    [webView stringByEvaluatingJavaScriptFromString:@"resizeText(-1);"];
}

-(void) toggleLang {
   
    
    if(currentDetailLangType == SongLangTypeMalayalam) {
        langDetailButton.title = @"MAL";
        currentDetailLangType = SongLangTypeEnglish;
        [self showSong];
    }
    else {
        langDetailButton.title = @"ENG";
        currentDetailLangType = SongLangTypeMalayalam;
        [self showSong];
    }
}

-(void) showSong {
    if (self.selectedSong) {
        
        NSString *columnTitle;
        NSString *columnFilename;
        
        if(currentDetailLangType == SongLangTypeMalayalam) {
            columnTitle = @"titleMl";
            columnFilename = @"filenameMl";
        }
        else {
            columnTitle = @"titleEn";
            columnFilename = @"filenameEn";
        }
        
        self.title = [self.selectedSong valueForKey:columnTitle];
        
        if(webView) {
            NSString *filename = [self.selectedSong valueForKey:columnFilename];
            NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@""];
         
            if(path) {
                NSURL *url = [NSURL fileURLWithPath:path];
            
                NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
                [webView loadRequest:requestObj];
            }
        }
    }
}

-(void) composeEmail: (Song *) song {
    NSString *title;
    NSString *filename;
    
    if(currentDetailLangType == SongLangTypeMalayalam) {
        title = song.titleMl;
        filename = song.filenameMl;
    }
    else {
        title = song.titleEn;
        filename = song.filenameEn;
    }
    
    NSError* error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:title];
    [mc setMessageBody:content isHTML:YES];
    [self presentViewController:mc animated:YES completion:NULL];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
    NSLog(@"scrollViewDidScroll");
    if(scrollView == webView.scrollView) {
        if(scrollView.contentOffset.y > scrollOffset) {
            NSLog(@"scrollViewDidScroll down");
            [self.navigationController.toolbar setHidden:YES];
        }
        else {
            NSLog(@"scrollViewDidScroll up");
            [self.navigationController.toolbar setHidden:NO];
        }
        scrollOffset = scrollView.contentOffset.y;
    }
    */
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{

    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
    [self destroyStreamer];
}

- (void)createStreamer
{
	if (streamer)
	{
		return;
	}
    
	[self destroyStreamer];
    
    NSString *escapedValue = [NSString stringWithFormat:@"http://jeesmon.csoft.net/songs/1162_AAKAASHAME_KEELKKA_BHUMIYEE.MP3"];
    
	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
}

- (void)destroyStreamer
{
	if (streamer)
	{
		[streamer stop];
		streamer = nil;
	}
    playing = NO;
}

- (void)dealloc
{
	[self destroyStreamer];
}
#pragma mark UIWebViewDelegate

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(UIWebView *)webView{
    

    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    
    NSString *jsFilePath = [[NSBundle mainBundle] pathForResource:@"script" ofType:@"js"];

    //NSURL *jsURL = [NSURL fileURLWithPath:jsFilePath];
    NSString *javascriptCode = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:nil];
    [self->webView stringByEvaluatingJavaScriptFromString:javascriptCode];

    NSString *jsFilePath1 = [[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"];

    //NSURL *jsURL1 = [NSURL fileURLWithPath:jsFilePath1];
    NSString *javascriptCode1 = [NSString stringWithContentsOfFile:jsFilePath1 encoding:NSUTF8StringEncoding error:nil];
    [self->webView stringByEvaluatingJavaScriptFromString:javascriptCode1];
}
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

@end
