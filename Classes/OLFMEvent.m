//
//  OLFMEvent.m
//  Jive
//
//  Created by Odie Edo-Osagie on 17/07/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import "OLFMEvent.h"

@implementation OLFMEvent



- (id) init
{
    self = [super init];
    
    if(self){
        self.headliner = [[OLFMArtist alloc] init];
        self.artistNames = [[NSMutableArray alloc] init];
    }
    
    return self;
}


- (instancetype) initWithEventID:(NSString *) event_id
{
    self = [self init];
    
    if([event_id isEqualToString:@""]){
        NSLog(@"<ERROR> EVENT ID IS EMPTY.");
        return nil;
    }
    
    if(!event_id){
        NSLog(@"<ERROR> EVENT ID IS NULL.");
        return nil;
    }
    
    [self fetchInfoForEventWithId:event_id];
    
    return self;
}


- (void) fetchInfoForEventWithId: (NSString *) event_id
{
    NSError *error;
    
    if([event_id isEqualToString:@""]){
        NSLog(@"<ERROR> EVENT ID IS EMPTY.");
        return;
    }
    
    if(!event_id){
        NSLog(@"<ERROR> EVENT ID IS NULL.");
        return;
    }
    
    /* Get event info as JSON and store as a dictionary */
    NSString *API_KEY = [[OLFMManager sharedManager] API_KEY];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=event.getinfo&event=%@&api_key=%@&format=json",
                           event_id, API_KEY];
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if(error){
        NSLog(@"<ERROR> AN ERROR OCCURED FETCHING EVENT DATA");
        return;
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if(error){
        NSLog(@"<ERROR> AN ERROR OCCURED FETCHING EVENT DATA");
        return;
    }

    NSDictionary *result = json[@"event"];
    
    if([result[@"artists"] isKindOfClass:[NSDictionary class]]){
        self.headliner.name = result[@"artists"][@"headliner"];
        if([result[@"artists"][@"artist"] isKindOfClass:[NSArray class]]){
            self.artistNames = result[@"artists"][@"artist"];
        }
        else{
            [self.artistNames addObject:result[@"artists"][@"artist"]];
        }
        
    }
    
    self.attendanceCount = result[@"attendance"];
    self.eventDescription = result[@"description"];
    self.eventID = result[@"id"];
    
    if([result[@"image"] isKindOfClass:[NSArray class]]){
        NSArray *imagesArray = result[@"image"];
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
    
    self.reviews = result[@"reviews"];
    self.startDate = result[@"startDate"];
    
    if([result[@"tickets"] isKindOfClass:[NSDictionary class]]){
        // TODO: Not yet sure how ticket data is stored. Couldnt find examples
    }
    else if([result[@"tickets"] isKindOfClass:[NSArray class]]){
        // TODO: Not yet sure how ticket data is stored. Couldnt find examples
    }
    
    self.eventTitle = result[@"title"];
    self.URL = result[@"url"];
    
    if([result[@"venue"] isKindOfClass:[NSDictionary class]]){
        OLFMVenue *venue = [[OLFMVenue alloc] init];
        venue.venueID = result[@"venue"][@"id"];
        
        if([result[@"venue"][@"image"] isKindOfClass:[NSArray class]]){
            NSArray *imagesArray = result[@"venue"][@"image"];
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
        
        if([result[@"venue"][@"location"] isKindOfClass:[NSDictionary class]]){
            venue.city = result[@"venue"][@"location"][@"city"];
            venue.country = result[@"venue"][@"location"][@"country"];
            if([result[@"venue"][@"location"][@"geo:point"] isKindOfClass:[NSDictionary class]]){
                NSString *lat = result[@"venue"][@"location"][@"geo:point"][@"geo:lat"];
                NSString *lon = result[@"venue"][@"location"][@"geo:point"][@"geo:long"];
                venue.location = (OLFMGeoLocation){.latitude=[lat floatValue], .longitude=[lon floatValue]};
            }
            venue.postalCode = result[@"venue"][@"location"][@"postalcode"];
            venue.street = result[@"venue"][@"location"][@"street"];
        }
        
        venue.venueName = result[@"venue"][@"name"];
        venue.phoneNumber = result[@"venue"][@"phonenumber"];
        venue.url = result[@"venue"][@"url"];
        venue.website = result[@"venue"][@"website"];
        self.venue = venue;
    }
    
    self.website = result[@"website"];
}


- (void) fill
{
    [self fetchInfoForEventWithId:self.eventID];
}


- (NSString *) description
{
    NSString *result = [NSString stringWithFormat:@"%@ \rEvent ID: %@ \rEvent Title: %@ \rHeadlinier: %@ \rArtists: %@ \rStart Date: %@ \rVenue: %@ \rDescription: %@ \rAttendance: %@ \rReviews: %@ \rURL: %@ \rWebsite: %@ \rTicketLinks: %@ \rSmallImage: %@ \rMediumImage: %@ \rLargeImage: %@ \rXLImage: %@ \rMegaImage: %@", [super description], _eventID, _eventTitle, _headliner, _artistNames, _startDate, _venue, _eventDescription, _attendanceCount, _reviews, _URL, _website, _ticketlinks, _smallImageURL, _mediumImageURL, _largeImageURL, _extraLargeImageURL, _megaLargeImageURL];
    
    return  result;
}





@end
