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
    
    cell.textLabel.text = [location[indexPath.row] description];
    
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
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [YaApi searchGeocode:searchBar.text block:^(NSArray *records) {
        
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



@end
