//
//  SPGooglePlacesAutocompletePlace.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompletePlace.h"
#import "SPGooglePlacesPlaceDetailQuery.h"

#define kNSCodingKeyName @"name"
#define kNSCodingKeyReference @"reference"
#define kNSCodingKeyIdentifier @"id"
#define kNSCodingKeyType @"type"
#define kNSCodingKeyMatchedRangeLoc @"matchedRangeLoc"
#define kNSCodingKeyMatchedRangeLen @"matchedRangeLen"
#define kNSCodingKeyComponents @"components"

@interface SPGooglePlacesAutocompletePlace()
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *reference;
@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, readwrite) NSRange matchedRange;
@property (nonatomic, strong, readwrite) NSArray *components;
@property (nonatomic, readwrite) SPGooglePlacesAutocompletePlaceType type;
@end

@implementation SPGooglePlacesAutocompletePlace

@synthesize name, reference, identifier, type, matchedRange, components;

+ (SPGooglePlacesAutocompletePlace *)placeFromDictionary:(NSDictionary *)placeDictionary {
    SPGooglePlacesAutocompletePlace *place = [[self alloc] init];
    place.name = placeDictionary[@"description"];
    place.reference = placeDictionary[@"reference"];
    place.identifier = placeDictionary[@"id"];
    place.type = SPPlaceTypeFromDictionary(placeDictionary);
    place.matchedRange = NSMakeRange([placeDictionary[@"matched_substrings"][0][@"offset"] intValue], [placeDictionary[@"matched_substrings"][0][@"length"] intValue]);
    place.components = [placeDictionary valueForKeyPath:@"terms.value"];
    return place;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Name: %@, Reference: %@, Identifier: %@, Type: %@",
            name, reference, identifier, SPPlaceTypeStringForPlaceType(type)];
}

- (CLGeocoder *)geocoder {
    if (!geocoder) {
        geocoder = [[CLGeocoder alloc] init];
    }
    return geocoder;
}

- (void)resolveEstablishmentPlaceToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    SPGooglePlacesPlaceDetailQuery *query = [SPGooglePlacesPlaceDetailQuery query];
    query.reference = self.reference;
    [query fetchPlaceDetail:^(NSDictionary *placeDictionary, NSError *error) {
        if (error) {
            block(nil, nil, error);
        } else {
            CLGeocodeCompletionHandler geocodeHandler = ^(NSArray *placemarks, NSError *error) {
                if (error) {
                    block(nil, nil, error);
                } else {
                    CLPlacemark *placemark = [placemarks onlyObject];
                    block(placemark, self.name, error);
                }
            };
            
            NSNumber *lat = [placeDictionary valueForKeyPath:@"geometry.location.lat"];
            NSNumber *lng = [placeDictionary valueForKeyPath:@"geometry.location.lng"];
            if (lat&&lng) {
                CLLocation *location = [[CLLocation alloc] initWithLatitude:lat.doubleValue longitude:lng.doubleValue];
                [[self geocoder] reverseGeocodeLocation:location completionHandler:geocodeHandler];
            } else {
                NSString *addressString = [placeDictionary objectForKey:@"formatted_address"];
                [[self geocoder] geocodeAddressString:addressString completionHandler:geocodeHandler];
            }
        }
    }];
}

- (void)resolveGecodePlaceToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    [[self geocoder] geocodeAddressString:self.name completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            block(nil, nil, error);
        } else {
            CLPlacemark *placemark = [placemarks onlyObject];
            block(placemark, self.name, error);
        }
    }];
}

- (void)resolveToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    if (type == SPPlaceTypeGeocode) {
        // Geocode places already have their address stored in the 'name' field.
        [self resolveGecodePlaceToPlacemark:block];
    } else {
        [self resolveEstablishmentPlaceToPlacemark:block];
    }
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    SPGooglePlacesAutocompletePlace *place = [[SPGooglePlacesAutocompletePlace alloc] init];
    place.name = [aDecoder decodeObjectForKey:kNSCodingKeyName];
    place.reference = [aDecoder decodeObjectForKey:kNSCodingKeyReference];
    place.identifier = [aDecoder decodeObjectForKey:kNSCodingKeyIdentifier];
    place.type = [aDecoder decodeIntForKey:kNSCodingKeyType];
    place.matchedRange = NSMakeRange([aDecoder decodeIntForKey:kNSCodingKeyMatchedRangeLoc], [aDecoder decodeIntForKey:kNSCodingKeyMatchedRangeLen]);
    place.components = [aDecoder decodeObjectForKey:kNSCodingKeyComponents];
    return place;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:name forKey:kNSCodingKeyName];
    [aCoder encodeObject:reference forKey:kNSCodingKeyReference];
    [aCoder encodeObject:identifier forKey:kNSCodingKeyIdentifier];
    [aCoder encodeInt:type forKey:kNSCodingKeyType];
    [aCoder encodeInt:matchedRange.location forKey:kNSCodingKeyMatchedRangeLoc];
    [aCoder encodeInt:matchedRange.length forKey:kNSCodingKeyMatchedRangeLen];
    [aCoder encodeObject:components forKey:kNSCodingKeyComponents];
}


@end
