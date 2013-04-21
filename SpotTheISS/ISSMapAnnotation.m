//
//  ISSMapAnnotation.m
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/20/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import "ISSMapAnnotation.h"

@implementation ISSMapAnnotation

- (MKMapItem*)mapItem {
    
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:nil];
    
    // 3
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    mapItem.phoneNumber = @"+44-20-8123-4567";
    mapItem.url = [NSURL URLWithString:@"http://www.raywenderlich.com/"];
    
    return mapItem;
}

@end
