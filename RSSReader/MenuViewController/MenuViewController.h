//
//  MenuViewController.h
//  RSSReader
//
//  Created by Dzmitry Noska on 8/29/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedResource.h"

@interface MenuViewController : UIViewController
@property (strong, nonatomic) UIButton* fetchButton;
@property (copy, nonatomic) void(^feedResourceWasChosenHandler)(FeedResource* resource);
@property (copy, nonatomic) void(^feedResourceWasAddedHandler)(FeedResource* resource);
@property (copy, nonatomic) void(^feedResourceWasChousenHandler)(FeedResource* resource);
@property (copy, nonatomic) void(^fetchButtonWasPressedHandler)(NSMutableArray<FeedResource *>* resource);
@property (copy, nonatomic) void(^storageWasChanged)(NSNumber* newStorageValue);
@end


