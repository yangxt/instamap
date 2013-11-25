//
//  InstaApi.m
//  invite
//
//  Created by a я on 13.09.13.
//  Copyright (c) 2013 zhorkov023. All rights reserved.
//

#import "InstaClient.h"

NSString * const kInstagramBaseURLString = @"https://api.instagram.com/v1/";
// Include your client id from instagr.am
NSString * const kClientId = @"335105d69b264389ad0424bf7cd40cca";
// Include your redirect uri
NSString * const kRedirectUrl = @"http://instagram.com/";

// Endpoints
NSString * const kRecentTags = @"tags/%@/media/recent";
NSString * const kTagsSearch = @"tags/search";
NSString * const kUserSearch = @"users/search";
NSString * const kUserId = @"users/%@";
NSString * const kUserMedia = @"users/%@/media/recent";
NSString * const kLocationSearch = @"locations/search";
NSString * const kLocationMedia = @"locations/%@/media/recent";
NSString * const kSelfLiked = @"users/self/media/liked";

NSString * const kAuthenticationEndpoint =
@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token&scope=likes";

@implementation InstaClient

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

+ (InstaClient *)sharedClient
{
    static InstaClient * _sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kInstagramBaseURLString]];
    });
    
    return _sharedClient;
}



@end
