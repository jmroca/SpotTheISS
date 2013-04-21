//
//  SpotResultViewController.h
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/20/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpotResultViewController;

@protocol SpotResultViewControllerDelegate <NSObject>

- (void)recordSpotResultViewController:(SpotResultViewController *)sender
                       recorded:(BOOL) result;

@end


@interface SpotResultViewController : UIViewController


@property (nonatomic,weak) id <SpotResultViewControllerDelegate> delegate;


@end
