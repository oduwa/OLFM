//
//  OLFMManager.m
//  Jive
//
//  Created by Odie Edo-Osagie on 12/06/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import "OLFMManager.h"


static OLFMManager *globalInstance = nil;

@implementation OLFMManager{
    CLGeocoder *geoCoder;
}


@synthesize API_KEY;
@synthesize country;
@synthesize locationManager;
@synthesize currentLocation;


+ (OLFMManager *) sharedManager
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
        API_KEY = [[NSString alloc] init];
        country = [[NSString alloc] init];
        currentLocation = [[CLLocation alloc] init];
        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
    }
    
    return self;
}


/* iVars */
- (void) setAPIKey: (NSString *) key
{
    API_KEY = key;
}


- (NSString *) API_KEY
{
    return API_KEY;
}


#pragma mark - Static Methods

+ (NSString *) escapeString:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    string = [string stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    string = [string stringByReplacingOccurrencesOfString:@"!" withString:@"%21"];
    string = [string stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    string = [string stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    
    NSString *result = string;
    
    return result;
}


#pragma mark - CLLocation Delegate Methods

//- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    currentLocation = [locations lastObject];
//    
//    NSLog(@"LOCATION UPDATE");
//    
//    /* Get country from location */
//    [geoCoder reverseGeocodeLocation: locationManager.location completionHandler:
//     ^(NSArray *placemarks, NSError *error) {
//         
//         
//         
//         if(error || [placemarks count] < 1){
//             
//             NSLog(@"PLACEMARKS ERROR");
//             
//             /* Get country from locale */
//             NSLocale *locale = [NSLocale currentLocale];
//             NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
//             country = [locale displayNameForKey: NSLocaleCountryCode value: countryCode];
//             country = [country stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//             NSLog(@"%@", country);
//         }
//         else{
//             CLPlacemark *placemark = [placemarks objectAtIndex:0];
//             country = placemark.country;
//             NSLog(@"PLACEMARK GOOD: %@", country);
//         }
//         
//         
//         
//     }];
//}


-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if([CLLocationManager locationServicesEnabled])
    {
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied)
        {
            NSLog(@"Permission Denied");
            currentLocation = nil;
            
            /* Get country from locale */
            NSLocale *locale = [NSLocale currentLocale];
            NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
            country = [locale displayNameForKey: NSLocaleCountryCode value: countryCode];
            country = [country stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    else{
        currentLocation = nil;
        
        /* Get country from locale */
        NSLocale *locale = [NSLocale currentLocale];
        NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
        country = [locale displayNameForKey: NSLocaleCountryCode value: countryCode];
        country = [country stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    }
}








@end
