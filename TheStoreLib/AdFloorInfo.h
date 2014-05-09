//
//  AdFloorInfo.h
//  TheStoreApp
//
//  Created by LinPan on 13-7-29.
//
//  首页楼层广告类的model

#import <Foundation/Foundation.h>

@interface AdFloorInfo : NSObject<NSCoding>

@property(copy,nonatomic) id head;
@property(copy,nonatomic) id bigPage;
@property(retain, nonatomic) NSMutableArray *productList;
@property(retain, nonatomic) NSArray *keywordList;

@end
