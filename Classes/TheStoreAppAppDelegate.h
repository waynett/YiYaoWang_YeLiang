//
//  TheStoreAppAppDelegate.h
//  TheStoreApp
//
//  Created by tianjsh on 11-2-15.
//  Copyright 2011 vsc. All rights reserved.
//

#define SharedDelegate ((TheStoreAppAppDelegate *)[UIApplication sharedApplication].delegate)

#import <UIKit/UIKit.h>
#import "CartNum.h"
#import "LocalCartService.h"
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "OTSTabBarController.h"
#import <MapKit/MapKit.h>
#import "MyStoreViewController.h"
#import "WapViewController.h"
#import "PhoneCartViewController.h"
#import "WeiboSDK.h"


@class LocalCartItemVO;
@class ConnectAction;
@class Reachability;
@class CLLocationManager;
@class OTSRockBuyVC;
@class OTSContainerViewController;
@class Trader;

@interface TheStoreAppAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,CLLocationManagerDelegate, MKReverseGeocoderDelegate,WeiboSDKDelegate> {
    IBOutlet UIWindow *window;//
    IBOutlet OTSTabBarController *tabBarController;//
    NSInteger temporaryIndex;
	Trader *trader;
    WapViewController *wapViewVC;    
    
    BOOL m_GpsAlertDisAble;
    BOOL m_Getlocation;
    BOOL m_IsFirstLaunch;
    BOOL m_IsFirstAddSwitch;
    BOOL m_isAlertViewShowing;
    BOOL isVersionUpdate;
    BOOL m_UpdateHomePage;
    BOOL m_UpdateCategory;
    BOOL m_UpdateCart;
    BOOL m_UpdateMyStore;
    Reachability *hostReach;
    NSDictionary* remoteNotificationInfo;
    CLLocationCoordinate2D currentUserCoordinate;
    BOOL needCachedPromotion;
}
@property (nonatomic,assign)BOOL m_UpdateCategory,m_UpdateCart,needCachedPromotion;
@property (nonatomic,retain)OTSTabBarController *tabBarController;
@property (nonatomic)BOOL isVersionUpdate;
@property (nonatomic)BOOL m_GpsAlertDisAble;
@property (nonatomic)BOOL m_isAlertViewShowing;
@property (nonatomic)BOOL m_IsFirstLaunch;
@property (nonatomic,retain)UIWindow *window;
@property (nonatomic,retain)OTSContainerViewController* tabbarMaskVC;
@property (nonatomic,retain)WapViewController *wapViewVC;


-(void)setCartNum:(int)cartNumber;//设置购物车显示商品数量
-(void)clearCartNum;//清空购物车显示商品数量
-(void)syncMyStoreBadge;//同步我的1号店肩标
-(void)addProductToLocal:(LocalCartItemVO *)localCartItemVO;//添加商品到本地购物车
/* 没有用到
-(BOOL)addUniqueProductToLocalCart:(LocalCartItemVO*)aCartItem;//添加商品到本地购物车，最多添加一件
 */

-(void)logout;

-(void)enterCategory;//进入分类
-(void)enterRockBuy;//进入1起摇界面
-(void)enterCartWithUpdate:(BOOL)update;
-(void)enterCartWithTipInView:(NSString *)string;//购物车提示信息
-(void)enterHomePageRoot;//进入首页主界面
-(void)enterCartRoot;//进入购物车主界面
-(void)enterMyStoreWithUpdate:(BOOL)update;//进入我的1号店
-(void)enterWap:(NSInteger)waptype invokeUrl:(NSString*)invokeUrl isClearCookie:(BOOL)isClearCookie;
-(void)enterHomePageLogistic;//进入首页物流查询
-(void)enterMyFavorite:(FavoriteFromTag)fromTag;//进入1号店我的收藏
-(void)enterJiePangWithProductVO:(ProductVO *)productVO isExclusive:(BOOL)isExclusive;//进入街旁
-(void)enterGrouponDetailWithAreaId:(NSNumber *)areaId products:(NSArray *)products currentIndex:(int)index fromTag:(int)fromTag isFullScreen:(BOOL)isFullScreen;//进入团购详情
-(void)enterUserManageWithTag:(int)tag;//进入登录注册页面


-(void)enterFilterWithSearchResultVO:(SearchResultVO *)searchResultVO condition:(NSMutableDictionary *)condition fromTag:(int)fromTag;//进入筛选
-(void)enterOnlinePayWithOrderId:(int)orderId;
-(void)homePageSearchBarBecomeFirstResponder;

//-(void)requestGPS;//定位
-(void)reportinterfaceLog;//报告接口状态
-(HomePage*)homePage;
-(PhoneCartViewController*)shoppingCart;//返回购物车vc
-(void)refreshCart;
-(UIImageView*)checkMarkView;//红色的勾号


-(void)showInMask:(OTSBaseViewController*)aVC;
-(void)popMask;

//- (void)addLocalProductItem:(LocalCartItemVO *)localProductVO;

//显示加入购物车动画
-(void)showAddCartAnimationWithDelegate:(id)delegate;
//发送接口出错日志
-(void)insertAppErrorLog:(NSString *)errorLog methodName:(NSString *)methodName;

-(CGRect)screenRectHasTabBar:(BOOL)aHasTabBar statusBar:(BOOL)aHasStatusBar;

//+(void)showFavoriteTipWithState:(int)aFavoriteState inView:(UIView*)aView;   // 显示收藏提示
+(void)showFavoriteTipWithState:(int)aFavoriteState inView:(UIView*)aView productId:(NSString *)productId;

#if defined (STANDARD_NAVIGATION_ENABLED)
-(void)standardNaviPushFromVC:(UIViewController*)aFromVC toVC:(UIViewController*)aToVC;
-(void)standardNaviPopVC:(UIViewController*)aViewController;
-(void)standardNaviPopToRootVC:(UIViewController *)aViewController;
-(UIViewController*)currentTabSelectedVC;
-(id)instanceWithNibByClassName:(NSString*)aClassName;
-(void)standardVC:(UIViewController*)aFromVC presentModalVC:(UIViewController*)aToVC;
-(void)standardDismissModalVC:(UIViewController*)aVC;
#endif

@end