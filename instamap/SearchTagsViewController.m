//
//  SearchTagsViewController.m
//  instamap
//
//  Created by a я on 25.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "SearchTagsViewController.h"
#import "InstaApi.h"
#import "TagMediaViewController.h"
#import "NSData+AsyncCacher.h"

@interface SearchTagsViewController ()
{
    NSString *accessToken;
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) NSMutableArray* tags;

@property (strong, nonatomic) NSMutableSet * loading_urls;
@property (strong, nonatomic) NSMutableDictionary * ipByUrl;

@end

@implementation SearchTagsViewController

- (NSMutableSet *)loading_urls
{
    return _loading_urls ?: (_loading_urls = [NSMutableSet set]);
}

- (NSMutableDictionary *)ipByUrl
{
    return _ipByUrl ?: (_ipByUrl = [NSMutableDictionary dictionary]);
}

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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TagCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"#%@", [self.tags[indexPath.row] name]];
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"tagmedia"])
    {
        TagMediaViewController *tagmedia = [segue destinationViewController];
        tagmedia.tag = [self.tags[[self.tableView indexPathForCell:sender].row] name];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(accessToken == nil) return;
    [InstaApi searchTags:searchBar.text withAccessToken:accessToken block:^(NSArray *records) {
        
        [activityIndicator stopAnimating];
        if (records.count == 0)
            NSLog(@"where is no users");
        else
        {
            self.tags = [[NSMutableArray alloc] initWithArray:records];
            
            NSLog(@"reloaded");
            [self.tableView reloadData];
        }
    }];
    
    [activityIndicator startAnimating];
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    self.tags = nil;
    [self.tableView reloadData];
}


@end
