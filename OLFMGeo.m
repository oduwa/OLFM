//
//  OLFMGeo.m
//  Jive
//
//  Created by Odie Edo-Osagie on 13/06/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import "OLFMGeo.h"
#import "OLFMArtist.h"
#import "OLFMManager.h"
#import "OLFMEvent.h"


static OLFMGeo *globalInstance = nil;

@implementation OLFMGeo{
    NSXMLParser *parser;
    NSString *element;
    NSString *attribute;
    NSMutableDictionary *artistData;
    NSMutableArray *artists;
    NSMutableString *name;
    NSMutableString *imageURL;
    
    CLLocation *currentLocation;
    BOOL useLocale;
}


/**
 *
 *  Charts singleton object
 *
 */
+ (OLFMGeo *) geo
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
        currentLocation = [[CLLocation alloc] init];
    }
    
    return self;
}


- (NSArray *) getTopArtistsFromLocaleWithResultsLimit: (NSUInteger) numberOfResults
{
    artists = [[NSMutableArray alloc] init];
    artistData = [[NSMutableDictionary alloc] init];
    NSString *countryName = @"";
    
    if(numberOfResults <= 0){
        numberOfResults =  1;
    }
    
    /* Get country from locale */
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    countryName = [locale displayNameForKey: NSLocaleCountryCode value: countryCode];
    countryName = [countryName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString *API_KEY = [OLFMManager sharedManager].API_KEY;
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=geo.gettopartists&country=%@&api_key=%@&limit=%lu", countryName, API_KEY, (unsigned long)numberOfResults];
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *dict in artists){
        //OLFMArtist *anArtist = [[OLFMArtist alloc] initWithName:aName];
        [result addObject:dict];
    }
    
    return result;
}


- (NSArray *) getHypedArtistsFromLocaleWithResultsLimit: (NSUInteger) numberOfResults
{
    artists = [[NSMutableArray alloc] init];
    artistData = [[NSMutableDictionary alloc] init];
    NSString *countryName = @"";
    
    if(numberOfResults <= 0){
        numberOfResults =  1;
    }
    
    /* Get country from locale */
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    countryName = [locale displayNameForKey: NSLocaleCountryCode value: countryCode];
    countryName = [countryName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString *API_KEY = [OLFMManager sharedManager].API_KEY;
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=geo.gethypedartists&country=%@&api_key=%@&limit=%lu", countryName, API_KEY, (unsigned long)numberOfResults];
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *dict in artists){
        //OLFMArtist *anArtist = [[OLFMArtist alloc] initWithName:aName];
        [result addObject:dict];
    }
    
    return result;
}


- (NSArray *) getTopArtistsWithResultsLimit: (NSUInteger)numberOfResults andCountry: (NSString *) countryName
{
    artists = [[NSMutableArray alloc] init];
    artistData = [[NSMutableDictionary alloc] init];
    
    if(numberOfResults <= 0){
        numberOfResults =  1;
    }
    
    countryName = [countryName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString *API_KEY = [OLFMManager sharedManager].API_KEY;
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=geo.gettopartists&country=%@&api_key=%@&limit=%lu", countryName, API_KEY, (unsigned long)numberOfResults];
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *dict in artists){
        //[result addObject:dict];
        OLFMArtist *artist = [[OLFMArtist alloc] init];
        artist.name = dict[@"name"];
        artist.extraLargeImageURL = dict[@"imageURL"];
        [result addObject:artist];
    }
    
    return result;
}

- (NSArray *) getHypedArtistsWithResultsLimit:(NSUInteger)numberOfResults Country:(NSString *)countryName andCity:(NSString *)cityName
{
    artists = [[NSMutableArray alloc] init];
    artistData = [[NSMutableDictionary alloc] init];
    
    if(numberOfResults <= 0){
        numberOfResults =  1;
    }
    
    countryName = [countryName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString *API_KEY = [OLFMManager sharedManager].API_KEY;
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=geo.getmetrohypeartistchart&metro=%@&country=%@&api_key=%@&limit=%lu",cityName, countryName, API_KEY, (unsigned long)numberOfResults];
    NSURL *url = [NSURL URLWithString:urlString];
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(NSMutableDictionary *dict in artists){
        [result addObject:dict];
    }
    
    return result;
}



- (NSArray *) getEventsInCountry:(NSString *)country withLimit:(NSUInteger)limit
{
    NSError *error;
    
    if([country isEqualToString:@""]){
        NSLog(@"<ERROR> COUNTRY IS EMPTY.");
        return nil;
    }
    
    if(country == nil){
        NSLog(@"<ERROR> COUNTRY IS NULL.");
        return nil;
    }
    
    /* Escaping */
    country = [country stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    country = [OLFMManager escapeString:country];
    
    /* Get event data */
    NSString *API_KEY = [[OLFMManager sharedManager] API_KEY];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=geo.getevents&location=%@&api_key=%@&limit=%d&festivalsonly=0&format=json", country, API_KEY, (int)limit];

    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if(error){
        NSLog(@"<ERROR> AN ERROR OCCURED FETCHING EVENT DATA");
        return nil;
    }
    else{
        return [self fetchEventsFromJSONWithData:data];
    }
}


- (NSArray *) getEventsInCountry:(NSString *)country withinDistance:(float)distance withLimit:(NSUInteger)limit
{
    NSError *error;
    
    if([country isEqualToString:@""]){
        NSLog(@"<ERROR> COUNTRY IS EMPTY.");
        return nil;
    }
    
    if(country == nil){
        NSLog(@"<ERROR> COUNTRY IS NULL.");
        return nil;
    }
    
    /* Escaping */
    country = [country stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    country = [OLFMManager escapeString:country];
    
    /* Get event data */
    NSString *API_KEY = [[OLFMManager sharedManager] API_KEY];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=geo.getevents&location=%@&distance=%f&api_key=%@&limit=%d&festivalsonly=0&format=json", country, distance, API_KEY, (int)limit];
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if(error){
        NSLog(@"<ERROR> AN ERROR OCCURED FETCHING EVENT DATA");
        return nil;
    }
    else{
        return [self fetchEventsFromJSONWithData:data];
    }
}


- (NSArray *) getEventsInLocationWithLatitude:(float)latitude andLongitude:(float)longitude withinDistance:(float)distance withLimit:(NSUInteger)limit
{
    NSError *error;
    
    if(limit <= 0){
        NSLog(@"<WARNING> LIMIT IS LESS THAN OR EQUAL TO 0.");
    }
    
    if(distance <= 0){
        NSLog(@"<WARNING> DISTANCE IS LESS THAN OR EQUAL TO 0.");
    }
    
    /* Get event data */
    NSString *API_KEY = [[OLFMManager sharedManager] API_KEY];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=geo.getevents&lat=%f&long=%f&distance=%f&api_key=%@&limit=%d&festivalsonly=0&format=json", latitude, longitude, distance, API_KEY, (int)limit];
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if(error){
        NSLog(@"<ERROR> AN ERROR OCCURED FETCHING EVENT DATA");
        return nil;
    }
    else{
        return [self fetchEventsFromJSONWithData:data];
    }
}


- (NSArray *) getEventsInLocationWithLatitude:(float)latitude andLongitude:(float)longitude withLimit:(NSUInteger)limit
{
    NSError *error;
    
    if(limit <= 0){
        NSLog(@"<WARNING> LIMIT IS LESS THAN OR EQUAL TO 0.");
    }
    
    /* Get event data */
    NSString *API_KEY = [[OLFMManager sharedManager] API_KEY];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=geo.getevents&lat=%f&long=%f&api_key=%@&limit=%d&festivalsonly=0&format=json", latitude, longitude, API_KEY, (int)limit];
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if(error){
        NSLog(@"<ERROR> AN ERROR OCCURED FETCHING EVENT DATA");
        return nil;
    }
    else{
        return [self fetchEventsFromJSONWithData:data];
    }
}

#pragma mark - Helper Methods

- (NSArray *) fetchEventsFromJSONWithData:(NSData *) data
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSError *error;
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if(error){
        NSLog(@"<ERROR> AN ERROR OCCURED FETCHING EVENT DATA");
        return nil;
    }
    
    if([json[@"events"][@"event"] isKindOfClass:[NSArray class]]){
        NSArray *results = json[@"events"][@"event"];
        
        for(NSDictionary *eventDictionary in results){
            OLFMEvent *event = [[OLFMEvent alloc] init];
            
            if([eventDictionary[@"artists"][@"artist"] isKindOfClass:[NSString class]]){
                [event.artistNames addObject:eventDictionary[@"artists"][@"artist"]];
            }
            else if([eventDictionary[@"artists"][@"artist"] isKindOfClass:[NSArray class]]){
                event.artistNames = eventDictionary[@"artists"][@"artist"];
            }
            
            event.headliner.name = eventDictionary[@"artists"][@"headliner"];
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
        event.artistNames = eventDictionary[@"artists"][@"artist"];
        event.headliner.name = eventDictionary[@"artists"][@"headliner"];
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
    
    return result;
}



#pragma mark - NSXML Delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if ([element isEqualToString:@"name"]) {
        name = [[NSMutableString alloc] init];
    }
    else if([element isEqualToString:@"image"]) {
        imageURL = [[NSMutableString alloc] init];
    }
    
    attribute = [attributeDict objectForKey:@"size"];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([element isEqualToString:@"name"]) {
        [name appendString:string];
    }
    else if([element isEqualToString:@"image"]) {
        if([attribute isEqualToString:@"extralarge"]){
            [imageURL appendString:string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
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



















@end
