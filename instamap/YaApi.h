//
//  YaApi.h
//  instamap
//
//  Created by a я on 24.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YaApi : NSObject

@property (nonatomic, strong) NSString* description;
@property (nonatomic, strong) NSString* latitude;
@property (nonatomic, strong) NSString* longitude;


+ (void)searchGeocode:(NSString *)geocode block:(void (^)(NSArray *records))block;

@end
