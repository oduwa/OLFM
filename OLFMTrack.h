//
//  OLFMTrack.h
//  Jive
//
//  Created by Odie Edo-Osagie on 15/06/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLFMArtist.h"
#import "OLFMAlbum.h"

@interface OLFMTrack : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableString *LFMid;
@property (nonatomic, strong) NSMutableString *mbid;
@property (nonatomic, strong) NSMutableString *name;
@property (nonatomic, strong) NSMutableString *trackURL;
@property (nonatomic, strong) NSMutableString *smallTrackCoverArtURL;
@property (nonatomic, strong) NSMutableString *mediumTrackCoverArtURL;
@property (nonatomic, strong) NSMutableString *largeTrackCoverArtURL;
@property (nonatomic, strong) NSMutableString *extraLargeTrackCoverArtURL;
@property (nonatomic, strong) NSMutableString *duration;
@property (nonatomic, strong) NSMutableString *listenersCount;
@property (nonatomic, strong) NSMutableString *playCount;
@property (nonatomic, strong) NSMutableString *trackSummary;
@property (nonatomic, strong) NSMutableString *trackInfo;
@property (nonatomic, strong) OLFMArtist *artist;
@property (nonatomic, strong) NSMutableString *artistName;
@property (nonatomic, strong) OLFMAlbum *album;
@property (nonatomic, strong) NSMutableString *albumName;
@property (nonatomic, strong) NSMutableArray *tags;


/**
 * Constructor for OLFMTrack object.
 *
 * Takes the name of the track and artist and creates an OLFMTrack with all the data for the track
 * whose name was provided.
 *
 * @param nameOfTrack The name of the track that is being modelled
 * @param nameOfArtist The name of the artist that performs the track that is being modelled
 * @return OLFMTrack object with data for the track whose name and artist was provided or nil if no data found.
 *
 */
- (instancetype) initWithName: (NSString *)nameOfTrack andArtist: (NSString *)nameOfArtist;


/**
 * Returns an OLFMArtist object for the artist responsible for the track.
 *
 * @return OLFMArtist corresponding with the calling objects "artistName" property
 */
- (OLFMArtist *) getArtist;


/**
 * Returns an OLFAlbum object for the album the track is from.
 *
 * @return OLFAlbum corresponding with the calling objects "albumName" property
 */
- (OLFMAlbum *) getAlbum;


/**
 * Returns a list of information on other tracks similar to the calling one
 *
 * @return An array whose elements are NSMutableDictionary objects with the
 * following keys - "trackName", "artistName", "trackURL", "mbid", "smallImageURL",
 * "mediumImageURL", "largeImageURL", "extraLargeImageURL" and "matchValue" with NSString values.
 * Returns nil if the calling track has no name or artistName
 */
- (NSArray *) getSimilarTracks;


/**
 * Connects to Last.fm and populates the calling OLFMTrack object's properties with the relevant
 * data
 */
- (void) fill;














@end
