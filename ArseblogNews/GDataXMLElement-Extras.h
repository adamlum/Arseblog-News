//
//  GDataXMLElement-Extras.h
//  ArseblogNews
//
//  Created by Adam Lum on 1/14/12.
//  Copyright (c) 2012 Adam Lum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface GDataXMLElement (Extras)

- (GDataXMLElement *)elementForChild:(NSString *)childName;
- (NSString *)valueForChild:(NSString *)childName;

@end
