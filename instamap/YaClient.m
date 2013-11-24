//
//  YaClient.m
//  instamap
//
//  Created by a я on 24.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "YaClient.h"

NSString * const kYaBaseURLString = @"http://geocode-maps.yandex.ru/1.x/";

// Endpoints
//NSString * const kRecentTags = @"tags/%@/media/recent";

@implementation YaClient

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

+ (YaClient *)sharedClient
{
    static YaClient * _sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kYaBaseURLString]];
    });
    
    return _sharedClient;
}
@end
