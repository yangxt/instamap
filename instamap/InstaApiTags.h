//
//  InstaApiTags.h
//  invite
//
//  Created by a я on 16.09.13.
//  Copyright (c) 2013 zhorkov023. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstaApiTags : NSObject

@property (nonatomic, strong) NSString* thumbnailUrl;
@property (nonatomic, strong) NSString* standardUrl;
@property (nonatomic, assign) NSUInteger likes;
@property (nonatomic, assign) NSUInteger comments;
@property (nonatomic, strong) NSString* index;

@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* userpic;

@property (nonatomic, strong) NSString* max_id;
@property (nonatomic, strong) NSString* min_id;

+ (void)searchUser:(NSString *)username withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block;

+ (void)mediaFromUser:(NSString*)userid withAccessToken:(NSString*)accessToken block:(void (^)(NSArray *records))block;
+ (void)mediaFromUser:(NSString*)userid afterMaxId:(NSString *)maxid withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block;
+ (void)mediaFromUser:(NSString*)userid beforeMinId:(NSString *)minid withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block;

@end
