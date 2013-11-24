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

@interface PhotosCollectionViewController ()
{
    SAMCache *cache;
    float minid;
    NSMutableArray *thumbnails;
    UIImage *blurrredImage;
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

- (void)viewWillAppear:(BOOL)animated {
    self.blurContainerView.alpha = 0.0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    cache = [SAMCache sharedCache];
    thumbnails = [NSMutableArray array];
    
    self.largeImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.largeImage.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.largeImage.layer.shadowOpacity = 0.41f;
    self.largeImage.layer.shadowRadius = 5.0f;
    
    self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(self.accessToken == nil){
         NSLog(@"accessToken == nil");
    }
    
    [self refresh];
    
}

- (void)refresh
{
    self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(self.accessToken == nil) return;
    [InstaApi mediaFromUser:self.userId withAccessToken:self.accessToken block:^(NSArray *records) {
        
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
    
    if(indexPath.row == self.images.count-5)
    {
        NSLog(@"Bottom" );
        InstaApi *q =(InstaApi *)[self.images lastObject];
        NSLog(@"max %@",q.index);
        
        [InstaApi mediaFromUser:self.userId afterMaxId:q.index withAccessToken:self.accessToken block:^(NSArray *records) {
            
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self hideLargeImage];
    if ([[segue identifier] isEqualToString:@"map"])
    {
        MapViewController *map = [segue destinationViewController];
        [map setThumbnails:thumbnails];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self captureBlur];
//    [self performSelectorInBackground:@selector(captureBlur) withObject:nil];
    
    NSString *url = [self.images[indexPath.row] imagesStandardUrl];
    UIImage *image = [cache imageForKey:url];
    if (image)
    {
        self.largeImage.image = image;
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            UIImage * image = [UIImage imageWithData:data];
            [cache setImage:image forKey:url];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.largeImage.image = image;
            });
        });
    }

    [UIView animateWithDuration:0.3 animations:^{
        self.blurContainerView.alpha = 1.0;
        self.collectionView.alpha = 0.0;
    }];
}

- (void) captureBlur {
    //Get a UIImage from the UIView
    NSLog(@"blur capture");
    UIGraphicsBeginImageContext(self.collectionView.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Blur the UIImage
    CIImage *imageToBlur = [CIImage imageWithCGImage:viewImage.CGImage];
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:imageToBlur forKey: @"inputImage"];
    [gaussianBlurFilter setValue:[NSNumber numberWithFloat: 2] forKey: @"inputRadius"];
    CIImage *resultImage = [gaussianBlurFilter valueForKey: @"outputImage"];
    
    //create UIImage from filtered image
    blurrredImage = [[UIImage alloc] initWithCIImage:resultImage];
    
    //Place the UIImage in a UIImageView
    UIImageView *newView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    newView.image = blurrredImage;
    
    //insert blur UIImageView below transparent view inside the blur image container
    [self.blurContainerView insertSubview:newView belowSubview:self.transparentView];
}

- (IBAction)taped:(id)sender {
    [self hideLargeImage];
}

- (void)hideLargeImage
{
    [UIView animateWithDuration:0.3 animations:^{
        self.blurContainerView.alpha = 0.0;
        self.collectionView.alpha = 1.0;
    }];
    self.largeImage.image = nil;
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
