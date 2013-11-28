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

@interface LargePhotoViewController ()
{
    SAMCache *cache;
    NSMutableArray *thumbnails;
    UIImage *blurrredImage;
    BOOL isOnBottom;
    UIActivityIndicatorView *activityIndicator;
}

@property (strong, nonatomic) NSMutableSet * loading_urls;
@property (strong, nonatomic) NSMutableDictionary * ipByUrl;

@property (nonatomic, strong) NSString* accessToken;


@end

@implementation LargePhotoViewController

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
//    self.blurContainerView.alpha = 0.0;
 [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.row inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    
//    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen:)];
//    swipeGesture.numberOfTouchesRequired = 1;
//    swipeGesture.direction = (UISwipeGestureRecognizerDirectionLeft);
//    [self.view addGestureRecognizer:swipeGesture];
    
    cache = [SAMCache sharedCache];
    thumbnails = [NSMutableArray array];
    isOnBottom = YES;
    
//    self.largeImage.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.largeImage.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
//    self.largeImage.layer.shadowOpacity = 0.41f;
//    self.largeImage.layer.shadowRadius = 5.0f;
    
    self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Access_token"]];
    if(self.accessToken == nil){
        NSLog(@"accessToken == nil");
    }
    
  [self.collectionView reloadData];
    
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



//
//- (void)scrollViewDidScroll: (UIScrollView *)scroll
//{
//    NSInteger currentOffset = scroll.contentOffset.y;
//    NSInteger maximumOffset = scroll.contentSize.height - scroll.frame.size.height;
//    
//    if (maximumOffset - currentOffset <= 150.0 && isOnBottom) {
//        NSLog(@"Bottom" );
//        
//        InstaApi *q =(InstaApi *)[self.images lastObject];
//        NSLog(@"max %@",q.index);
//        if(!q.index)
//            return;
//        isOnBottom = NO;
//        [activityIndicator startAnimating];
//        [InstaApi mediaFromUser:self.userId afterMaxId:q.index withAccessToken:self.accessToken block:^(NSArray *records) {
//            [activityIndicator stopAnimating];
//            if (records.count == 0)
//                return;
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.images addObjectsFromArray:records];
//                isOnBottom = YES;
//                [self.collectionView reloadData];
//            });
//        }];
//    }
//}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self captureBlur];
//    //    [self performSelectorInBackground:@selector(captureBlur) withObject:nil];
//    [self.activityIndicatorCenter startAnimating];
//    
//    NSString *url = [self.images[indexPath.row] imagesStandardUrl];
//    UIImage *image = [cache imageForKey:url];
//    if (image)
//    {
//        self.largeImage.image = image;
//    }
//    else
//    {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
//            UIImage * image = [UIImage imageWithData:data];
//            [cache setImage:image forKey:url];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.largeImage.image = image;
//            });
//        });
//    }
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.blurContainerView.alpha = 1.0;
//        self.collectionView.alpha = 0.0;
//    }];
}
//
//- (void) captureBlur {
//    //Get a UIImage from the UIView
//    NSLog(@"blur capture");
//    UIGraphicsBeginImageContext(self.collectionView.bounds.size);
//    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    //Blur the UIImage
//    CIImage *imageToBlur = [CIImage imageWithCGImage:viewImage.CGImage];
//    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
//    [gaussianBlurFilter setValue:imageToBlur forKey: @"inputImage"];
//    [gaussianBlurFilter setValue:[NSNumber numberWithFloat: 2] forKey: @"inputRadius"];
//    CIImage *resultImage = [gaussianBlurFilter valueForKey: @"outputImage"];
//    
//    //create UIImage from filtered image
//    blurrredImage = [[UIImage alloc] initWithCIImage:resultImage];
//    
//    //Place the UIImage in a UIImageView
//    UIImageView *newView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    newView.image = blurrredImage;
//    
//    //insert blur UIImageView below transparent view inside the blur image container
//    [self.blurContainerView insertSubview:newView belowSubview:self.transparentView];
//}

@end
