//
//  WeatherModel.h
//  Weather
//
//  Created by mike oh on 2018-01-11.
//  Copyright © 2018 mike oh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^WeatherModelRequestCompletionBlock)(NSDictionary *result, NSError *error);

@interface WeatherModel : NSObject

- (void)getWeatherData: (NSString *)city completion:(WeatherModelRequestCompletionBlock)completion;
- (void)loadIcon:(NSString *)icon imageView:(UIImageView *)imageView placeHolder:(UIImage *)palaceHolder ;

@end
