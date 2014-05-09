//
//  SpecialRecommendInfo.m
//  TheStoreApp
//
//  Created by LinPan on 13-7-17.
//
//


#import "SpecialRecommendInfo.h"

@implementation SpecialRecommendInfo

@synthesize pic;
- (void)dealloc
{
    [_spaceCode release];
    [_content release];
    [pic release];
    [_title release];
    [super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_spaceCode forKey:@"spaceCode"];
    [aCoder encodeObject:_content forKey:@"content"];
    [aCoder encodeObject:pic forKey:@"pic"];
    [aCoder encodeObject:_title forKey:@"title"];
    
    [aCoder encodeInt:_triggerType forKey:@"triggerType"];
    [aCoder encodeInt:_platId forKey:@"platId"];
    [aCoder encodeInt:_specialId forKey:@"specialId"];
    [aCoder encodeInt:_areaId forKey:@"areaId"];
    
    [aCoder encodeInt:_type forKey:@"type"];
    [aCoder encodeInt:_sindex forKey:@"sindex"];
    [aCoder encodeInt:_specialType forKey:@"specialType"];
    [aCoder encodeInteger:_productId forKey:@"productId"];
    [aCoder encodeInteger:_catalogId forKey:@"categoryId"];
    [aCoder encodeInteger:_brandId forKey:@"brandId"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self.spaceCode = [aDecoder decodeObjectForKey:@"spaceCode"];
    self.content = [aDecoder decodeObjectForKey:@"content"];
    self.pic = [aDecoder decodeObjectForKey:@"pic"];
    self.title = [aDecoder decodeObjectForKey:@"title"];
    
    self.triggerType = [aDecoder decodeObjectForKey:@"triggerType"];
    self.specialId = [aDecoder decodeObjectForKey:@"specialId"];
    self.platId = [aDecoder decodeObjectForKey:@"platId"];
    self.areaId = [aDecoder decodeObjectForKey:@"areaId"];
    
    self.type = [aDecoder decodeIntForKey:@"type"];
    self.sindex = [aDecoder decodeIntForKey:@"sindex"];
    self.specialType = [aDecoder decodeIntForKey:@"specialType"];
    
    self.productId = [aDecoder decodeObjectForKey:@"productId"];
    self.catalogId = [aDecoder decodeObjectForKey:@"categoryId"];
    self.brandId = [aDecoder decodeObjectForKey:@"brandId"];
    
    return self;
}

- (NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"\nspaceCode %@\ncontent %@\npic %@\ntitle %@\ntriggerType %d\nspecialId %d\nplatId %d\nareaId %d",_spaceCode,_content,pic,_title,_triggerType,_platId,_specialId,_areaId];
    return desc;
}

@end
