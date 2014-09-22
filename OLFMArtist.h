//
//  OLFMArtist.h
//  Jive
//
//  Created by Odie Edo-Osagie on 11/06/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OLFMArtist : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableString *name;
@property (nonatomic, strong) NSMutableString *playCount;
@property (nonatomic, strong) NSMutableString *listenersCount;
@property (nonatomic, strong) NSMutableString *mbid; // MusicBrainz ID
@property (nonatomic, strong) NSMutableString *url;
@property (nonatomic, strong) NSMutableString *streamable;
@property (nonatomic, strong) NSMutableString *onTour;
@property (nonatomic, strong) NSMutableString *smallImageURL;
@property (nonatomic, strong) NSMutableString *mediumImageURL;
@property (nonatomic, strong) NSMutableString *largeImageURL;
@property (nonatomic, strong) NSMutableString *extraLargeImageURL;
@property (nonatomic, strong) NSMutableString *megaLargeImageURL;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, strong) NSMutableArray *similar;
@property (nonatomic, strong) NSMutableString *bioSummary;
@property (nonatomic, strong) NSMutableString *bioContent;
@property (nonatomic, strong) NSMutableString *yearFormed;


/**
 * Constructor for OLFMArtist object.
 *
 * Takes the name of the artist and creates an OLFMArtist with all the data for the artist
 * whose name was provided.
 *
 * @param artistName The name of the artist that is being modelled
 * @return OLFMArtist object with data for the artist
 * whose name was provided or nil if no data found.
 */
- (instancetype) initWithName: (NSString *)artistName;


/**
 * Connects to Last.fm and populates the calling OLFMTrack object's properties with the relevant
 * data
 */
- (void) fill;


/**
 * Returns a list of information on other artists similar to the calling one
 *
 * @return An array whose elements are NSMutableDictionary objects with the
 * following keys - "artistName", "mbid", "matchValue", "artistURL", "smallImageURL",
 * "mediumImageURL", "largeImageURL", "extraLargeImageURL" and "megaImageURL" with NSString values.
 * Returns nil if the calling artist has no name
 */
- (NSArray *) getSimilarArtists;



/**
 * Returns a list of information on the top tracks for the calling artist
 *
 * @return An array whose elements are NSMutableDictionary objects with the
 * following keys - "trackName", "artistName", "trackURL", "mbid", "smallImageURL",
 * "mediumImageURL", "largeImageURL", "extraLargeImageURL" and "matchValue" with NSString values.
 * Returns nil if the calling track has no name or artistName
 */
- (NSArray *) getTopTracks;


/**
 * Fetches a list of the calling artist's top albums
 *
 * @param limit The maximum numner of albums to be fetched.
 * @return An array whose elements are OLFMAlbum objects with the
 * following fields set - @a name , @a playcount , @a mbid , @a url , @a artistName ,
 * @a smallImageURL , @a mediumImageURL , @a largeImageURL and @a extraLargeImageURL.
 */
- (NSArray *) getTopAlbumsWithLimit:(NSUInteger) limit;



/**
 * Fetches a list of upcoming events for the calling Artist.
 *
 * @param limit The maximum number of Events to return.
 * @return An array whose elements are OLFMEvent objects.
 */
- (NSArray *) getEventsWithLimit:(int)limit;





@end
