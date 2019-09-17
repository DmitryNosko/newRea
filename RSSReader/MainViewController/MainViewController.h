//
//  MainViewController.h
//  RSSReader
//
//  Created by Dzmitry Noska on 8/26/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewControllerDelegate.h"
#import "FeedResource.h"
#import "FeedItem.h"

@interface MainViewController : UIViewController
@property (weak, nonatomic) id<MainViewControllerDelegate> delegate;

@property (copy, nonatomic) void(^feedResourceWasChosenHandler)(FeedResource* resource);
@property (copy, nonatomic) void(^feedResourceWasAddedHandler)(FeedResource* resource);
@property (copy, nonatomic) void(^fetchButtonWasPressedHandler)(NSMutableArray<FeedResource *>* resource);
@property (copy, nonatomic) void(^storageWasChanged)(NSNumber* newStorageValue);
@end

