//
//  PlacesViewController.h
//  instamap
//
//  Created by Andrei Rozhkov on 20.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PlacesViewController : UITableViewController

@property(strong, nonatomic) NSString *lat;
@property(strong, nonatomic) NSString *lng;
@end
