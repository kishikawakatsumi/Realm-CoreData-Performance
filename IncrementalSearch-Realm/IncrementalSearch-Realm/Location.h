//
//  Location.h
//  IncrementalSearch-Realm
//
//  Created by kishikawakatsumi on 12/31/15.
//  Copyright © 2015 Realm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface Location : RLMObject

@property NSInteger identifier;
@property NSString *address;

@end
