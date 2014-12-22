//
//  OLFMAlbum.h
//  Jive
//
//  Created by Odie Edo-Osagie on 26/06/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLFMArtist.h"

@interface OLFMAlbum : NSObject <NSXMLParserDelegate>

/**
 * The name of the album
 */
@property (nonatomic, strong) NSMutableString *name;

/**
 * The name of the artist(s) responsible for the album
 */
@property (nonatomic, strong) NSMutableString *artistName;

/**
 * An OLFMArtist representation of the artis responsible for the album
 */
@property (nonatomic, strong) OLFMArtist *artist;

/**
 * Last.fm ID
 */
@property (nonatomic, strong) NSMutableString *LFMid;

/**
 * MusicBrainz ID. This can be used with their API if needed.
 */
@property (nonatomic, strong) NSMutableString *mbid;

/**
 * Album URL in Last.fm website
 */
@property (nonatomic, strong) NSMutableString *url;

/**
 * Album release date
 */
@property (nonatomic, strong) NSMutableString *releaseDate;

/**
 * URL for a small sized image of the album cover. Approx. 32x32
 */
@property (nonatomic, strong) NSMutableString *smallImageURL;

/**
 * URL for a medium sized image of the album cover. Approx. 64x64
 */
@property (nonatomic, strong) NSMutableString *mediumImageURL;

/**
 * URL for a large sized image of the album cover. Approx. 174x174
 */
@property (nonatomic, strong) NSMutableString *largeImageURL;

/**
 * URL for an extra large sized image of the album cover. Approx. 300x300
 */
@property (nonatomic, strong) NSMutableString *extraLargeImageURL;

/**
 * URL for a mega sized image of the album cover. Approx. 600x600
 */
@property (nonatomic, strong) NSMutableString *megaLargeImageURL;

/**
 * The number of people who have listened to this album on Last.fm
 */
@property (nonatomic, strong) NSMutableString *listenersCount;

/**
 * The number of times this album has been played on Last.fm
 */
@property (nonatomic, strong) NSMutableString *playCount;

/**
 * An array of OLFMTracks with name, trackURL, duration and mbid properties set.
 * If required, the remaining fields can be filled by calling the fill method.
 * The tracks are ordered in the array as they appear in the album. That is, tracks[0]
 * is track number 1 and so on.
 */
@property (nonatomic, strong) NSMutableArray *tracks;

/**
 * An array of (NSString *) objects where each string is tag/genre for the album
 */
@property (nonatomic, strong) NSMutableArray *tags;

/**
 * A summary/abstract of information about the album
 */
@property (nonatomic, strong) NSMutableString *albumInfoSummary;

/**
 * (Comprehensive) information about the album
 */
@property (nonatomic, strong) NSMutableString *albumInfoContent;



/**
 * Constructor for OLFMAlbum object.
 *
 * Takes the name of the album and artist and creates an OLFMAlbum with all the data for the album
 * whose name was provided.
 *
 * @param nameOfAlbum The name of the album that is being modelled
 * @param nameOfArtist The name of the artist that performs the track that is being modelled
 * @return OLFMAlbum object with data for the album whose name and artist was provided or nil if no data found.
 *
 */
- (instancetype) initWithName: (NSString *)nameOfAlbum andArtist: (NSString *)nameOfArtist;



/**
 * Returns an OLFMArtist object for the artist responsible for the track.
 *
 * @return OLFMArtist corresponding with the calling objects "artistName" property
 */
- (OLFMArtist *) getArtist;




/**
 * This method gets a list containing information and URLs where digital copies of the calling
 * album can be purchased.
 *
 * @param country This should be a string representing the country in which the album is to be bought
 * from. This could be the country name or the two character country code, as defined by
 * the ISO 3166-1 country names standard.
 *
 * @return an array containing dictionaries with the keys @a supplierName , @a supplierIconURL ,
 * @a buyLink , @a priceAmount , @a priceCurrency , @a priceCurrencyFormatted and @a isSearch
 * containing string values.
 * It may be worth noting that @a isSearch is a string value that is either 1 or 0 and is a sort of
 * "pseudo-boolean".
 */
- (NSArray *) getDigitalBuyLinksForCountry:(NSString *)country;




/**
 * This method gets a list containing information and URLs where physical copies of the calling
 * album can be purchased.
 *
 * @param country This should be a string representing the country in which the album is to be bought
 * from. This could be the country name or the two character country code, as defined by
 * the ISO 3166-1 country names standard.
 *
 * @return an array containing dictionaries with the keys @a supplierName , @a supplierIconURL ,
 * @a buyLink , @a priceAmount , @a priceCurrency , @a priceCurrencyFormatted and @a isSearch
 * containing string values.
 * It may be worth noting that @a isSearch is a string value that is either 1 or 0 and is a sort of
 * "pseudo-boolean".
 */
- (NSArray *) getPhysicalBuyLinksForCountry:(NSString *)country;
































@end
