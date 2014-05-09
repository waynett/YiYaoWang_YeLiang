//
//  HomePageModelACell.h
//  TheStoreApp
//
//  Created by yuan jun on 13-1-15.
//
//

#import <UIKit/UIKit.h>
#import "AdvertisingPromotionVO.h"
#import "AdFloorInfo.h"
#import "SpecialRecommendInfo.h"

@protocol HomePageModelACellDelegate;

@interface HomePageModelACell : UITableViewCell
{
    UIImageView*adBg;
    NSArray* keywordsArray;
    UIImageView* bigImg;
    UIView* promotionImg;
    
    UIButton *headBtn;
    
    BOOL isLeft;
    id <HomePageModelACellDelegate>delegate;
}

@property(nonatomic,assign)id <HomePageModelACellDelegate>delegate;
@property(nonatomic,retain)NSArray* keywordsArray;
@property(nonatomic,assign)BOOL isLeft;
- (void)freshCell:(int)tag style:(int)style title:(NSString*)title;
-(void)loadBigImg:(NSString*)bigImgStr title:(NSString*)title subTitle:(NSString*)subtit;
-(void)loadFistImg:(NSString*)firstImgStr title:(NSString*)title subTitle:(NSString*)subtit;
-(void)loadsecondImg:(NSString*)secondImgStr title:(NSString*)title subTitle:(NSString*)subtit;
-(void)loadBtn:(AdFloorInfo *)floor;
-(void)loadHeadBtn:(AdFloorInfo *)floor;
@end
@protocol HomePageModelACellDelegate <NSObject>
-(void)keywordBtnSelceted:(UIButton*)button type:(int)type;
-(void)promotionTapcell:(HomePageModelACell*)cell withIdenty:(int)tag;
-(void)pushSmallBtn:(HomePageModelACell*)cell withIdent:(int)tag;
-(void)pushHeadBtn:(HomePageModelACell*)cell;
@end