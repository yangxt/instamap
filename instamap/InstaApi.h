//
//  InstaApiTags.h
//  invite
//
//  Created by a я on 16.09.13.
//  Copyright (c) 2013 zhorkov023. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstaApi : NSObject

@property (nonatomic, strong) NSString* imagesThumbnailUrl;
@property (nonatomic, strong) NSString* imagesStandardUrl;
@property (nonatomic, assign) NSUInteger likes;
@property (nonatomic, assign) NSUInteger comments;
@property (nonatomic, strong) NSString* index;

@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* userPic;
@property (nonatomic, strong) NSString* userUserName;
@property (nonatomic, strong) NSString* userUserPic;
@property (nonatomic, strong) NSString* userUserId;

@property (nonatomic, strong) NSString* max_id;
@property (nonatomic, strong) NSString* min_id;

@property (nonatomic, strong) NSString* locationLatitude;
@property (nonatomic, strong) NSString* locationLongitude;
@property (nonatomic, strong) NSString* locationName;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* createdTime;

+ (void)searchUser:(NSString *)username withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block;

+ (void)mediaFromUser:(NSString*)userid withAccessToken:(NSString*)accessToken block:(void (^)(NSArray *records))block;
+ (void)mediaFromUser:(NSString*)userid afterMaxId:(NSString *)maxid withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block;
+ (void)mediaFromUser:(NSString*)userid beforeMinId:(NSString *)minid withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block;

+ (void)searchLocationByLat:(NSString*)lat andLng:(NSString *)lng withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block;
+ (void)mediaFromLocation:(NSString*)locationId withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block;


+ (void)searchUserId:(NSString*)userid withAccessToken:(NSString*)accessToken block:(void (^)(NSArray *records))block;

@end
