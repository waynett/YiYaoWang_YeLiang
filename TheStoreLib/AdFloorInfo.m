//
//  AdFloorInfo.m
//  TheStoreApp
//
//  Created by LinPan on 13-7-29.
//
//

#import "AdFloorInfo.h"

@implementation AdFloorInfo

- (void)dealloc
{
    [_head release];
    [_bigPage release];
    [_productList release];
    [_keywordList release];
    [super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_head forKey:@"head"];
    [aCoder encodeObject:_bigPage forKey:@"bigPage"];
    [aCoder encodeObject:_productList forKey:@"productList"];
    [aCoder encodeObject:_keywordList forKey:@"keywordList"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.head = [aDecoder decodeObjectForKey:@"head"];
    self.bigPage = [aDecoder decodeObjectForKey:@"bigPage"];
    self.productList = [aDecoder decodeObjectForKey:@"productList"];
    self.keywordList = [aDecoder decodeObjectForKey:@"keywordList"];
    return  self;
}

@end
