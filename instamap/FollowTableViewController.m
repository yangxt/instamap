//
//  FollowTableViewController.m
//  instamap
//
//  Created by Andrei Rozhkov on 25.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "FollowTableViewController.h"
#import "InstaApi.h"
#import "PhotosCollectionViewController.h"
#import "NSData+AsyncCacher.h"

@interface FollowTableViewController ()
{
    NSString *accessToken;
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) NSMutableArray* users;

@property (strong, nonatomic) NSMutableSet * loading_urls;
@property (strong, nonatomic) NSMutableDictionary * ipByUrl;

@end

@implementation FollowTableViewController

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

    if([self.users count]==0)
        [self refresh];
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
    
    NSString * url = [self.users[indexPath.row] userPic];
    self.ipByUrl[url] = indexPath;
    
    UIImageView *imageView = (id)[cell.contentView viewWithTag:100];
    imageView.image = nil;
    UILabel *label1 = (id)[cell.contentView viewWithTag:101];
    label1.text = [self.users[indexPath.row] userName];
    UILabel *label2 = (id)[cell.contentView viewWithTag:102];
    label2.text = [self.users[indexPath.row] userFullName];
    
    [NSData getDataFromURL:[NSURL URLWithString:url]
                   toBlock:^(NSData * data, BOOL * retry)
     {
         if (data == nil) {
             *retry = YES;
             return;
         }
         
         UIImageView * imageView = (id)[cell.contentView viewWithTag:100];
         imageView.image =  [UIImage imageWithData:data];
         [self.ipByUrl removeObjectForKey:url];
     }];
    
    return cell;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"usermedia"])
    {
        PhotosCollectionViewController *photos = [segue destinationViewController];
        photos.userId = [self.users[[self.tableView indexPathForCell:sender].row] index];
        photos.userProfileName = [self.users[[self.tableView indexPathForCell:sender].row] userName];
        photos.userProfilePic = [self.users[[self.tableView indexPathForCell:sender].row] userPic];
    }
}


- (void)refresh
{
    accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(accessToken == nil) return;
    [activityIndicator startAnimating];
    [InstaApi followedUserswithAccessToken:accessToken block:^(NSArray *records)
    {
      
        [activityIndicator stopAnimating];
        if (records.count == 0)
            NSLog(@"where is no users");
        else
        {
            self.users = [NSMutableArray arrayWithArray:records];
                    
            NSLog(@"%d", self.users.count);
            NSLog(@"reloaded");
            [self.tableView reloadData];
            
        }
    }];
}


@end
