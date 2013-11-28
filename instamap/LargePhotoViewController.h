//
//  LargePhotoViewController.h
//  instamap
//
//  Created by Andrei Rozhkov on 27.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LargePhotoViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSMutableArray *images;
@property (assign, nonatomic) NSInteger row;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
