//
//  Song.h
//  Malayalam Christian Songs
//
//  Created by Jacob, Jeesmon on 7/16/13.
//  Copyright (c) 2013 Jacob, Jeesmon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SongLangType.h"

@interface Song : NSObject {
}

@property(nonatomic) int songId;
@property(nonatomic, retain) NSString *titleMl;
@property(nonatomic, retain) NSString *titleEn;
@property(nonatomic, retain) NSString *filenameMl;
@property(nonatomic, retain) NSString *filenameEn;
@property(nonatomic) SongLangType langType;

@end
