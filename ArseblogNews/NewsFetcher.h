//
//  NewsFetcher.h
//  ArseblogNews
//
//  Created by Adam Lum on 1/15/12.
//  Copyright (c) 2012 Adam Lum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsFetcher : NSObject

#define ARSEBLOG_NEWS_LINK @"http://feeds.feedburner.com/arseblognews"

+ (NSData *)executeNewsFetch;

@end
