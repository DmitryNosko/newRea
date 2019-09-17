//
//  FeedResourceRepository.m
//  RSSReader
//
//  Created by Dzmitry Noska on 9/13/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "SQLFeedResourceRepository.h"
#import "DBManager.h"

static NSString* const INSERT_FEEDRESOURCE_SQL = @"INSERT INTO FeedResource (name, url) VALUES (\"%@\", \"%@\")";
static NSString* const DELETE_FEEDRESOURCE_SQL = @"DELETE FROM FeedResource WHERE FeedResource.id = \"%@\"";
static NSString* const SELECT_FEEDRESOURSE_BY_URL = @"SELECT fr.ID, fr.name, fr.url FROM FeedResource AS fr WHERE fr.url = \"%@\"";
static const char* SELECT_FEEDRESOURCE_SQL = "SELECT ID, name, url FROM FeedResource";


@implementation SQLFeedResourceRepository

static SQLFeedResourceRepository* shared;

+(instancetype) sharedFeedResourceRepository {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [SQLFeedResourceRepository new];
    });
    return shared;
}

#pragma mark - FeedResource Requests

- (FeedResource *) addFeedResource:(FeedResource *) resource {
    
    sqlite3_stmt *statement;
    const char *dataBasePath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    
    if (sqlite3_open(dataBasePath, &rssDataBase) == SQLITE_OK) {
        
        const char *insertStatement = [[NSString stringWithFormat:INSERT_FEEDRESOURCE_SQL, resource.name, resource.url.absoluteString] UTF8String];
        
        sqlite3_prepare_v2(rssDataBase, insertStatement, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSInteger lastRowID = sqlite3_last_insert_rowid(rssDataBase);
            resource.identifier = lastRowID;
            NSLog(@"FeedResource added with lastRowID = %@", @(lastRowID));
        } else {
            NSLog(@"Failed to add FeedResource by stmt = %@", @(insertStatement));
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
    return resource;
}


- (void) removeFeedResource:(FeedResource *) resource {
    
    const char *dbpath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
        
        const char *removeStatement = [[NSString stringWithFormat:DELETE_FEEDRESOURCE_SQL, @(resource.identifier)] UTF8String];
        
        sqlite3_prepare_v2(rssDataBase, removeStatement, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"FeedResource removed by id = %@", @(resource.identifier));
        } else {
            NSLog(@"Failed to delete FeedResource by stmt = %@", @(removeStatement));
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
}

- (NSMutableArray<FeedResource *>*) feedResources {
    
    const char *dbpath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray<FeedResource *>* resources = [NSMutableArray array];
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
        
        if (sqlite3_prepare_v2(rssDataBase, SELECT_FEEDRESOURCE_SQL, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSInteger identifier = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)].integerValue;
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                NSURL* url = [NSURL URLWithString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)]];
                
                [resources addObject:[[FeedResource alloc] initWithID:identifier name:name url:url]];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
    return resources;
}

- (FeedResource *) resourceByURL:(NSURL *) url {
    sqlite3_stmt *statement;
    const char *dataBasePath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    FeedResource* resource = nil;
    if (sqlite3_open(dataBasePath, &rssDataBase) == SQLITE_OK) {
        
        const char *selectFeedResourceStatement = [[NSString stringWithFormat:SELECT_FEEDRESOURSE_BY_URL, url.absoluteString] UTF8String];
        
        if (sqlite3_prepare_v2(rssDataBase, selectFeedResourceStatement, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSInteger identifier = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)].integerValue;
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                NSURL* url = [NSURL URLWithString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)]];
                
                resource = [[FeedResource alloc] initWithID:identifier name:name url:url];
                
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
        
    }
    
    return resource;
}

@end
