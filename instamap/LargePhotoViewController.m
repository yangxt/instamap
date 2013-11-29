//
//  LargePhotoViewController.m
//  instamap
//
//  Created by Andrei Rozhkov on 27.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "LargePhotoViewController.h"
#import "PhotosCollectionViewController.h"
#import "InstaApi.h"
#import "SAMCache.h"
#import <JPSThumbnail.h>
#import "RCBlurredImageView.h"

@interface LargePhotoViewController ()
{
    __block SAMCache *cache;
    NSMutableArray *thumbnails;
    BOOL isOnBottom;
    UIActivityIndicatorView *activityIndicator;
    RCBlurredImageView *blurredImageView;
}

@property (strong, nonatomic) __block NSMutableSet * loading_urls;
@property (strong, nonatomic) NSMutableDictionary * ipByUrl;

@property (nonatomic, strong) NSString* accessToken;


@end

@implementation LargePhotoViewController

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

- (void)viewWillAppear:(BOOL)animated {

 [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.row inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];

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
    
    blurredImageView = [[RCBlurredImageView alloc] initWithImage:self.background];
    [blurredImageView setBlurIntensity:0.8f];
    blurredImageView.frame = self.view.frame;
    [self.view addSubview:blurredImageView ];
    [self.view sendSubviewToBack:blurredImageView ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(320, 320);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleIdentifier = @"cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:simpleIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
        cell = [[UICollectionViewCell alloc] init];
    
    NSString * url = [self.images[indexPath.row] imagesStandardUrl];
    self.ipByUrl[url] = indexPath;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
        if(indexPath.row-1<0)return ;
        NSString * urlprev = [self.images[indexPath.row-1] imagesStandardUrl];
        if([self.loading_urls containsObject:urlprev])
            return ;
        NSLog(@"prev-%d", indexPath.row-1);
        [self.loading_urls addObject:urlprev];
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlprev]];
        UIImage * image = [UIImage imageWithData:data];
        [cache setImage:image forKey:urlprev];
    });
    dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
        if(indexPath.row==self.images.count-1)
            return ;
        NSString * urlnext = [self.images[indexPath.row+1] imagesStandardUrl];
        if([self.loading_urls containsObject:urlnext])return ;
        NSLog(@"next-%d", indexPath.row+1);
        [self.loading_urls addObject:urlnext];
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlnext]];
        UIImage * image = [UIImage imageWithData:data];
        [cache setImage:image forKey:urlnext];
    });
    
    UIImageView * imageView = (id)[cell.contentView viewWithTag:200];
    imageView.image = nil;
    UIImage * image = [cache imageForKey:url];
    if (image)
    {
         NSLog(@"imaged-%d", indexPath.row);
        imageView.image = image;
        return cell;
    }
    
    dispatch_group_async(group,dispatch_get_global_queue(0,0), ^{
        NSLog(@"cur-%d", indexPath.row);
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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(testest) userInfo:nil repeats:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [blurredImageView setBlurIntensity:0.0f];
        self.collectionView.alpha = 0.0;
    }];
}
- (void) testest
{
    NSLog(@"dismiss");
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
