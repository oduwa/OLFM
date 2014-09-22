//
//  OLFMManager.h
//  Jive
//
//  Created by Odie Edo-Osagie on 12/06/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "OLFMTrack.h"
#import "OLFMArtist.h"
#import "OLFMAlbum.h"

@interface OLFMManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) NSString *API_KEY;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;


/* Enum declaration to control the parsing of different xml responses */
typedef NS_ENUM(NSUInteger, ParseType){
    ParsingArtistInfo,
    ParsingTrackInfo,
    ParsingSimilarTracks,
    ParsingTrackSearch,
    ParsingArtistSearch,
    ParsingSimilarArtists,
    ParsingChartArtists,
    ParsingChartTracks,
};

+ (OLFMManager *) sharedManager;
+ (NSString *) escapeString:(NSString *)string;
- (void) setAPIKey: (NSString *) key;
- (NSString *) API_KEY;

@end
