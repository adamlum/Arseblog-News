//
//  NewsEntryViewController.h
//  ArseblogNews
//
//  Created by Adam Lum on 1/16/12.
//  Copyright (c) 2012 Adam Lum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsEntry.h"

@interface NewsEntryViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NewsEntry *newsEntry;

@end
