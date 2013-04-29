/*
 *  WGVectorObject.h
 *  WhirlyGlobeComponent
 *
 *  Created by Steve Gifford on 8/2/12.
 *  Copyright 2012 mousebird consulting
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

#import <Foundation/Foundation.h>
#import <WGCoordinate.h>

/** WhirlyGlobe Component Vector Object.
    This can represent one or more vector features parsed out of GeoJSON.
  */
@interface WGVectorObject : NSObject

/// Get the attributes.  If it's a multi-object this will just return the first
///  attribute dictionary.
@property (nonatomic,readonly) NSDictionary *attributes;

/// Parse vector data from geoJSON.  Returns one object to represent
///  the whole thing, which might include multiple different vectors.
/// We assume the geoJSON is all in decimal degrees in WGS84. 
+ (WGVectorObject *)VectorObjectFromGeoJSON:(NSData *)geoJSON;

/// Construct with a single point
- (id)initWithPoint:(WGCoordinate *)coord attributes:(NSDictionary *)attr;
/// Construct with a linear feature (e.g. line string)
- (id)initWithLineString:(WGCoordinate *)coords numCoords:(int)numCoords attributes:(NSDictionary *)attr;
/// Construct as an areal with an exterior
- (id)initWithAreal:(WGCoordinate *)coords numCoords:(int)numCoords attributes:(NSDictionary *)attr;

/// Add a hole to an existing areal feature
- (void)addHole:(WGCoordinate *)coords numCoords:(int)numCoords;

/// For areal features, check if the given point is inside
- (bool)pointInAreal:(WGCoordinate)coord;

/// Calculate and return the center of the whole object
- (WGCoordinate)center;

/// Calculate and return the center of the single largest loop
- (WGCoordinate)largestLoopCenter;

@end
