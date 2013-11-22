//
//  PlacesViewController.m
//  instamap
//
//  Created by Andrei Rozhkov on 20.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "PlacesViewController.h"
#import "InstaApi.h"
#import "PlaceImagesViewController.h"

@interface PlacesViewController ()
{
    NSString *accessToken;
    NSMutableArray *places;
    NSMutableArray *filteredPlacesArray;
    NSIndexPath *selectedIndexPath;
}

@end

@implementation PlacesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    
[self refresh];
}

- (void)refresh
{
    accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(accessToken == nil) return;
    [InstaApi searchLocationByLat:self.lat andLng:self.lng withAccessToken:accessToken block:^(NSArray *records) {
        
        if (records.count == 0)
        {
            NSLog(@"Where is no places");
            return;
        }
        places = [[NSMutableArray alloc]initWithArray:records];
        //        [cache removeAllObjects];
        NSLog(@"get it");
        [self.tableView reloadData];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    filteredPlacesArray = [NSMutableArray arrayWithCapacity:[places count]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [filteredPlacesArray count];
    } else {
        return [places count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlacesCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [filteredPlacesArray [indexPath.row] locationName2];
        cell.detailTextLabel.text = [filteredPlacesArray [indexPath.row] index];
        
    } else {
        cell.textLabel.text = [places [indexPath.row] locationName2];
        cell.detailTextLabel.text = [places [indexPath.row] index];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndexPath=indexPath;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([self.searchDisplayController.searchBar.text length]!=0) {
        if ([[segue identifier] isEqualToString:@"PlaceImages"])
        {
            NSString *locationId = [filteredPlacesArray [selectedIndexPath.row] index];
            PlaceImagesViewController *placeimages = [segue destinationViewController];
            [placeimages setLocationId:locationId];
            [placeimages setLocationIdArray:nil];
        }
        if ([[segue identifier] isEqualToString:@"AllPlaces"])
        {
            NSMutableArray *locationIds = [NSMutableArray array];
            for(int i=0;i<[filteredPlacesArray count];i++)
            {
                [locationIds addObject:[filteredPlacesArray[i] index]];
            }
            PlaceImagesViewController *placeimages = [segue destinationViewController];
            [placeimages setLocationIdArray:locationIds];
        }
    }
    else{
        if ([[segue identifier] isEqualToString:@"PlaceImages"])
        {
            NSString *locationId = [places [[self.tableView indexPathForCell:sender].row] index];
            PlaceImagesViewController *placeimages = [segue destinationViewController];
            [placeimages setLocationId:locationId];
            [placeimages setLocationIdArray:nil];
        }
        if ([[segue identifier] isEqualToString:@"AllPlaces"])
        {
            NSMutableArray *locationIds = [NSMutableArray array];
            for(int i=0;i<[places count];i++)
            {
                [locationIds addObject:[places[i] index]];
            }
            PlaceImagesViewController *placeimages = [segue destinationViewController];
            [placeimages setLocationIdArray:locationIds];
        }
    }
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [filteredPlacesArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.locationName2 contains[cd] %@",searchText];
    filteredPlacesArray = [NSMutableArray arrayWithArray:[places filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

//not hide navigationController
-(void)viewWillLayoutSubviews
{
    if(self.searchDisplayController.isActive)
    {
        [UIView animateWithDuration:0.001 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }completion:nil];
    }
    [super viewWillLayoutSubviews];
}

@end
