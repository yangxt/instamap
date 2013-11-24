//
//  YaApi.m
//  instamap
//
//  Created by a я on 24.11.13.
//  Copyright (c) 2013 Andrei Rozhkov. All rights reserved.
//

#import "YaApi.h"
#import "YaClient.h"

@implementation YaApi

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    NSString *position = [[[attributes valueForKeyPath:@"GeoObject"] valueForKey:@"Point"] valueForKey:@"pos"];
    NSArray *location = [position componentsSeparatedByString:@" "];
    self.latitude = location[1];
    self.longitude = location[0];
    self.description = [[[[attributes valueForKeyPath:@"GeoObject"] valueForKey:@"metaDataProperty"] valueForKey:@"GeocoderMetaData"] valueForKey:@"text"];
    
    return self;
}

+ (void)sendRequestWithPath:(NSString *)path andParam:(NSDictionary *)params andBlock:(void (^)(NSArray *records))block
{
    [[YaClient sharedClient] postPath:path
                             parameters:params
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    if (responseObject==nil) [NSException raise:@"Запрос прошел, но картинки не пришли из за Afhttpclient" format:@"Что то с responseObject"];
                                    NSMutableArray *mutableRecords = [NSMutableArray array];
                                    NSArray* data = [[[responseObject objectForKey:@"response"] objectForKey:@"GeoObjectCollection"] objectForKey:@"featureMember"];
                                    for (NSDictionary* obj in data) {
                                        YaApi* tags = [[YaApi alloc] initWithAttributes:obj];
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
+ (void)searchGeocode:(NSString *)geocode block:(void (^)(NSArray *records))block
{
        NSString * newgeocode = [geocode stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: newgeocode, @"json", @"result", nil]
                                                       forKeys:[NSArray arrayWithObjects: @"geocode", @"format", @"5", nil]];
    
    
//    NSString * newgeocode = [geocode stringByReplacingOccurrencesOfString:@" " withString:@"+"];
//    NSString *url = [NSString stringWithFormat:@"?format=json&geocode=%@", newgeocode];
    [[self class] sendRequestWithPath:@"" andParam:params andBlock:block];
}

@end
