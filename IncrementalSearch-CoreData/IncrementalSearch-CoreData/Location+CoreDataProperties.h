//
//  Location+CoreDataProperties.h
//  IncrementalSearch-CoreData
//
//  Created by kishikawakatsumi on 12/31/15.
//  Copyright © 2015 Realm. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface Location (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSNumber *identifier;

@end

NS_ASSUME_NONNULL_END
