//
//  FeedResourceService.h
//  RSSReader
//
//  Created by Dzmitry Noska on 9/13/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedResource.h"
#import "FeedResourceServiceProtocol.h"

@interface SQLFeedResourceService : NSObject <FeedResourceServiceProtocol>
+(instancetype) sharedFeedResourceService;
@end

