//
//  SPGooglePlacesAutocompleteUtilities.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/18/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SPGooglePlacesAutocompleteUtilities.h"
#import "SPGooglePlacesPlacemark.h"

@implementation NSArray(SPFoundationAdditions)
- (id)onlyObject {
    return [self count] == 1 ? [self objectAtIndex:0] : nil;
}
@end

SPGooglePlacesAutocompletePlaceType SPPlaceTypeFromDictionary(NSDictionary *placeDictionary) {
    return [[placeDictionary objectForKey:@"types"] containsObject:@"establishment"] ? SPPlaceTypeEstablishment : SPPlaceTypeGeocode;
}

NSString *SPBooleanStringForBool(BOOL boolean) {
    return boolean ? @"true" : @"false";
}

NSString *SPPlaceTypeStringForPlaceType(SPGooglePlacesAutocompletePlaceType type) {
    return (type == SPPlaceTypeGeocode) ? @"geocode" : @"establishment";
}

#ifndef TARGET_IS_EXTENSION // if it's not defined
BOOL SPEnsureGoogleAPIKey() {
    BOOL userHasProvidedAPIKey = YES;
    if ([kGoogleAPIKey isEqualToString:@"YOUR_API_KEY"]) {
        userHasProvidedAPIKey = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"API Key Needed" message:@"Please replace kGoogleAPIKey with your Google API key." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    return userHasProvidedAPIKey;
}
#endif

void SPPresentAlertViewWithErrorAndTitle(NSError *error, NSString *title) {
    #ifndef TARGET_IS_EXTENSION // if it's not defined
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    #endif
}

extern BOOL SPIsEmptyString(NSString *string) {
    return !string || ![string length];
}
