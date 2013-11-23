//
//  PhotoViewController.h
//  instamap
//
//  Created by a я on 23.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *userName;
@property (weak, nonatomic) IBOutlet UIImageView *largeImage;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) NSString *userProfilePic;
@property (strong, nonatomic) NSString *userProfileName;
@property (strong, nonatomic) NSString *userProfileId;
@property (strong, nonatomic) NSString *photoUrl;
@end
