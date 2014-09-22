//
//  OLFMArtist.m
//  Jive
//
//  Created by Odie Edo-Osagie on 11/06/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import "OLFMArtist.h"
#import "OLFMQuery.h"
#import "OLFMManager.h"

@implementation OLFMArtist{
    NSXMLParser *parser;
    NSString *element;
    NSString *attribute;
    ParseType parseType;
    
    /* For handling multiple occurences of "name", "url" and "mbid" elements */
    BOOL handledSimilarArtist;
    BOOL gotArtistName;
    BOOL gotArtistURL;
    BOOL gotArtistImage;
    
    /* For obtaining similar tracks */
    NSMutableArray *similars;
    NSMutableDictionary *similarArtist;
    NSMutableString *similarArtistName;
    NSMutableString *similarArtistURL;
    NSMutableString *similarArtistImage;
    NSMutableString *similarArtistMBID;
    NSMutableString *similarArtistMatchValue;
    NSMutableString *similarArtistImageURL;
    NSMutableString *similarArtistSmallImageURL;
    NSMutableString *similarArtistMediumImageURL;
    NSMutableString *similarArtistLargeImageURL;
    NSMutableString *similarArtistExtraLargeImageURL;
    NSMutableString *similarArtistMegaImageURL;
    
    /* For handling tags */
    BOOL handledTag;
    NSMutableString *tagName;
}


- (instancetype) init
{
    self = [super init];
    
    if(self){
        self.name = [[NSMutableString alloc] init];
        self.playCount = [[NSMutableString alloc] init];
        self.listenersCount = [[NSMutableString alloc] init];
        self.mbid = [[NSMutableString alloc] init];
        self.url = [[NSMutableString alloc] init];
        self.streamable = [[NSMutableString alloc] init];
        self.onTour = [[NSMutableString alloc] init];
        self.smallImageURL = [[NSMutableString alloc] init];
        self.mediumImageURL = [[NSMutableString alloc] init];
        self.largeImageURL = [[NSMutableString alloc] init];
        self.extraLargeImageURL = [[NSMutableString alloc] init];
        self.megaLargeImageURL = [[NSMutableString alloc] init];
        self.bioSummary = [[NSMutableString alloc] init];
        self.bioContent = [[NSMutableString alloc] init];
        self.yearFormed = [[NSMutableString alloc] init];
        self.tags = [[NSMutableArray alloc] init];
        self.similar = [[NSMutableArray alloc] init];
        
        similars = [[NSMutableArray alloc] init];
        similarArtist = [[NSMutableDictionary alloc] init];
        similarArtistName = [[NSMutableString alloc] init];
        similarArtistURL = [[NSMutableString alloc] init];
        similarArtistImage = [[NSMutableString alloc] init];
        similarArtistMBID = [[NSMutableString alloc] init];
        similarArtistMatchValue = [[NSMutableString alloc] init];
        similarArtistImageURL = [[NSMutableString alloc] init];
        similarArtistSmallImageURL = [[NSMutableString alloc] init];
        similarArtistMediumImageURL = [[NSMutableString alloc] init];
        similarArtistLargeImageURL = [[NSMutableString alloc] init];
        similarArtistExtraLargeImageURL = [[NSMutableString alloc] init];
        similarArtistMegaImageURL = [[NSMutableString alloc] init];
        tagName = [[NSMutableString alloc] init];
        
        handledTag = YES;
    }
    
    return self;
}


- (instancetype) initWithName: (NSString *)artistName
{
    self = [self init];
    
    if(self){
        if([artistName isEqualToString:@""] || artistName == nil){
            NSLog(@"<WARNING>: TRYING TO INITIALIZE OLFMARTIST WITH EMPTY NAME");
            return nil;
        }
        else{
            [self fetchInfo:artistName];
        }
    }
    
    return self;
}


#pragma mark - Class and Instance Methods

- (void) fill
{
    if([self.name isEqualToString:@""] || self.name == nil){
        NSLog(@"<WARNING>: TRYING TO INITIALIZE OLFMARTIST WITH EMPTY NAME");
        //[NSException raise:@"ArtistFillException" format:@"For an OLFMArtist object to be filled, name field cannot be Null or empty"];
    }
    else{
        [self fetchInfo:self.name];
    }
}

- (NSArray *) getSimilarArtists
{
    similars = [[NSMutableArray alloc] init];
    
    NSString *APIKey = [OLFMManager sharedManager].API_KEY;
    
    if([self.name isEqualToString:@""]){
        NSLog(@"WARNING: Empty Parameter");
        return nil;
    }
    
    /* Escaping space characters */
    NSString *name = [self.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    name = [OLFMManager escapeString:name];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&artist=%@&api_key=%@&limit=10", name, APIKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parseType = ParsingSimilarArtists;
    
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *dict in similars){
        OLFMArtist *artist = [[OLFMArtist alloc] init];
        artist.name = dict[@"artistName"];
        artist.mbid = dict[@"mbid"];
        artist.url = dict[@"artistURL"];
        artist.smallImageURL = dict[@"smallImageURL"];
        artist.mediumImageURL = dict[@"mediumImageURL"];
        artist.largeImageURL = dict[@"largeImageURL"];
        artist.extraLargeImageURL = dict[@"extraLargeImageURL"];
        artist.megaLargeImageURL = dict[@"megaLargeImageURL"];
        //artist.m = dict[@"matchValue"];
        [result addObject:artist];
    }
    
    return result;
}


- (NSArray *) getTopTracks
{
    return [[OLFMQuery Query] getTopTracksForArtist:self.name];
}

- (NSArray *) getTopAlbumsWithLimit:(NSUInteger) limit
{
    return [[OLFMQuery Query] getTopAlbumsForArtist:self.name WithLimit:(int)limit];
}

- (NSArray *) getEventsWithLimit:(int)limit
{
    return [[OLFMQuery Query] getEventsForArtist:self.name WithLimit:limit];
}


#pragma mark - Helper Methods

/**
 *
 *  Connects to Last.fm to get artists information
 *
 */
- (void) fetchInfo:(NSString *)artistName
{
    NSError* error;
    
    NSString *APIKey = [OLFMManager sharedManager].API_KEY;
    
    /* Escaping spaces */
    artistName = [artistName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    artistName = [OLFMManager escapeString:artistName];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=%@&api_key=%@&autocorrect=1&format=json", artistName, APIKey];

    NSURL *url = [NSURL URLWithString:urlString];
    NSData* data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if(!error){
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

        NSDictionary *result = json[@"artist"];
        
        if([result[@"bio"] respondsToSelector:@selector(objectForKeyedSubscript:)]){
            _bioContent = result[@"bio"][@"content"];
            _bioContent = result[@"bio"][@"summary"];
            _yearFormed = result[@"bio"][@"yearFormed"];
            if([result[@"bio"][@"formationlist"][@"formation"] respondsToSelector:@selector(objectForKeyedSubscript:)]){
                // TODO: Maybe add yearfrom and yearTo
                //_yearFormed = result[@"bio"][@"formationlist"][@"formation"][@"yearfrom"];
            }
        }
        
        NSArray *imagesArray = result[@"image"];
        
        if([result[@"image"] isKindOfClass:[NSArray class]]){
            for(int i = 0; i < [imagesArray count]; i++){
                if([imagesArray[i] isKindOfClass:[NSDictionary class]]){
                    NSDictionary *imageDictionary = imagesArray[i];
                    
                    if([imageDictionary[@"size"] isEqualToString:@"small"]){
                        self.smallImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"medium"]){
                        self.mediumImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"large"]){
                        self.largeImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"extralarge"]){
                        self.extraLargeImageURL = imageDictionary[@"#text"];
                    }
                    else if([imageDictionary[@"size"] isEqualToString:@"mega"]){
                        self.megaLargeImageURL = imageDictionary[@"#text"];
                    }
                }
            }
        }
        
        _mbid = result[@"mbid"];
        _name = result[@"name"];
        _onTour = result[@"ontour"];
        
        if([result[@"similar"] isKindOfClass:[NSDictionary class]] && [result[@"similar"][@"artist"] isKindOfClass:[NSArray class]]){
            NSArray *similarArray = result[@"similar"][@"artist"];
            for(int i = 0; i < [similarArray count]; i++){
                if([similarArray[i] isKindOfClass:[NSDictionary class]]){
                    NSDictionary *similarDictionary = similarArray[i];
                    
                    OLFMArtist *artist = [[OLFMArtist alloc] init];
                    
                    artist.name = similarDictionary[@"name"];
                    artist.url = similarDictionary[@"url"];
                    
                    NSDictionary *imagesArray = similarDictionary[@"image"];
                    
                    for(NSDictionary *imageDictionary in imagesArray){
                        if([imageDictionary[@"size"] isEqualToString:@"small"]){
                            artist.smallImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"medium"]){
                            artist.mediumImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"large"]){
                            artist.largeImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"extralarge"]){
                            artist.extraLargeImageURL = imageDictionary[@"#text"];
                        }
                        else if([imageDictionary[@"size"] isEqualToString:@"mega"]){
                            artist.megaLargeImageURL = imageDictionary[@"#text"];
                        }
                    }
                    [self.similar addObject:artist];
                }
            }
        }
        
        if([result[@"stats"] isKindOfClass:[NSDictionary class]]){
            _listenersCount = result[@"stats"][@"listeners"];
            _playCount = result[@"stats"][@"playcount"];
        }
        
        _streamable = result[@"streamable"];
        
        if([result[@"tags"] isKindOfClass:[NSDictionary class]] && [result[@"tags"][@"tag"] isKindOfClass:[NSArray class]]){
            for(NSDictionary *tagDictionary in result[@"tags"][@"tag"]){
                [_tags addObject:tagDictionary[@"name"]];
            }
        }
        
        _url = result[@"url"];

    }
    else{
        NSLog(@"<ERROR>: %@", error);
    }
    
    
    
}


#pragma mark - NSXML Delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if(parseType == ParsingArtistInfo){
        if([elementName isEqualToString:@"tag"]){
            handledTag = NO;
        }
        
        attribute = [attributeDict objectForKey:@"size"];
    }
    else if(parseType == ParsingSimilarArtists){
        attribute = [attributeDict objectForKey:@"size"];
        
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

    if(parseType == ParsingArtistInfo){
        if ([element isEqualToString:@"name"] && !gotArtistName) {
            [self.name appendString:string];
            gotArtistName = YES;
        }
        else if ([element isEqualToString:@"mbid"]) {
            [self.mbid appendString:string];
        }
        else if ([element isEqualToString:@"url"] && !gotArtistURL) {
            [self.url appendString:string];
            gotArtistURL = YES;
        }
        else if ([element isEqualToString:@"image"] && !gotArtistImage) {
            if([attribute isEqualToString:@"small"]){
                [self.smallImageURL appendString:string];
            }
            if([attribute isEqualToString:@"medium"]){
                [self.mediumImageURL appendString:string];
            }
            if([attribute isEqualToString:@"large"]){
                [self.largeImageURL appendString:string];
            }
            if([attribute isEqualToString:@"extralarge"]){
                [self.extraLargeImageURL appendString:string];
                gotArtistImage = YES;
            }
            if([attribute isEqualToString:@"mega"]){
                [self.megaLargeImageURL appendString:string];
            }
        }
        else if ([element isEqualToString:@"streamable"]) {
            [self.streamable appendString:string];
        }
        else if ([element isEqualToString:@"listeners"]) {
            [self.listenersCount appendString:string];
        }
        else if ([element isEqualToString:@"playcount"]) {
            [self.playCount appendString:string];
        }
        else if ([element isEqualToString:@"playcount"]) {
            [self.playCount appendString:string];
        }
        else if ([element isEqualToString:@"name"] && gotArtistName && handledTag) {
            [similarArtistName appendString:string];
            handledSimilarArtist = YES;
        }
        else if ([element isEqualToString:@"url"] && gotArtistURL && handledTag) {
            [similarArtistURL appendString:string];
            handledSimilarArtist = YES;
        }
        else if ([element isEqualToString:@"image"] && gotArtistImage && handledTag) {
            if([attribute isEqualToString:@"large"]){
                [similarArtistImage appendString:string];
                handledSimilarArtist = YES;
            }
        }
        else if ([element isEqualToString:@"name"] && !handledTag) {
            [tagName appendString:string];
            handledTag = YES;
        }
        else if ([element isEqualToString:@"summary"]) {
            [self.bioSummary appendString:string];
        }
        else if ([element isEqualToString:@"content"]) {
            [self.bioContent appendString:string];
        }
        else if ([element isEqualToString:@"yearformed"]) {
            [self.yearFormed appendString:string];
        }
    }
    else if(parseType == ParsingSimilarArtists){
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
    
    if(parseType == ParsingArtistInfo){
        if([elementName isEqualToString:@"artist"]){
            if(handledSimilarArtist){
                [similarArtist setObject:similarArtistName forKey:@"name"];
                [similarArtist setObject:similarArtistURL forKey:@"url"];
                [similarArtist setObject:similarArtistImage forKey:@"imageURL"];
                
                [self.similar addObject:[similarArtist copy]];
                
                similarArtist = [[NSMutableDictionary alloc] init];
                similarArtistName = [[NSMutableString alloc] init];
                similarArtistURL = [[NSMutableString alloc] init];
                similarArtistImage = [[NSMutableString alloc] init];
                handledSimilarArtist = NO;
            }
        }
        
        if([elementName isEqualToString:@"tag"]){
            if(handledTag){
                [self.tags addObject:[tagName copy]];
                tagName = [[NSMutableString alloc] init];
                handledTag = NO;
            }
        }
    }
    else if(parseType == ParsingSimilarArtists){
        if ([element isEqualToString:@"name"]) {
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
        else if([element isEqualToString:@"match"]) {
            /* Remove leading and trailing whitespace */
            similarArtistMatchValue = (NSMutableString *) [similarArtistMatchValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            /* Remove accent marks */
            similarArtistMatchValue = (NSMutableString *)[similarArtistMatchValue stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
            
            [similarArtist setObject:similarArtistMatchValue forKey:@"matchValue"];
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
        else if([element isEqualToString:@"streamable"]){
            if(!handledSimilarArtist){
                [similars addObject:[similarArtist copy]];
                handledSimilarArtist = YES;
            }
        }
    }
    
    
}


-(void) parserDidEndDocument:(NSXMLParser *)parser
{
    handledSimilarArtist = NO;
    handledTag = NO;
}


#pragma mark - NSObject Overrides

- (NSString *) description
{
    NSString *result = [NSString stringWithFormat:@"%@ \rName: %@ \rSmallImage: %@ \rMediumImage: %@ \rLargeImage: %@ \rExtraLargeImage: %@ \rMegaLargeImage: %@ \rlfmURL: %@", [super description], self.name, self.smallImageURL, self.mediumImageURL, self.largeImageURL, self.extraLargeImageURL, self.megaLargeImageURL, self.url];
    
    return result;
}



@end
