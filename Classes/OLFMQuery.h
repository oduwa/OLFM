//
//  OLFMQuery.h
//  Jive
//
//  Created by Odie Edo-Osagie on 12/07/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLFMManager.h"

@interface OLFMQuery : NSObject <NSXMLParserDelegate>


/**
 * Creates a singleton instance of a OLFMQuery object from which methods are called
 *
 * @return OLFMQuery singleton instance
 */
+ (OLFMQuery *) Query;



/**
 * Returns a list of OLFMTrack objects matching the track name and artist specified.
 *
 * @param nameOfTrack The name of the track to find
 * @param nameOfArtist The name of the artist of the track to find
 *
 * @return An array of OLFMTrack objects with the
 * following fields set - "name", "artistName", "trackURL", "mbid", "smallTrackCoverArtURL",
 * "mediumTrackCoverArtURL", "largeTrackCoverArtURL" and "extralargeTrackCoverArtURL".
 * Returns nil if the calling track has no name or artistName
 */
- (NSArray *) searchForTrackWithName: (NSString *)nameOfTrack withArtistName: (NSString *)nameOfArtist;



/**
 * Returns a list of OLFMTrack objects matching the track name specified.
 *
 * @param nameOfTrack The name of the track to find
 *
 * @return An array of OLFMTrack objects with the
 * following fields set - "name", "artistName", "trackURL", "mbid", "smallTrackCoverArtURL",
 * "mediumTrackCoverArtURL", "largeTrackCoverArtURL" and "extralargeTrackCoverArtURL".
 * Returns nil if the calling track has no name or artistName
 */
- (NSArray *) searchForTrackWithName: (NSString *)nameOfTrack;



/**
 * Returns a list of information on other tracks similar to the one specified
 *
 * @param nameOfTrack The name of the track for which similar tracks are required
 * @param nameOfArtist The name of the artist(s) responsible for the track for which similar tracks are required
 *
 * @return An array whose elements are NSMutableDictionary objects with the
 * following keys - "trackName", "artistName", "trackURL", "mbid", "smallImageURL",
 * "mediumImageURL", "largeImageURL", "extraLargeImageURL" and "matchValue" with NSString values.
 * Returns nil if the calling track has no name or artistName
 */
- (NSArray *) getSimilarTracksToTrackWithName: (NSString *)nameOfTrack andArtist: (NSString *)nameOfArtist;



/**
 * Returns a list of information on a specified artist's top tracks
 *
 * @param nameOfTrack The name of the track for which similar tracks are required
 *
 * @return An array whose elements are NSMutableDictionary objects with the
 * following keys - "trackName", "artistName", "trackURL", "mbid", "smallImageURL",
 * "mediumImageURL", "largeImageURL", "extraLargeImageURL" and "matchValue" with NSString values.
 * Returns nil if the calling track has no name or artistName
 */
- (NSArray *) getTopTracksForArtist: (NSString *)nameOfArtist;


/**
 * Fetches a list of the calling artist's top albums
 *
 * @param artistName The name of the artist whose top albums are to be fetched.
 * @param limit The maximum numner of albums to be fetched.
 * @return An array whose elements are OLFMAlbum objects with the
 * following fields set - @a name , @a playcount , @a mbid , @a url , @a artistName ,
 * @a smallImageURL , @a mediumImageURL , @a largeImageURL and @a extraLargeImageURL.
 */
- (NSArray *) getTopAlbumsForArtist:(NSString *)artistName WithLimit:(int)limit;


/**
 * Returns a list of OLFMArtist objects matching the artist specified.
 *
 * @param nameOfArtist The name of the artist that is the subject of the search
 *
 * @return An array whose elements are @b OLFMArtist objects with the
 * following fields set - "name", "url", "mbid", "smallImageURL",
 * "mediumImageURL", "largeImageURL" and "extraLargeImageURL".
 * Returns nil if the calling track has no name or artistName
 */
- (NSArray *) searchForArtistWithName: (NSString *)nameOfArtist;


/**
 * Returns a list of information on other tracks similar to the one specified
 *
 * @param nameOfArtist The name of the artist(s) for which similar tracks are required
 *
 * @return An array whose elements are OLFMArtist objects with the
 * following fields set - @a name, @a mbid, @a url, @a smallImageURL,
 * @a mediumImageURL, @a largeImageURL, @a extraLargeImageURL and @a megaImageURL with NSString values.
 * Returns nil if the calling artist has no name
 */
- (NSArray *) getSimilarArtistsToArtistWithName:(NSString *)nameOfArtist;



/**
 * Returns a list of OLFMAlbum objects matching the artist specified.
 *
 * @param nameOfAlbum The name of the album that is the subject of the search
 *
 * @return An array whose elements are OLFMAlbum objects with the
 * following fields set - "name", "url", "mbid", "LFMid", "smallImageURL"
 * "mediumImageURL", "largeImageURL" and "extraLargeImageURL" and "artistName".
 * Returns nil if the calling track has no name or artistName
 */
- (NSArray *) searchForAlbumWithName: (NSString *)nameOfAlbum;



/**
 * Fetches a list of upcoming events for a specified Artist.
 *
 * @param artistName The name of the artist to get events for
 * @param limit The maximum number of Events to return.
 * @return An array whose elements are OLFMEvent objects.
 */
- (NSArray *) getEventsForArtist:(NSString *)artistName WithLimit:(int)limit;




@end
