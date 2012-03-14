//
//  NewsEntry+Create.h
//  ArseblogNews
//
//  Created by Adam Lum on 1/15/12.
//  Copyright (c) 2012 Adam Lum. All rights reserved.
//

#import "NewsEntry.h"

@interface NewsEntry (Create)

+ (NewsEntry *) newsEntryFromGuid: (NSString *)guid withTitle: (NSString *)title withEntryDate: (NSDate *)entryDate withEntryDescription: (NSString *)entryDescription withEntryContent: (NSString *)entryContent withLink: (NSString *)link withAuthor: (NSString *)author inManagedContext: (NSManagedObjectContext *)context;

@end
