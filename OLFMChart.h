//
//  OLFMChart.h
//  Jive
//
//  Created by Odie Edo-Osagie on 11/06/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OLFMChart : NSObject <NSXMLParserDelegate>


/**
 * Creates a singleton instance of a OLFMGeo object from which methods are called
 *
 * @return OLFMChart singleton instance
 */
+ (OLFMChart *) chart;


/**
 * Get the top artists in the world charts.
 *
 * @param numberOfResults A whole number specifiying the total number of artists the method should return
 *
 * @return an array of OLFMArtist objects with the following fields set - @a name and @a extraLargeImageURL.
 */
- (NSArray *) getTopArtistsWithResultsLimit: (NSUInteger) numberOfResults;



/**
 * Get the top up and coming artists in the world.
 *
 * @param numberOfResults A whole number specifiying the total number of artists the method should return
 *
 * @return an array of OLFMArtist objects with the following fields set - @a name and @a extraLargeImageURL.
 */
- (NSArray *) getHypedArtistsWithResultsLimit: (NSUInteger) numberOfResults;


/**
 * Get the top tracks in the world charts.
 *
 * @param numberOfResults A whole number specifiying the total number of tracks the method should return
 *
 * @return an array of OLFMTrack objects with the following fields set - @a name, @a artistName,
 * and @a trackURL.
 */
- (NSArray *) getTopTracksWithResultsLimit: (NSUInteger) numberOfResults;


/**
 * Get the top up and coming tracks in the world.
 *
 * @param numberOfResults A whole number specifiying the total number of tracks the method should return
 *
 * @return an array of OLFMTrack objects with the following fields set - @a name, @a artistName,
 * and @a trackURL.
 */
- (NSArray *) getHypedTracksWithResultsLimit: (NSUInteger) numberOfResults;













@end
