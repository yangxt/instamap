//
//  PhotosCollectionViewController.h
//  instamap
//
//  Created by Andrei Rozhkov on 19.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

@interface PhotosCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString *userId;

@property (strong, nonatomic) NSString *userProfilePic;
@property (strong, nonatomic) NSString *userProfileName;
@end
