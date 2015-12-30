//
//  ViewController.m
//  IncrementalSearch-CoreData
//
//  Created by kishikawakatsumi on 12/31/15.
//  Copyright © 2015 Realm. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Location+CoreDataProperties.h"

@interface ViewController () <UISearchBarDelegate>

@property (nonatomic) NSArray *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self importData];

    [self searchAll];
}

- (void)searchAll {
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = app.managedObjectContext;

    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]];

    NSArray *data = [context executeFetchRequest:request error:nil];
    self.data = data;
    NSLog(@"%@", @(data.count));

    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"%@: %g", @(data.count), end - start);
}

- (void)importData {
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = app.managedObjectContext;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    if ([context countForFetchRequest:request error:nil] > 0) {
        return;
    }

    NSString *string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ken_all.txt" ofType:nil] encoding:NSUTF8StringEncoding error:nil];
    __block NSUInteger identifier = 0;
    [string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];
        location.address = line;
        location.identifier = @(++identifier);
    }];

    [context save:nil];
}

- (void)searchWithText:(NSString *)searchText {
    NSLog(@"%s", __func__);
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];

    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = app.managedObjectContext;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.predicate = [NSPredicate predicateWithFormat:@"address CONTAINS %@", searchText];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]];

    NSArray *data = [context executeFetchRequest:request error:nil];
    self.data = data;

    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"%@: %g", @(data.count), end - start);

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
