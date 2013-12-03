//
//  PhotosCollectionViewController.m
//  instamap
//
//  Created by Andrei Rozhkov on 19.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "PhotosCollectionViewController.h"
#import "InstaApi.h"
#import "SAMCache.h"
#import "MapViewController.h"
#import <JPSThumbnail.h>
#import "PhotosCollectionReusableView.h"
#import "LargePhotoViewController.h"
#import "RCBlurredImageView.h"

@interface PhotosCollectionViewController ()
{
    SAMCache *cache;
    NSMutableArray *thumbnails;
    RCBlurredImageView *blurredImageView;
    BOOL isOnBottom;
    UIActivityIndicatorView *activityIndicator;
    NSInteger curRow;
    UIImage *screenshot;
}

@property (strong, nonatomic) NSMutableSet * loading_urls;
@property (strong, nonatomic) NSMutableDictionary * ipByUrl;

@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSMutableArray* images;

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
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen:)];
    swipeGesture.numberOfTouchesRequired = 1;
    swipeGesture.direction = (UISwipeGestureRecognizerDirectionLeft);
    [self.view addGestureRecognizer:swipeGesture];
    
    cache = [SAMCache sharedCache];
    thumbnails = [NSMutableArray array];
    isOnBottom = YES;

    self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(self.accessToken == nil){
         NSLog(@"accessToken == nil");
    }
    
    [self refresh];
    
}

- (void) swipedScreen:(UISwipeGestureRecognizer*)swipeGesture {
    NSLog(@"perform map");
    [self performSegueWithIdentifier:@"map" sender:self];
}

- (void)refresh
{
    self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(self.accessToken == nil) return;
    [activityIndicator startAnimating];
    [InstaApi mediaFromUser:self.userId withAccessToken:self.accessToken block:^(NSArray *records) {
        [activityIndicator stopAnimating];
        if (records.count == 0)
            return;
        
        self.images = [[NSMutableArray alloc]initWithArray:records];
//        [cache removeAllObjects];
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
    
        NSString *latitude = [self.images[indexPath.row] locationLatitude];
        NSString *longitude = [self.images[indexPath.row] locationLongitude];
        if ((NSNull *) latitude != [NSNull null])
        {
            JPSThumbnail *thumbnail = [[JPSThumbnail alloc] init];
            thumbnail.image = image;
            thumbnail.title = [self.images[indexPath.row] locationName];
            NSDate *dateToday =[NSDate dateWithTimeIntervalSince1970:[[self.images[indexPath.row] createdTime] integerValue]];
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"d-MMM-yyyy HH:mm"];
            thumbnail.subtitle = [format stringFromDate:dateToday];;
            thumbnail.coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
            [thumbnails addObject:thumbnail];
        }
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
        NSLog(@"max %@",q.index);
        if(!q.index)
            return;
        isOnBottom = NO;
        [activityIndicator startAnimating];
        [InstaApi mediaFromUser:self.userId afterMaxId:q.index withAccessToken:self.accessToken block:^(NSArray *records) {
            [activityIndicator stopAnimating];
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
    if ([[segue identifier] isEqualToString:@"map"])
    {
        MapViewController *map = [segue destinationViewController];
        [map setThumbnails:thumbnails];
    }
    if ([[segue identifier] isEqualToString:@"large"])
    {
        LargePhotoViewController *photo = [segue destinationViewController];
        photo.images = self.images;
        photo.row = curRow;
        photo.background = screenshot;
    }
}

- (UIImage *) takeScreenshot
{
    CALayer *layer = [[UIApplication sharedApplication] keyWindow].layer;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, scale);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    return UIGraphicsGetImageFromCurrentImageContext();
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    curRow = indexPath.row;
    
    screenshot = [self takeScreenshot];
    
    [self setWantsFullScreenLayout:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.tabBarController.tabBar setHidden:YES];
    
    blurredImageView = [[RCBlurredImageView alloc] initWithImage:screenshot];
    [blurredImageView setBlurIntensity:0.0f];
    blurredImageView.frame = blurredImageView.bounds;
    [self.view insertSubview:blurredImageView aboveSubview:self.collectionView ];
    [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(delayPerform) userInfo:nil repeats:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [blurredImageView setBlurIntensity:0.8f];
    }];
}
- (void) delayPerform
{
    NSLog(@"perform");
    [self performSegueWithIdentifier:@"large" sender:nil];
    [blurredImageView removeFromSuperview];
    [self setWantsFullScreenLayout:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.tabBarController.tabBar setHidden:NO];

}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        PhotosCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"profileCell" forIndexPath:indexPath];

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
