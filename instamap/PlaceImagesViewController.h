//
//  PlaceImagesViewController.h
//  instamap
//
//  Created by Andrei Rozhkov on 20.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceImagesViewController : UICollectionViewController

@property (strong, nonatomic) NSString *locationId;
@property (strong, nonatomic) NSMutableArray *locationIdArray;

@end
