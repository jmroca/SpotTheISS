//
//  AppDelegate.h
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/19/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,strong) CLLocationManager * locationManager;
@property (nonatomic,strong) CLLocation* currentLocation;


@end
