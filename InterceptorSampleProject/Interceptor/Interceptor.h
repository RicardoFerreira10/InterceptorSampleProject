//
//  Interceptor.h
//  InterceptorSampleProject
//
//  Created by Ricardo Ferreira on 28/05/2019.
//  Copyright © 2019 Ricardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Interceptor : NSURLProtocol

@property (nonatomic, readwrite, strong) NSURLConnection *connection;

@end

NS_ASSUME_NONNULL_END
