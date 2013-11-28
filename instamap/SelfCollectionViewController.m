//
//  SelfCollectionViewController.m
//  instamap
//
//  Created by Andrei Rozhkov on 25.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "SelfCollectionViewController.h"

#import "InstaApi.h"
#import "SAMCache.h"
#import "PhotoViewController.h"
#import "SelfCollectionReusableView.h"

@interface SelfCollectionViewController ()
{
    SAMCache *cache;
    NSMutableArray *thumbnails;
    BOOL isOnBottom;
    UIActivityIndicatorView *activityIndicator;
}

@property (strong, nonatomic) NSMutableSet * loading_urls;
@property (strong, nonatomic) NSMutableDictionary * ipByUrl;

@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSMutableArray* images;

@property (strong, nonatomic) NSString *userProfilePic;
@property (strong, nonatomic) NSString *userProfileName;

@end

@implementation SelfCollectionViewController

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
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    
    cache = [SAMCache sharedCache];
    thumbnails = [NSMutableArray array];
    isOnBottom = YES;
    
    self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(self.accessToken == nil){
        NSLog(@"accessToken == nil");
    }
    
    [activityIndicator startAnimating];
    [self selfUserProfileLoad];
}

- (void)selfUserProfileLoad
{
    if(self.accessToken == nil) return;
    [InstaApi searchUserId:@"self" withAccessToken:self.accessToken block:^(NSArray *records) {
        
        if (records.count == 0)
            return;
        
        self.userProfileName = [records[0] userName];
        self.userProfilePic  = [records[0] userPic];
        NSLog(@"reloaded");
        [self.collectionView reloadData];
        [self refresh];
    }];
}

- (void)refresh
{
    [InstaApi mediaSelfLikedwithAccessToken:self.accessToken block:^(NSArray *records) {
        
        [activityIndicator stopAnimating];
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 100);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleIdentifier = @"instaCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:simpleIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
        cell = [[UICollectionViewCell alloc] init];
    
    NSString * url = [self.images[indexPath.row] imagesThumbnailUrl];
    self.ipByUrl[url] = indexPath;
    
    UIImageView * imageView = (id)[cell.contentView viewWithTag:200];
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
            
            UIImageView * imageView = (id)[cell2.contentView viewWithTag:200];
            imageView.image = image;
            [self.ipByUrl removeObjectForKey:url];
            
        });
    });
    
    return cell;
    
}


- (void)scrollViewDidScroll: (UIScrollView *)scroll
{
    NSInteger currentOffset = scroll.contentOffset.y;
    NSInteger maximumOffset = scroll.contentSize.height - scroll.frame.size.height;
    
    if (maximumOffset - currentOffset <= 150.0 && isOnBottom) {
        NSLog(@"Bottom" );
        InstaApi *q =(InstaApi *)[self.images lastObject];
        NSLog(@"max %@",q.nextmaxlikeid);
        if(!q.nextmaxlikeid)
            return;
        
        isOnBottom = NO;
        
        [InstaApi mediaSelfLikedFromMaxId:q.nextmaxlikeid withAccessToken:self.accessToken block:^(NSArray *records) {
            
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"photo"])
    {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        PhotoViewController *photo = [segue destinationViewController];
        [photo setUserProfilePic:[self.images[indexPath.row] userUserPic]];
        [photo setUserProfileName:[self.images[indexPath.row] userUserName]];
        [photo setPhotoUrl:[self.images[indexPath.row] imagesStandardUrl]];
        [photo setUserProfileId:[self.images[indexPath.row] userUserId]];
    }    if([[segue identifier] isEqualToString:@"logout"])
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

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        SelfCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"profileCell" forIndexPath:indexPath];
        
        headerView.userName.text = self.userProfileName;
        
        UIImage *image = [cache imageForKey:self.userProfilePic];
        if (image)
        {
            headerView.userPic.image = image;
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.userProfilePic]];
                UIImage * image = [UIImage imageWithData:data];
                [cache setImage:image forKey:self.userProfilePic];
                dispatch_async(dispatch_get_main_queue(), ^{
                    headerView.userPic.image = image;
                });
            });
        }
        
        reusableview = headerView;
    }
    
    return reusableview;
}
@end