//
//  OLFMTrack.m
//  Jive
//
//  Created by Odie Edo-Osagie on 15/06/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import "OLFMTrack.h"
#import "OLFMArtist.h"
#import "OLFMManager.h"


@implementation OLFMTrack{
    NSXMLParser *parser;
    NSString *element;
    NSString *attribute;
    ParseType parseType;
    
    /* For handling multiple occurences of "name", "url" and "mbid" elements */
    BOOL gotTrackName;
    BOOL gotArtistName;
    BOOL gotTrackURL;
    BOOL gotTrackMBID;
    
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
}

- (instancetype) init
{
    self = [super init];
    
    if(self){
        self.name = [[NSMutableString alloc] init];
        self.artist = [[OLFMArtist alloc] init];
        self.LFMid = [[NSMutableString alloc] init];
        self.mbid = [[NSMutableString alloc] init];
        self.trackURL = [[NSMutableString alloc] init];
        self.smallTrackCoverArtURL = [[NSMutableString alloc] init];
        self.mediumTrackCoverArtURL = [[NSMutableString alloc] init];
        self.largeTrackCoverArtURL = [[NSMutableString alloc] init];
        self.extraLargeTrackCoverArtURL = [[NSMutableString alloc] init];
        self.duration = [[NSMutableString alloc] init];
        self.playCount = [[NSMutableString alloc] init];
        self.listenersCount = [[NSMutableString alloc] init];
        self.trackSummary = [[NSMutableString alloc] init];
        self.trackInfo = [[NSMutableString alloc] init];
        self.tags = [[NSMutableArray alloc] init];
        self.artistName = [[NSMutableString alloc] init];
        self.albumName = [[NSMutableString alloc] init];
        
        tagName = [[NSMutableString alloc] init];
        
        similarTracks = [[NSMutableArray alloc] init];
        similarTrackData = [[NSMutableDictionary alloc] init];
        similarTrackName = [[NSMutableString alloc] init];
        similarTrackArtist = [[NSMutableString alloc] init];
        similarTrackURL = [[NSMutableString alloc] init];
        similarTrackMBID = [[NSMutableString alloc] init];
        similarTrackMatchValue = [[NSMutableString alloc] init];
    }
    
    return self;
}


- (instancetype) initWithName: (NSString *)nameOfTrack andArtist: (NSString *)nameOfArtist
{
    self = [self init];
    
    if(self){
        [self fetchInfoWithTrack:nameOfTrack andArtist:nameOfArtist];
        if([self.name isEqualToString:@""]){
            return nil;
        }
    }
    
    return self;
}

#pragma mark - Instance and Class Methods

- (OLFMArtist *) getArtist
{
    if([self.artistName isEqualToString:@""]){
        NSLog(@"WARNING: EMPTY ARTIST NAME");
        return nil;
    }
    else if(self.artistName == nil){
        NSLog(@"WARNING: NULL/UNINITIALIZED ARTIST NAME");
        return nil;
    }
    else{
        return [[OLFMArtist alloc] initWithName:self.artistName];
    }
}


- (OLFMAlbum *) getAlbum
{
    if([self.artistName isEqualToString:@""] || [self.albumName isEqualToString:@""]){
        NSLog(@"WARNING: EMPTY PARAMETER");
        return nil;
    }
    else if(self.artistName == nil || self.albumName == nil){
        NSLog(@"WARNING: NULL/UNINITIALIZED PARAMETER");
        return nil;
    }
    else{
        return [[OLFMAlbum alloc] initWithName:self.albumName andArtist:self.artistName];
    }
}


- (NSArray *) getSimilarTracks
{
    similarTracks = [[NSMutableArray alloc] init];
    
    NSString *APIKey = [OLFMManager sharedManager].API_KEY;
    
    if([self.name isEqualToString:@""] || [self.artistName isEqualToString:@""]){
        NSLog(@"WARNING: Empty Parameter");
        return nil;
    }
    
    NSString *name = [self.name stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    name = [self.name stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSString *artist = [self.artistName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    artist = [self.artistName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=track.getsimilar&artist=%@&track=%@&api_key=%@&limit=10", artist, name, APIKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parseType = ParsingSimilarTracks;
    
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];

    for(NSMutableDictionary *dict in similarTracks){
        [result addObject:dict];
    }
    
    return result;
}


#pragma mark - Helper Methods

/**
 *
 *  Connects to Last.fm to get artists information
 *
 */
- (void) fetchInfoWithTrack:(NSString *)nameOfTrack andArtist:(NSString *)nameOfArtist
{
    
    if([nameOfTrack isEqualToString:@""] || [nameOfArtist isEqualToString:@""]){
        NSLog(@"WARNING: Empty Parameter");
    }
    
    if(nameOfTrack == nil || nameOfArtist == nil){
        NSLog(@"WARNING: NULL Parameter");
    }
    
    NSString *APIKey = [OLFMManager sharedManager].API_KEY;
    
    /* Escaping spaces */
    nameOfTrack = [nameOfTrack stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    nameOfTrack = [nameOfTrack stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    nameOfArtist = [nameOfArtist stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    nameOfArtist = [nameOfArtist stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=%@&artist=%@&track=%@&autocorrect=1", APIKey, nameOfArtist, nameOfTrack];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parseType = ParsingTrackInfo;
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}

- (void) fetchInfoFromJSONWithTrack:(NSString *)nameOfTrack andArtist:(NSString *)nameOfArtist
{
    NSError* error;
    
    if([nameOfTrack isEqualToString:@""] || [nameOfArtist isEqualToString:@""]){
        NSLog(@"WARNING: Empty Parameter");
    }
    
    if(nameOfTrack == nil || nameOfArtist == nil){
        NSLog(@"WARNING: NULL Parameter");
    }
    
    NSString *APIKey = [OLFMManager sharedManager].API_KEY;
    
    /* Escaping spaces */
    nameOfTrack = [nameOfTrack stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    nameOfArtist = [nameOfArtist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    nameOfTrack = [OLFMManager escapeString:nameOfTrack];
    nameOfArtist = [OLFMManager escapeString:nameOfArtist];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=%@&artist=%@&track=%@&format=json&autocorrect=1", APIKey, nameOfArtist, nameOfTrack];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData* data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if(!error){
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if(json[@"error"]){
            NSLog(@"<ERROR> OLFMTRACK DATA NOT FOUND FOR TRACK WITH NAME \"%@\" AND ARTIST \"%@\"", nameOfTrack, nameOfArtist);
            return;
        }
        
        NSDictionary *result = json[@"track"];
        
        if([result[@"artist"] respondsToSelector:@selector(objectForKeyedSubscript:)]){
            NSDictionary *artistDictionary = result[@"artist"];
            self.artistName = artistDictionary[@"name"];
        }
        else{
            self.artistName = result[@"artist"];
        }

        if(result[@"album"]){
            NSDictionary *albumDictionary = result[@"album"];
            NSArray *imageArray = albumDictionary[@"image"];
            for(NSDictionary *imageDictionary in imageArray){
                if([imageDictionary[@"size"] isEqualToString:@"small"]){
                    self.smallTrackCoverArtURL = imageDictionary[@"#text"];
                }
                else if([imageDictionary[@"size"] isEqualToString:@"medium"]){
                    self.mediumTrackCoverArtURL = imageDictionary[@"#text"];
                }
                else if([imageDictionary[@"size"] isEqualToString:@"large"]){
                    self.largeTrackCoverArtURL = imageDictionary[@"#text"];
                }
                else if([imageDictionary[@"size"] isEqualToString:@"extralarge"]){
                    self.extraLargeTrackCoverArtURL = imageDictionary[@"#text"];
                }
            }
            self.albumName = albumDictionary[@"title"];
        }
        
        self.duration = result[@"duration"];
        self.LFMid = result[@"id"];
        self.listenersCount = result[@"listeners"];
        self.mbid = result[@"mbid"];
        self.name = result[@"name"];
        self.playCount = result[@"playcount"];

        
        if([result[@"toptags"] respondsToSelector:@selector(objectForKeyedSubscript:)]){
            if([result[@"toptags"][@"tag"] respondsToSelector:@selector(objectForKeyedSubscript:)]){
                [self.tags addObject:result[@"toptags"][@"tag"][@"name"]];
            }
            else{
                for(NSDictionary *tagDictionary in result[@"toptags"][@"tag"]){
                    [self.tags addObject:tagDictionary[@"name"]];
                }
            }
            
        }
        
        if(result[@"wiki"][@"content"]){
            self.trackInfo = result[@"wiki"][@"content"];
        }
        
        if(result[@"wiki"][@"summary"]){
            self.trackInfo = result[@"wiki"][@"summary"];
        }
        
        self.trackURL = result[@"url"];
        
    }
    else{
        NSLog(@"ERROR: %@", error);
    }

}

- (void) fill
{
    [self fetchInfoFromJSONWithTrack:self.name andArtist:self.artistName];
}

- (NSString *) description
{
    /*
    NSString *result = [NSString stringWithFormat:@"%@\nName: %@ \nArtistName: %@ \nAlbumName: %@ \nLast.fm ID: %@ \nMusicBrainz ID: %@ \nURL: %@ \nSmallImageURL: %@ \nMediumImageURL: %@ \nLargeImageURL: %@ \nExtraLargeImageURL: %@ \nDuration: %@ \nListeners: %@ \nPlayCount: %@ \nTrack Summary: %@ \nTrack Info: %@ \nTags: %@", [super description], self.name, self.artistName, self.albumName, self.LFMid, self.mbid, self.trackURL, self.smallTrackCoverArtURL, self.mediumTrackCoverArtURL, self.largeTrackCoverArtURL, self.extraLargeTrackCoverArtURL, self.duration, self.listenersCount, self.playCount, self.trackSummary, self.trackInfo, self.tags];
     */
    
    NSString *result = [NSString stringWithFormat:@"%@ \rName: %@ \rArtist: %@ \rAlbum: %@ \rMBid: %@ \rsmallImageURL: %@",[super description], self.name, self.artistName, self.albumName, self.mbid, self.smallTrackCoverArtURL];
    
    return result;
}

#pragma mark - NSXML Delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if(parseType == ParsingTrackInfo){
        if([elementName isEqualToString:@"tag"]){
            handledTag = NO;
        }
        
        attribute = [attributeDict objectForKey:@"size"];
    }
    else if(parseType == ParsingSimilarTracks){
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
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if(parseType == ParsingTrackInfo){
        if ([element isEqualToString:@"name"] && !gotTrackName) {
            [self.name appendString:string];
            gotTrackName = YES;
        }
        else if ([element isEqualToString:@"id"]) {
            [self.LFMid appendString:string];
        }
        else if ([element isEqualToString:@"mbid"] && !gotTrackMBID) {
            [self.mbid appendString:string];
            gotTrackMBID = YES;
        }
        else if ([element isEqualToString:@"image"]) {
            if([attribute isEqualToString:@"small"]){
                [self.smallTrackCoverArtURL appendString:string];
            }
            else if([attribute isEqualToString:@"medium"]){
                [self.mediumTrackCoverArtURL appendString:string];
            }
            else if([attribute isEqualToString:@"large"]){
                [self.largeTrackCoverArtURL appendString:string];
            }
            else if([attribute isEqualToString:@"extralarge"]){
                [self.extraLargeTrackCoverArtURL appendString:string];
            }
        }
        else if ([element isEqualToString:@"url"] && !gotTrackURL) {
            [self.trackURL appendString:string];
            gotTrackURL = YES;
        }
        else if ([element isEqualToString:@"duration"]) {
            [self.duration appendString:string];
        }
        else if ([element isEqualToString:@"listeners"]) {
            [self.listenersCount appendString:string];
        }
        else if ([element isEqualToString:@"playcount"]) {
            [self.playCount appendString:string];
        }
        else if ([element isEqualToString:@"name"] && gotTrackName && !gotArtistName && handledTag) {
            [self.artistName appendString:string];
            gotArtistName = YES;
        }
        else if ([element isEqualToString:@"title"] && gotTrackName && gotArtistName && handledTag) {
            [self.albumName appendString:string];
        }
        else if ([element isEqualToString:@"name"] && !handledTag) {
            [tagName appendString:string];
            handledTag = YES;
        }
        else if ([element isEqualToString:@"summary"]) {
            [self.trackSummary appendString:string];
        }
        else if ([element isEqualToString:@"content"]) {
            [self.trackInfo appendString:string];
        }
    }
    else if(parseType == ParsingSimilarTracks){
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
    }
    
    
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if(parseType == ParsingTrackInfo){
        if([elementName isEqualToString:@"tag"]){
            if(handledTag){
                [self.tags addObject:[tagName copy]];
                tagName = [[NSMutableString alloc] init];
                handledTag = NO;
            }
        }
    }
    else if(parseType == ParsingSimilarTracks){
        if([element isEqualToString:@"name"] && !gotTrackName) {
            
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
            [similarTracks addObject:[similarTrackData copy]];
            gotTrackMBID = !gotTrackMBID;
        }
        else if([element isEqualToString:@"url"] && !gotTrackURL) {
            [similarTrackData setObject:similarTrackURL forKey:@"trackURL"];
            similarTrackURL = [[NSMutableString alloc] init];
            gotTrackURL = YES;
        }
        else if([element isEqualToString:@"image"]) {// image is thhe last tag before a new track
            gotTrackURL = NO;
        }
        else if([element isEqualToString:@"match"]) {
            [similarTrackData setObject:similarTrackMatchValue forKey:@"matchValue"];
            similarTrackMatchValue = [[NSMutableString alloc] init];
        }
    }
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
        gotTrackURL = NO;
        gotTrackName = NO;
        gotTrackMBID = NO;
}










@end
