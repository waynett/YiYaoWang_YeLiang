//
//  MyBrowse.h
//  TheStoreApp
//
//  Created by towne on 12-9-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "StrikeThroughLabel.h"
#import "BackToTopView.h"
#import "OTSAlertView.h"
#import "ProductVO.h"

@interface MyBrowse : OTSBaseViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>{
    
    BOOL _running;//开启线程
    NSInteger _currentState;// 当前线程状态
    NSString* _delProductId;   //待删除的产品id
    NSNumber* _delGrouponId;   //待删除的团购id
    NSInteger _currentActionIndex;
    ProductVO *_productVo;// 浏览商品vo
    
    UIView *_noProductView;
    
	BOOL _isAnimStop;								// 是否可以启动其他动画
	UIButton *_mEditBtn;
	BackToTopView *_backView;
@public
	UITableView *_mTableView;
    BOOL _isfromcart;
}

@property NSInteger _currentState;
@property(retain)NSString* _delProductId;
@property(retain)NSNumber* _delGrouponId;
@property(retain)NSMutableArray* browseArray;  // 此成员变量可能由多个线程同时读写，故使用线程安全属性 --- dym.12.06.12.
@property(retain)NSNumber* grouponAreaId;      //团购地区

-(void)setUpThread:(BOOL)showLoading;
-(void)startThread;
-(void)stopThread;

#pragma mark 显示收藏Sheet列表
-(void)showSheetView;
-(void)startAnimation;                      // 开始动画
-(void)showBuyProductAnimation;             // 购物车动画
@end
