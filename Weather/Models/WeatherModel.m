//
//  WeatherModel.m
//  Weather
//
//  Created by mike oh on 2018-01-11.
//  Copyright © 2018 mike oh. All rights reserved.
//

#import "WeatherModel.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

static NSString * const kApiKey = @"fe7fdc191de562c00fa5ef366bd0e59e";
static NSString * const kAPIUrl = @"http://api.openweathermap.org/";
static NSString * const kAPIWeatherEndPoint = @"data/2.5/weather";
static NSString * const kAPIImageEndPoint = @"img/w/";

@implementation WeatherModel

- (void)getWeatherData:(NSString *)city completion:(WeatherModelRequestCompletionBlock)completion {
    NSString *urlString = [self apiURLString:kAPIWeatherEndPoint];
    NSDictionary *parameters = [self parameters:@{@"q": city}];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            completion(responseObject, nil);
        } else {
            // Custom error used in case the return object is not kind of nsdictionary.
            NSError *error = [NSError errorWithDomain:kAPIUrl code:-1 userInfo:nil];
            completion(nil, error);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)loadIcon:(NSString *)icon imageView:(UIImageView *)iv placeHolder:(UIImage *)palaceHolder {
    if (!icon) {
        return;
    }
    
    [iv setImageWithURL:[self iconURL:icon] placeholderImage:palaceHolder];
}

#pragma mark helpers

- (NSURL *)iconURL:(NSString *)icon {
    NSString *endPoint = [NSString stringWithFormat:@"%@%@%@", kAPIUrl,kAPIImageEndPoint, icon];
    
    return [NSURL URLWithString:endPoint];
}

- (NSString *)apiURLString:(NSString *)endPoint {
    return [NSString stringWithFormat:@"%@%@", kAPIUrl, endPoint];
}

// This method will add apikey for further api calls.
- (NSDictionary *)parameters:(NSDictionary *)dic {
    NSMutableDictionary *returnDic = [dic mutableCopy];
    returnDic[@"APPID"] = kApiKey;
    returnDic[@"units"] = @"imperial";
    return returnDic;
}

@end
