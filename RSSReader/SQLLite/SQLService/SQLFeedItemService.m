//
//  FeedItemService.m
//  RSSReader
//
//  Created by Dzmitry Noska on 9/13/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "SQLFeedItemService.h"
#import "SQLFeedItemRepository.h"

@interface SQLFeedItemService()
@property (strong, nonatomic) SQLFeedItemRepository* feedItemRepository;
@end

@implementation SQLFeedItemService

static SQLFeedItemService* shared;

+(instancetype) sharedFeedItemService {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [SQLFeedItemService new];
        shared.feedItemRepository = [SQLFeedItemRepository sharedFeedItemRepository];
    });
    return shared;
}

- (NSMutableArray<FeedItem *>*) cleanSaveFeedItems:(NSMutableArray<FeedItem *>*) items {
    FeedResource* resource = [items firstObject].resource;
    [self.feedItemRepository removeFeedItemForResource:resource.identifier];
    NSMutableArray<FeedItem *>* createdItems = [self addFeedItems:items];
    return createdItems;
}

- (NSMutableArray<FeedItem *> *) addFeedItems:(NSMutableArray<FeedItem *>*) items {
    
    NSMutableArray<FeedItem *>* resultItems = [[NSMutableArray alloc] init];
    for (FeedItem* item in items) {
        [resultItems addObject:[self addFeedItem:item]];
    }
    
    return resultItems;
}

- (FeedItem *) addFeedItem:(FeedItem *) item {
    return [self.feedItemRepository addFeedItem:item];
}

- (NSMutableArray<FeedItem *>*) feedItemsForResource:(FeedResource *) resource {
    return [self.feedItemRepository feedItemsForResource:resource.identifier];
}

- (NSMutableArray<FeedItem *>*) feedItemsForResources:(NSMutableArray<FeedResource *>*) resources {
    return [self.feedItemRepository feedItemsForResources:[resources valueForKey:@"identifier"]];
}

- (void)updateFeedItem:(FeedItem *)item {
    [self.feedItemRepository updateFeedItem:item];
}

- (void) removeFeedItem:(FeedItem *) item {
    [self.feedItemRepository removeFeedItem:item];
}

- (NSMutableArray<FeedItem *>*) favoriteFeedItems:(NSMutableArray<FeedResource *>*) resources {
    return [self.feedItemRepository favoriteFeedItems:[resources valueForKey:@"identifier"]];
}

- (NSMutableArray<NSString *>*) favoriteFeedItemLinks:(NSMutableArray<FeedResource *>*) resources {
    return [self.feedItemRepository favoriteFeedItemLinks:[resources valueForKey:@"identifier"]];
}

- (NSMutableArray<NSString *>*) readingInProgressFeedItemLinks:(NSMutableArray<FeedResource *>*) resources {
    return [self.feedItemRepository readingInProgressFeedItemLinks:[resources valueForKey:@"identifier"]];
}

- (NSMutableArray<NSString *>*) readingCompliteFeedItemLinks:(NSMutableArray<FeedResource *>*) resources {
    return [self.feedItemRepository readingCompliteFeedItemLinks:[resources valueForKey:@"identifier"]];
}

@end
