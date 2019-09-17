//
//  FeedItemRepository.m
//  RSSReader
//
//  Created by Dzmitry Noska on 9/13/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "SQLFeedItemRepository.h"
#import "DBManager.h"

@interface SQLFeedItemRepository()
@property (strong, nonatomic) NSDateFormatter* dateFormatter;
@end

static NSString* const INSERT_FEEDITEM = @"INSERT INTO FeedItem (itemTitle, link, pubDate, itemDescription, enclousure, imageURL, isFavorite, isReadingInProgress, isReadingComplite, isAvailable, resourceURL, resourceID) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")";

static NSString* const UPDATE_FEEDITEM = @"UPDATE FeedItem SET isFavorite = \"%@\", isReadingInProgress = \"%@\", isReadingComplite = \"%@\", isAvailable = \"%@\" WHERE ID = \"%@\"";

static NSString* const SELECT_FEEDITEM_BY_ID = @"SELECT fi.ID, fi.itemTitle, fi.link, fi.pubDate, fi.itemDescription, fi.enclousure, fi.imageURL, fi.isFavorite, fi.isReadingInProgress, fi.isReadingComplite, fi.isAvailable, fi.resourceURL, fr.ID, fr.name, fr.url FROM FeedItem AS fi JOIN FeedResource AS fr ON fi.resourceID = fr.ID WHERE fi.resourceID = \"%@\" AND fi.isReadingComplite = 0";

static NSString* const SELECT_FEEDITEM_BY_IDS = @"SELECT fi.ID, fi.itemTitle, fi.link, fi.pubDate, fi.itemDescription, fi.enclousure, fi.imageURL, fi.isFavorite, fi.isReadingInProgress, fi.isReadingComplite, fi.isAvailable, fi.resourceURL, fr.ID, fr.name, fr.url FROM FeedItem AS fi JOIN FeedResource AS fr ON fi.resourceID = fr.ID WHERE fi.resourceID IN (%@) AND fi.isReadingComplite = 0";

static NSString* const SELECT_FAVORITE_FEEDITEM = @"SELECT fi.ID, fi.itemTitle, fi.link, fi.pubDate, fi.itemDescription, fi.enclousure, fi.imageURL, fi.isFavorite, fi.isReadingInProgress, fi.isReadingComplite, fi.isAvailable, fi.resourceURL FROM FeedItem AS fi WHERE fi.resourceID IN (%@) AND fi.isFavorite = 1;";

static NSString* const SELECT_FAVORITE_FEEDITEM_URL = @"SELECT fi.link FROM FeedItem AS fi WHERE fi.resourceID IN (%@) AND fi.isFavorite = 1";

static NSString* const SELECT_READING_IN_PROGRESS_FEEDITEM_URL = @"SELECT fi.link FROM FeedItem AS fi WHERE fi.resourceID IN (%@) AND fi.isReadingInProgress = 1 AND fi.isReadingComplite = 0";

static NSString* const SELECT_READING_COMPLITE_FEEDITEM_URL = @"SELECT fi.link FROM FeedItem AS fi WHERE fi.resourceID IN (%@) AND fi.isReadingComplite = 1";

static NSString* const DELETE_FEEDITEM = @"DELETE FROM FeedItem WHERE FeedItem.id = \"%@\"";

static NSString* const DELETE_FEEDITEM_BY_RESOURCE_ID = @"DELETE FROM FeedItem WHERE FeedItem.resourceID = \"%@\"";

static const char* DELETE_ALL_FEEDITEMS = "DELETE FROM FeedItem";


@implementation SQLFeedItemRepository

static SQLFeedItemRepository* shared;

+(instancetype) sharedFeedItemRepository {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [SQLFeedItemRepository new];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[[NSLocale preferredLanguages] objectAtIndex:0]]];
        [_dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    }
    return self;
}

#pragma mark - FeedItem Requests

- (FeedItem *) addFeedItem:(FeedItem *) item {
    
    sqlite3_stmt *statement;
    const char *dbpath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
        
        NSString *insertFeedItem = [NSString stringWithFormat:INSERT_FEEDITEM,
                                    item.itemTitle,
                                    item.link,
                                    item.pubDate,
                                    item.itemDescription,
                                    item.enclosure,
                                    item.imageURL,
                                    @(item.isFavorite),
                                    @(item.isReadingInProgress),
                                    @(item.isReadingComplite),
                                    @(item.isAvailable),
                                    item.resourceURL,
                                    @(item.resource.identifier)
                                    ];
        const char *insertStatement = [insertFeedItem UTF8String];
        
        sqlite3_prepare_v2(rssDataBase, insertStatement, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSInteger lastRowID = sqlite3_last_insert_rowid(rssDataBase);
            item.identifier = lastRowID;
            NSLog(@"FeedItem added with lastRowID = %@", @(lastRowID));
        } else {
            NSLog(@"Failed to add FeedItem by insertStatement = %@", @(insertStatement));
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
    return item;
}

- (void) updateFeedItem:(FeedItem *) item {
    
    sqlite3_stmt *statement;
    
    const char *dbpath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
        
        NSString *updateFeedItem = [NSString stringWithFormat:UPDATE_FEEDITEM, @(item.isFavorite), @(item.isReadingInProgress), @(item.isReadingComplite), @(item.isAvailable), @(item.identifier)];
        const char *updateStatement = [updateFeedItem UTF8String];
        
        sqlite3_prepare_v2(rssDataBase, updateStatement, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            sqlite3_reset(statement);
            NSLog(@"Success to update FeedItem by updateStatement = %@", @(updateStatement));
        } else {
            NSLog(@"Failed to update FeedItem by updateStatement = %@", @(updateStatement));
        }
    }
}

- (NSMutableArray<FeedItem *>*) feedItemsForResource:(NSInteger) identifier {
    
    const char *dbpath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray<FeedItem *>* items = [NSMutableArray array];
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
        
        const char *selectFeedItemsStatement = [[NSString stringWithFormat:SELECT_FEEDITEM_BY_ID, @(identifier)] UTF8String];
        
        if (sqlite3_prepare_v2(rssDataBase, selectFeedItemsStatement, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSInteger itemID = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)].integerValue;
                NSString *itemTitle = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                NSMutableString* link = [[NSMutableString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                NSDate *pubDate = [self dateFromString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)]];
                NSMutableString *itemDescription = [[NSMutableString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                NSString *enclousure = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                NSString *imageURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)];
                BOOL isFavorite = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)] boolValue];
                BOOL isReadingInProgress = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)] boolValue];
                BOOL isReadingComplite = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)] boolValue];
                BOOL isAvailable = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)] boolValue];
                NSURL *resourceURL = [NSURL URLWithString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 11)]];
                
                NSInteger resourceID = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 12)].integerValue;
                NSString *resourceName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 13)];
                NSURL *resURL = [NSURL URLWithString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 14)]];
                
                FeedResource* resource = [[FeedResource alloc] initWithID:resourceID name:resourceName url:resURL];
                FeedItem* item = [[FeedItem alloc] initWithID:itemID
                                                    itemTitle:itemTitle
                                                         link:link
                                                      pubDate:pubDate
                                              itemDescription:itemDescription
                                                    enclosure:enclousure
                                                     imageURL:imageURL
                                                   isFavorite:isFavorite
                                          isReadingInProgress:isReadingInProgress
                                          isReadingComplite:isReadingComplite
                                                  isAvailable:isAvailable
                                                  resourceURL:resourceURL
                                                     resource:resource];
                [items addObject:item];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
    return items;
}

- (NSMutableArray<FeedItem *>*) feedItemsForResources:(NSMutableArray<NSNumber *>*) resourcesIDs {
    const char *dbpath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray<FeedItem *>* items = [NSMutableArray array];
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
        
        const char *selectFeedItemsStatement = [[NSString stringWithFormat:SELECT_FEEDITEM_BY_IDS, [self prepareQueryParameters:resourcesIDs]] UTF8String];
        
        if (sqlite3_prepare_v2(rssDataBase, selectFeedItemsStatement, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSInteger itemID = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)].integerValue;
                NSString *itemTitle = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                NSMutableString* link = [[NSMutableString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                NSDate *pubDate = [self dateFromString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)]];
                NSMutableString *itemDescription = [[NSMutableString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                NSString *enclousure = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                NSString *imageURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)];
                BOOL isFavorite = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)] boolValue];
                BOOL isReadingInProgress = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)] boolValue];
                BOOL isReadingComplite = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)] boolValue];
                BOOL isAvailable = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)] boolValue];
                NSURL *resourceURL = [NSURL URLWithString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 11)]];
                
                NSInteger resourceID = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 12)].integerValue;
                NSString *resourceName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 13)];
                NSURL *resURL = [NSURL URLWithString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 14)]];
                
                FeedResource* resource = [[FeedResource alloc] initWithID:resourceID name:resourceName url:resURL];
                FeedItem* item = [[FeedItem alloc] initWithID:itemID
                                                    itemTitle:itemTitle
                                                         link:link
                                                      pubDate:pubDate
                                              itemDescription:itemDescription
                                                    enclosure:enclousure
                                                     imageURL:imageURL
                                                   isFavorite:isFavorite
                                          isReadingInProgress:isReadingInProgress
                                            isReadingComplite:isReadingComplite
                                                  isAvailable:isAvailable
                                                  resourceURL:resourceURL
                                                     resource:resource];
                [items addObject:item];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
    return items;
}

- (void) removeFeedItem:(FeedItem *) item {
    
    const char *dbpath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
        
        const char *deleteStatement = [[NSString stringWithFormat:DELETE_FEEDITEM, @(item.identifier)] UTF8String];
        
        sqlite3_prepare_v2(rssDataBase, deleteStatement, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"FeedItem removed by id = %@", @(item.identifier));
        } else {
            NSLog(@"Failed to remove FeedItem by id = %@", @(item.identifier));
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
}

- (void) removeFeedItemForResource:(NSInteger) identifier {
    const char *dbpath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
        
        const char *deleteFeedItemByResourceIDStatement = [[NSString stringWithFormat:DELETE_FEEDITEM_BY_RESOURCE_ID, @(identifier)] UTF8String];
        
        sqlite3_prepare_v2(rssDataBase, deleteFeedItemByResourceIDStatement, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"FeedItem removeFeedItemForResource by id = %@", @(identifier));
        } else {
            NSLog(@"Failed to removeFeedItemForResource FeedItem by id = %@", @(identifier));
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
}

- (void) removeAllFeedItems {
    
    const char *dbpath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
        
        sqlite3_prepare_v2(rssDataBase, DELETE_ALL_FEEDITEMS, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"removeAllFeedItems");
        } else {
            NSLog(@"Failed to removeAllFeedItems");
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
}

- (NSMutableArray<FeedItem *>*) favoriteFeedItems:(NSMutableArray<NSNumber *>*) resourcesIDs {
    
    const char *dbpath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray<FeedItem *>* resources = [NSMutableArray array];
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {

        const char *selectFavoriteItemsStatement = [[NSString stringWithFormat:SELECT_FAVORITE_FEEDITEM, [self prepareQueryParameters:resourcesIDs]] UTF8String];
        
        if (sqlite3_prepare_v2(rssDataBase, selectFavoriteItemsStatement, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSInteger itemID = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)].integerValue;
                NSString *itemTitle = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                NSMutableString* link = [[NSMutableString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                NSDate *pubDate = [self dateFromString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)]];
                NSMutableString *itemDescription = [[NSMutableString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                NSString *enclousure = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                NSString *imageURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)];
                BOOL isFavorite = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)] boolValue];
                BOOL isReadingInProgress = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)] boolValue];
                BOOL isReadingComplite = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)] boolValue];
                BOOL isAvailable = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)] boolValue];
                NSURL *resourceURL = [NSURL URLWithString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 11)]];

                FeedItem* item = [[FeedItem alloc] initWithID:itemID
                                                    itemTitle:itemTitle
                                                         link:link
                                                      pubDate:pubDate
                                              itemDescription:itemDescription
                                                    enclosure:enclousure
                                                     imageURL:imageURL
                                                   isFavorite:isFavorite
                                          isReadingInProgress:isReadingInProgress
                                            isReadingComplite:isReadingComplite
                                                  isAvailable:isAvailable
                                                  resourceURL:resourceURL
                                                     resource:nil];
                [resources addObject:item];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
    return resources;
}

- (NSMutableArray<NSString *>*) favoriteFeedItemLinks:(NSMutableArray<NSNumber *>*) resourcesIDs {
    
    const char *dbpath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray<NSString *>* links = [NSMutableArray array];
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
        
        const char *selectFavoriteItemLinksStatement = [[NSString stringWithFormat:SELECT_FAVORITE_FEEDITEM_URL, [self prepareQueryParameters:resourcesIDs]] UTF8String];
        
        if (sqlite3_prepare_v2(rssDataBase, selectFavoriteItemLinksStatement, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString* link = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [links addObject:link];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
    return links;
}

- (NSMutableArray<NSString *>*) readingInProgressFeedItemLinks:(NSMutableArray<NSNumber *>*) resourcesIDs {
    const char *dbpath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray<NSString *>* links = [NSMutableArray array];
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
        
        const char *selectReadingInProgressFeedItemLinksStatement = [[NSString stringWithFormat:SELECT_READING_IN_PROGRESS_FEEDITEM_URL, [self prepareQueryParameters:resourcesIDs]] UTF8String];
        
        if (sqlite3_prepare_v2(rssDataBase, selectReadingInProgressFeedItemLinksStatement, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString* link = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [links addObject:link];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
    return links;
}

- (NSMutableArray<NSString *>*) readingCompliteFeedItemLinks:(NSMutableArray<NSNumber *>*) resourcesIDs {
    const char *dbpath = [[[DBManager sharedDBManager] dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray<NSString *>* links = [NSMutableArray array];
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
        
        const char *selectReadingCompliteFeedItemLinksStatement = [[NSString stringWithFormat:SELECT_READING_COMPLITE_FEEDITEM_URL, [self prepareQueryParameters:resourcesIDs]] UTF8String];
        
        if (sqlite3_prepare_v2(rssDataBase, selectReadingCompliteFeedItemLinksStatement, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString* link = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [links addObject:link];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
    return links;
}

- (NSString *) prepareQueryParameters:(NSArray<id>*) parameters {
    NSMutableArray<NSString *>* params = [NSMutableArray new];
    for (id obj in parameters) {
        [params addObject:[NSString stringWithFormat:@"\"%@\"", obj]];
    }
    
    return [params componentsJoinedByString:@","];
}

- (NSDate *) dateFromString:(NSString *) dateString {
    NSDate* date = [self.dateFormatter dateFromString:dateString];
    return date;
}

@end
