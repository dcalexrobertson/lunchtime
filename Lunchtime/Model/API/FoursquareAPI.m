//
//  FoursquareAPI.m
//  Lunchtime
//
//  Created by Alex on 2015-11-15.
//  Copyright © 2015 Alex. All rights reserved.
//

#import "FoursquareAPI.h"
#import "LunchtimeLocationManager.h"
#import "Restaurant.h"
#import "User.h"

static NSString *kResultsLimit = @"&limit=50";
static NSString *kClientID = @"CGH3OKEERY3MSUZGPHQVDS2PCPLQEJ5TLTDPG0GRN02J50GL";
static NSString *kClientSecret =@"1C5YTYJ4JM2Y1OEOIN0WKXMI33TS4Q4LFEEIPW0WSR2TW3FY";
static NSString *kExploreAPIURL = @"https://api.foursquare.com/v2/venues/explore?v=20151101";

@interface FoursquareAPI ()

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end

@implementation FoursquareAPI

- (instancetype)initWithLocation:(CLLocation *)location {
    self = [super init];
    if (self) {
        _latitude = location.coordinate.latitude;
        _longitude = location.coordinate.longitude;
    }
    return self;
}

- (void)createRestaurants:(NSArray *)restaurants {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    for (NSDictionary *restaurant in restaurants) {
        
        Restaurant *newRestaurant = [[Restaurant alloc] init];

        newRestaurant.name = restaurant[@"venue"][@"name"];
    
        NSArray *formattedAddress = restaurant[@"venue"][@"location"][@"formattedAddress"];
        newRestaurant.address = [NSString stringWithFormat:@"%@ %@", formattedAddress[0], formattedAddress[1]];
        
        NSNumber *lat = restaurant[@"venue"][@"location"][@"lat"];
        NSNumber *lng = restaurant[@"venue"][@"location"][@"lng"];
        newRestaurant.coordinate = CLLocationCoordinate2DMake([lat doubleValue],[lng doubleValue]);
        
        // newRestaurant.URL = restaurant[@"venue"][@"url"];
        
        newRestaurant.category = restaurant[@"venue"][@"categories"][@"name"];
    
        [Restaurant createOrUpdateInRealm:realm withValue:newRestaurant];
    }
    
    [realm commitWriteTransaction];
}

- (void)findRestaurantsForUser:(User *)user withCompletionHandler:(void (^)(void))completionHandler {
    
    __block NSArray *restaurantsArray = [NSArray new];
    
    NSString *location = [NSString stringWithFormat:@"&ll=%f,%f", self.latitude, self.longitude];
    NSString *price = [NSString stringWithFormat:@"&price=%u", user.priceLimit + 1];
    NSString *radius = @"&radius=1500";
    
    NSString *exploreAPI = [NSString stringWithFormat:@"%@&client_id=%@&client_secret=%@", kExploreAPIURL, kClientID, kClientSecret];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@%@%@%@", exploreAPI, kResultsLimit, location, price, radius];
    
    NSLog(@"%@", URLString);
    
    NSURL *url = [NSURL URLWithString:URLString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            
            NSError *jsonError = nil;
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            restaurantsArray = jsonDict[@"response"][@"groups"][0][@"items"];
            
            [self createRestaurants:restaurantsArray];
            
        }
        
    }];
                            
    [task resume];
}

@end
