//
//  MKMapView+MKMapView_ZoomLevel.h
//  SpotTheISS
//
//  Created by Jose De La Roca on 4/21/13.
//  Copyright (c) 2013 Jose De La Roca. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end
