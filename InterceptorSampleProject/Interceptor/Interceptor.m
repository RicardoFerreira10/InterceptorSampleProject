//
//  Interceptor.m
//  InterceptorSampleProject
//
//  Created by Ricardo Ferreira on 28/05/2019.
//  Copyright © 2019 Ricardo Ferreira. All rights reserved.
//

#import "Interceptor.h"

@implementation Interceptor

@synthesize connection = connection_;

#if WORKAROUND_MUTABLE_COPY_LEAK
// required to workaround http://openradar.appspot.com/11596316
@interface NSURLRequest(AvoidMutableCopyLeak)

- (id) avoidMutableCopyLeak;

@end
#endif

/**
 * Implementation of URLProtocol abstract method. Should determine if,
 * according to the request scheme, the Interceptor is able to handle the request.
 * @param request the original NSURLRequest
 * @return BOOL true if Interceptor handles the scheme, ortherwise, returns false
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *) request {
    NSLog(@"[%@] Requesting....", NSStringFromClass([self class]));
    
    if ([request.URL.absoluteString hasPrefix:@"https"]) {
        return YES;
    }
    return NO;
}

/**
 * Implementation of NSURLProtocol abstract method.
 * - seealso:
 [NSURLProtocol](https://developer.apple.com/documentation/foundation/nsurlprotocol)
 */
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *) request {
    NSLog(@"[%@] canonicalRequestForRequest", NSStringFromClass([self class]));
    return request;
}

/**
 * Implementation of NSURLProtocol method.
 * - seealso:
 [NSURLProtocol](https://developer.apple.com/documentation/foundation/nsurlprotocol/1408989-startloading?language=objc)
 * Starts loading of a request
 */
- (void)startLoading {
    NSLog(@"[%@] Starting Loading the request: %@", NSStringFromClass([self class]),[[self request] allHTTPHeaderFields]);
    
    NSMutableURLRequest *interceptorRequest =
#if WORKAROUND_MUTABLE_COPY_LEAK
    [[self request] avoidMutableCopyLeak];
#else
    [[self request] mutableCopy];
#endif
    [interceptorRequest addValue:@"1.0.1" forHTTPHeaderField:@"Interceptor Version"];
    
    [self setConnection:[NSURLConnection connectionWithRequest:interceptorRequest delegate:self]];

}

/**
 * Implementation of NSURLProtocol method.
 * - seealso:
 [NSURLProtocol](https://developer.apple.com/documentation/foundation/nsurlprotocol/1408666-stoploading?language=objc)
 * Stop loading of a request calling the connection cancel method.
 */
- (void)stopLoading {
    [[self connection] cancel];
}

/**
 * Implementation of NSURLConnectionDataDelegate method that receives and handles
 * - seealso:
 [NSURLConnectionDataDelegate](https://developer.apple.com/documentation/foundation/nsurlconnectiondatadelegate/1415830-connection?language=objc)
 * Invokes the client method with the error. Empties the connection,data and repsonse variables.
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"[%@] Failed With error: %@", NSStringFromClass([self class]), error.debugDescription);
    
    [[self client] URLProtocol:self didFailWithError:error];
}

/**
 * Implementation of NSURLConnectionDataDelegate method that receives and handles
 * the info when a request will be sent.
 * - seealso:
 [NSURLConnectionDataDelegate](https://developer.apple.com/documentation/foundation/nsurlconnectiondatadelegate/1415830-connection?language=objc)
 * Notified when a request will be sent
 */
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    NSLog(@"[%@] Will send request: %@ ", NSStringFromClass([self class]), [request allHTTPHeaderFields]);

    return request;
}

/**
 * Implementation of NSURLConnectionDataDelegate method.
 * - seealso:
 [NSURLConnectionDataDelegate](https://developer.apple.com/documentation/foundation/nsurlconnectiondatadelegate/1416409-connectiondidfinishloading?language=objc)
 * Notified when a response is received, redirects the response to the client.
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"[%@] Received response code: %ld", NSStringFromClass([self class]), (long)[((NSHTTPURLResponse *) response) statusCode]);
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

/**
 * Implementation of NSURLConnectionDataDelegate method.
 * - seealso:
 [NSURLConnectionDataDelegate](https://developer.apple.com/documentation/foundation/nsurlconnectiondatadelegate/1416409-connectiondidfinishloading?language=objc)
 * Notified when data is received, notifies the client with respective data.
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"[%@] Received data\n%@", NSStringFromClass([self class]), [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);

    [[self client] URLProtocol:self didLoadData:data];
}

/**
 * Implementation of NSURLConnectionDataDelegate method.
 * - seealso:
 [NSURLConnectionDataDelegate](https://developer.apple.com/documentation/foundation/nsurlconnectiondatadelegate/1416409-connectiondidfinishloading?language=objc)
 * Called when a connection finish loading passes the info to the client
 * and clears the connection,data and repsonse variables.
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"[%@] Finish loading", NSStringFromClass([self class]));

    [[self client] URLProtocolDidFinishLoading:self];
}

@end

#if WORKAROUND_MUTABLE_COPY_LEAK
@implementation NSURLRequest(AvoidMutableCopyLeak)

- (id) avoidMutableCopyLeak {
    
    NSMutableURLRequest *mutableURLRequest = [self mutableCopy];

    return mutableURLRequest;
}

@end
#endif
