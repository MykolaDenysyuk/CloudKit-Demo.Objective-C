//
//  SelectCitiesViewController.m
//  CloudKit-demo
//
//  Created by Maksim Usenko on 3/18/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//

#import "SelectCityViewController.h"
#import "CloudKitManager.h"

static NSString * const kSelectCitiesCellReuseId = @"SelectCitiesCellReuseId";
static NSString * const kUnwindId = @"unwindToMainId";

@interface SelectCityViewController ()
<
UITableViewDataSource,
UITableViewDelegate
>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSArray *listOfCities;
@property (nonatomic, strong) NSArray *defaultContent;

@end

@implementation SelectCityViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView reloadData];
}

#pragma mark - Custom Accessors

- (NSArray *)listOfCities {
    if (!_listOfCities) {
        _listOfCities = [[City defaultContent] allKeys];
    }
    
    return _listOfCities;
}

- (NSArray *)defaultContent {
    if (!_defaultContent) {
        _defaultContent = [[City defaultContent] allValues];
    }
    
    return _defaultContent;
}

#pragma mark - IBActions

- (IBAction)saveButtonDidPress:(id)sender {
    
    [self shouldAnimateIndicator:YES];
    NSIndexPath *selectedIndexPath = [self.tableView.indexPathsForSelectedRows lastObject];
    __weak typeof(self) weakSelf = self;
    [CloudKitManager createRecord:self.defaultContent[selectedIndexPath.item]
                completionHandler:^(NSArray *results, NSError *error) {
                    
                    if (error) {
                        [weakSelf presentMessage:error.userInfo[NSLocalizedDescriptionKey]];
                        [weakSelf shouldAnimateIndicator:NO];
                    } else {
                        weakSelf.selectedCity = [[City alloc] initWithInputData:[results lastObject]];
                        [weakSelf performSegueWithIdentifier:kUnwindId sender:self];
                    }
    }];
}

#pragma mark - Private

- (void)shouldAnimateIndicator:(BOOL)animate {
    if (animate) {
        [self.indicatorView startAnimating];
    } else {
        [self.indicatorView stopAnimating];
    }

    self.tableView.userInteractionEnabled = !animate;
    self.navigationController.navigationBar.userInteractionEnabled = !animate;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listOfCities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSelectCitiesCellReuseId];
    cell.textLabel.text = self.listOfCities[indexPath.item];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = (cell.accessoryType == UITableViewCellAccessoryNone) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

@end
