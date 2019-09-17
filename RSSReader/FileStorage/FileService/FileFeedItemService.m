//
//  FileFeedItemService.m
//  RSSReader
//
//  Created by USER on 9/16/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "FileFeedItemService.h"
#import "FileFeedItemRepository.h"

@interface FileFeedItemService ()
@property (strong, nonatomic) FileFeedItemRepository* fileFeedItemRepository;
@end

static NSString* TXT_FORMAT_NAME = @".txt";

@implementation FileFeedItemService

static FileFeedItemService* shared;

+(instancetype) sharedFileFeedItemService {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [FileFeedItemService new];
        shared.fileFeedItemRepository = [FileFeedItemRepository sharedFileFeedItemRepository];
    });
    return shared;
}

- (NSMutableArray<FeedItem *>*) cleanSaveFeedItems:(NSMutableArray<FeedItem *>*) items {
    FeedResource* resource = [items firstObject].resource;
    [self.fileFeedItemRepository createAndSaveFeedItems:items toFileWithName:[self toTXTFormar:resource.name]];
    return items;
}

- (NSMutableArray<FeedItem *>*) feedItemsForResource:(FeedResource *) resource {
    NSMutableArray<FeedItem *>* allItems = [self.fileFeedItemRepository readFeedItemsFile:[self toTXTFormar:resource.name]];
    return [[NSMutableArray alloc] initWithArray:[allItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FeedItem*  _Nullable obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        return !obj.isReadingComplite;
    }]]];
}

- (NSMutableArray<FeedItem *>*) feedItemsForResources:(NSMutableArray<FeedResource *> *)resources {
    
    NSMutableArray<FeedItem *>* allItems = [NSMutableArray new];

    for (FeedResource* resource in resources) {
         [allItems addObjectsFromArray:[self.fileFeedItemRepository readFeedItemsFile:[self toTXTFormar:resource.name]]];
    }
    
    return [[NSMutableArray alloc] initWithArray:[allItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FeedItem*  _Nullable obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        return !obj.isReadingComplite;
    }]]];
}

- (void) updateFeedItem:(FeedItem *) item {
    [self.fileFeedItemRepository updateFeedItem:item inFile:[self toTXTFormar:item.resource.name]];
}

- (void) removeFeedItem:(FeedItem *) item {
    [self.fileFeedItemRepository removeFeedItem:item fromFile:[self toTXTFormar:item.resource.name]];
}

- (NSMutableArray<FeedItem *>*) favoriteFeedItems:(NSMutableArray<FeedResource *>*) resources {
    NSMutableArray<FeedItem *>* allItems = [[NSMutableArray alloc] init];
    
    for (FeedResource* resource in resources) {
        [allItems addObjectsFromArray:[self.fileFeedItemRepository readFeedItemsFile:[self toTXTFormar:resource.name]]];
    }
    
    return [[NSMutableArray alloc] initWithArray:[allItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FeedItem*  _Nullable obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        return obj.isFavorite;
    }]]];
}

- (NSMutableArray<NSString *>*) favoriteFeedItemLinks:(NSMutableArray<FeedResource *>*) resources {
    NSMutableArray<FeedItem *>* allItems = [[NSMutableArray alloc] init];
    
    for (FeedResource* resource in resources) {
        [allItems addObjectsFromArray:[self.fileFeedItemRepository readFeedItemsFile:[self toTXTFormar:resource.name]]];
    }
    NSArray<FeedItem *>* favoriteItems = [allItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FeedItem*  _Nullable obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        return obj.isFavorite;
    }]];
    
    return [[NSMutableArray alloc] initWithArray:[favoriteItems valueForKey:@"link"]];
}

- (NSMutableArray<NSString *>*) readingInProgressFeedItemLinks:(NSMutableArray<FeedResource *>*) resources {
    NSMutableArray<FeedItem *>* allItems = [[NSMutableArray alloc] init];
    
    for (FeedResource* resource in resources) {
        [allItems addObjectsFromArray:[self.fileFeedItemRepository readFeedItemsFile:[self toTXTFormar:resource.name]]];
    }
    
    return [[NSMutableArray alloc] initWithArray:[allItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FeedItem*  _Nullable obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        return obj.isReadingInProgress && !obj.isReadingComplite;
    }]]];
}

- (NSMutableArray<NSString *>*) readingCompliteFeedItemLinks:(NSMutableArray<FeedResource *>*) resources {
    NSMutableArray<FeedItem *>* allItems = [[NSMutableArray alloc] init];
    
    for (FeedResource* resource in resources) {
        [allItems addObjectsFromArray:[self.fileFeedItemRepository readFeedItemsFile:[self toTXTFormar:resource.name]]];
    }
    NSArray<FeedItem *>* favoriteItems = [allItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FeedItem*  _Nullable obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        return obj.isReadingComplite;
    }]];
    
    return [[NSMutableArray alloc] initWithArray:[favoriteItems valueForKey:@"link"]];
}

- (NSString *) toTXTFormar:(NSString *) prefix {
    return [NSString stringWithFormat:@"%@%@", prefix, TXT_FORMAT_NAME];
}

@end
