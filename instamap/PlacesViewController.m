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
    if ([places count]==0)
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
    if ([self.searchBar.text length]!=0) {
        return [filteredPlacesArray count];
    } else {
        return [places count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlacesCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ([self.searchBar.text length]!=0) {
        cell.textLabel.text = [filteredPlacesArray [indexPath.row] locationName2];
        cell.detailTextLabel.text = [filteredPlacesArray [indexPath.row] index];
        
    } else {
        cell.textLabel.text = [places [indexPath.row] locationName2];
        cell.detailTextLabel.text = [places [indexPath.row] index];
    }
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([self.searchBar.text length]!=0) {
        if ([[segue identifier] isEqualToString:@"PlaceImages"])
        {
            NSString *locationId = [filteredPlacesArray [[self.tableView indexPathForCell:sender].row] index];
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
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [filteredPlacesArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.locationName2 contains[cd] %@",searchBar.text];
    filteredPlacesArray = [NSMutableArray arrayWithArray:[places filteredArrayUsingPredicate:predicate]];
    
    [self.searchBar resignFirstResponder];
    [self.tableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    [self.tableView reloadData];
}

@end
