//
//  NewsFetcher.m
//  ArseblogNews
//
//  Created by Adam Lum on 1/15/12.
//  Copyright (c) 2012 Adam Lum. All rights reserved.
//

#import "NewsFetcher.h"

@implementation NewsFetcher

+ (NSData *)executeNewsFetch
{
    return [[NSString stringWithContentsOfURL:[NSURL URLWithString:ARSEBLOG_NEWS_LINK] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
}

@end
