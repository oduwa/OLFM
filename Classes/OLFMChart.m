//
//  OLFMChart.m
//  Jive
//
//  Created by Odie Edo-Osagie on 11/06/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import "OLFMChart.h"
#import "OLFMArtist.h"
#import "OLFMManager.h"


static OLFMChart *globalInstance = nil;

@implementation OLFMChart{
    NSXMLParser *parser;
    NSString *element;
    NSString *attribute;
    NSMutableDictionary *artistData;
    NSMutableDictionary *trackData;
    NSMutableArray *artists;
    NSMutableArray *tracks;
    NSMutableString *name;
    NSMutableString *imageURL;
    NSMutableString *artistName;
    NSMutableString *trackURL;
    
    ParseType parseType;
    
    BOOL gotTrackName;
    BOOL gotTrackURL;
}


/**
 *
 *  Charts singleton object
 *
 */
+ (OLFMChart *) chart
{
    @synchronized(self)
    {
        if (!globalInstance)
            globalInstance = [[self alloc] init];
        
        return globalInstance;
    }
    
    return globalInstance;
}

- (id) init
{
    self = [super init];
    
    if(self){
        artists = [[NSMutableArray alloc] init];
        artistData = [[NSMutableDictionary alloc] init];
        tracks = [[NSMutableArray alloc] init];
        trackData = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


- (NSArray *) getTopArtistsWithResultsLimit: (NSUInteger) numberOfResults
{
    artists = [[NSMutableArray alloc] init];
    artistData = [[NSMutableDictionary alloc] init];
    
    if(numberOfResults <= 0){
        numberOfResults =  1;
    }
    
    NSString *API_KEY = [OLFMManager sharedManager].API_KEY;
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=chart.gettopartists&api_key=%@&limit=%lu", API_KEY, (unsigned long)numberOfResults];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parseType = ParsingChartArtists;
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];

    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *dict in artists){
        OLFMArtist *artist = [[OLFMArtist alloc] init];
        artist.name = dict[@"name"];
        artist.extraLargeImageURL = dict[@"imageURL"];
        [result addObject:artist];
    }

    return result;
}


- (NSArray *) getHypedArtistsWithResultsLimit:(NSUInteger)numberOfResults
{
    artists = [[NSMutableArray alloc] init];
    artistData = [[NSMutableDictionary alloc] init];
    
    if(numberOfResults <= 0){
        numberOfResults =  1;
    }
    
    NSString *API_KEY = [OLFMManager sharedManager].API_KEY;
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=chart.gethypedartists&api_key=%@&limit=%lu", API_KEY, (unsigned long)numberOfResults];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parseType = ParsingChartArtists;
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *dict in artists){
        OLFMArtist *artist = [[OLFMArtist alloc] init];
        artist.name = dict[@"name"];
        artist.extraLargeImageURL = dict[@"imageURL"];
        [result addObject:artist];
    }
    
    return result;
}


- (NSArray *) getTopTracksWithResultsLimit: (NSUInteger) numberOfResults
{
    tracks = [[NSMutableArray alloc] init];
    trackData = [[NSMutableDictionary alloc] init];
    
    if(numberOfResults <= 0){
        numberOfResults =  1;
    }
    
    NSString *API_KEY = [OLFMManager sharedManager].API_KEY;
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=chart.gettoptracks&api_key=%@&limit=%lu", API_KEY, (unsigned long)numberOfResults];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parseType = ParsingChartTracks;
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];

    for(NSMutableDictionary *dict in tracks){
        OLFMTrack *track = [[OLFMTrack alloc] init];
        track.name = dict[@"trackName"];
        track.artistName = dict[@"artistName"];
        track.trackURL = dict[@"trackURL"];
        [result addObject:track];
    }
    
    return result;
}



- (NSArray *) getHypedTracksWithResultsLimit:(NSUInteger)numberOfResults
{
    tracks = [[NSMutableArray alloc] init];
    trackData = [[NSMutableDictionary alloc] init];
    
    if(numberOfResults <= 0){
        numberOfResults =  1;
    }
    
    NSString *API_KEY = [OLFMManager sharedManager].API_KEY;
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=chart.gethypedtracks&api_key=%@&limit=%lu", API_KEY, (unsigned long)numberOfResults];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parseType = ParsingChartTracks;
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *dict in tracks){
        OLFMTrack *track = [[OLFMTrack alloc] init];
        track.name = dict[@"trackName"];
        track.artistName = dict[@"artistName"];
        track.trackURL = dict[@"trackURL"];
        [result addObject:track];
    }
    
    return result;
}



#pragma mark - NSXML Delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    if(parseType == ParsingChartArtists){
        element = elementName;

        if ([element isEqualToString:@"name"]) {
            name = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"image"]) {
            imageURL = [[NSMutableString alloc] init];
        }
        
        attribute = [attributeDict objectForKey:@"size"];
    }
    else if(parseType == ParsingChartTracks){
        element = elementName;
        
        if ([element isEqualToString:@"name"] && !gotTrackName) {
            name = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"name"] && gotTrackName) {
            name = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"url"] && !gotTrackURL) {
            trackURL = [[NSMutableString alloc] init];
        }
    }
    
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if(parseType == ParsingChartArtists){
        if ([element isEqualToString:@"name"]) {
            [name appendString:string];
        }
        else if([element isEqualToString:@"image"]) {
            if([attribute isEqualToString:@"extralarge"]){
                [imageURL appendString:string];
            }
        }
    }
    else if(parseType == ParsingChartTracks){
        if ([element isEqualToString:@"name"] && !gotTrackName) {
            [name appendString:string];
        }
        else if([element isEqualToString:@"name"] && gotTrackName) {
            [name appendString:string];
        }
        else if([element isEqualToString:@"url"] && !gotTrackURL) {
            [trackURL appendString:string];
        }
    }
    
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  
    if(parseType == ParsingChartArtists){
        if ([element isEqualToString:@"name"]) {
            
            /* Remove leading and trailing whitespace */
            name = (NSMutableString *) [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            /* Remove accent marks */
            name = (NSMutableString *)[name stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
            
            [artistData setObject:name forKey:@"name"];
            name = [[NSMutableString alloc] init];
        }
        else if([element isEqualToString:@"image"] && [attribute isEqualToString:@"extralarge"]) {
            [artistData setObject:imageURL forKey:@"imageURL"];
            imageURL = [[NSMutableString alloc] init];
            [artists addObject:[artistData copy]];
        }
    }
    
    else if(parseType == ParsingChartTracks){
        if ([element isEqualToString:@"name"] && !gotTrackName) {
            
            /* Remove leading and trailing whitespace */
            name = (NSMutableString *) [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            /* Remove accent marks */
            name = (NSMutableString *)[name stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
            
            [trackData setObject:name forKey:@"trackName"];
            name = [[NSMutableString alloc] init];
            gotTrackName = !gotTrackName;
        }
        else if([element isEqualToString:@"url"] && !gotTrackURL) {
            [trackData setObject:trackURL forKey:@"trackURL"];
            trackURL = [[NSMutableString alloc] init];
        }
        else if ([element isEqualToString:@"name"] && gotTrackName) {
            
            /* Remove leading and trailing whitespace */
            name = (NSMutableString *) [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            /* Remove accent marks */
            name = (NSMutableString *)[name stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
            
            [trackData setObject:name forKey:@"artistName"];
            [tracks addObject:[trackData copy]];
            name = [[NSMutableString alloc] init];
            gotTrackName = !gotTrackName;
        }
        else if([element isEqualToString:@"url"]) {
            gotTrackURL = !gotTrackURL;
        }
    }
    
    
}


- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if(parseType == ParsingChartTracks){
        gotTrackURL = NO;
        gotTrackName = NO;
    }
}















@end
