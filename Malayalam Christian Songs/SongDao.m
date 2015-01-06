//
//  SongDao.m
//  Malayalam Christian Songs
//
//  Created by Jacob, Jeesmon on 7/16/13.
//  Copyright (c) 2013 Jacob, Jeesmon. All rights reserved.
//

#import "SongDao.h"
#import "Song.h"
#import "sqlite3.h"

@implementation SongDao

- (NSString *) getDatabasePath: (NSString *) databaseName {
    NSString *path;
    if([databaseName isEqualToString:@"songs"]) {
        path = [[NSBundle mainBundle] pathForResource:databaseName ofType:@"db" inDirectory:@"/"];
    }
    else {
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [[NSString alloc] initWithString: [dirPaths[0] stringByAppendingPathComponent: @"bookmarks.db"]];
    }
    
    NSLog(@"%@", path);
    
    return path;
}

- (NSDictionary *) fetchSongs: (NSString *) databaseName withLangType: (SongLangType) langType {
    NSLog(@"fetchSongs: %i", langType);
    NSMutableArray *songs = [NSMutableArray array];
    NSMutableArray *sectionIndexTitleArray = [NSMutableArray array];
    NSMutableArray *sectionIndexTitlePosArray = [NSMutableArray array];
    NSMutableArray *sectionCountArray = [NSMutableArray array];
    NSMutableArray *sectionIndexArray = [NSMutableArray array];
    
    int order = langType == SongLangTypeMalayalam ? 2 : 3;
    NSString *sectionIndexTitleColumn = langType == SongLangTypeMalayalam ? @"titleMl" : @"titleEn";
    
    NSString *sql = [NSString stringWithFormat:@"SELECT song_id, title_ml, title_en, filename_ml, filename_en FROM songs order by %i COLLATE NOCASE", order];
    NSString *pathname = [self getDatabasePath:databaseName];
    const char *dbpath = [pathname UTF8String];
    
    sqlite3 *db;
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK){
            int count = 0;
            int section = 0;
            int sectionCount = 0;
            NSString *prevSectionIndexTitle = nil;
            while(sqlite3_step(stmt) == SQLITE_ROW) {
                Song *song = [[Song alloc] init];
                song.songId = sqlite3_column_int(stmt, 0);
                song.titleMl = [[NSString alloc] initWithUTF8String:
                                (const char *) sqlite3_column_text(stmt, 1)];
                song.titleEn = [[NSString alloc] initWithUTF8String:
                                (const char *) sqlite3_column_text(stmt, 2)];
                song.filenameMl = [[NSString alloc] initWithUTF8String:
                                (const char *) sqlite3_column_text(stmt, 3)];
                song.filenameEn = [[NSString alloc] initWithUTF8String:
                                (const char *) sqlite3_column_text(stmt, 4)];
                
                NSString *sectionIndexTitle = [[[song valueForKey:sectionIndexTitleColumn] substringToIndex:1] uppercaseString];
                if(prevSectionIndexTitle == nil || ![prevSectionIndexTitle isEqualToString:sectionIndexTitle]) {
                    if(section > 0) {
                        [sectionCountArray addObject:[NSNumber numberWithInt:sectionCount]];
                        sectionCount = 0;
                    }
                    
                    prevSectionIndexTitle = sectionIndexTitle;
                    [sectionIndexTitleArray addObject:sectionIndexTitle];
                    [sectionIndexTitlePosArray addObject:[NSNumber numberWithInt:section]];
                    [sectionIndexArray addObject:[NSNumber numberWithInt:count]];
                    section++;
                }
                
                [songs addObject:song];
                
                count++;
                sectionCount++;
            }
            [sectionCountArray addObject:[NSNumber numberWithInt:sectionCount]];
            sqlite3_finalize(stmt);
        }
        else {
            NSLog(@"err: %s", sqlite3_errmsg(db));
        }
        sqlite3_close(db);
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:songs, @"songs", sectionIndexTitleArray, @"index", sectionIndexTitlePosArray, @"indexPos", sectionCountArray, @"sectionCount", sectionIndexArray, @"sectionIndex", nil];
}

- (Song *) fetchFirstSong: (NSString *) databaseName withLangType: (SongLangType) langType {
    NSLog(@"fetchSongs: %i", langType);
    
    Song *song = nil;
    
    int order = langType == SongLangTypeMalayalam ? 2 : 3;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT song_id, title_ml, title_en, filename_ml, filename_en FROM songs order by %i COLLATE NOCASE limit 1", order];
    NSString *pathname = [self getDatabasePath:databaseName];
    const char *dbpath = [pathname UTF8String];
    
    sqlite3 *db;
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK){
            if(sqlite3_step(stmt) == SQLITE_ROW) {
                song = [[Song alloc] init];
                song.songId = sqlite3_column_int(stmt, 0);
                song.titleMl = [[NSString alloc] initWithUTF8String:
                                (const char *) sqlite3_column_text(stmt, 1)];
                song.titleEn = [[NSString alloc] initWithUTF8String:
                                (const char *) sqlite3_column_text(stmt, 2)];
                song.filenameMl = [[NSString alloc] initWithUTF8String:
                                   (const char *) sqlite3_column_text(stmt, 3)];
                song.filenameEn = [[NSString alloc] initWithUTF8String:
                                   (const char *) sqlite3_column_text(stmt, 4)];
            }
            sqlite3_finalize(stmt);
        }
        else {
            NSLog(@"err: %s", sqlite3_errmsg(db));
        }
        sqlite3_close(db);
    }
    
    return song;
}

- (BOOL) copyBookmarksDatabase
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if(dirPaths && dirPaths.count > 0) {
        NSString *databasePath = [self getDatabasePath:@"bookmarks"];
        if(databasePath) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath: databasePath ] == NO) {
                NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"bookmarks" ofType:@"db" inDirectory:@"/"];
                NSError *error;
                [fileManager copyItemAtPath:resourcePath toPath:databasePath error:&error];
                if(error) {
                    return NO;
                }
            }
            return YES;
        }
    }
    return NO;
}

- (BOOL) addBookmark: (Song *) song {
    NSLog(@"addBookmark: %@", song.titleMl);
    
    NSString *databaseName = @"bookmarks";
    NSString *countSql = [NSString stringWithFormat:@"SELECT count(*) from songs where title_ml = '%@'", song.titleMl];
    NSString *insertSql = [NSString stringWithFormat:@"INSERT into songs (title_ml, title_en, filename_ml, filename_en) VALUES('%@', '%@', '%@', '%@')", song.titleMl, song.titleEn, song.filenameMl, song.filenameEn];
    NSString *pathname = [self getDatabasePath:databaseName];
    const char *dbpath = [pathname UTF8String];
    
    sqlite3 *db;
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [countSql UTF8String], -1, &stmt, NULL) == SQLITE_OK){
            if(sqlite3_step(stmt) == SQLITE_ROW) {
                int count = sqlite3_column_int(stmt, 0);
                if(count > 0) {
                    return NO;
                }
            }
            sqlite3_finalize(stmt);
        }
        else {
            NSLog(@"err: %s", sqlite3_errmsg(db));
        }
                
        if (sqlite3_prepare_v2(db, [insertSql UTF8String], -1, &stmt, NULL) == SQLITE_OK){
            if(sqlite3_step(stmt) == SQLITE_DONE) {
              NSLog(@"Inserted");  
            }
            sqlite3_finalize(stmt);
        }
        else {
            NSLog(@"err: %s", sqlite3_errmsg(db));
        }
        sqlite3_close(db);
    }
    
    return YES;
}

- (void) deleteBookmark: (Song *) song {
    NSLog(@"deleteBookmark: %@", song.titleMl);
    
    NSString *databaseName = @"bookmarks";
    NSString *sql = [NSString stringWithFormat:@"DELETE from songs WHERE song_id = %i", song.songId];
    NSString *pathname = [self getDatabasePath:databaseName];
    const char *dbpath = [pathname UTF8String];
    
    sqlite3 *db;
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK){
            if(sqlite3_step(stmt) == SQLITE_DONE) {
                NSLog(@"Deleted");
            }
            sqlite3_finalize(stmt);
        }
        else {
            NSLog(@"err: %s", sqlite3_errmsg(db));
        }
        sqlite3_close(db);
    }
}

- (void) deleteAllBookmarks {
    NSLog(@"deleteAllBookmarks");
    
    NSString *databaseName = @"bookmarks";
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM songs"];
    NSString *pathname = [self getDatabasePath:databaseName];
    const char *dbpath = [pathname UTF8String];
    
    sqlite3 *db;
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK){
            if(sqlite3_step(stmt) == SQLITE_DONE) {
                NSLog(@"Deleted");
            }
            sqlite3_finalize(stmt);
        }
        else {
            NSLog(@"err: %s", sqlite3_errmsg(db));
        }
        sqlite3_close(db);
    }
}

@end
