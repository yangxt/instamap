//
//  PhotosCollectionReusableView.h
//  instamap
//
//  Created by a я on 24.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIImageView *userPic;
@property (weak, nonatomic) IBOutlet UILabel *userName;
- (IBAction)followUser:(id)sender;


@end
