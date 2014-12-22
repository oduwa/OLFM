//
//  OLFMGeo.h
//  Jive
//
//  Created by Odie Edo-Osagie on 13/06/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface OLFMGeo : NSObject<NSXMLParserDelegate, CLLocationManagerDelegate>


/**
 * Creates a singleton instance of a OLFMGeo object from which methods are called
 *
 * @return OLFMGeo singleton instance
 */
+ (OLFMGeo *) geo;


/**
 * Get the top artists in the user's device locale
 *
 * @param numberOfResults A whole number specifiying the total number of artists the method should return
 * @return an array of dictionaries with the following keys - "name", "imageURL".
 */
- (NSArray *) getTopArtistsFromLocaleWithResultsLimit: (NSUInteger) numberOfResults;


/**
 * Get the top artists in the user's country. This is different from
 * getTopArtistsFromLocaleWithResultsLimit: because the device locale country may not
 * necessarily be the country  the user is located in.
 *
 * @param numberOfResults A whole number specifiying the total number of artists the method should return
 * @param countryName A string containing the name of the country conforming to the ISO 3166-1 specification
 * @return an array of OLFMArtist objects with the following fields set - @a name and @a imageURL.
 */
- (NSArray *) getTopArtistsWithResultsLimit: (NSUInteger) numberOfResults andCountry: (NSString *) countryName;


/**
 * Get the up and coming artists in the user's device locale
 *
 * @param numberOfResults A whole number specifiying the total number of artists the method should return
 * @return an array of dictionaries with the following keys - "name", "imageURL".
 */
- (NSArray *) getHypedArtistsFromLocaleWithResultsLimit: (NSUInteger) numberOfResults;


/**
 * Get the up and coming artists in the user's country. This is different from
 * getHypedArtistsWithResultsLimit: because the device locale country may not
 * necessarily be the country  the user is located in.
 *
 * @param numberOfResults A whole number specifiying the total number of artists the method should return
 * @param countryName A string containing the name of the country conforming to the ISO 3166-1 specification
 * @param cityName A string containing the name of a metro city within the provided country
 * @return an array of dictionaries with the following keys - "name", "imageURL".
 */
- (NSArray *) getHypedArtistsWithResultsLimit: (NSUInteger)numberOfResults Country: (NSString *)countryName andCity:(NSString *)cityName;


/**
 * Gets a list upcoming events in a specified area.
 *
 * @param latitude The latitude of the location at which to check for events.
 * @param longitude The longitude of the location at which to check for events.
 * @param distance This value specifies the radius around the specified location 
 * for which events should be returned.
 * @param limit The maximum number of Events to return.
 * @return an array of OLFMevent objects.
 */
- (NSArray *) getEventsInLocationWithLatitude:(float)latitude andLongitude:(float)longitude withinDistance:(float)distance withLimit:(NSUInteger)limit;


/**
 * Gets a list upcoming events in a specified area.
 *
 * A default value is used for the distance of the search radius.
 *
 * @param latitude The latitude of the location at which to check for events.
 * @param longitude The longitude of the location at which to check for events.
 * @param limit The maximum number of Events to return.
 * @return an array of OLFMevent objects.
 */
- (NSArray *) getEventsInLocationWithLatitude:(float)latitude andLongitude:(float)longitude withLimit:(NSUInteger)limit;


/**
 * Gets a list upcoming events in a specified area.
 *
 * @param country The name or 2-letter code for the country to find events in conforming to
 * the ISO 3166-1 specification
 * @param distance This value specifies the radius around the specified location
 * for which events should be returned.
 * @param limit The maximum number of Events to return.
 * @return an array of OLFMevent objects.
 */
- (NSArray *) getEventsInCountry:(NSString *)country withinDistance:(float)distance withLimit:(NSUInteger)limit;


/**
 * Gets a list upcoming events in a specified area.
 *
 * A default value is used for the distance of the search radius.
 *
 * @param country The name or 2-letter code for the country to find events in conforming to
 * the ISO 3166-1 specification
 * @param limit The maximum number of Events to return.
 * @return an array of OLFMevent objects.
 */
- (NSArray *) getEventsInCountry:(NSString *)country withLimit:(NSUInteger)limit;












@end
