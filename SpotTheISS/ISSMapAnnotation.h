//
//  ISSMapAnnotation.h
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/20/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ISSMapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (MKMapItem*)mapItem;


@end
