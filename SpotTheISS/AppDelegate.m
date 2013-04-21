//
//  AppDelegate.m
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/19/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;




-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
    
    NSDate* eventDate = self.currentLocation.timestamp;
    
    NSLog(@"%@ Latitud: %+.4f, Longitud: %+.6f\n", eventDate.description, self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    
}

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.currentLocation = newLocation;
    
    NSDate* eventDate = newLocation.timestamp;
    
    NSLog(@"%@ Latitud: %+.6f, Longitud: %+.6f\n", eventDate.description, newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    
}


-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    self.currentLocation = nil;
    
    NSLog(@"Error CLLocationManager %@ \n", error.description);
}


-(void) aplicarPlantillaVisualUI
{
    
    // Set the background image for *all* UINavigationBars
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:11/255.f green:11/255.f blue:11/255.f alpha:0.75]];
    [[UIToolbar appearance] setTintColor:[UIColor colorWithRed:11/255.f green:11/255.f blue:11/255.f alpha:0.75]];
    
    // Customize the title text for *all* UINavigationBars
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
      UITextAttributeTextColor,
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      UITextAttributeTextShadowOffset,
      nil]];
    
    
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // crear objeto para CLocationManager
    if (!_locationManager) {
        
        _locationManager = [[CLLocationManager alloc] init];
        
        self.locationManager.delegate = self;
        
        // nivel de certeza establecido a un rango de 100 metros de error
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
        // filtrar solo si se tiene una distancia mayor
        self.locationManager.distanceFilter = 1;
        
    }
    
    [self aplicarPlantillaVisualUI];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
