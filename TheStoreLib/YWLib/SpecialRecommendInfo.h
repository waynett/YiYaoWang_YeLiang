//
//  SpecialRecommendInfo.h
//  TheStoreApp
//
//  Created by LinPan on 13-7-17.
//
//  特别推荐的商品或者专题大图  

#import <Foundation/Foundation.h>


typedef enum
{
    kYaoSpecialBrand = 0, //品牌列表
    kYaoSpecialCatagory = 1, //分类列表
    kYaoSpecialProduct = 2 //商品页面
}kYaoSpecialType;


@interface SpecialRecommendInfo : NSObject<NSCoding>


@property (copy, nonatomic) NSString *spaceCode;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *pic;
@property (copy, nonatomic) NSString *title;

@property (assign, nonatomic) int triggerType;
@property (assign, nonatomic) int platId;
@property (assign, nonatomic) int specialId;//id
@property (assign, nonatomic) int areaId;

@property (assign, nonatomic) kYaoSpecialType type;
@property (assign, nonatomic) int sindex;
@property (assign, nonatomic) int specialType;

@property (assign, nonatomic) NSUInteger brandId;   //品牌id
@property (assign, nonatomic) NSUInteger catalogId; //分类id
@property (assign, nonatomic) NSUInteger productId; //商品id

@end
