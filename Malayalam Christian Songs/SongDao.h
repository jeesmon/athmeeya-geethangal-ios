//
//  SongDao.h
//  Malayalam Christian Songs
//
//  Created by Jacob, Jeesmon on 7/16/13.
//  Copyright (c) 2013 Jacob, Jeesmon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SongLangType.h"
#import "Song.h"

@interface SongDao : NSObject

- (NSString *) getDatabasePath: (NSString *) databaseName;
- (NSDictionary *) fetchSongs: (NSString *) databaseName withLangType: (SongLangType) langType;
- (Song *) fetchFirstSong: (NSString *) databaseName withLangType: (SongLangType) langType;
- (BOOL) copyBookmarksDatabase;
- (BOOL) addBookmark: (Song *) song;
- (void) deleteBookmark: (Song *) song;
- (void) deleteAllBookmarks;

@end
