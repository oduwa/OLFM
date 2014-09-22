//
//  OLFMEvent.h
//  Jive
//
//  Created by Odie Edo-Osagie on 17/07/2014.
//  Copyright (c) 2014 Odie Edo-Osagie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLFMArtist.h"
#import "OLFMVenue.h"

@interface OLFMEvent : NSObject

@property (nonatomic, strong) NSString *eventID;
@property (nonatomic, strong) NSString *eventTitle;
@property (nonatomic, strong) NSMutableArray *artistNames;
@property (nonatomic, strong) OLFMArtist *headliner; // has only name set. call [OLFMArtist fill] to get remaining data
@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) OLFMVenue *venue;
@property (nonatomic, strong) NSString *eventDescription;
@property (nonatomic, strong) NSString *attendanceCount;
@property (nonatomic, strong) NSString *reviews;
@property (nonatomic, strong) NSString *URL;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSArray *ticketlinks;
@property (nonatomic, strong) NSString *smallImageURL;
@property (nonatomic, strong) NSString *mediumImageURL;
@property (nonatomic, strong) NSString *largeImageURL;
@property (nonatomic, strong) NSString *extraLargeImageURL;
@property (nonatomic, strong) NSString *megaLargeImageURL;





- (instancetype) initWithEventID:(NSString *) event_id;
- (void) fill;









@end
