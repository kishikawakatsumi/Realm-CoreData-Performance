//
//  Location.m
//  IncrementalSearch-Realm
//
//  Created by kishikawakatsumi on 12/31/15.
//  Copyright © 2015 Realm. All rights reserved.
//

#import "Location.h"

@implementation Location

+ (NSString *)primaryKey {
    return @"identifier";
}

+ (NSArray<NSString *> *)indexedProperties {
    return @[@"identifier"];
}

+ (NSArray<NSString *> *)requiredProperties {
    return @[@"identifier", @"address"];
}

@end
