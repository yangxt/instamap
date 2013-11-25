//
//  TagMediaViewController.m
//  instamap
//
//  Created by a я on 25.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "TagMediaViewController.h"
#import "InstaApi.h"
#import "SAMCache.h"
#import "PhotoViewController.h"
#import "UsersTableViewController.h"

@interface TagMediaViewController ()
{
    SAMCache *cache;
    float minid;
    BOOL isOnBottom;
}

@property (strong, nonatomic) NSMutableSet * loading_urls;
@property (strong, nonatomic) NSMutableDictionary * ipByUrl;

@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSMutableArray* images;
@property (nonatomic, strong) UIRefreshControl* refreshControl;

@end

@implementation TagMediaViewController

- (NSMutableSet *)loading_urls
{
    return _loading_urls ?: (_loading_urls = [NSMutableSet set]);
}

- (NSMutableDictionary *)ipByUrl
{
    return _ipByUrl ?: (_ipByUrl = [NSMutableDictionary dictionary]);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    cache = [SAMCache sharedCache];
    isOnBottom = YES;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor orangeColor];
    [refreshControl addTarget:self action:@selector(updatePhotos) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.collectionView addSubview:self.refreshControl];
    
    
    self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(self.accessToken == nil){
        NSLog(@"Access_token fail");
    }
    
    
    [self refresh];
    
}

- (void)refresh
{
    self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(self.accessToken == nil) return;
    [InstaApi getTag:self.tag withAccessToken:self.accessToken block:^(NSArray *records) {
        
        if (records.count == 0)
            return;
        
        self.images = [[NSMutableArray alloc]initWithArray:records];
        [cache removeAllObjects];
        NSLog(@"%d", self.images.count);
        NSLog(@"reloaded");
        [self.collectionView reloadData];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 100);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleIdentifier = @"InstaCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:simpleIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
        cell = [[UICollectionViewCell alloc] init];
    
    NSString * url = [self.images[indexPath.row] imagesThumbnailUrl];
    self.ipByUrl[url] = indexPath;
    
    UIImageView * imageView = (id)[cell.contentView viewWithTag:100];
    imageView.image = nil;
    
    UIImage * image = [cache imageForKey:url];
    
    if (image)
    {
        imageView.image = image;
        return cell;
    }
    
    if ([self.loading_urls containsObject:url])
        return cell;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // ....
        [self.loading_urls addObject:url];
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage * image = [UIImage imageWithData:data];
        [cache setImage:image forKey:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            //...
            UICollectionViewCell * cell2 = [collectionView cellForItemAtIndexPath:self.ipByUrl[url]];
            if (!cell2)
                return;
            UIImageView * imageView = (id)[cell2.contentView viewWithTag:100];
            imageView.image = image;
            [self.ipByUrl removeObjectForKey:url];
        });
    });
    
//    if(indexPath.row == self.images.count-5)
//    {
//        NSLog(@"Bottom" );
//        InstaApi *q =(InstaApi *)[self.images lastObject];
//        NSLog(@"max %@",q.max_id);
//        
//        [InstaApi getTag:self.tag afterMaxId:q.max_id withAccessToken:self.accessToken block:^(NSArray *records) {
//            
//            if (records.count == 0)
//                return;
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.images addObjectsFromArray:records];
//                [self.collectionView reloadData];
//                
//            });
//        }];
//        
//    }
    
    return cell;
}
- (void)scrollViewDidScroll: (UIScrollView *)scroll
{
    NSInteger currentOffset = scroll.contentOffset.y;
    NSInteger maximumOffset = scroll.contentSize.height - scroll.frame.size.height;
    
    if (maximumOffset - currentOffset <= 150.0 && isOnBottom) {
        NSLog(@"Bottom" );
        isOnBottom = NO;
        InstaApi *q =(InstaApi *)[self.images lastObject];
        NSLog(@"max %@",q.max_id);
        if(!q.max_id)
            return;
        
        [InstaApi getTag:self.tag afterMaxId:q.max_id withAccessToken:self.accessToken block:^(NSArray *records) {
            
            if (records.count == 0)
                return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.images addObjectsFromArray:records];
                isOnBottom = YES;
                [self.collectionView reloadData];
                
            });
        }];
    }
}

-(void) updatePhotos
{
    NSLog(@"Top" );
    
    InstaApi *q =(InstaApi *)[self.images objectAtIndex:0];
    
    NSLog(@"min %@",q.min_id);
    
    [InstaApi getTag:self.tag beforeMinId:q.min_id withAccessToken:self.accessToken block:^(NSArray *records) {
        
        if (records.count == 0)
            return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.images insertObjects:records atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, records.count)]];
            
            NSMutableDictionary * dict = [NSMutableDictionary dictionary];
            for (NSString * key in self.ipByUrl.keyEnumerator) {
                dict[key] = [NSIndexPath indexPathForRow:[self.ipByUrl[key] row]+records.count
                                               inSection:[self.ipByUrl[key] section]];
            }
            self.ipByUrl = dict;
            
            NSLog(@"%d", self.images.count);
            [self.collectionView reloadData];
            
            [self.refreshControl endRefreshing];
            
        });
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"users"])
    {
        NSMutableArray *userIds = [NSMutableArray array];
        for(int i=0;i<[self.images count];i++)
        {
            if (![userIds containsObject:[self.images[i] userUserName]])
                [userIds addObject:[self.images[i] userUserName]];
        }
        UsersTableViewController *users = [segue destinationViewController];
        [users setUserIdArray:userIds];
    }
    if ([[segue identifier] isEqualToString:@"photo"])
    {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        PhotoViewController *photo = [segue destinationViewController];
        [photo setUserProfilePic:[self.images[indexPath.row] userUserPic]];
        [photo setUserProfileName:[self.images[indexPath.row] userUserName]];
        [photo setPhotoUrl:[self.images[indexPath.row] imagesStandardUrl]];
        [photo setUserProfileId:[self.images[indexPath.row] userUserId]];
    }
}

@end
