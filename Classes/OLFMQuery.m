//
//  OLFMQuery.m
//  Jive
//
//  Created by Odie Edo-Osagie on 12/07/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import "OLFMQuery.h"
#import "OLFMEvent.h"

static OLFMQuery *globalInstance = nil;

@implementation OLFMQuery{
    NSXMLParser *parser;
    NSString *element;
    NSString *attribute;
    ParseType parseType;
    
    /* For handling multiple occurences of "name", "url" and "mbid" elements */
    BOOL gotTrackName;
    BOOL gotArtistName;
    BOOL gotTrackURL;
    BOOL gotTrackMBID;
    BOOL handledSimilarArtist;
    BOOL foundImage;
    
    /* For handling tags */
    BOOL handledTag;
    NSMutableString *tagName;
    
    /* For obtaining similar tracks */
    NSMutableArray *similarTracks;
    NSMutableDictionary *similarTrackData;
    NSMutableString *similarTrackName;
    NSMutableString *similarTrackArtist;
    NSMutableString *similarTrackURL;
    NSMutableString *similarTrackMBID;
    NSMutableString *similarTrackMatchValue;
    NSMutableString *smallTrackImageURL;
    NSMutableString *mediumTrackImageURL;
    NSMutableString *largeTrackImageURL;
    NSMutableString *extralargeTrackImageURL;
    
    /* For obtaining similar artists */
    NSMutableArray *similars;
    NSMutableDictionary *similarArtist;
    NSMutableString *similarArtistName;
    NSMutableString *similarArtistURL;
    NSMutableString *similarArtistMBID;
    NSMutableString *similarArtistMatchValue;
    NSMutableString *similarArtistImageURL;
}



+ (OLFMQuery *) Query
{
    @synchronized(self)
    {
        if (!globalInstance)
            globalInstance = [[self alloc] init];
        
        return globalInstance;
    }
    
    return globalInstance;
}

- (instancetype) init
{
    self = [super init];
    
    if(self){
        similarTracks = [[NSMutableArray alloc] init];
        similarTrackData = [[NSMutableDictionary alloc] init];
        similarTrackName = [[NSMutableString alloc] init];
        similarTrackArtist = [[NSMutableString alloc] init];
        similarTrackURL = [[NSMutableString alloc] init];
        similarTrackMBID = [[NSMutableString alloc] init];
        similarTrackMatchValue = [[NSMutableString alloc] init];
        smallTrackImageURL = [[NSMutableString alloc] init];
        mediumTrackImageURL = [[NSMutableString alloc] init];
        largeTrackImageURL = [[NSMutableString alloc] init];
        extralargeTrackImageURL = [[NSMutableString alloc] init];
        
        similars = [[NSMutableArray alloc] init];
        similarArtist = [[NSMutableDictionary alloc] init];
        similarArtistName = [[NSMutableString alloc] init];
        similarArtistURL = [[NSMutableString alloc] init];
        similarArtistMBID = [[NSMutableString alloc] init];
        similarArtistMatchValue = [[NSMutableString alloc] init];
        similarArtistImageURL = [[NSMutableString alloc] init];
    }
    
    return self;
}


#pragma mark - Instance Methods

- (NSArray *) searchForTrackWithName: (NSString *)nameOfTrack withArtistName: (NSString *)nameOfArtist
{
    similarTracks = [[NSMutableArray alloc] init];
    
    NSString *APIKey = [OLFMManager sharedManager].API_KEY;
    
    if(nameOfTrack == nil || nameOfArtist == nil){
        NSLog(@"WARNING: Null Parameter");
        return nil;
    }
    
    if([nameOfTrack isEqualToString:@""] || [nameOfArtist isEqualToString:@""]){
        NSLog(@"WARNING: Empty Parameter");
        return nil;
    }
    
    NSString *name = [nameOfTrack stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    name = [OLFMManager escapeString:name];
    NSString *artist = [nameOfArtist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    artist = [OLFMManager escapeString:artist];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=track.search&artist=%@&track=%@&api_key=%@&limit=10", artist, name, APIKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parseType = ParsingTrackSearch;
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    [parser parse];
    NSLog(@"URL2: %@\n", urlString);
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *dict in similarTracks){
        OLFMTrack *track = [[OLFMTrack alloc] init];
        
        track.artistName = dict[@"artistName"];
        track.name = dict[@"trackName"];
        track.trackURL = dict[@"trackURL"];
        track.mbid = dict[@"mbid"];
        
        if(dict[@"smallImageURL"]){
            track.smallTrackCoverArtURL = dict[@"smallImageURL"];
        }
        if(dict[@"mediumImageURL"]){
            track.mediumTrackCoverArtURL = dict[@"mediumImageURL"];
        }
        if(dict[@"largeImageURL"]){
            track.largeTrackCoverArtURL = dict[@"largeImageURL"];
        }
        if(dict[@"extraLargeImageURL"]){
            track.extraLargeTrackCoverArtURL = dict[@"extraLargeImageURL"];
        }
        
        [result addObject:track];
    }
    
    return result;
}

- (void) searchForTrackWithName: (NSString *)nameOfTrack withArtistName: (NSString *)nameOfArtist completion:(void (^)(NSArray *results))completion
{
    dispatch_queue_t backgroundQueue = dispatch_queue_create("Search Bakground Queue",NULL);
    
    dispatch_async(backgroundQueue, ^{
        NSArray *results = [self searchForTrackWithName:nameOfTrack withArtistName:nameOfArtist];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(results);
        });
    });
}


- (NSArray *) searchForTrackWithName: (NSString *)nameOfTrack
{
    similarTracks = [[NSMutableArray alloc] init];
    
    NSString *APIKey = [OLFMManager sharedManager].API_KEY;
    
    if(nameOfTrack == nil){
        NSLog(@"WARNING: Null Parameter");
        return nil;
    }
    
    if([nameOfTrack isEqualToString:@""]){
        NSLog(@"WARNING: Empty Parameter");
        return nil;
    }
    
    NSString *name = [nameOfTrack stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    name = [OLFMManager escapeString:name];

    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=track.search&track=%@&api_key=%@&limit=10", name, APIKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parseType = ParsingTrackSearch;
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    [parser parse];
    NSLog(@"URL2: %@\n", urlString);
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *dict in similarTracks){
        OLFMTrack *track = [[OLFMTrack alloc] init];
        
        track.artistName = dict[@"artistName"];
        track.name = dict[@"trackName"];
        track.trackURL = dict[@"trackURL"];
        track.mbid = dict[@"mbid"];
        
        if(dict[@"smallImageURL"]){
            track.smallTrackCoverArtURL = dict[@"smallImageURL"];
        }
        if(dict[@"mediumImageURL"]){
            track.mediumTrackCoverArtURL = dict[@"mediumImageURL"];
        }
        if(dict[@"largeImageURL"]){
            track.largeTrackCoverArtURL = dict[@"largeImageURL"];
        }
        if(dict[@"extraLargeImageURL"]){
            track.extraLargeTrackCoverArtURL = dict[@"extraLargeImageURL"];
        }
        
        [result addObject:track];
    }
    
    return result;
}

- (void) searchForTrackWithName: (NSString *)nameOfTrack completion:(void (^)(NSArray *results))completion
{
    dispatch_queue_t backgroundQueue = dispatch_queue_create("Search Bakground Queue",NULL);
    
    dispatch_async(backgroundQueue, ^{
        NSArray *results = [self searchForTrackWithName:nameOfTrack];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(results);
        });
    });
}



- (NSArray *) getSimilarTracksToTrackWithName: (NSString *)nameOfTrack andArtist: (NSString *)nameOfArtist
{
    similarTracks = [[NSMutableArray alloc] init];
    
    NSString *APIKey = [OLFMManager sharedManager].API_KEY;
    
    if(nameOfTrack == nil || nameOfArtist == nil){
        NSLog(@"WARNING: Null Parameter");
        return nil;
    }
    
    if([nameOfTrack isEqualToString:@""] || [nameOfArtist isEqualToString:@""]){
        NSLog(@"WARNING: Empty Parameter");
        return nil;
    }
    
    NSString *name = [nameOfTrack stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    name = [OLFMManager escapeString:name];
    NSString *artist = [nameOfArtist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    artist = [OLFMManager escapeString:artist];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=track.getSimilar&artist=%@&track=%@&api_key=%@&limit=10&autocorrect=1", artist, name, APIKey];

    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parseType = ParsingSimilarTracks;
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    [parser parse];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *dict in similarTracks){
        OLFMTrack *track = [[OLFMTrack alloc] init];
        track.name = dict[@"trackName"];
        track.artistName = dict[@"artistName"];
        track.trackURL = dict[@"trackURL"];
        track.mbid = dict[@"mbid"];
        track.smallTrackCoverArtURL = dict[@"smallImageURL"];
        track.mediumTrackCoverArtURL = dict[@"mediumImageURL"];
        track.largeTrackCoverArtURL = dict[@"largeImageURL"];
        track.extraLargeTrackCoverArtURL = dict[@"extraLargeImageURL"];
        //track.matchValue = dict[@"matchValue"];
        
        [result addObject:track];
    }
    
    return result;
}

- (NSArray *) getSimilarArtistsToArtistWithName:(NSString *)nameOfArtist
{
    OLFMArtist *artist = [[OLFMArtist alloc] init];
    artist.name = (NSMutableString *) nameOfArtist;
    return [artist getSimilarArtists];
}



- (NSArray *) getTopTracksForArtist: (NSString *)nameOfArtist
{
    similarTracks = [[NSMutableArray alloc] init];
    
    NSString *APIKey = [OLFMManager sharedManager].API_KEY;
    
    if(nameOfArtist == nil){
        NSLog(@"WARNING: Null Parameter");
        return nil;
    }
    
    if([nameOfArtist isEqualToString:@""]){
        NSLog(@"WARNING: Empty Parameter");
        return nil;
    }
    
    NSString *artist = [nameOfArtist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    artist = [OLFMManager escapeString:artist];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=%@&api_key=%@&autocorrect=1&limit=10", artist, APIKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parseType = ParsingSimilarTracks;
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    [parser parse];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *dict in similarTracks){
        OLFMTrack *track = [[OLFMTrack alloc] init];
        track.name = dict[@"trackName"];
        track.artistName = dict[@"artistName"];
        track.trackURL = dict[@"url"];
        track.mbid = dict[@"mbid"];
        track.smallTrackCoverArtURL = dict[@"smallImageURL"];
        track.mediumTrackCoverArtURL = dict[@"mediumImageURL"];
        track.largeTrackCoverArtURL = dict[@"largeImageURL"];
        track.extraLargeTrackCoverArtURL = dict[@"extraLargeImageURL"];
        [result addObject:track];
    }

    return result;
}


- (NSArray *) getTopAlbumsForArtist:(NSString *)artistName WithLimit:(int)limit
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSError *error;
    
    if(artistName == nil){
        NSLog(@"WARNING: Null Parameter");
        return nil;
    }
    
    if([artistName isEqualToString:@""]){
        NSLog(@"WARNING: Empty Parameter");
        return nil;
    }
    
    /* Escaping */
    artistName = [artistName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    artistName = [OLFMManager escapeString:artistName];
    
    /* Get event info as JSON and store as a dictionary */
    NSString *API_KEY = [[OLFMManager sharedManager] API_KEY];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.gettopalbums&artist=%@&api_key=%@&limit=%d&autocorrect=1&format=json",
                           artistName, API_KEY, limit];
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if(error){
        NSLog(@"<ERROR> AN ERROR OCCURED FETCHING EVENT DATA");
        return nil;
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if(error){
        NSLog(@"<ERROR> AN ERROR OCCURED FETCHING EVENT DATA");
        return nil;
    }
    
    if([json[@"topalbums"][@"album"] isKindOfClass:[NSArray class]]){
        NSArray *result = json[@"topalbums"][@"album"];
        
        for(int i = 0; i < [result count]; i++){
            NSDictionary *albumDictionary = result[i];
            OLFMAlbum *album = [[OLFMAlbum alloc] init];
            
            if([albumDictionary[@"artist"] isKindOfClass:[NSDictionary class]]){
                album.artistName = albumDictionary[@"artist"][@"name"];
            }
            
            if([albumDictionary[@"image"] isKindOfClass:[NSArray class]]){
                NSArray *imagesArray = albumDictionary[@"image"];
                for(int i = 0; i < [imagesArray count]; i++){
                    if([imagesArray[i] isKindOfClass:[NSDictionary class]]){
                        NSDictionary *imageDictionary = imagesArray[i];
                        if([imageDictionary[@"size"] isEqualToString:@"small"]){
                            album.smallImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"medium"]){
                            album.mediumImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"large"]){
                            album.largeImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"extralarge"]){
                            album.extraLargeImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"mega"]){
                            album.megaLargeImageURL = imageDictionary[@"#text"];
                        }
                    }
                }
            }
            
            album.mbid = albumDictionary[@"mbid"];
            album.name = albumDictionary[@"name"];
            album.playCount = albumDictionary[@"playcount"];
            album.url = albumDictionary[@"url"];
            [results addObject:album];
        }
        
    }
    else if([json[@"topalbums"][@"album"] isKindOfClass:[NSDictionary class]]){
        NSDictionary *albumDictionary = json[@"topalbums"][@"album"];
        OLFMAlbum *album = [[OLFMAlbum alloc] init];
        
        if([albumDictionary[@"artist"] isKindOfClass:[NSDictionary class]]){
            album.artistName = albumDictionary[@"artist"][@"name"];
        }
        
        if([albumDictionary[@"image"] isKindOfClass:[NSArray class]]){
            NSArray *imagesArray = albumDictionary[@"image"];
            for(int i = 0; i < [imagesArray count]; i++){
                if([imagesArray[i] isKindOfClass:[NSDictionary class]]){
                    NSDictionary *imageDictionary = imagesArray[i];
                    if([imageDictionary[@"size"] isEqualToString:@"small"]){
                        album.smallImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"medium"]){
                        album.mediumImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"large"]){
                        album.largeImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"extralarge"]){
                        album.extraLargeImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"mega"]){
                        album.megaLargeImageURL = imageDictionary[@"#text"];
                    }
                }
            }
        }
        
        album.mbid = albumDictionary[@"mbid"];
        album.name = albumDictionary[@"name"];
        album.playCount = albumDictionary[@"playcount"];
        album.url = albumDictionary[@"url"];
        [results addObject:album];
    }
    
    return results;
}


- (NSArray *) searchForArtistWithName: (NSString *)nameOfArtist
{
    similars = [[NSMutableArray alloc] init];
    
    NSString *APIKey = [OLFMManager sharedManager].API_KEY;
    
    if([nameOfArtist isEqualToString:@""]){
        NSLog(@"WARNING: Empty Parameter");
        return nil;
    }
    
    /* Escaping space characters */
    nameOfArtist = [nameOfArtist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    nameOfArtist = [OLFMManager escapeString:nameOfArtist];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.search&artist=%@&api_key=%@&limit=10", nameOfArtist, APIKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parseType = ParsingArtistSearch;
    
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *dict in similars){
        //[result addObject:dict];
        OLFMArtist *artist = [[OLFMArtist alloc] init];
        artist.name = dict[@"artistName"];
        artist.url = dict[@"artistURL"];
        artist.mbid = dict[@"mbid"];
        
        NSString *trimmedSmallImage = [dict[@"smallImageURL"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        artist.smallImageURL = [NSMutableString stringWithString:trimmedSmallImage];
        
        NSString *trimmedMediumImage = [dict[@"mediumImageURL"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        artist.mediumImageURL = [NSMutableString stringWithString:trimmedMediumImage];
        
        NSString *trimmedLargeImage = [dict[@"largeImageURL"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        artist.largeImageURL = [NSMutableString stringWithString:trimmedLargeImage];
        
        NSString *trimmedExtraLargeImage = [dict[@"extraLargeImageURL"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        artist.extraLargeImageURL = [NSMutableString stringWithString:trimmedExtraLargeImage];

        if(dict[@"megaLargeImageURL"]){
            NSString *trimmedMegaImage = [dict[@"megaLargeImageURL"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            artist.megaLargeImageURL = [NSMutableString stringWithString:trimmedMegaImage];
        }
        [result addObject:artist];
    }
    
    return result;
}


- (NSArray *) searchForAlbumWithName:(NSString *)nameOfAlbum
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *albumArray;
    NSError* error;
    
    if([nameOfAlbum isEqualToString:@""]){
        NSLog(@"WARNING: Empty Parameter");
    }
    
    if(nameOfAlbum == nil){
        NSLog(@"WARNING: NULL Parameter");
    }
    
    NSString *APIKey = [OLFMManager sharedManager].API_KEY;
    
    /* Escaping spaces */
    nameOfAlbum = [nameOfAlbum stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    nameOfAlbum = [OLFMManager escapeString:nameOfAlbum];
    
    /* Fetching JSON data */
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=album.search&album=%@&api_key=%@&format=json", nameOfAlbum, APIKey];
    NSURL *url = [NSURL URLWithString:urlString];
    NSData* data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if(!error){
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if(error){
            NSLog(@"ERROR SEARCHING ALBUM: %@", error);
            return result;
        }
        
        NSString *resultsCountString = json[@"results"][@"opensearch:totalResults"];
        int resultsCount = [resultsCountString intValue];
        
        if(resultsCount > 0){
            /* if only one result and album is a dictionary */
            if([json[@"results"][@"albummatches"][@"album"] class] == [json[@"results"] class]){
                albumArray = @[json[@"results"][@"albummatches"][@"album"]];
            }
            else {
                albumArray = json[@"results"][@"albummatches"][@"album"];
            }
            
            
            for(NSDictionary *albumDictionary in albumArray){
                OLFMAlbum *album = [[OLFMAlbum alloc] init];
                album.artistName = albumDictionary[@"artist"];
                album.LFMid = albumDictionary[@"id"];
                
                NSArray *imageArray = albumDictionary[@"image"];
                for(NSDictionary *imageDictionary in imageArray){
                    if([imageDictionary[@"size"] isEqualToString:@"small"]){
                        album.smallImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"medium"]){
                        album.mediumImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"large"]){
                        album.largeImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"extralarge"]){
                        album.extraLargeImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"mega"]){
                        album.megaLargeImageURL = imageDictionary[@"#text"];
                    }
                }
                
                album.mbid = albumDictionary[@"mbid"];
                album.name = albumDictionary[@"name"];
                album.url = albumDictionary[@"url"];
                
                [result addObject:album];
            }
        }

    }
    else{
        NSLog(@"ERROR SEARCHING ALBUM: %@", error);
        return result;
    }
    
    
    
    return result;
}



- (NSArray *) getEventsForArtist:(NSString *)artistName WithLimit:(int)limit
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSError *error;
    
    if([artistName isEqualToString:@""]){
        NSLog(@"<ERROR> ARTIST NAME IS EMPTY.");
        return nil;
    }
    
    if(!artistName){
        NSLog(@"<ERROR> ARTIST NAME IS NULL.");
        return nil;
    }
    
    /* Escaping */
    artistName = [artistName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    artistName = [OLFMManager escapeString:artistName];
    
    /* Get event info as JSON and store as a dictionary */
    NSString *API_KEY = [[OLFMManager sharedManager] API_KEY];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.getevents&artist=%@&api_key=%@&limit=%d&autocorrect=1&format=json",
                           artistName, API_KEY, limit];
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if(error){
        NSLog(@"<ERROR> AN ERROR OCCURED FETCHING EVENT DATA");
        return nil;
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if(error){
        NSLog(@"<ERROR> AN ERROR OCCURED FETCHING EVENT DATA");
        return nil;
    }
    
    if([json[@"events"][@"event"] isKindOfClass:[NSArray class]]){
        NSArray *results = json[@"events"][@"event"];
        
        for(NSDictionary *eventDictionary in results){
            OLFMEvent *event = [[OLFMEvent alloc] init];
            
            if([eventDictionary[@"artists"] isKindOfClass:[NSDictionary class]]){
                event.headliner.name = eventDictionary[@"artists"][@"headliner"];
                if([eventDictionary[@"artists"][@"artist"] isKindOfClass:[NSArray class]]){
                    event.artistNames = eventDictionary[@"artists"][@"artist"];
                }
                else{
                    [event.artistNames addObject:eventDictionary[@"artists"][@"artist"]];
                }
                
            }
            
            event.attendanceCount = eventDictionary[@"attendance"];
            event.eventDescription = eventDictionary[@"description"];
            event.eventID = eventDictionary[@"id"];
            
            if([eventDictionary[@"image"] isKindOfClass:[NSArray class]]){
                NSArray *imagesArray = eventDictionary[@"image"];
                for(int i = 0; i < [imagesArray count]; i++){
                    if([imagesArray[i] isKindOfClass:[NSDictionary class]]){
                        NSDictionary *imageDictionary = imagesArray[i];
                        if([imageDictionary[@"size"] isEqualToString:@"small"]){
                            event.smallImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"medium"]){
                            event.mediumImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"large"]){
                            event.largeImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"extralarge"]){
                            event.extraLargeImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"mega"]){
                            event.megaLargeImageURL = imageDictionary[@"#text"];
                        }
                    }
                }
            }
            
            event.reviews = eventDictionary[@"reviews"];
            event.startDate = eventDictionary[@"startDate"];
            
            if([eventDictionary[@"tickets"] isKindOfClass:[NSDictionary class]]){
                // TODO: Not yet sure how ticket data is stored. Couldnt find examples
            }
            else if([eventDictionary[@"tickets"] isKindOfClass:[NSArray class]]){
                // TODO: Not yet sure how ticket data is stored. Couldnt find examples
            }
            
            event.eventTitle = eventDictionary[@"title"];
            event.URL = eventDictionary[@"url"];
            
            if([eventDictionary[@"venue"] isKindOfClass:[NSDictionary class]]){
                OLFMVenue *venue = [[OLFMVenue alloc] init];
                venue.venueID = eventDictionary[@"venue"][@"id"];
                
                if([eventDictionary[@"venue"][@"image"] isKindOfClass:[NSArray class]]){
                    NSArray *imagesArray = eventDictionary[@"venue"][@"image"];
                    for(int i = 0; i < [imagesArray count]; i++){
                        if([imagesArray[i] isKindOfClass:[NSDictionary class]]){
                            NSDictionary *imageDictionary = imagesArray[i];
                            if([imageDictionary[@"size"] isEqualToString:@"small"]){
                                venue.smallImageURL = imageDictionary[@"#text"];
                            }
                            else if([imageDictionary[@"size"] isEqualToString:@"medium"]){
                                venue.mediumImageURL = imageDictionary[@"#text"];
                            }
                            else if([imageDictionary[@"size"] isEqualToString:@"large"]){
                                venue.largeImageURL = imageDictionary[@"#text"];
                            }
                            else if([imageDictionary[@"size"] isEqualToString:@"extralarge"]){
                                venue.extraLargeImageURL = imageDictionary[@"#text"];
                            }
                            else if([imageDictionary[@"size"] isEqualToString:@"mega"]){
                                venue.megaLargeImageURL = imageDictionary[@"#text"];
                            }
                        }
                    }
                }
                
                if([eventDictionary[@"venue"][@"location"] isKindOfClass:[NSDictionary class]]){
                    venue.city = eventDictionary[@"venue"][@"location"][@"city"];
                    venue.country = eventDictionary[@"venue"][@"location"][@"country"];
                    if([eventDictionary[@"venue"][@"location"][@"geo:point"] isKindOfClass:[NSDictionary class]]){
                        NSString *lat = eventDictionary[@"venue"][@"location"][@"geo:point"][@"geo:lat"];
                        NSString *lon = eventDictionary[@"venue"][@"location"][@"geo:point"][@"geo:long"];
                        venue.location = (OLFMGeoLocation){.latitude=[lat floatValue], .longitude=[lon floatValue]};
                    }
                    venue.postalCode = eventDictionary[@"venue"][@"location"][@"postalcode"];
                    venue.street = eventDictionary[@"venue"][@"location"][@"street"];
                }
                
                venue.venueName = eventDictionary[@"venue"][@"name"];
                venue.phoneNumber = eventDictionary[@"venue"][@"phonenumber"];
                venue.url = eventDictionary[@"venue"][@"url"];
                venue.website = eventDictionary[@"venue"][@"website"];
                event.venue = venue;
            }
            
            [result addObject:event];
        }
        
    }
    else if([json[@"events"][@"event"] isKindOfClass:[NSDictionary class]]){
        
        NSDictionary *eventDictionary = json[@"events"][@"event"];
        
        OLFMEvent *event = [[OLFMEvent alloc] init];
        
        if([eventDictionary[@"artists"] isKindOfClass:[NSDictionary class]]){
            event.headliner.name = eventDictionary[@"artists"][@"headliner"];
            if([eventDictionary[@"artists"][@"artist"] isKindOfClass:[NSArray class]]){
                event.artistNames = eventDictionary[@"artists"][@"artist"];
            }
            else{
                [event.artistNames addObject:eventDictionary[@"artists"][@"artist"]];
            }
            
        }
        
        event.attendanceCount = eventDictionary[@"attendance"];
        event.eventDescription = eventDictionary[@"description"];
        event.eventID = eventDictionary[@"id"];
        
        if([eventDictionary[@"image"] isKindOfClass:[NSArray class]]){
            NSArray *imagesArray = eventDictionary[@"image"];
            for(int i = 0; i < [imagesArray count]; i++){
                if([imagesArray[i] isKindOfClass:[NSDictionary class]]){
                    NSDictionary *imageDictionary = imagesArray[i];
                    if([imageDictionary[@"size"] isEqualToString:@"small"]){
                        event.smallImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"medium"]){
                        event.mediumImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"large"]){
                        event.largeImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"extralarge"]){
                        event.extraLargeImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"mega"]){
                        event.megaLargeImageURL = imageDictionary[@"#text"];
                    }
                }
            }
        }
        
        event.reviews = eventDictionary[@"reviews"];
        event.startDate = eventDictionary[@"startDate"];
        
        if([eventDictionary[@"tickets"] isKindOfClass:[NSDictionary class]]){
            // Not yet sure how ticket data is stored. Couldnt find examples
            NSLog(@"TIIIIIICCCCCKKKKKKKKEEEEEEEEEEETTTTTTTSSSSSsSSS: %@", eventDictionary[@"tickets"]);
        }
        else if([eventDictionary[@"tickets"] isKindOfClass:[NSArray class]]){
            // Not yet sure how ticket data is stored. Couldnt find examples
            NSLog(@"TIIIIIICCCCCKKKKKKKKEEEEEEEEEEETTTTTTTSSSSSsSSS: %@", eventDictionary[@"tickets"]);
        }
        
        event.eventTitle = eventDictionary[@"title"];
        event.URL = eventDictionary[@"url"];
        
        if([eventDictionary[@"venue"] isKindOfClass:[NSDictionary class]]){
            OLFMVenue *venue = [[OLFMVenue alloc] init];
            venue.venueID = eventDictionary[@"venue"][@"id"];
            
            if([eventDictionary[@"venue"][@"image"] isKindOfClass:[NSArray class]]){
                NSArray *imagesArray = eventDictionary[@"venue"][@"image"];
                for(int i = 0; i < [imagesArray count]; i++){
                    if([imagesArray[i] isKindOfClass:[NSDictionary class]]){
                        NSDictionary *imageDictionary = imagesArray[i];
                        if([imageDictionary[@"size"] isEqualToString:@"small"]){
                            venue.smallImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"medium"]){
                            venue.mediumImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"large"]){
                            venue.largeImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"extralarge"]){
                            venue.extraLargeImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"mega"]){
                            venue.megaLargeImageURL = imageDictionary[@"#text"];
                        }
                    }
                }
            }
            
            if([eventDictionary[@"venue"][@"location"] isKindOfClass:[NSDictionary class]]){
                venue.city = eventDictionary[@"venue"][@"location"][@"city"];
                venue.country = eventDictionary[@"venue"][@"location"][@"country"];
                if([eventDictionary[@"venue"][@"location"][@"geo:point"] isKindOfClass:[NSDictionary class]]){
                    NSString *lat = eventDictionary[@"venue"][@"location"][@"geo:point"][@"geo:lat"];
                    NSString *lon = eventDictionary[@"venue"][@"location"][@"geo:point"][@"geo:long"];
                    venue.location = (OLFMGeoLocation){.latitude=[lat floatValue], .longitude=[lon floatValue]};
                }
                venue.postalCode = eventDictionary[@"venue"][@"location"][@"postalcode"];
                venue.street = eventDictionary[@"venue"][@"location"][@"street"];
            }
            
            venue.venueName = eventDictionary[@"venue"][@"name"];
            venue.phoneNumber = eventDictionary[@"venue"][@"phonenumber"];
            venue.url = eventDictionary[@"venue"][@"url"];
            venue.website = eventDictionary[@"venue"][@"website"];
            event.venue = venue;
        }
        
        [result addObject:event];
    }

    return result;
}



#pragma mark - NSXML Delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    attribute = [attributeDict objectForKey:@"size"];
    
    if(parseType == ParsingSimilarTracks){
        if ([element isEqualToString:@"name"] && !gotTrackName) {
            similarTrackName = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"name"] && gotTrackName) {
            similarTrackArtist = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"mbid"] && !gotTrackMBID) {
            similarTrackMBID = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"url"] && !gotTrackURL) {
            similarTrackURL = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"match"]) {
            similarTrackMatchValue = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"image"]) {
            if([attribute isEqualToString:@"small"]){
                smallTrackImageURL = [[NSMutableString alloc] init];
            }
            else if([attribute isEqualToString:@"medium"]){
                mediumTrackImageURL = [[NSMutableString alloc] init];
            }
            else if([attribute isEqualToString:@"large"]){
                largeTrackImageURL = [[NSMutableString alloc] init];
            }
            else if([attribute isEqualToString:@"extralarge"]){
                extralargeTrackImageURL = [[NSMutableString alloc] init];
            }
            //foundImage = YES;
        }
    }
    else if(parseType == ParsingTrackSearch){
        if ([element isEqualToString:@"name"]) {
            similarTrackName = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"artist"]) {
            similarTrackArtist = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"url"]) {
            similarTrackURL = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"mbid"]) {
            similarTrackMBID = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"image"]) {
            if([attribute isEqualToString:@"small"]){
                smallTrackImageURL = [[NSMutableString alloc] init];
            }
            else if([attribute isEqualToString:@"medium"]){
                mediumTrackImageURL = [[NSMutableString alloc] init];
            }
            else if([attribute isEqualToString:@"large"]){
                largeTrackImageURL = [[NSMutableString alloc] init];
            }
            else if([attribute isEqualToString:@"extralarge"]){
                extralargeTrackImageURL = [[NSMutableString alloc] init];
            }
        }
    }
    /* Handling artist search */
    else if(parseType == ParsingArtistSearch){
        if ([element isEqualToString:@"name"]) {
            similarArtistName = [[NSMutableString alloc] init];
            handledSimilarArtist = NO;
        }
        else if([element isEqualToString:@"mbid"]) {
            similarArtistMBID = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"match"]) {
            similarArtistMatchValue = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"url"]) {
            similarArtistURL = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"image"]) {
            similarArtistImageURL = [[NSMutableString alloc] init];
        }
    }
    
    
    
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if(parseType == ParsingSimilarTracks){
        if ([element isEqualToString:@"name"] && !gotTrackName) {
            [similarTrackName appendString:string];
        }
        else if([element isEqualToString:@"name"] && gotTrackName) {
            [similarTrackArtist appendString:string];
        }
        else if([element isEqualToString:@"mbid"] && !gotTrackMBID) {
            [similarTrackMBID appendString:string];
        }
        else if([element isEqualToString:@"url"] && !gotTrackURL) {
            [similarTrackURL appendString:string];
        }
        else if([element isEqualToString:@"match"]) {
            [similarTrackMatchValue appendString:string];
        }
        else if([element isEqualToString:@"image"]) {
            if([attribute isEqualToString:@"small"]){
                [smallTrackImageURL appendString:string];
                foundImage = YES;
            }
            else if([attribute isEqualToString:@"medium"]){
                [mediumTrackImageURL appendString:string];
                foundImage = YES;
            }
            else if([attribute isEqualToString:@"large"]){
                [largeTrackImageURL appendString:string];
                foundImage = YES;
            }
            else if([attribute isEqualToString:@"extralarge"]){
                [extralargeTrackImageURL appendString:string];
                foundImage = YES;
            }
        }
    }
    else if(parseType == ParsingTrackSearch){
        if ([element isEqualToString:@"name"]) {
            [similarTrackName appendString:string];
        }
        else if([element isEqualToString:@"artist"]) {
            [similarTrackArtist appendString:string];
        }
        else if([element isEqualToString:@"url"]) {
            [similarTrackURL appendString:string];
        }
        else if([element isEqualToString:@"mbid"]) {
            [similarTrackMBID appendString:string];
        }
        else if([element isEqualToString:@"image"]) {
            if([attribute isEqualToString:@"small"]){
                [smallTrackImageURL appendString:string];
            }
            else if([attribute isEqualToString:@"medium"]){
                [mediumTrackImageURL appendString:string];
            }
            else if([attribute isEqualToString:@"large"]){
                [largeTrackImageURL appendString:string];
            }
            else if([attribute isEqualToString:@"extralarge"]){
                [extralargeTrackImageURL appendString:string];
            }
        }
    }
    /* Handling artist search */
    else if(parseType == ParsingArtistSearch){
        if ([element isEqualToString:@"name"]) {
            [similarArtistName appendString:string];
        }
        else if([element isEqualToString:@"mbid"]) {
            [similarArtistMBID appendString:string];
        }
        else if([element isEqualToString:@"match"]) {
            [similarArtistMatchValue appendString:string];
        }
        else if([element isEqualToString:@"url"]) {
            [similarArtistURL appendString:string];
        }
        else if([element isEqualToString:@"image"]) {
            [similarArtistImageURL appendString:string];
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    /* HANDLING SIMILAR TRACKS */
    if(parseType == ParsingSimilarTracks){
        if([elementName isEqualToString:@"track"]) {
            [similarTracks addObject:[similarTrackData copy]];
            similarTrackData = [NSMutableDictionary dictionary];
            foundImage = NO;
        }
        else if([element isEqualToString:@"name"] && !gotTrackName) {
            
            /* Remove leading and trailing whitespace */
            similarTrackName = (NSMutableString *) [similarTrackName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            /* Remove accent marks */
            similarTrackName = (NSMutableString *)[similarTrackName stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
            
            [similarTrackData setObject:similarTrackName forKey:@"trackName"];
            similarTrackName = [[NSMutableString alloc] init];
            gotTrackName = !gotTrackName;
        }
        else if([element isEqualToString:@"name"]) {
            
            /* Remove leading and trailing whitespace */
            similarTrackArtist = (NSMutableString *) [similarTrackArtist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            /* Remove accent marks */
            similarTrackArtist = (NSMutableString *)[similarTrackArtist stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
            
            [similarTrackData setObject:similarTrackArtist forKey:@"artistName"];
            similarTrackArtist = [[NSMutableString alloc] init];
            gotTrackName = !gotTrackName;
        }
        else if([element isEqualToString:@"mbid"] && !gotTrackMBID) {
            [similarTrackData setObject:similarTrackMBID forKey:@"mbid"];
            similarTrackMBID = [[NSMutableString alloc] init];
            gotTrackMBID = !gotTrackMBID;
        }
        else if([element isEqualToString:@"mbid"] && gotTrackMBID) {
            gotTrackMBID = !gotTrackMBID;
        }
        else if([element isEqualToString:@"url"] && !gotTrackURL) {
            [similarTrackData setObject:similarTrackURL forKey:@"trackURL"];
            similarTrackURL = [[NSMutableString alloc] init];
            gotTrackURL = YES;
        }
        else if([element isEqualToString:@"image"]) {// image is the last tag before a new track
            gotTrackURL = NO;

            if([attribute isEqualToString:@"small"]){
                if(foundImage){
                    [similarTrackData setObject:smallTrackImageURL forKey:@"smallImageURL"];
                }
                smallTrackImageURL = [[NSMutableString alloc] init];
                foundImage = NO;
            }
            else if([attribute isEqualToString:@"medium"]){
                if(foundImage){
                    [similarTrackData setObject:mediumTrackImageURL forKey:@"mediumImageURL"];
                }
                mediumTrackImageURL = [[NSMutableString alloc] init];
                foundImage = NO;
            }
            else if([attribute isEqualToString:@"large"]){
                if(foundImage == YES){
                    [similarTrackData setObject:largeTrackImageURL forKey:@"largeImageURL"];
                }
                largeTrackImageURL = [[NSMutableString alloc] init];
                foundImage = NO;
            }
            else if([attribute isEqualToString:@"extralarge"]){
                if(foundImage){
                    [similarTrackData setObject:extralargeTrackImageURL forKey:@"extraLargeImageURL"];
                }
                extralargeTrackImageURL = [[NSMutableString alloc] init];
                foundImage = NO;
            }
        }
        else if([element isEqualToString:@"match"]) {
            [similarTrackData setObject:similarTrackMatchValue forKey:@"matchValue"];
            similarTrackMatchValue = [[NSMutableString alloc] init];
        }
    }
    /* END HANDLING SIMILAR TRACKS */
    
    
    
    /* HANDLING TRACK SEARCH */
    else if(parseType == ParsingTrackSearch){
        if ([element isEqualToString:@"name"]) {
            /* Remove leading and trailing whitespace */
            similarTrackName = (NSMutableString *) [similarTrackName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            /* Remove accent marks */
            similarTrackName = (NSMutableString *)[similarTrackName stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
            
            [similarTrackData setObject:similarTrackName forKey:@"trackName"];
            similarTrackName = [[NSMutableString alloc] init];
            
            gotTrackMBID = NO;
        }
        else if([element isEqualToString:@"artist"]) {
            /* Remove leading and trailing whitespace */
            similarTrackArtist = (NSMutableString *) [similarTrackArtist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            /* Remove accent marks */
            similarTrackArtist = (NSMutableString *)[similarTrackArtist stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
            
            [similarTrackData setObject:similarTrackArtist forKey:@"artistName"];
            similarTrackArtist = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"url"]) {
            [similarTrackData setObject:similarTrackURL forKey:@"trackURL"];
            similarTrackURL = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"image"]) {
            if([attribute isEqualToString:@"small"]){
                [similarTrackData setObject:smallTrackImageURL forKey:@"smallImageURL"];
                smallTrackImageURL = [[NSMutableString alloc] init];
            }
            else if([attribute isEqualToString:@"medium"]){
                [similarTrackData setObject:mediumTrackImageURL forKey:@"mediumImageURL"];
                mediumTrackImageURL = [[NSMutableString alloc] init];
            }
            else if([attribute isEqualToString:@"large"]){
                [similarTrackData setObject:largeTrackImageURL forKey:@"largeImageURL"];
                largeTrackImageURL = [[NSMutableString alloc] init];
            }
            else if([attribute isEqualToString:@"extralarge"]){
                [similarTrackData setObject:extralargeTrackImageURL forKey:@"extraLargeImageURL"];
                extralargeTrackImageURL = [[NSMutableString alloc] init];
            }
        }
        else if([element isEqualToString:@"mbid"] && !gotTrackMBID) {
            [similarTrackData setObject:similarTrackMBID forKey:@"mbid"];
            similarTrackMBID = [[NSMutableString alloc] init];
            [similarTracks addObject:[similarTrackData copy]];
            gotTrackMBID = YES;
        }
    }
    /* END HANDLING TRACK SEARCH */
    
    
    /* HANDLING ARTIST SEARCH */
    else if(parseType == ParsingArtistSearch){
        if([elementName isEqualToString:@"artist"]){
            [similars addObject:[similarArtist copy]];
        }
        else if ([element isEqualToString:@"name"]) {
            /* Remove leading and trailing whitespace */
            similarArtistName = (NSMutableString *) [similarArtistName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            /* Remove accent marks */
            similarArtistName = (NSMutableString *)[similarArtistName stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
            
            [similarArtist setObject:similarArtistName forKey:@"artistName"];
        }
        else if([element isEqualToString:@"mbid"]) {
            /* Remove leading and trailing whitespace */
            similarArtistMBID = (NSMutableString *) [similarArtistMBID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            /* Remove accent marks */
            similarArtistMBID = (NSMutableString *)[similarArtistMBID stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
            
            [similarArtist setObject:similarArtistMBID forKey:@"mbid"];
        }
        else if([element isEqualToString:@"url"]) {
            /* Remove leading and trailing whitespace */
            similarArtistURL = (NSMutableString *) [similarArtistURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            /* Remove accent marks */
            similarArtistURL = (NSMutableString *)[similarArtistURL stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
            
            [similarArtist setObject:similarArtistURL forKey:@"artistURL"];
        }
        else if([element isEqualToString:@"image"]) {
            
            /* Remove leading and trailing whitespace */
            similarArtistImageURL = (NSMutableString *) [similarArtistImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            /* Remove accent marks */
            similarArtistImageURL = (NSMutableString *)[similarArtistImageURL stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
            
            if([attribute isEqualToString:@"small"]){
                [similarArtist setObject:similarArtistImageURL forKey:@"smallImageURL"];
            }
            else if([attribute isEqualToString:@"medium"]){
                [similarArtist setObject:similarArtistImageURL forKey:@"mediumImageURL"];
            }
            else if([attribute isEqualToString:@"large"]){
                [similarArtist setObject:similarArtistImageURL forKey:@"largeImageURL"];
            }
            else if([attribute isEqualToString:@"extralarge"]){
                [similarArtist setObject:similarArtistImageURL forKey:@"extraLargeImageURL"];
            }
            else if([attribute isEqualToString:@"mega"]){
                [similarArtist setObject:similarArtistImageURL forKey:@"megaImageURL"];
            }
        }
    }
    /* END HANDLING ARTIST SEARCH */
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    gotTrackURL = NO;
    gotTrackName = NO;
    gotTrackMBID = NO;
    handledTag = NO;
    handledSimilarArtist = NO;
}















@end
