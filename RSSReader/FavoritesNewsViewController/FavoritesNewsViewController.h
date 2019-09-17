//
//  FavoritesNewsViewController.h
//  RSSReader
//
//  Created by Dzmitry Noska on 9/3/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedItem.h"

@interface FavoritesNewsViewController : UIViewController
@property (copy, nonatomic) void(^storageWasChanged)(NSNumber* newStorageValue);
@end

