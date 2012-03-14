//
//  NewsEntry.h
//  ArseblogNews
//
//  Created by Adam Lum on 1/15/12.
//  Copyright (c) 2012 Adam Lum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NewsEntry : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * entryDate;
@property (nonatomic, retain) NSString * entryDescription;
@property (nonatomic, retain) NSString * entryContent;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * link;

@end
