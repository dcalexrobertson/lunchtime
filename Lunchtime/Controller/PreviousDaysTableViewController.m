//
//  PreviousDaysTableViewController.m
//  Lunchtime
//
//  Created by Willow Belle on 2015-11-15.
//  Copyright © 2015 Cosmic Labs. All rights reserved.
//

#import "PreviousDaysTableViewController.h"
#import "PreviousDaysMapViewController.h"
#import "UIAlertController+Extras.h"
#import "LunchtimeTableViewCell.h"
#import "Realm+Convenience.h"
#import "LunchtimeMaps.h"
#import "Restaurant.h"
#import "User.h"

static NSString *kSegueToPreviousDaysMapViewController = @"segueToPreviousDaysMapViewController";
static NSString *kReuseIdentifier = @"previousCell";

@interface PreviousDaysTableViewController ()

@property (nonatomic) User *user;

@end

@implementation PreviousDaysTableViewController

#pragma mark - Controller Lifecycle
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];

    if (self) {
        _user = [User objectForPrimaryKey:@1];
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueToPreviousDaysMapViewController]) {
        PreviousDaysMapViewController *previousDaysMapViewController = [segue destinationViewController];
        previousDaysMapViewController.user = self.user;
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.user.savedRestaurants.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil preferredStyle:UIAlertControllerStyleActionSheet];
    Restaurant *restaurant = self.user.savedRestaurants[indexPath.row];
    [alert addCancelAction];

    [alert addDefaultAction:@"I know where it is" withHandler:^(UIAlertAction *action) {
        [RealmConvenience addRestaurantToSavedArray:restaurant];
    }];

    [alert addDefaultAction:@"Open Restaurant in Maps" withHandler:^(UIAlertAction *action) {
        [RealmConvenience addRestaurantToSavedArray:restaurant];
        [LunchtimeMaps openInMapsWithAddress:restaurant.address];
    }];

    [self presentViewController:alert animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LunchtimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier forIndexPath:indexPath];

    Restaurant *restaurant = self.user.savedRestaurants[indexPath.row];
    cell.textLabel.text = restaurant.name;
    cell.detailTextLabel.text = restaurant.thoroughfare;

    return cell;
}

@end
