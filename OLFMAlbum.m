//
//  OLFMAlbum.m
//  Jive
//
//  Created by Odie Edo-Osagie on 26/06/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import "OLFMAlbum.h"
#import "OLFMManager.h"
#import "OLFMTrack.h"

@implementation OLFMAlbum


- (instancetype) init
{
    self = [super init];
    
    if(self){
        self.name = [[NSMutableString alloc] init];
        self.artistName = [[NSMutableString alloc] init];
        self.artist = [[OLFMArtist alloc] init];
        self.LFMid = [[NSMutableString alloc] init];
        self.mbid = [[NSMutableString alloc] init];
        self.url = [[NSMutableString alloc] init];
        self.releaseDate = [[NSMutableString alloc] init];
        self.smallImageURL = [[NSMutableString alloc] init];
        self.mediumImageURL = [[NSMutableString alloc] init];
        self.largeImageURL = [[NSMutableString alloc] init];
        self.extraLargeImageURL = [[NSMutableString alloc] init];
        self.megaLargeImageURL = [[NSMutableString alloc] init];
        self.tracks = [[NSMutableArray alloc] init];
        self.playCount = [[NSMutableString alloc] init];
        self.listenersCount = [[NSMutableString alloc] init];
        self.albumInfoSummary = [[NSMutableString alloc] init];
        self.albumInfoContent = [[NSMutableString alloc] init];
        self.tags = [[NSMutableArray alloc] init];
    }
    
    return self;
}


- (instancetype) initWithName: (NSString *)nameOfAlbum andArtist: (NSString *)nameOfArtist
{
    self = [self init];
    
    if(self){
        [self fetchInfoWithTrack:nameOfAlbum andArtist:nameOfArtist];
        if([self.name isEqualToString:@""]){
            return nil;
        }
    }
    
    return self;
}


/**
 *
 *  Connects to Last.fm to get artists information using JSON format
 *
 */
- (void) fetchInfoWithTrack:(NSString *)nameOfAlbum andArtist:(NSString *)nameOfArtist
{
    NSError* error;
    
    if([nameOfAlbum isEqualToString:@""] || [nameOfArtist isEqualToString:@""]){
        NSLog(@"WARNING: Empty Parameter");
    }
    
    if(nameOfAlbum == nil || nameOfArtist == nil){
        NSLog(@"WARNING: NULL Parameter");
    }
    
    NSString *APIKey = [OLFMManager sharedManager].API_KEY;
    
    /* Escaping */
    nameOfArtist = [nameOfArtist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    nameOfAlbum = [nameOfAlbum stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    nameOfArtist = [OLFMManager escapeString:nameOfArtist];
    nameOfAlbum = [OLFMManager escapeString:nameOfAlbum];
    
    /* Fetching JSON data */
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=album.getinfo&api_key=%@&artist=%@&album=%@&format=json&autocorrect=1", APIKey, nameOfArtist, nameOfAlbum];
    NSLog(@"ESCAPED ALBUM URL: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSData* data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if(!error){
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        /* Populating OLFMAlbum object with json data */
        NSDictionary *albumDictionary = json[@"album"];
        
        self.artistName = albumDictionary[@"artist"];
        self.LFMid = albumDictionary[@"id"];
        
        NSArray *imagesArray = albumDictionary[@"image"];
        for(NSDictionary *imageDictionary in imagesArray){
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
        
        self.listenersCount = albumDictionary[@"listeners"];
        self.mbid = albumDictionary[@"mbid"];
        self.name = albumDictionary[@"name"];
        self.playCount = albumDictionary[@"playcount"];
        self.releaseDate = albumDictionary[@"releasedate"];
        
        self.releaseDate = (NSMutableString *) [self.releaseDate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        if([albumDictionary[@"toptags"] respondsToSelector:@selector(objectForKeyedSubscript:)]){
            if([albumDictionary[@"toptags"][@"tag"] respondsToSelector:@selector(objectForKeyedSubscript:)]){
                [self.tags addObject:albumDictionary[@"toptags"][@"tag"][@"name"]];
            }
            else{
                for(NSDictionary *tagDictionary in albumDictionary[@"toptags"][@"tag"]){
                    [self.tags addObject:tagDictionary[@"name"]];
                }
            }
            
        }
        
        NSArray *tracksArray;
        if([albumDictionary[@"tracks"] respondsToSelector:@selector(objectForKeyedSubscript:)]){
            if([albumDictionary[@"tracks"][@"track"] respondsToSelector:@selector(objectForKeyedSubscript:)]){
                NSDictionary *tracksDictionary = albumDictionary[@"tracks"][@"track"];
                OLFMTrack *track = [[OLFMTrack alloc] init];
                track.name = tracksDictionary[@"name"];
                track.mbid = tracksDictionary[@"mbid"];
                track.duration = tracksDictionary[@"duration"];
                track.trackURL = tracksDictionary[@"url"];
                track.artistName = self.artistName;
                track.albumName = self.name;
                
                [self.tracks addObject:track];
            }
            else{
                tracksArray = albumDictionary[@"tracks"][@"track"];
                for(NSDictionary *tracksDictionary in tracksArray){
                    OLFMTrack *track = [[OLFMTrack alloc] init];
                    track.name = tracksDictionary[@"name"];
                    track.mbid = tracksDictionary[@"mbid"];
                    track.duration = tracksDictionary[@"duration"];
                    track.trackURL = tracksDictionary[@"url"];
                    track.artistName = self.artistName;
                    track.albumName = self.name;
                    
                    [self.tracks addObject:track];
                }
            }
            
        }
        
        self.url = albumDictionary[@"url"];
        self.albumInfoSummary = albumDictionary[@"wiki"][@"summary"];
        self.albumInfoContent = albumDictionary[@"wiki"][@"content"];
    }
    else{
        NSLog(@"ERROR: %@", error);
    }
}


#pragma mark - Instance and Class Methods

- (OLFMArtist *) getArtist
{
    if(![self.artistName isEqualToString:@""]){
        return [[OLFMArtist alloc] initWithName:self.artistName];
    }
    else {
        NSLog(@"<WARNING>: ARTIST NAME IS EMPTY OR NIL");
        return nil;
    }
}


- (NSArray *) getDigitalBuyLinksForCountry:(NSString *)country
{
    NSMutableArray *links = [[NSMutableArray alloc] init];
    
    if([self.artistName isEqualToString:@""] || self.artistName == nil){
        NSLog(@"<ERROR>: COULD NOT FETCH LINKS. ARTIST NAME IS EMPTY OR NULL");
        return nil;
    }
    
    if([self.name isEqualToString:@""] || self.name == nil){
        NSLog(@"<ERROR>: COULD NOT FETCH LINKS. ALBUM NAME IS EMPTY OR NULL");
        return nil;
    }
    
    if([country isEqualToString:@""] || country == nil){
        NSLog(@"<ERROR>: COULD NOT FETCH LINKS. COUNTRY IS EMPTY OR NULL");
        return nil;
    }
    
    NSString *artist = [_artistName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *album = [_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    country = [country stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *APIKey = [OLFMManager sharedManager].API_KEY;
    NSError *error;
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=album.getbuylinks&artist=%@&album=%@&country=%@&api_key=%@&format=json&autocorrect=1", artist, album, country, APIKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData* data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if(!error){
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSDictionary *result = json[@"affiliations"];
        
        if([result[@"downloads"] isKindOfClass:[NSDictionary class]]){
            if([result[@"downloads"][@"affiliation"] isKindOfClass:[NSArray class]]){
                NSArray *affiliations = result[@"downloads"][@"affiliation"];
                
                for(int i = 0; i < [affiliations count]; i++){
                    if([affiliations[i] isKindOfClass:[NSDictionary class]]){
                        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
                        
                        item[@"buyLink"] = affiliations[i][@"buyLink"];
                        item[@"isSearch"] = affiliations[i][@"isSearch"];
                        item[@"supplierIconURL"] = affiliations[i][@"supplierIcon"];
                        item[@"supplierName"] = affiliations[i][@"supplierName"];
                        
                        if([affiliations[i][@"price"] isKindOfClass:[NSDictionary class]]){
                            item[@"priceAmount"] = affiliations[i][@"price"][@"amount"];
                            item[@"priceCurrency"] = affiliations[i][@"price"][@"currency"];
                            item[@"priceCurrencyFormatted"] = affiliations[i][@"price"][@"formatted"];
                            NSString *string = item[@"priceCurrencyFormatted"];
                            item[@"priceCurrencyFormatted"] = [[NSString alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding];
                        }
                        
                        [links addObject:item];
                    }
                }
            }
            else if([result[@"downloads"][@"affiliation"] isKindOfClass:[NSDictionary class]]){
                NSDictionary *affiliations = result[@"downloads"][@"affiliation"];
                NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
                
                item[@"buyLink"] = affiliations[@"buyLink"];
                item[@"isSearch"] = affiliations[@"isSearch"];
                item[@"supplierIconURL"] = affiliations[@"supplierIcon"];
                item[@"supplierName"] = affiliations[@"supplierName"];
                
                if([affiliations[@"price"] isKindOfClass:[NSDictionary class]]){
                    item[@"priceAmount"] = affiliations[@"price"][@"amount"];
                    item[@"priceCurrency"] = affiliations[@"price"][@"currency"];
                    item[@"priceCurrencyFormatted"] = affiliations[@"price"][@"formatted"];
                }
                
                [links addObject:item];
            }
        }
    }
    else{
        NSLog(@"<ERROR> FAILED TO FETCH DATA WITH ERROR: %@", error);
    }

    return links;
}


- (NSArray *) getPhysicalBuyLinksForCountry:(NSString *)country
{
    NSMutableArray *links = [[NSMutableArray alloc] init];
    
    if([self.artistName isEqualToString:@""] || self.artistName == nil){
        NSLog(@"<ERROR>: COULD NOT FETCH LINKS. ARTIST NAME IS EMPTY OR NULL");
        return nil;
    }
    
    if([self.name isEqualToString:@""] || self.name == nil){
        NSLog(@"<ERROR>: COULD NOT FETCH LINKS. ALBUM NAME IS EMPTY OR NULL");
        return nil;
    }
    
    if([country isEqualToString:@""] || country == nil){
        NSLog(@"<ERROR>: COULD NOT FETCH LINKS. COUNTRY IS EMPTY OR NULL");
        return nil;
    }
    
    NSString *artist = [_artistName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *album = [_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    country = [country stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *APIKey = [OLFMManager sharedManager].API_KEY;
    NSError *error;
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=album.getbuylinks&artist=%@&album=%@&country=%@&api_key=%@&format=json&autocorrect=1", artist, album, country, APIKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData* data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if(!error){
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSDictionary *result = json[@"affiliations"];
        
        if([result[@"physicals"] isKindOfClass:[NSDictionary class]]){
            if([result[@"physicals"][@"affiliation"] isKindOfClass:[NSArray class]]){
                NSArray *affiliations = result[@"physicals"][@"affiliation"];
                
                for(int i = 0; i < [affiliations count]; i++){
                    if([affiliations[i] isKindOfClass:[NSDictionary class]]){
                        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
                        
                        item[@"buyLink"] = affiliations[i][@"buyLink"];
                        item[@"isSearch"] = affiliations[i][@"isSearch"];
                        item[@"supplierIconURL"] = affiliations[i][@"supplierIcon"];
                        item[@"supplierName"] = affiliations[i][@"supplierName"];
                        
                        if([affiliations[i][@"price"] isKindOfClass:[NSDictionary class]]){
                            item[@"priceAmount"] = affiliations[i][@"price"][@"amount"];
                            item[@"priceCurrency"] = affiliations[i][@"price"][@"currency"];
                            item[@"priceCurrencyFormatted"] = affiliations[i][@"price"][@"formatted"];
                            NSString *string = item[@"priceCurrencyFormatted"];
                            item[@"priceCurrencyFormatted"] = [[NSString alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding];
                        }
                        
                        [links addObject:item];
                    }
                }
            }
            else if([result[@"physicals"][@"affiliation"] isKindOfClass:[NSDictionary class]]){
                NSDictionary *affiliations = result[@"physicals"][@"affiliation"];
                NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
                
                item[@"buyLink"] = affiliations[@"buyLink"];
                item[@"isSearch"] = affiliations[@"isSearch"];
                item[@"supplierIconURL"] = affiliations[@"supplierIcon"];
                item[@"supplierName"] = affiliations[@"supplierName"];
                
                if([affiliations[@"price"] isKindOfClass:[NSDictionary class]]){
                    item[@"priceAmount"] = affiliations[@"price"][@"amount"];
                    item[@"priceCurrency"] = affiliations[@"price"][@"currency"];
                    item[@"priceCurrencyFormatted"] = affiliations[@"price"][@"formatted"];
                }
                
                [links addObject:item];
            }
        }
    }
    else{
        NSLog(@"<ERROR> FAILED TO FETCH DATA WITH ERROR: %@", error);
    }
    
    return links;
}









#pragma mark - Description

- (NSString *) description
{
    NSString *description = [NSString stringWithFormat:@"%@ \nName: %@ \nArtistName: %@ \nLFMID: %@ \nMBID: %@ \nSmallImageURL: %@ \nMediumImageURL: %@ \nLargeImageURL: %@ \nExtraLargeImageURL: %@ \nMegaImageURL: %@ \nListeners: %@  \nPlayCount: %@ \nReleaseDate: %@ \nTags: %@ \nTracks: %@ \nURL: %@ \nSummary: %@ \nContent: %@", [super description], self.name, self.artistName, self.LFMid, self.mbid, self.smallImageURL, self.mediumImageURL, self.largeImageURL, self.extraLargeImageURL, self.megaLargeImageURL, self.listenersCount, self.playCount, self.releaseDate, self.tags, self.tracks, self.url, self.albumInfoSummary, self.albumInfoContent];
    
    return description;
}





















@end
