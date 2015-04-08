//
//  MasterViewController.m
//  Malayalam Christian Songs
//
//  Created by Jacob, Jeesmon on 4/16/13.
//  Copyright (c) 2013 Jacob, Jeesmon. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "WebViewController.h"
#import "Toast+UIView.h"
#import "SongDao.h"
#import "Song.h"
#import "SongLangType.h"

@implementation MasterViewController

UIBarButtonItem *langButton;
SongLangType currentLangType;
bool bookmarksShown = NO;
UIView *noResultsView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentLangType = SongLangTypeMalayalam;
    
    [self setupSearch];
    
    [self loadData:@"songs" withLangType:currentLangType];
    
    [self configureView];
}

- (void)configureView
{
    if (self) {
        self.title = @"Songs";
        
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
        
        NSString *langButtonTitle = currentLangType == SongLangTypeMalayalam ? @"ENG" : @"MAL";

        langButton = [[UIBarButtonItem alloc] initWithTitle:langButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(toggleLang)];
        self.navigationItem.rightBarButtonItem = langButton;
        currentLangType = SongLangTypeMalayalam;
    }    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tableView) {
       
        if([songs count] == 0 ){
            noResultsView.hidden = NO;
        } else {
            noResultsView.hidden = YES;
        }
        return [indexArray count];
    }
    else {
      
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tableView) {
        return [[sectionCountArray objectAtIndex:section] integerValue];
    }
    else {
        return [searchResults count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == self.tableView) {
        //NSLog(@"titleForHeaderInSection - main");
        return [indexArray objectAtIndex:section];
    }
    else {
        //NSLog(@"titleForHeaderInSection - filtered");
        return nil;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SongCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Song *song;
    
    if(tableView == self.tableView) {
        int row = [[sectionIndexArray objectAtIndex:indexPath.section] integerValue] + indexPath.row;
        song = [songs objectAtIndex:row];
    }
    else {
        song = [searchResults objectAtIndex:indexPath.row];
    }
    
    NSString *column = currentLangType == SongLangTypeMalayalam ? @"titleMl" : @"titleEn";
    cell.textLabel.text = [song valueForKey:column];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    return bookmarksShown ? YES : NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    
        int row = [[sectionIndexArray objectAtIndex:indexPath.section] integerValue] + indexPath.row;
        Song *song = [songs objectAtIndex:row];
        SongDao *dao = [[SongDao alloc] init];
        [dao deleteBookmark:song];
        [self loadData:@"bookmarks" withLangType:currentLangType];
        
        [self.view makeToast:@"Bookmark deleted"
                    duration:2.0
                    position:@"bottom"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song;
    
    if(tableView == self.tableView) {
        int row = [[sectionIndexArray objectAtIndex:indexPath.section] integerValue] + indexPath.row;
        song = [songs objectAtIndex:row];
    }
    else {
        song = [searchResults objectAtIndex:indexPath.row];
    }
    
   
    song.langType = currentLangType;
    self.detailViewController.selectedSong = song;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    }
    else {
        [self.detailViewController showSong];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if(tableView == self.tableView) {
        return indexArray;
    }
    else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString
                                                                             *)title atIndex:(NSInteger)index {
    return [[indexPosArray objectAtIndex:index] integerValue];
}

- (void)viewDidAppear:(BOOL)animated {
    //self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbarHidden = YES;
    
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.tableView setScrollsToTop:YES];
    
    //[self setupToolbar];
    [self setupNoResultsView];
}

- (void) setupToolbar {
    /*UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *bookmarksToggleButton;
    
    if(bookmarksShown) {
        bookmarksToggleButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"music.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSongs)];
    }
    else {
        bookmarksToggleButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showBookmarks)];
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    if(bookmarksShown && [songs count] > 0) {
        UIBarButtonItem *deleteAllButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAllBookmarks)];
        [items addObject:deleteAllButton];
    }
    
    [items addObjectsFromArray:@[flexSpace, bookmarksToggleButton]];
    
    self.navigationController.toolbar.barTintColor = [UIColor whiteColor];
    self.navigationController.toolbar.tintColor = [UIColor blackColor];
    self.navigationController.toolbar.barStyle = UIBarStyleDefault;
    [self.navigationController.toolbar setItems:items animated:YES];
     */
}

- (void) deleteAllBookmarks {
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:nil
                          message: @"Delete all bookmarks?"
                          delegate: self
                          cancelButtonTitle: nil
                          otherButtonTitles: @"Delete", @"Cancel", nil];
    alert.cancelButtonIndex = 1;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            SongDao *dao = [[SongDao alloc] init];
            [dao deleteAllBookmarks];
            [self loadData:@"bookmarks" withLangType:currentLangType];
            [self setupToolbar];
            [self.view makeToast:@"Bookmarks deleted" duration:2.0 position:@"bottom"];
        }
        break;
    }
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
    songs = nil;
    indexArray = nil;
    indexPosArray = nil;
    sectionCountArray = nil;
    sectionIndexArray = nil;
    self.songSearchDisplayController = nil;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
   
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
   
}

- (void) setupSearch {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    self.songSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    [searchBar sizeToFit];
    searchBar.delegate = self;
    searchBar.placeholder = @"Search in English";
    //searchBar.barStyle = UIBarStyleBlackOpaque;
    
    self.songSearchDisplayController.searchResultsDelegate = self;
    self.songSearchDisplayController.searchResultsDataSource = self;
    self.songSearchDisplayController.delegate = self;
    
    self.tableView.tableHeaderView = searchBar;
}

- (void) setupNoResultsView {
    UILabel *noResultsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    noResultsLabel.font = [UIFont boldSystemFontOfSize:20];
    noResultsLabel.minimumFontSize = 12.0f;
    noResultsLabel.numberOfLines = 1;
    noResultsLabel.lineBreakMode = UILineBreakModeWordWrap;
    noResultsLabel.textColor = [UIColor lightGrayColor];
    noResultsLabel.backgroundColor = [UIColor clearColor];
    noResultsLabel.textAlignment =  UITextAlignmentCenter;
    
    //Here is the text for when there are no results
    noResultsLabel.text = @"No Bookmarks";
    [noResultsLabel sizeToFit];
    
    noResultsView = [[UIView alloc] initWithFrame:noResultsLabel.frame];
    noResultsView.backgroundColor = [UIColor clearColor];
    [noResultsView setCenter:self.tableView.center];
    noResultsView.hidden = YES;
    [noResultsView addSubview:noResultsLabel];
    
    [self.tableView insertSubview:noResultsView belowSubview:self.tableView];
}

- (void) loadData: (NSString *) databaseName withLangType: (SongLangType) lang {
    SongDao *dao = [[SongDao alloc] init];
    NSDictionary *dict = [dao fetchSongs:databaseName withLangType:lang];
    songs = dict[@"songs"];
    indexArray = dict[@"index"];
    indexPosArray = dict[@"indexPos"];
    sectionCountArray = dict[@"sectionCount"];
    sectionIndexArray = dict[@"sectionIndex"];
    
    [self.tableView setEditing:NO animated:NO];
    [self.tableView reloadData];
}

-(void) showSearch {
   
}

-(void) showSongs {
   
    self.title = @"Songs";
    [self loadData:@"songs" withLangType:currentLangType];
    bookmarksShown = NO;
    [self setupToolbar];
}

-(void) showBookmarks {
   
    self.title = @"Bookmarks";
    [self loadData:@"bookmarks" withLangType:currentLangType];
    bookmarksShown = YES;
    [self setupToolbar];
}

- (void)filterContentForSearchText:(NSString*)searchText
{
   
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"titleEn contains[cd] %@",
                                    searchText];
    
    searchResults = [songs filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    
    [self filterContentForSearchText:searchString];
    
    return YES;
}

-(void) showInfo {
    
    WebViewController *webViewController = [[WebViewController alloc] init];
    webViewController.title = @"About";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"about.html" ofType:@""];
    webViewController.url = [NSURL fileURLWithPath:path];
    [self.navigationController pushViewController:webViewController animated:YES];
}

-(void) toggleLang {
    
    NSString *databaseName = bookmarksShown ? @"bookmarks" : @"songs";
    
    if(currentLangType == SongLangTypeMalayalam) {
        langButton.title = @"MAL";
        currentLangType = SongLangTypeEnglish;
        [self loadData:databaseName withLangType:SongLangTypeEnglish];
    }
    else {
        langButton.title = @"ENG";
        currentLangType = SongLangTypeMalayalam;
        [self loadData:databaseName withLangType:SongLangTypeMalayalam];
    }
    
  
}

-(void)inspectViewAndSubViews:(UIView*) v level:(int)level {
    
    NSMutableString* str = [NSMutableString string];
    
    for (int i = 0; i < level; i++) {
        [str appendString:@"   "];
    }
    
    [str appendFormat:@"%@", [v class]];
    
    if ([v isKindOfClass:[UITableView class]]) {
        [str appendString:@" : UITableView "];
    }
    
    if ([v isKindOfClass:[UIScrollView class]]) {
        [str appendString:@" : UIScrollView "];
        
        UIScrollView* scrollView = (UIScrollView*)v;
        if (scrollView.scrollsToTop) {
            [str appendString:@" >>>scrollsToTop<<<<"];
        }
    }
    
    for (UIView* sv in [v subviews]) {
        [self inspectViewAndSubViews:sv level:level+1];
    }
}

@end
