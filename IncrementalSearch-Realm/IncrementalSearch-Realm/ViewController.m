//
//  ViewController.m
//  IncrementalSearch-Realm
//
//  Created by kishikawakatsumi on 12/31/15.
//  Copyright © 2015 Realm. All rights reserved.
//

#import "ViewController.h"
#import "Location.h"

@interface ViewController () <UISearchBarDelegate>

@property (nonatomic) RLMResults *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self importData];

    [self searchAll];
}

- (void)searchAll {
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];

    RLMSortDescriptor *sortDescriptor = [RLMSortDescriptor sortDescriptorWithProperty:@"identifier" ascending:YES];
    RLMResults *data = [[Location allObjectsInRealm:realm] sortedResultsUsingDescriptors:@[sortDescriptor]];
    self.data = data;

    NSInteger count = data.count;

    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"%@: %g", @(count), end - start);
}

- (void)importData {
    RLMRealm *realm = [RLMRealm defaultRealm];
    if (!realm.isEmpty) {
        return;
    }

    [realm transactionWithBlock:^{
        NSString *string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ken_all.txt" ofType:nil] encoding:NSUTF8StringEncoding error:nil];
        __block NSUInteger identifier = 0;
        [string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            Location *location = [[Location alloc] init];
            location.address = line;
            location.identifier = ++identifier;

            [realm addObject:location];
        }];
    }];
}

- (void)searchWithText:(NSString *)searchText {
    NSLog(@"%s", __func__);
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];

    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address CONTAINS %@", searchText];

    RLMSortDescriptor *sortDescriptor = [RLMSortDescriptor sortDescriptorWithProperty:@"identifier" ascending:YES];
    RLMResults *data = [[Location objectsInRealm:realm withPredicate:predicate] sortedResultsUsingDescriptors:@[sortDescriptor]];
    self.data = data;
    NSInteger count = data.count;

    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"%@: %g", @(count), end - start);

    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Location *address = self.data[indexPath.row];

    NSArray *components = [[address.address stringByReplacingOccurrencesOfString:@"\"" withString:@""] componentsSeparatedByString:@","];
    NSMutableString *postalCode = [NSMutableString stringWithString:components[2]];
    [postalCode insertString:@"-" atIndex:3];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@", postalCode, components[6], components[7], components[8]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@", postalCode, components[3], components[4], components[5]];

    return cell;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *searchText = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    NSMutableString *str = [NSMutableString stringWithString:searchText];
    CFRange r = CFRangeMake(0, str.length);
    CFStringTransform((CFMutableStringRef)str, &r, kCFStringTransformHiraganaKatakana, NO);
    CFStringTransform((CFMutableStringRef)str, &r, kCFStringTransformFullwidthHalfwidth, NO);
    [self searchWithText:str];
    
    return YES;
}

@end
