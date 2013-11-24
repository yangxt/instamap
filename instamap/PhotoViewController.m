//
//  PhotoViewController.m
//  instamap
//
//  Created by a я on 23.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "PhotoViewController.h"
#import "SAMCache.h"
#import "PhotosCollectionViewController.h"

@interface PhotoViewController ()
{
    SAMCache *cache;
}

@end

@implementation PhotoViewController

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
    
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh
{
    [self.userName setTitle:self.userProfileName forState:UIControlStateNormal];
    CGSize stringsize = [self.userProfileName sizeWithFont:[UIFont systemFontOfSize:17]];
    CGPoint pos = self.userName.frame.origin;
    [self.userName setFrame:CGRectMake(pos.x,pos.y,stringsize.width, stringsize.height)];

    UIImage *bigPhoto = [cache imageForKey:self.photoUrl];
    UIImage *profilePhoto = [cache imageForKey:self.userProfilePic];
    if (bigPhoto)
        self.largeImage.image = bigPhoto;
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData * bigPhotoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.photoUrl]];
            UIImage * bigPhoto = [UIImage imageWithData:bigPhotoData];
            [cache setImage:bigPhoto forKey:self.photoUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.largeImage.image = bigPhoto;
            });
        });
    }
    if (profilePhoto)
        self.userImage.image = profilePhoto;
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData * profilePhotoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.userProfilePic]];
            UIImage * profilePhoto = [UIImage imageWithData:profilePhotoData];
            [cache setImage:profilePhoto forKey:self.userProfilePic];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userImage.image = profilePhoto;
            });
        });
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"userprofile"])
    {
        PhotosCollectionViewController *photos = [segue destinationViewController];
        photos.userId = self.userProfileId;
        photos.userProfileName = self.userProfileName;
        photos.userProfilePic = self.userProfilePic;
    }
}

@end
