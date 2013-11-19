//
//  PhotosCollectionViewController.m
//  instamap
//
//  Created by Andrei Rozhkov on 19.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "PhotosCollectionViewController.h"
#import "InstaApiTags.h"
#import "SAMCache.h"

@interface PhotosCollectionViewController ()
{
    SAMCache *cache;
    float minid;
}

@property (strong, nonatomic) NSMutableSet * loading_urls;
@property (strong, nonatomic) NSMutableDictionary * ipByUrl;

@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSMutableArray* images;
@property (nonatomic, strong) UIRefreshControl* refreshControl;

@end

@implementation PhotosCollectionViewController

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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor orangeColor];
    [refreshControl addTarget:self action:@selector(updatePhotos) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.collectionView addSubview:self.refreshControl];
    
    
    self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(self.accessToken == nil){
         NSLog(@"accessToken == nil");
    }
    
    [self refresh];
    
}

- (IBAction)refresh
{
    self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(self.accessToken == nil) return;
    [InstaApiTags mediaFromUser:self.userId withAccessToken:self.accessToken block:^(NSArray *records) {
        
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
    static NSString *simpleIdentifier = @"InstaCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:simpleIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] init];// dequeueReusableCellWithReuseIdentifier:simpleIdentifier forIndexPath:indexPath];
    }
    
    NSString * url = [self.images[indexPath.row] thumbnailUrl];
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
    
    if(indexPath.row == self.images.count-5)
    {
        NSLog(@"Bottom" );
        InstaApiTags *q =(InstaApiTags *)[self.images lastObject];
        NSLog(@"max %@",q.index);
        
        [InstaApiTags mediaFromUser:self.userId afterMaxId:q.index withAccessToken:self.accessToken block:^(NSArray *records) {
            
            if (records.count == 0)
                return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.images addObjectsFromArray:records];
                [self.collectionView reloadData];
                
            });
        }];
        
    }
    
    return cell;

}

-(void) updatePhotos
{
    NSLog(@"Top" );
    
    InstaApiTags *q =(InstaApiTags *)[self.images objectAtIndex:0];
    
    NSLog(@"min %@",q.index);
    
    [InstaApiTags mediaFromUser:self.userId beforeMinId:q.index withAccessToken:self.accessToken block:^(NSArray *records) {
        
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


@end
