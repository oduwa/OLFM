//
//  OLFMVenue.h
//  Jive
//
//  Created by Odie Edo-Osagie on 17/07/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLFMManager.h"

@interface OLFMVenue : NSObject

typedef struct {
    float latitude;
    float longitude;
} OLFMGeoLocation;

@property (nonatomic, strong) NSString *venueID;
@property (nonatomic, strong) NSString *venueName;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, assign) OLFMGeoLocation location;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *smallImageURL;
@property (nonatomic, strong) NSString *mediumImageURL;
@property (nonatomic, strong) NSString *largeImageURL;
@property (nonatomic, strong) NSString *extraLargeImageURL;
@property (nonatomic, strong) NSString *megaLargeImageURL;


@end


