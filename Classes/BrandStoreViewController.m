//
//  BrandStoreViewController.m
//  TheStoreApp
//
//  Created by yuan jun on 13-1-15.
//
//

#import "BrandStoreViewController.h"
#import "AdvertisementServer.h"
#import "GlobalValue.h"
#import "HomePageModelBCell.h"
#import "OTSLoadingView.h"
#import "HotPointNewVO.h"
#import "GrouponVO.h"
#import "OTSUtility.h"
#import "TheStoreAppAppDelegate.h"
#import "OTSProductDetail.h"
#import "GroupBuyHomePage.h"
#import "OTSNNPiecesVC.h"
#import "CategoryProductsViewController.h"
#import "GTMBase64.h"
#import "JSTrackingPrama.h"
#import "DoTracking.h"
#import "ProductService.h"
#import "DataController.h"
#import "LocalCartItemVO.h"
#define FROM_GROUPON_HOMEPAGE_TO_DETAIL   0
#define FROM_CMS_TO_DETAIL   1

#define cellHeight 200
#define adWidth 290
#define  adHeight 140
#define adTextHeight 35
@interface BrandStoreViewController ()

@end

@implementation BrandStoreViewController
-(void)dealloc{
    [adArray release];
    [brandTable release];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        adArray=[[NSMutableArray alloc] init];
        currentPage=1;
        pageSize=5;
    }
    return self;
}
-(void)getBrandData{
    @autoreleasepool {
        AdvertisementServer* adser=[[AdvertisementServer alloc] init];
        Page*page =[adser getAdvertisingPromotionVOByType:[GlobalValue getGlobalValueInstance].trader provinceId:[GlobalValue getGlobalValueInstance].provinceId type:[NSNumber numberWithInt:1] currentPage:[NSNumber numberWithInt:currentPage] pageSize:[NSNumber numberWithInt:pageSize]];
        if (page!=nil) {
            totalPage=[page.totalSize intValue];
            [adArray addObjectsFromArray:page.objList];
            [self performSelectorOnMainThread:@selector(updateBrandTable) withObject:nil waitUntilDone:YES];
        }else{
            [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
        }
        [adser release];
    }
}
-(void)showAlert{
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"网络异常" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
    [alert release];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        [self backClick:nil];
    }
}
-(void)updateBrandTable{
    [self hideLoading];
    [brandTable reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView* topNav=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    topNav.userInteractionEnabled=YES;
    topNav.image=[UIImage imageNamed:@"title_bg.png"];
    [self.view addSubview:topNav];
    [topNav release];
    UILabel* titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 44)];
    titleLabel.font=[UIFont boldSystemFontOfSize:20];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.shadowColor=[UIColor darkGrayColor];
    titleLabel.text = @"品牌旗舰店";
    titleLabel.shadowOffset=CGSizeMake(1, -1);
    titleLabel.backgroundColor=[UIColor clearColor];
    [topNav addSubview:titleLabel];
    [titleLabel release];
    
    UIButton* backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame=CGRectMake(0,0,61,44);
    backBtn.titleLabel.font=[UIFont boldSystemFontOfSize:13];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"title_left_btn.png"] forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"title_left_btn_sel.png"] forState:UIControlStateHighlighted];    
    [backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    [topNav addSubview:backBtn];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0]];

    brandTable=[[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height-44-49)];
    brandTable.delegate=self;
    brandTable.backgroundColor=[UIColor clearColor];
    brandTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    brandTable.dataSource=self;
    [self.view addSubview:brandTable];
    
    [self showLoading:YES];
    [self otsDetatchMemorySafeNewThreadSelector:@selector(getBrandData) toTarget:self withObject:nil];
}
-(void)backClick:(id)sender{
    [self popSelfAnimated:YES];
}

-(void)enterGrouponDetailWithProducts:(NSArray *)products currentIndex:(int)index areaId:(NSNumber *)areaId fromTag:(int)fromTag {
    [SharedDelegate enterGrouponDetailWithAreaId:areaId products:products currentIndex:index fromTag:fromTag isFullScreen:YES];
}
//-(void)enterNNPieces
//{
//    [self removeSubControllerClass:[OTSNNPiecesVC class]];
//    OTSNNPiecesVC* vc = [[[OTSNNPiecesVC alloc] init] autorelease];
//    [self.view.layer addAnimation:[OTSNaviAnimation animationPushFromRight] forKey:@"Reveal"];
//    [self pushVC:vc animated:YES];
//    //	[self setUniqueScrollToTopFor:(UIScrollView*)(vc.tv)];
//}

-(void)enterRePromotion:(HotPointNewVO*)HTnewVO{
    CategoryProductsViewController*cateProduct=[[[CategoryProductsViewController alloc] init] autorelease] ;
    [cateProduct setCateId:[NSNumber numberWithInt:0]];
    [cateProduct setTitleLableText:HTnewVO.title];
    [cateProduct setTitleText:@"全部"];
    [cateProduct setPromotionId:HTnewVO.promotionId];
    [cateProduct setIsCashPromotionList:YES];
    [cateProduct setIsFailSatisfyFullDiscount:YES];
    [self pushVC:cateProduct animated:YES fullScreen:YES];
}

-(void)enterCMSPage:(HotPointNewVO *)hotPointNewVO
{
    firstInWeb=YES;
    
    JSTrackingPrama* prama = [[[JSTrackingPrama alloc]initWithJSType:EJStracking_AD_HotPage extraPrama:[NSString stringWithFormat:@"%@",hotPointNewVO.promotionId],nil]autorelease];
    [DoTracking doJsTrackingWithParma:prama];
    
    if (0==[[hotPointNewVO type] intValue]){//热销商品
        HotPointNewVO *hotPointVO=hotPointNewVO;
        if ([hotPointVO grouponVOList]!=nil) {//团购商品列表
            GrouponVO *grouponVO=[OTSUtility safeObjectAtIndex:0 inArray:[hotPointVO grouponVOList]];
            
            NSMutableArray *products=[[NSMutableArray alloc] init];
            [products addObject:grouponVO];
            
            [self enterGrouponDetailWithProducts:products currentIndex:0 areaId:nil fromTag:FROM_CMS_TO_DETAIL];
            
            [products release];
        } else if ([hotPointVO productVOList]!=nil) {
            ProductVO *productVO=[OTSUtility safeObjectAtIndex:0 inArray:[hotPointVO productVOList]];
            OTSProductDetail *productDetail=[[[OTSProductDetail alloc] initWithProductId:[productVO.productId longValue] promotionId:productVO.promotionId fromTag:PD_FROM_OTHER] autorelease];
            [self.view.layer addAnimation:[OTSNaviAnimation animationPushFromRight] forKey:@"Reveal"];
            [self pushVC:productDetail animated:YES];
        } else {
        }
    } else if (1==[[hotPointNewVO type] intValue]){//热销活动
        if (celebrateTitleStr!=nil) {
            [celebrateTitleStr release];
        }
        celebrateTitleStr=[hotPointNewVO.title retain];
        if (celebrateWebUrl!=nil) {
            [celebrateWebUrl release];
        }
        celebrateWebUrl=[hotPointNewVO.detailUrl retain];
        CATransition *animation = [CATransition animation];
        animation.duration = 0.3f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        [animation setType:kCATransitionPush];
        [animation setSubtype: kCATransitionFromRight];
        [self.view.superview.layer addAnimation:animation forKey:@"Reveal"];
        [self initCelebrateView];
    } else if (2==[[hotPointNewVO type] intValue]){//市场活动规则
        
        if (celebrateTitleStr!=nil) {
            [celebrateTitleStr release];
        }
        celebrateTitleStr=[hotPointNewVO.title retain];
        if (celebrateWebUrl!=nil) {
            [celebrateWebUrl release];
        }
        celebrateWebUrl=[hotPointNewVO.detailUrl retain];
        CATransition *animation = [CATransition animation];
        animation.duration = 0.3f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        [animation setType:kCATransitionPush];
        [animation setSubtype: kCATransitionFromRight];
        [self.view.superview.layer addAnimation:animation forKey:@"Reveal"];
        [self initCelebrateView];
        //[DoTracking doTrackingSecond:[NSString stringWithFormat:@"homeHotActivityRule_%@",[GlobalValue getGlobalValueInstance].provinceId]];//进入市场活动规则数据统计
    } else if (3==[[hotPointNewVO type] intValue]) {//绑定团购
        [self removeSubControllerClass:[GroupBuyHomePage class]];
        GroupBuyHomePage *groupBuyHomePage=[[[GroupBuyHomePage alloc] initWithNibName:@"GroupBuyHomePage" bundle:nil] autorelease];
        [self.view.layer addAnimation:[OTSNaviAnimation animationPushFromRight] forKey:@"Reveal"];
        [self.view addSubview:[groupBuyHomePage view]];
        
        //[DoTracking doTrackingSecond:[NSString stringWithFormat:@"homeHotBindingGroupon_%@",[GlobalValue getGlobalValueInstance].provinceId]];//进入团购数据统计
    } else if (4==[[hotPointNewVO type] intValue]) {//新热销活动
        if (celebrateTitleStr!=nil) {
            [celebrateTitleStr release];
        }
        celebrateTitleStr=[hotPointNewVO.title retain];
        if (celebrateWebUrl!=nil) {
            [celebrateWebUrl release];
        }
        celebrateWebUrl=[[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/30/%@",hotPointNewVO.detailUrl,[GlobalValue getGlobalValueInstance].provinceId]];
        CATransition *animation = [CATransition animation];
        animation.duration = 0.3f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        [animation setType:kCATransitionPush];
        [animation setSubtype: kCATransitionFromRight];
        [self.view.superview.layer addAnimation:animation forKey:@"Reveal"];
        [self initCelebrateView];
        //[DoTracking doTrackingSecond:[NSString stringWithFormat:@"homeHotActivityNew_%@_%@",[GlobalValue getGlobalValueInstance].provinceId,hotPointNewVO.topicId]];//进入新热销活动数据统计
    }
}
//初始化周年庆界面
-(void)initCelebrateView {
    if (m_CelebrateView!=nil) {
        [m_CelebrateView removeFromSuperview];
        [m_CelebrateView release];
    }
    if (m_CelebrateWebView!=nil) {
        [m_CelebrateWebView removeFromSuperview];
        [m_CelebrateWebView release];
    }
    m_CelebrateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ApplicationWidth, ApplicationHeight)];
    [m_CelebrateView setBackgroundColor:[UIColor grayColor]];
    m_CelebrateWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, ApplicationWidth, ApplicationHeight-TABBAR_HEIGHT-NAVIGATION_BAR_HEIGHT)];
	//标题图片
	UIImageView * titleBGImg = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,ApplicationWidth,NAVIGATION_BAR_HEIGHT)];
	titleBGImg.image = [UIImage imageNamed:@"title_bg.png"];
	//标题栏
	celebrateTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, 190, NAVIGATION_BAR_HEIGHT)];
	[celebrateTitleLabel setText:celebrateTitleStr];
	[celebrateTitleLabel setBackgroundColor:[UIColor clearColor]];
	celebrateTitleLabel.textColor = [UIColor whiteColor];
	[celebrateTitleLabel setTextAlignment:NSTextAlignmentCenter];
	[celebrateTitleLabel setNumberOfLines:2];
	celebrateTitleLabel.font = [UIFont boldSystemFontOfSize:18.0];
	celebrateTitleLabel.shadowColor = [UIColor darkGrayColor];
	celebrateTitleLabel.shadowOffset = CGSizeMake(1.0, -1.0);
	[titleBGImg addSubview:celebrateTitleLabel];
	[celebrateTitleLabel release];
	//返回按钮
	UIButton * backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,61,NAVIGATION_BAR_HEIGHT)];
	[backBtn setTitleColor:[UIColor whiteColor] forState:0];
	backBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
	backBtn.titleLabel.shadowColor = [UIColor darkGrayColor];
	backBtn.titleLabel.shadowOffset = CGSizeMake(1.0, -1.0);
	[backBtn setBackgroundImage:[UIImage imageNamed:@"title_left_btn.png"] forState:0];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"title_left_btn_sel.png"] forState:UIControlStateHighlighted];
	[backBtn addTarget:self action:@selector(backHomepage) forControlEvents:UIControlEventTouchUpInside];
	titleBGImg.userInteractionEnabled = YES;
	[titleBGImg addSubview:backBtn];
	[backBtn release];
	[m_CelebrateView addSubview:titleBGImg];
	[titleBGImg release];
	//周年浏览器
	[m_CelebrateWebView setDelegate:self];
	//[m_CelebrateWebView setOpaque:NO];
	//m_CelebrateWebView.backgroundColor=[UIColor whiteColor];
	[m_CelebrateView addSubview:m_CelebrateWebView];
	[self.view addSubview:m_CelebrateView];
    [self performSelectorOnMainThread:@selector(loadWeb) withObject:self waitUntilDone:YES];
}

-(void)backHomepage{
	CATransition *animation = [CATransition animation];
    animation.duration = 0.3f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
	[animation setType:kCATransitionPush];
	[animation setSubtype: kCATransitionFromLeft];
	[self.view.superview.layer addAnimation:animation forKey:@"Reveal"];
    if (m_CelebrateView!=nil) {
        [m_CelebrateView removeFromSuperview];
    }
	if (m_CelebrateWebView!=nil) {
        [m_CelebrateWebView setDelegate:nil];
        [m_CelebrateWebView removeFromSuperview];
    }
    [self hideLoading];
}
-(void)loadWeb {
	[m_CelebrateWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:celebrateWebUrl]]];
}
-(void)enterNNPieces:(HotPointNewVO *)hotPointNewVO
{
    [self removeSubControllerClass:[OTSNNPiecesVC class]];
    OTSNNPiecesVC* vc = [[[OTSNNPiecesVC alloc] init] autorelease];
    [vc setPromotionId:hotPointNewVO.promotionId];
    [vc setPromotionLevelId:hotPointNewVO.promotionLevelId];
    [vc setNnpiecesTitle:hotPointNewVO.title];
    [self.view.layer addAnimation:[OTSNaviAnimation animationPushFromRight] forKey:@"Reveal"];
    [self pushVC:vc animated:YES];
}
//website页面进入商品详情
-(void)enterProductDetail:(NSArray *)array {
    if ([array count]<2) {
        return;
    }
    int productId=[[array objectAtIndex:0] intValue];
    NSString *promotionId=[array objectAtIndex:1];
    if ([promotionId isEqualToString:@"0"]) {
        promotionId=@"";
    }
    
    OTSProductDetail *productDetail=[[[OTSProductDetail alloc] initWithProductId:productId promotionId:promotionId fromTag:PD_FROM_OTHER] autorelease];
    [self.view.layer addAnimation:[OTSNaviAnimation animationPushFromRight] forKey:@"Reveal"];
    [self pushVC:productDetail animated:YES];
}

#pragma mark webviewdelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestString=[[request URL] absoluteString];
    //    requestString = @"http://m.1mall.com/mw/groupdetail/124764/1";
	NSArray *components=[requestString componentsSeparatedByString:@"/"];
    
    //查看商品详情
    if ([components count]>=2 && [(NSString *)[components objectAtIndex:[components count]-2] isEqualToString:@"product"]) {
        NSString *tailStr=[components objectAtIndex:[components count]-1];
        NSArray *subComponents=[tailStr componentsSeparatedByString:@"_"];
        NSMutableArray *mArray=[[[NSMutableArray alloc] init] autorelease];
        int i;
        NSString *promotionId=@"";
        for (i=0; i<[subComponents count]; i++) {
            if (i==0) {
                NSString *string=[subComponents objectAtIndex:i];
                [mArray addObject:string];
            } else {
                NSString *string=[subComponents objectAtIndex:i];
                if (i==[subComponents count]-1) {
                    promotionId=[promotionId stringByAppendingString:string];
                } else {
                    promotionId=[promotionId stringByAppendingString:[NSString stringWithFormat:@"%@_",string]];
                }
                if (i==[subComponents count]-1) {
                    [mArray addObject:promotionId];
                }
            }
        }
        [self  performSelectorOnMainThread:@selector(enterProductDetail:) withObject:mArray waitUntilDone:NO];
        return NO;
    }
    
    //加入购物车
    if ([components count]>=2 && [(NSString *)[components objectAtIndex:[components count]-2] isEqualToString:@"buypro"]) {
        if ([GlobalValue getGlobalValueInstance].token==nil&&[requestString rangeOfString:@"landingpage"].location!=NSNotFound) {
            [SharedDelegate enterUserManageWithTag:0];
            return NO;
        }

        NSString *tailStr=[components objectAtIndex:[components count]-1];
        NSArray *subComponents=[tailStr componentsSeparatedByString:@"_"];
        NSMutableArray *mArray=[[[NSMutableArray alloc] init] autorelease];
        
        int i;
        NSString *promotionId=@"";
        for (i=0; i<[subComponents count]; i++) {// productid, merchantId, quantilty
            if (i==0 || i==1 || i==2) {
                NSString *string=[subComponents objectAtIndex:i];
                [mArray addObject:string];
            } else {
                NSString *string=[subComponents objectAtIndex:i];
                if (i==[subComponents count]-1) {
                    promotionId=[promotionId stringByAppendingString:string];
                } else {
                    promotionId=[promotionId stringByAppendingString:[NSString stringWithFormat:@"%@_",string]];
                }
                if (i==[subComponents count]-1) {
                    [mArray addObject:promotionId];
                }
            }
        }
        NSNumberFormatter * formatter = [[[NSNumberFormatter alloc] init]autorelease];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * productIdNub = [formatter numberFromString:[mArray objectAtIndex:0]];
        
        JSTrackingPrama* prama = [[[JSTrackingPrama alloc]initWithJSType:EJStracking_AddCart extraPramaDic:nil]autorelease];
        [prama setProductId:productIdNub];
        [prama setMerchant_id:[mArray objectAtIndex:1]];
        [DoTracking doJsTrackingWithParma:prama];
        [NSThread detachNewThreadSelector:@selector(newThreadAddCart:) toTarget:self withObject:mArray];
        return NO;
    }
    
    //1号店团购
    if ([components count]>=3 && [(NSString *)[components objectAtIndex:[components count]-3] isEqualToString:@"cmsgroupon"]) {
        
        NSMutableArray *mArray=[[[NSMutableArray alloc] init] autorelease];
        NSString *groupId=[components objectAtIndex:[components count]-2];
        [mArray addObject:groupId];
        NSString *areaId = [components objectAtIndex:[components count]-1];
        [mArray addObject:areaId];
        
        [self  performSelectorOnMainThread:@selector(enterGroupDetail:) withObject:mArray waitUntilDone:NO];
        return NO;
    }
    
    //商城团购
    NSRange grouponRange = [requestString rangeOfString:@"http://m.1mall.com/mw/groupdetail/"];
    if (grouponRange.location != NSNotFound) {
        if ([components count]>=3 && [(NSString *)[components objectAtIndex:[components count]-3] isEqualToString:@"groupdetail"]) {
            
            NSString *urlStr = @"http://m.1mall.com/mw/groupdetail/";
            NSString *grouponId = [components objectAtIndex:[components count]-2];
            NSString *tailString = [components objectAtIndex:[components count]-1];
            NSArray *subComponent = [tailString componentsSeparatedByString:@"_"];
            NSString *areaId = @"1";
            if ([subComponent count] > 0) {
                areaId = [OTSUtility safeObjectAtIndex:0 inArray:subComponent];
            }
            if ([GlobalValue getGlobalValueInstance].token == nil) {
                urlStr = [urlStr stringByAppendingFormat:@"%@/%@_%d",grouponId,areaId,30];
            } else {
                // 对 token 进行base64加密
                NSData *b64Data = [GTMBase64 encodeData:[[GlobalValue getGlobalValueInstance].token dataUsingEncoding:NSUTF8StringEncoding]];
                NSString *b64Str = [[[NSString alloc] initWithData:b64Data encoding:NSUTF8StringEncoding] autorelease];
                
                urlStr = [urlStr stringByAppendingFormat:@"%@/%@_%@_%d",grouponId,areaId,b64Str,30];
                
            }
            DebugLog(@"enterWap -- url is:\n%@",urlStr);
            [SharedDelegate enterWap:1 invokeUrl:urlStr isClearCookie:NO];
            
            return NO;
        }
    }
    //商城普通
    NSRange mallProductRange=[requestString rangeOfString:@"http://m.1mall.com/mw/product/"];
    if (mallProductRange.location!=NSNotFound) {
        if ([components count]>=3 && [(NSString *)[components objectAtIndex:[components count]-4] isEqualToString:@"product"]) {
            
            NSString *urlStr = @"http://m.1mall.com/mw/product/";
            NSString *grouponId = [components objectAtIndex:[components count]-3];
            NSString *areaId = [components objectAtIndex:[components count]-2];
            if ([GlobalValue getGlobalValueInstance].token == nil) {
                urlStr = [urlStr stringByAppendingFormat:@"%@/%@/?osType=%d",grouponId,areaId,30];
            } else {
                // 对 token 进行base64加密
                NSData *b64Data = [GTMBase64 encodeData:[[GlobalValue getGlobalValueInstance].token dataUsingEncoding:NSUTF8StringEncoding]];
                NSString *b64Str = [[[NSString alloc] initWithData:b64Data encoding:NSUTF8StringEncoding] autorelease];
                urlStr = [urlStr stringByAppendingFormat:@"%@/%@/?osType=%d&token=%@",grouponId,areaId,30,b64Str];
            }
            DebugLog(@"enterWap -- url is:\n%@",urlStr);
            [SharedDelegate enterWap:1 invokeUrl:urlStr isClearCookie:NO];
        }
        return NO;
    }
    if (firstInWeb) {
        firstInWeb=NO;
    }else{
        celebrateTitleLabel.text=@"促销活动";
    }
	return YES;
}
#pragma mark    新线程加入购物车
//website页面进入团购商品详情

-(void)enterGroupDetail:(NSArray*)array{
    if ([array count]<2) {
        return;
    }
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];                       // string转换为 nsnumber
    [f setNumberStyle:kCFNumberFormatterNoStyle];
    NSNumber * groupId = [f numberFromString:[array objectAtIndex:0]];              // 团购ID
    NSNumber * areaId = [f numberFromString:[array objectAtIndex:1]];               // 地区ID
    [f release];
    
    GrouponVO * grouponVO = [[GrouponVO alloc] init];
    [grouponVO setNid:groupId];
    [grouponVO setAreaId:areaId];
    
    NSMutableArray *products=[[NSMutableArray alloc] init];
    [products addObject:grouponVO];
    [grouponVO release];
    
    [self enterGrouponDetailWithProducts:products currentIndex:0 areaId:areaId fromTag:FROM_CMS_TO_DETAIL];
    
    [products release];
}

-(void)newThreadAddCart:(NSArray *)array
{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    if ([array count]<4) {
        [pool release];
        return;
    }
    int productId=[[array objectAtIndex:0] intValue];
    int merchantId=[[array objectAtIndex:1] intValue];
    int buyQuantity=[[array objectAtIndex:2] intValue];
    NSString *promotionId=[array objectAtIndex:3];
    if ([promotionId isEqualToString:@"0"]) {
        promotionId=@"";
    }
    //获取商品详情后加入购物车
    ProductService *pSer=[[[ProductService alloc] init] autorelease];
    ProductVO *tempProductVO=[pSer getProductDetail:[GlobalValue getGlobalValueInstance].trader productId:[NSNumber numberWithInt:productId] provinceId:[GlobalValue getGlobalValueInstance].provinceId promotionid:promotionId];
    if (tempProductVO!=nil && ![tempProductVO isKindOfClass:[NSNull class]] && tempProductVO.cnName!=nil && ![tempProductVO.cnName isEqualToString:@""]) {
        //图片
        NSString *fileName=[NSString stringWithFormat:@"middle_%@",[NSNumber numberWithInt:productId]];
        NSData *data=[DataController applicationDataFromFile:fileName];
        if (data==nil) {
            NSData *netData=[NSData dataWithContentsOfURL:[NSURL URLWithString:[tempProductVO midleDefaultProductUrl]]];
            [DataController writeApplicationData:netData name:fileName];
        }
        
        if ([GlobalValue getGlobalValueInstance].token!=nil)
        {
            CartService *cSer=[[[CartService alloc] init] autorelease];
            
            AddProductResult *result=[cSer addSingleProduct:[GlobalValue getGlobalValueInstance].token productId:[NSNumber numberWithInt:productId] merchantId:[NSNumber numberWithInt:merchantId] quantity:[NSNumber numberWithInt:buyQuantity] promotionid:promotionId];
            if (result!=nil && ![result isKindOfClass:[NSNull class]]) {
                if ([[result resultCode] intValue]==1) {//成功
                    HomePage* homep=(HomePage*)[SharedDelegate.tabBarController.viewControllers objectAtIndex:0];
                    [homep performSelectorOnMainThread:@selector(showBuyProductAnimation:) withObject:array waitUntilDone:NO];
                } else {
                    [self performSelectorOnMainThread:@selector(showError:) withObject:[result errorInfo] waitUntilDone:NO];
                }
            } else {
                [self performSelectorOnMainThread:@selector(showError:) withObject:@"网络异常，请检查网络配置..." waitUntilDone:NO];
            }
        } else {
            LocalCartItemVO *localProductVO=[[LocalCartItemVO alloc] initWithProductVO:tempProductVO quantity:[NSString stringWithFormat:@"%d",buyQuantity]];
            [SharedDelegate addProductToLocal:localProductVO];
            HomePage* homep=(HomePage*)[SharedDelegate.tabBarController.viewControllers objectAtIndex:0];
            [homep performSelectorOnMainThread:@selector(showBuyProductAnimation:) withObject:array waitUntilDone:YES];
            [localProductVO release];
        }
        // 加入购物车统计
        JSTrackingPrama* prama = [[[JSTrackingPrama alloc]initWithJSType:EJStracking_AddCart extraPramaDic:nil]autorelease];
        [prama setProductId:[NSNumber numberWithInt:productId]];
        [prama setMerchant_id:[NSString stringWithFormat:@"%d",merchantId]];
        [DoTracking doJsTrackingWithParma:prama];
    } else {
        [self performSelectorOnMainThread:@selector(showError:) withObject:@"网络异常，请检查网路配置..." waitUntilDone:NO];
    }
    [pool drain];
}
-(void)showError:(NSString *)errorInfo
{
    [AlertView showAlertView:nil alertMsg:errorInfo buttonTitles:nil alertTag:ALERTVIEW_TAG_COMMON];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showLoading:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideLoading];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideLoading];
}


#pragma mark tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (totalPage>adArray.count) {
        return adArray.count+1;
    }else{
        return adArray.count;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (adArray.count>0&&indexPath.row==adArray.count) {
        return 44;
    }
    return cellHeight;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* more=@"more";
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:more];
    if (cell==nil) {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:more] autorelease];
    }
    if (adArray.count) {
        if (adArray.count==indexPath.row) {
            cell.textLabel.text=@"正在加载";
            cell.textLabel.font=[UIFont systemFontOfSize:16];
            cell.textLabel.textAlignment=NSTextAlignmentCenter;
            UIView*act=[cell.contentView viewWithTag:119];
            [act removeFromSuperview];
            return cell;
        }else{
            static NSString* identy=@"cell";
            HomePageModelBCell* cell=[tableView dequeueReusableCellWithIdentifier:identy];
            if (cell==nil) {
                cell=[[[HomePageModelBCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy] autorelease];
            }
            HotPointNewVO*vo= [adArray objectAtIndex:indexPath.row];
            cell.adText=vo.title;
            cell.advPicUrl=vo.picUrl;
            [cell reloadCell];
            return cell;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row<adArray.count) {
        HotPointNewVO* newVO=[adArray objectAtIndex:indexPath.row];
        int ty=[newVO.type intValue];
        if (ty==5) {
            [self enterNNPieces:newVO];//n n
        }else if (ty==6){
            [self enterRePromotion:newVO];
        }else{
            [self enterCMSPage:newVO];
            JSTrackingPrama* prama = [[[JSTrackingPrama alloc]initWithJSType:EJStracking_AD_HotPage extraPrama:[NSString stringWithFormat:@"%@",newVO.promotionId],nil]autorelease];
            [DoTracking doJsTrackingWithParma:prama];
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (totalPage>adArray.count) {
        if (indexPath.row==adArray.count) {
            UIActivityIndicatorView* act=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [act startAnimating];
            act.tag=119;
            act.frame=CGRectMake(100, 10, 22, 22);
            [cell.contentView addSubview:act];
            [act release];
            currentPage++;
            [self otsDetatchMemorySafeNewThreadSelector:@selector(getBrandData) toTarget:self withObject:nil];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
