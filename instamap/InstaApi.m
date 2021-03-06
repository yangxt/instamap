//
//  InstaApiTags.m
//  invite
//
//  Created by a я on 16.09.13.
//  Copyright (c) 2013 zhorkov023. All rights reserved.
//

#import "InstaApi.h"
#import "InstaClient.h"

@implementation InstaApi

- (id)initWithAttributes:(NSDictionary *)attributes andPagination:(NSDictionary *)pagination {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.imagesThumbnailUrl = [[[attributes valueForKeyPath:@"images"] valueForKeyPath:@"thumbnail"] valueForKeyPath:@"url"];
    self.imagesStandardUrl = [[[attributes valueForKeyPath:@"images"] valueForKeyPath:@"standard_resolution"] valueForKeyPath:@"url"];
//    self.likes = [[[attributes objectForKey:@"likes"] valueForKey:@"count"] integerValue];
//    self.comments = [[[attributes objectForKey:@"comments"] valueForKey:@"count"] integerValue];
    self.userName = [attributes valueForKeyPath:@"username"];
    self.userFullName = [attributes valueForKeyPath:@"full_name"];
    self.userPic = [attributes valueForKeyPath:@"profile_picture"];
    self.index = [attributes valueForKeyPath:@"id"];
    self.userUserName = [[attributes valueForKey:@"user"] valueForKey:@"username"];
    self.userUserPic = [[attributes valueForKey:@"user"] valueForKeyPath:@"profile_picture"];
    self.userUserId = [[attributes valueForKey:@"user"] valueForKey:@"id"];
    self.name = [attributes valueForKeyPath:@"name"];
  
    self.max_id = [pagination objectForKey:@"next_max_tag_id"];
    self.min_id = [pagination objectForKey:@"min_tag_id"];
    self.nextmaxlikeid = [pagination objectForKey:@"next_max_like_id"];
    
    self.locationLatitude = [[attributes valueForKeyPath:@"location"] valueForKeyPath:@"latitude"];
    self.locationLongitude = [[attributes valueForKeyPath:@"location"] valueForKeyPath:@"longitude"];
    self.locationName = [[attributes valueForKeyPath:@"location"] valueForKeyPath:@"name"];
    self.createdTime = [attributes valueForKeyPath:@"created_time"];
    
    return self;
}

+ (void)sendRequestWithPath:(NSString *)path andParam:(NSDictionary *)params andBlock:(void (^)(NSArray *records))block
{
    [[InstaClient sharedClient] getPath:path
                          parameters:params
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 if (responseObject==nil) [NSException raise:@"Запрос прошел, но картинки не пришли из за Afhttpclient" format:@"Что то с responseObject"];
                                 NSMutableArray *mutableRecords = [NSMutableArray array];
                                 NSDictionary* pdata = [responseObject objectForKey:@"pagination"];
                                 
                                 NSArray* data = [responseObject objectForKey:@"data"];
                                 for (NSDictionary* obj in data) {
                                     InstaApi* tags = [[InstaApi alloc] initWithAttributes:obj andPagination:pdata];
                                     [mutableRecords addObject:tags];
                                 }
                                 if (block) {
                                     block([NSArray arrayWithArray:mutableRecords]);
                                 }
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"error: %@", error.localizedDescription);
                                 if (block) {
                                     block([NSArray array]);
                                 }
                             }];
}

- (id)initWithAttributes:(NSArray *)attributes{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.userName = [attributes valueForKeyPath:@"username"];
    self.userPic = [attributes valueForKeyPath:@"profile_picture"];
    self.index = [attributes valueForKeyPath:@"id"];
    
    return self;
}

+ (void)sendSimpleRequestWithPath:(NSString *)path andParam:(NSDictionary *)params andBlock:(void (^)(NSArray *records))block
{
    [[InstaClient sharedClient] getPath:path
                             parameters:params
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    if (responseObject==nil) [NSException raise:@"Запрос прошел, но картинки не пришли из за Afhttpclient" format:@"Что то с responseObject"];
                                    NSMutableArray *mutableRecords = [NSMutableArray array];
                                    
                                    NSArray* data = [responseObject objectForKey:@"data"];
                                    InstaApi* tags = [[InstaApi alloc] initWithAttributes:data];
                                    [mutableRecords addObject:tags];
                                    if (block) {
                                        block([NSArray arrayWithArray:mutableRecords]);
                                    }
                                }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"error: %@", error.localizedDescription);
                                    if (block) {
                                        block([NSArray array]);
                                    }
                                }];
}

+ (void)searchUser:(NSString *)username withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: username, accessToken, nil]
                                                       forKeys:[NSArray arrayWithObjects: @"q", @"access_token", nil]];
    
    [[self class] sendRequestWithPath:kUserSearch andParam:params andBlock:block];
}

+ (void)searchUserId:(NSString*)userid withAccessToken:(NSString*)accessToken block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: accessToken, nil]
                                                       forKeys:[NSArray arrayWithObjects: @"access_token", nil]];
    
    NSString *url = [NSString stringWithFormat:kUserId, userid];
    [[self class] sendSimpleRequestWithPath:url andParam:params andBlock:block];
}

+ (void)mediaFromUser:(NSString*)userid withAccessToken:(NSString*)accessToken block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: accessToken, nil]
                                                       forKeys:[NSArray arrayWithObjects: @"access_token", nil]];
    
    NSString *url = [NSString stringWithFormat:kUserMedia, userid];
    
    [[self class] sendRequestWithPath:url andParam:params andBlock:block];
}

+ (void)mediaFromUser:(NSString*)userid afterMaxId:(NSString *)maxid withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: maxid, accessToken, nil]
                                                       forKeys:[NSArray arrayWithObjects: @"max_id", @"access_token", nil]];

    NSString *url = [NSString stringWithFormat:kUserMedia, userid];
    
    [[self class] sendRequestWithPath:url andParam:params andBlock:block];
}

+ (void)mediaFromUser:(NSString*)userid beforeMinId:(NSString *)minid withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: minid, accessToken, nil]
                                                       forKeys:[NSArray arrayWithObjects: @"min_id", @"access_token", nil]];

    NSString *url = [NSString stringWithFormat:kUserMedia, userid];
    
    [[self class] sendRequestWithPath:url andParam:params andBlock:block];
}

+ (void)searchLocationByLat:(NSString*)lat andLng:(NSString *)lng withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: lat, lng, accessToken, nil] forKeys:[NSArray arrayWithObjects: @"lat", @"lng", @"access_token", nil]];
    
    [[self class] sendRequestWithPath:kLocationSearch andParam:params andBlock:block];
}

+ (void)mediaFromLocation:(NSString*)locationId withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: accessToken, nil] forKeys:[NSArray arrayWithObjects: @"access_token", nil]];
    
    NSString *url = [NSString stringWithFormat:kLocationMedia, locationId];
    
    [[self class] sendRequestWithPath:url andParam:params andBlock:block];
}

+ (void)getTag:(NSString*)tagname withAccessToken:(NSString*)accessToken block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: tagname, accessToken, nil]
                                                       forKeys:[NSArray arrayWithObjects: @"tag-name", @"access_token", nil]];
    NSString *url = [NSString stringWithFormat:kRecentTags, tagname];
    
    [[self class] sendRequestWithPath:url andParam:params andBlock:block];
}

+ (void)getTag:(NSString*)tagname afterMaxId:(NSString *)maxid withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: tagname, maxid, accessToken, nil]
                                                       forKeys:[NSArray arrayWithObjects: @"tag-name", @"max_id", @"access_token", nil]];
    NSString *url = [NSString stringWithFormat:kRecentTags, tagname];
    
    [[self class] sendRequestWithPath:url andParam:params andBlock:block];
}

+ (void)getTag:(NSString*)tagname beforeMinId:(NSString *)minid withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: tagname, minid, accessToken, nil]
                                                       forKeys:[NSArray arrayWithObjects: @"tag-name", @"min_id", @"access_token", nil]];
    NSString *url = [NSString stringWithFormat:kRecentTags, tagname];
    
    [[self class] sendRequestWithPath:url andParam:params andBlock:block];
}

+ (void)searchTags:(NSString *)tag withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: tag, accessToken, nil]
                                                       forKeys:[NSArray arrayWithObjects: @"q", @"access_token", nil]];
    
    [[self class] sendRequestWithPath:kTagsSearch andParam:params andBlock:block];
}

+ (void)mediaSelfLikedwithAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: accessToken, nil]
                                                       forKeys:[NSArray arrayWithObjects: @"access_token", nil]];
    
    [[self class] sendRequestWithPath:kSelfLiked andParam:params andBlock:block];
}

+ (void)mediaSelfLikedFromMaxId:(NSString *)maxid withAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: maxid, accessToken, nil]
                                                       forKeys:[NSArray arrayWithObjects: @"max_like_id", @"access_token", nil]];
    
    [[self class] sendRequestWithPath:kSelfLiked andParam:params andBlock:block];
}

+ (void)followedUserswithAccessToken:(NSString *)accessToken block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: accessToken, nil]
                                                       forKeys:[NSArray arrayWithObjects: @"access_token", nil]];
    
    [[self class] sendRequestWithPath:kSelfFollowed andParam:params andBlock:block];
}

@end
