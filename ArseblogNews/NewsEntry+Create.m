//
//  NewsEntry+Create.m
//  ArseblogNews
//
//  Created by Adam Lum on 1/15/12.
//  Copyright (c) 2012 Adam Lum. All rights reserved.
//

#import "NewsEntry+Create.h"

@implementation NewsEntry (Create)

+ (NewsEntry *) newsEntryFromGuid: (NSString *)guid withTitle: (NSString *)title withEntryDate: (NSDate *)entryDate withEntryDescription: (NSString *)entryDescription withEntryContent: (NSString *)entryContent withLink: (NSString *)link withAuthor: (NSString *)author inManagedContext: (NSManagedObjectContext *)context
{
    NewsEntry *newsEntry = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NewsEntry"];
    request.predicate = [NSPredicate predicateWithFormat:@"guid = %@", guid];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"guid" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:descriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if ([matches count] == 0)
    {
        newsEntry = [NSEntityDescription insertNewObjectForEntityForName:@"NewsEntry" inManagedObjectContext:context];
        newsEntry.guid = guid;
        newsEntry.title = title;
        newsEntry.entryDate = entryDate;
        newsEntry.entryDescription = entryDescription;
        newsEntry.entryContent = entryContent;
        newsEntry.link = link;
        newsEntry.author = author;
    }
    else
    {
        newsEntry = [matches lastObject];
    }
    
    return newsEntry;
}

@end
