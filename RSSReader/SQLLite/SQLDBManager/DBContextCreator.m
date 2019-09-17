//
//  DBContextCreator.m
//  RSSReader
//
//  Created by Dzmitry Noska on 9/13/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "DBContextCreator.h"
#import "DBManager.h"

@interface DBContextCreator()
@property (strong, nonatomic) NSFileManager* fileManager;
@end

static const char* CREATE_FEEDRESOURCE_SQL = "CREATE TABLE IF NOT EXISTS FeedResource (ID INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, url TEXT)";
static const char* CREATE_FEEDITEM_SQL = "CREATE TABLE IF NOT EXISTS FeedItem (ID INTEGER PRIMARY KEY AUTOINCREMENT, itemTitle TEXT, link TEXT, pubDate DATETIME, itemDescription TEXT, enclousure TEXT, imageURL TEXT, isFavorite BOOL NOT NULL DEFAULT 0, isReadingInProgress BOOL NOT NULL DEFAULT 0, isReadingComplite BOOL NOT NULL DEFAULT 0, isAvailable BOOL NOT NULL DEFAULT 0, resourceURL TEXT, resourceID INTEGER, FOREIGN KEY (resourceID) REFERENCES FeedResource(id))";

@implementation DBContextCreator

#pragma mark - CreateDB

- (void) createDB {
    NSLog(@"DBPath = %@", [[DBManager sharedDBManager] dataBasePath]);
    if (![self isDBCreated]) {
        const char *dataBasePath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
        
        if (sqlite3_open(dataBasePath, &rssDataBase) == SQLITE_OK) {
            char *errMsg = nil;
            
            [self createTable:CREATE_FEEDRESOURCE_SQL errMsg:errMsg];
            [self createTable:CREATE_FEEDITEM_SQL errMsg:errMsg];
            
            sqlite3_close(rssDataBase);
        } else {
            NSLog(@"Failed to open/create database at path %@", [[DBManager sharedDBManager] dataBasePath]);
        }
    }
}

- (BOOL) isDBCreated {
    return [self.fileManager fileExistsAtPath:[[DBManager sharedDBManager] dataBasePath]];
}

#pragma mark - Table Requests

- (void) createTable:(const char*) createSQL errMsg:(char *) errorMsg {
    if (sqlite3_exec(rssDataBase, createSQL, NULL, NULL, &errorMsg) == SQLITE_OK) {
        NSLog(@"Successful created = %@", @(createSQL));
    } else {
        NSLog(@"Failed to create = %@", @(createSQL));
    }
}

@end
