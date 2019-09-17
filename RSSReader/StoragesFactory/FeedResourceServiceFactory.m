//
//  FeedResourceServiceFactory.m
//  RSSReader
//
//  Created by Dzmitry Noska on 9/17/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "FeedResourceServiceFactory.h"
#import "FileFeedResourceService.h"
#import "SQLFeedResourceService.h"

@interface FeedResourceServiceFactory ()
@property (strong, nonatomic) NSDictionary<NSNumber*, id<FeedResourceServiceProtocol>>* serviceByID;
@end


@implementation FeedResourceServiceFactory

static FeedResourceServiceFactory* shared;

+(instancetype) sharedFeedResourceServiceFactory {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [FeedResourceServiceFactory new];
        shared.serviceByID = @{@(0) : [FileFeedResourceService sharedFileFeedResourceService],
                               @(1) : [SQLFeedResourceService sharedFeedResourceService]
                               };
    });
    return shared;
}

- (id<FeedResourceServiceProtocol>) feedResourceServiceProtocol:(NSNumber*) storageValue {
    return [self.serviceByID objectForKey:@(storageValue.integerValue)];
}
@end
