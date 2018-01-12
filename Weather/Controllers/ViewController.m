//
//  ViewController.m
//  Weather
//
//  Created by mike oh on 2018-01-11.
//  Copyright © 2018 mike oh. All rights reserved.
//

#import "ViewController.h"
#import "WeatherModel.h"

static NSString * const kLastSearchedCity = @"lastSearchedCity";

@interface ViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherMainLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UILabel *temp_maxLabel;
@property (weak, nonatomic) IBOutlet UILabel *temp_minLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *busyView;

@property (nonatomic) WeatherModel *weatherModel;
@property (nonatomic) NSString *lastSearchedCity;

@end

@implementation ViewController

#pragma mark lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _weatherModel = [WeatherModel.alloc init];
    
    self.cityLabel.text = self.lastSearchedCity;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *city = self.cityLabel.text;
    
    if (city.length) {
        [self doSearch:city];
    }
}

#pragma mark internal methods

- (void) doSearch:(NSString *)searchText {
    [self loading:YES];
    
    __weak typeof(self) weakSelf = self;

    [self.weatherModel getWeatherData:searchText completion:^(NSDictionary *result, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf loading:NO];
        
        if (!error) {
            [strongSelf displayWeatherData:result];
        } else {
            [strongSelf displayErrorStatus:error];
        }
    }];
}

- (void)displayErrorStatus:(NSError *)error {
    [self resetWeathrData];
    // Error can be handled here such as displaying error status.
}

- (void)displayWeatherData:(NSDictionary *)dic {
    if (!dic) {
        [self resetWeathrData];
        return;
    }
    
    NSString *city = dic[@"name"];
    NSString *searchCity = self.searchBar.text;
    
    // When app loaded with previous city, no need check between city and searchCity.
    // This condition check is needed when there are more than one response avaiable from async patches.
    if (searchCity.length > 0  && [city caseInsensitiveCompare:searchCity]) {
        [self resetWeathrData];
        return;
    }

    self.lastSearchedCity = city;
    
    NSDictionary *sysDic = dic[@"main"];
    NSString *country = sysDic[@"country"] ? sysDic[@"country"] : @"";
    self.cityLabel.text = [NSString stringWithFormat:@"%@ %@", city, country];

    // main information
    NSDictionary *mainDic = dic[@"main"];
    self.tempLabel.text = [NSString stringWithFormat:@"%.2f \u00B0F",
                           [self numberToDouble:mainDic[@"temp"]]];
    self.temp_maxLabel.text = [NSString stringWithFormat: @"High: %.2f \u00B0F",
                               [self numberToDouble:mainDic[@"temp_max"]]];
    self.temp_minLabel.text = [NSString stringWithFormat: @"Low: %.2f \u00B0F",
                               [self numberToDouble:mainDic[@"temp_min"]]];
    self.humidityLabel.text = [NSString stringWithFormat: @"Humidity: %.0f",
                               [self numberToDouble:mainDic[@"humidity"]]];
    self.pressureLabel.text = [NSString stringWithFormat: @"Pressure: %.0f",
                               [self numberToDouble:mainDic[@"pressure"]]];

    // wind information
    NSDictionary *windDic = dic[@"wind"];
    self.windLabel.text = [NSString stringWithFormat: @"Wind: %@km/h", windDic[@"speed"]];
    //self.degLabel.text = [NSString stringWithFormat: @"%@", mainDic[@"deg"]];

    // weather information
    if ([dic[@"weather"] isKindOfClass: [NSArray class]]) {
        // Took the last object from weather array.
        NSDictionary *weatherDic = [dic[@"weather"] lastObject];
        self.weatherMainLabel.text = weatherDic[@"main"];
        NSString *icon = weatherDic[@"icon"];
        [self.weatherModel loadIcon:icon imageView:self.iconImageView placeHolder:[self placeHolder]];
    }
}

- (void)resetWeathrData {
    self.cityLabel.text = nil;
    self.tempLabel.text = nil;
    self.weatherMainLabel.text = nil;
    self.windLabel.text = nil;
    self.temp_maxLabel.text = nil;
    self.temp_minLabel.text = nil;
    self.humidityLabel.text = nil;
    self.pressureLabel.text = nil;
    
    self.iconImageView.image = [self placeHolder];
}

#pragma mark getters & setters

- (NSString *)lastSearchedCity {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kLastSearchedCity];
}


- (void)setLastSearchedCity:(NSString *)lastSearchedCity {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:lastSearchedCity forKey:kLastSearchedCity];
    //synchronize is deprecated.
}

#pragma mark helpers

- (UIImage *)placeHolder {
    // not set. Would be set later.
    return nil;
}

// This method can be replaced in a helper class.
- (double)numberToDouble:(NSNumber *)number {
    if(number) {
        return number.doubleValue;
    }
    return 0;
}

#pragma mark loading

- (void)loading:(BOOL)isLoading {
    self.loadingView.hidden = !isLoading;
    if (isLoading) {
        [self.busyView startAnimating];
    } else {
        [self.busyView stopAnimating];
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        [searchBar resignFirstResponder];
    }
    // The below line is commented out because my account is limited maximum 60 calls per minute.
    //[self doSearch:searchText];
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self doSearch:_searchBar.text];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = @"";
}

@end
