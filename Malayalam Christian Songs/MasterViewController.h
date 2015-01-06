//
//  MasterViewController.h
//  Malayalam Christian Songs
//
//  Created by Jacob, Jeesmon on 4/16/13.
//  Copyright (c) 2013 Jacob, Jeesmon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *songs;
    NSMutableArray *indexArray;
    NSMutableArray *indexPosArray;
    NSMutableArray *sectionCountArray;
    NSMutableArray *sectionIndexArray;
    
    NSArray *searchResults;
}

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) UISearchDisplayController *songSearchDisplayController;

@end
