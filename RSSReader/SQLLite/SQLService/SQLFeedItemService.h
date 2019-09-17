//
//  FeedItemService.h
//  RSSReader
//
//  Created by Dzmitry Noska on 9/13/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItem.h"
#import "FeedResource.h"
#import "FeedItemServiceProtocol.h"

@interface SQLFeedItemService : NSObject <FeedItemServiceProtocol>
+(instancetype) sharedFeedItemService;
@end

