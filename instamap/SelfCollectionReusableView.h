//
//  SelfCollectionReusableView.h
//  instamap
//
//  Created by Andrei Rozhkov on 25.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelfCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIImageView *userPic;
@property (weak, nonatomic) IBOutlet UILabel *userName;
- (IBAction)following:(id)sender;

- (IBAction)followed:(id)sender;

@end
