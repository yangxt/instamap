//
//  PlaceImagesViewController.m
//  instamap
//
//  Created by Andrei Rozhkov on 20.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "PlaceImagesViewController.h"
#import "InstaApi.h"
#import "SAMCache.h"
#import "UsersTableViewController.h"

@interface PlaceImagesViewController ()
{
    SAMCache *cache;
}

@property (strong, nonatomic) NSMutableSet * loading_urls;
@property (strong, nonatomic) NSMutableDictionary * ipByUrl;

@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSMutableArray* images;
@property (nonatomic, strong) UIRefreshControl* refreshControl;

@end

@implementation PlaceImagesViewController

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
    
    self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(self.accessToken == nil){
        NSLog(@"accessToken == nil");
        return;
    }
    
    [self refresh];
    
}

- (void)refresh
{
    if([self.locationIdArray count]==0)
    {
        [InstaApi mediaFromLocation:self.locationId withAccessToken:self.accessToken block:^(NSArray *records) {
        
            if (records.count == 0)
            {
                NSLog(@"where is no images");
                return;
            }
        
            self.images = [[NSMutableArray alloc]initWithArray:records];
            [cache removeAllObjects];
            NSLog(@"%d", self.images.count);
            NSLog(@"reloaded");
            [self.collectionView reloadData];
        }];
    }
    else
    {
        self.images = [NSMutableArray array];
        [cache removeAllObjects];
        for(int i=0; i<[self.locationIdArray count];i++)
        {
            [InstaApi mediaFromLocation:self.locationIdArray[i] withAccessToken:self.accessToken block:^(NSArray *records) {
                
                if (records.count == 0)
                {
                    NSLog(@"where is no images");
                    if(i == [self.locationIdArray count]-1)
                    {
                        NSLog(@"reloaded");
                        [self.collectionView reloadData];
                    }
                 
                }
                else
                {
                    [self.images addObjectsFromArray:records];
               
                    NSLog(@"%d", self.images.count);
                    if(i == [self.locationIdArray count]-1)
                    {
                        NSLog(@"reloaded");
                        [self.collectionView reloadData];
                    }
                }
            }];
        }

    }
    
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
    static NSString *simpleIdentifier = @"PlaceCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:simpleIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] init];
    }
    
    NSString * url = [self.images[indexPath.row] thumbnailUrl];
    self.ipByUrl[url] = indexPath;
    
    UIImageView * imageView = (id)[cell.contentView viewWithTag:300];
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
            
            UIImageView * imageView = (id)[cell2.contentView viewWithTag:300];
            imageView.image = image;
            [self.ipByUrl removeObjectForKey:url];
            
            
        });
    });
    
//    if(indexPath.row == self.images.count-5)
//    {
//        NSLog(@"Bottom" );
//        InstaApi *q =(InstaApi *)[self.images lastObject];
//        NSLog(@"max %@",q.index);
//        
//        [InstaApi mediaFromUser:self.userId afterMaxId:q.index withAccessToken:self.accessToken block:^(NSArray *records) {
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"users"])
    {
        NSMutableArray *userIds = [NSMutableArray array];
        for(int i=0;i<[self.images count];i++)
        {
            if (![userIds containsObject:[self.images[i] userid]])
                [userIds addObject:[self.images[i] userid]];
        }
        UsersTableViewController *users = [segue destinationViewController];
        [users setUserIdArray:userIds];
    }
}

@end