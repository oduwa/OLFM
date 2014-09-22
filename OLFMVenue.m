//
//  OLFMVenue.m
//  Jive
//
//  Created by Odie Edo-Osagie on 17/07/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import "OLFMVenue.h"


@implementation OLFMVenue

- (NSString *) description
{
    NSString *result = [NSString stringWithFormat:@"%@ Venue ID: %@ \nVenue Name: %@ \nStreet: %@ \nCity: %@ \nCountry: %@ \nPostalCode: %@ \nLatitude: %f \nLongitude: %f \nURL: %@ \nWebsite: %@ \nPhone Number: %@ \nSmallImage: %@ \nMediumImage: %@ \nLargeImage: %@ \nXLImage: %@ \nMegaImage: %@", [super description], _venueID, _venueName, _street, _city, _country, _postalCode, _location.latitude, _location.longitude, _url, _website, _phoneNumber, _smallImageURL, _mediumImageURL, _largeImageURL, _extraLargeImageURL, _megaLargeImageURL];
    
    return result;
}


@end
