//
//  SearchLocationViewController.m
//  instamap
//
//  Created by a я on 24.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "SearchLocationViewController.h"
#import "YaApi.h"
#import "MapSearchViewController.h"

@interface SearchLocationViewController ()
{
    NSMutableArray *location;
    UIActivityIndicatorView *activityIndicator;
}

@end

@implementation SearchLocationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen:)];
    swipeGesture.numberOfTouchesRequired = 1;
    swipeGesture.direction = (UISwipeGestureRecognizerDirectionLeft);
    [self.view addGestureRecognizer:swipeGesture];
}

- (void) swipedScreen:(UISwipeGestureRecognizer*)swipeGesture {
    NSLog(@"perform map");
    [self performSegueWithIdentifier:@"map" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [location count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"locationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [location[indexPath.row] name];
    cell.detailTextLabel.text =[location[indexPath.row] description];
    
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"search"])
    {
        MapSearchViewController *map = [segue destinationViewController];
        map.latitude = [location[[self.tableView indexPathForCell:sender].row] latitude];
        map.longitude = [location[[self.tableView indexPathForCell:sender].row] longitude];
        map.mytitle = [location[[self.tableView indexPathForCell:sender].row] name];
        map.mysubtitle = [location[[self.tableView indexPathForCell:sender].row] description];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [activityIndicator startAnimating];
    [YaApi searchGeocode:searchBar.text block:^(NSArray *records) {
        [activityIndicator stopAnimating];
        if (records.count == 0)
            NSLog(@"No such location");
        
        else
        {
            NSLog(@"yes");
            location = [[NSMutableArray alloc]initWithArray:records];
            
            [searchBar resignFirstResponder];
            [self.tableView reloadData];
        }
    }];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    location = nil;
    [self.tableView reloadData];
}


@end
