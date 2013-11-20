//
//  UsersTableViewController.m
//  instamap
//
//  Created by Andrei Rozhkov on 19.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "UsersTableViewController.h"
#import "InstaApi.h"
#import "PhotosCollectionViewController.h"
#import "NSData+AsyncCacher.h"

@interface UsersTableViewController ()
{
    NSString *accessToken;
}

@property (nonatomic, strong) NSMutableArray* users;

@property (strong, nonatomic) NSMutableSet * loading_urls;
@property (strong, nonatomic) NSMutableDictionary * ipByUrl;

@end

@implementation UsersTableViewController

- (NSMutableSet *)loading_urls
{
    if (_loading_urls == nil)
        _loading_urls = [NSMutableSet set];
    return _loading_urls;
    //return _loading_urls ?: (_loading_urls = [NSMutableSet set]);
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

//    cache = [SAMCache sharedCache];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
    NSString * url = [self.users[indexPath.row] userpic];
    self.ipByUrl[url] = indexPath;
    
    UIImageView *imageView = (id)[cell.contentView viewWithTag:100];
    imageView.image = nil;
    UILabel *label1 = (id)[cell.contentView viewWithTag:101];
    label1.text = [self.users[indexPath.row] username];
    UILabel *label2 = (id)[cell.contentView viewWithTag:102];
    label2.text = [self.users[indexPath.row] index];
    
    [NSData getDataFromURL:[NSURL URLWithString:url]
                             toBlock:^(NSData * data, BOOL * retry)
     {
         if (data == nil) {
             *retry = YES;
             return;
         }
         
         UIImageView * imageView = (id)[cell.contentView viewWithTag:100];
         imageView.image =  [UIImage imageWithData:data];;
         [self.ipByUrl removeObjectForKey:url];
     }];
    
    return cell;
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"search %@", searchBar.text);
    
    [searchBar resignFirstResponder];
    
    accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(accessToken == nil){
        NSLog(@"accessToken == nil");
    }

    [self refresh:searchBar.text];
}


- (void)refresh:(NSString *)userName
{
    accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(accessToken == nil) return;
    [InstaApi searchUser:userName withAccessToken:accessToken block:^(NSArray *records) {
        
        if (records.count == 0)
            return;
        
        self.users = [[NSMutableArray alloc]initWithArray:records];
//        [cache removeAllObjects];
        NSLog(@"get it");
        [self.tableView reloadData];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"usermedia"])
    {
        NSString *userId = [self.users[[self.tableView indexPathForCell:sender].row] index];
        PhotosCollectionViewController *photos = [segue destinationViewController];
        [photos setUserId:userId];
    }
    if([[segue identifier] isEqualToString:@"logout"])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Access_token"];
        
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


@end
