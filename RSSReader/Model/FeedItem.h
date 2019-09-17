//
//  FeedItem.h
//  RSSReader
//
//  Created by Dzmitry Noska on 8/30/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedResource.h"

@interface FeedItem : NSObject
@property (assign, nonatomic) NSInteger identifier;
@property (strong, nonatomic) NSString* itemTitle;
@property (strong, nonatomic) NSMutableString* link;
@property (strong, nonatomic) NSDate* pubDate;
@property (strong, nonatomic) NSMutableString* itemDescription;
@property (strong, nonatomic) NSString* enclosure;
@property (strong, nonatomic) NSString* imageURL;
@property (assign, nonatomic) BOOL isFavorite;
@property (assign, nonatomic) BOOL isReadingInProgress;
@property (assign, nonatomic) BOOL isReadingComplite;
@property (assign, nonatomic) BOOL isAvailable;
@property (strong, nonatomic) NSURL* resourceURL;
@property (strong, nonatomic) FeedResource* resource;

- (instancetype)initWithID:(NSInteger) identifier itemTitle:(NSString *) itemTitle link:(NSMutableString *) link pubDate:(NSDate *) pubDate itemDescription:(NSMutableString *) itemDescription enclosure:(NSString *) enclosure imageURL:(NSString *) imageURL isFavorite:(BOOL) isFavorite isReadingInProgress:(BOOL) isReadingInProgress isReadingComplite:(BOOL)isReadingComplite isAvailable:(BOOL) isAvailable resourceURL:(NSURL *) resourceURL resource:(FeedResource *) resource;
@end;

