//
//  YaClient.h
//  instamap
//
//  Created by a я on 24.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

extern NSString * const kYaBaseURLString;

@interface YaClient : AFHTTPClient

+ (YaClient *)sharedClient;
- (id)initWithBaseURL:(NSURL *)url;

@end
