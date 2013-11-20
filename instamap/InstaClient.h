//
//  InstaApi.h
//  invite
//
//  Created by a я on 13.09.13.
//  Copyright (c) 2013 zhorkov023. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFHTTPSessionManager.h>

extern NSString * const kInstagramBaseURLString;
extern NSString * const kClientId;
extern NSString * const kRedirectUrl;

// Endpoints
extern NSString * const kAuthenticationEndpoint;
extern NSString * const kRecentTags;
extern NSString * const kUserSearch;
extern NSString * const kUserMedia;
extern NSString * const kLocationSearch;
extern NSString * const kLocationMedia;

@interface InstaClient : AFHTTPSessionManager

+ (InstaClient *)sharedClient;
- (id)initWithBaseURL:(NSURL *)url;

@end
