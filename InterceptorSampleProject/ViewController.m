//
//  ViewController.m
//  InterceptorSampleProject
//
//  Created by Ricardo Ferreira on 28/05/2019.
//  Copyright © 2019 Ricardo Ferreira. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _requestURL = @"https://postman-echo.com/get";
    [self makeRequest];
}

- (void) makeRequest {
    NSLog(@"Requesting...");
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (configuration.protocolClasses != nil ) {
        configuration.protocolClasses = @[[Interceptor class]];
    }
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_requestURL]];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200) {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSLog(@"[%@] Received response: %@",NSStringFromClass([self class]), responseDictionary);
        } else {
            NSLog(@"Error");
        }
    }];
    
    [dataTask resume];
}

@end
