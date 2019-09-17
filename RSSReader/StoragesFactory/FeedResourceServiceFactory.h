//
//  FeedResourceServiceFactory.h
//  RSSReader
//
//  Created by Dzmitry Noska on 9/17/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedResourceServiceProtocol.h"

@interface FeedResourceServiceFactory : NSObject
+(instancetype) sharedFeedResourceServiceFactory;

- (id<FeedResourceServiceProtocol>) feedResourceServiceProtocol:(NSNumber*) storageValue;
@end

