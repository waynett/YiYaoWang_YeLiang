//
//  OTSOrderSubmitOKVC.m
//  TheStoreApp
//
//  Created by yiming dong on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "OTSOrderSubmitOKVC.h"
#import "OrderV2.h"
#import "OrderService.h"
#import "OTSUtility.h"
#import "OTSNavigationBar.h"
#import "GlobalValue.h"
#import "OTSLoadingView.h"
#import "PaymentMethodVO.h"
#import "GroupBuyOrderDetail.h"
#import "GroupBuyService.h"
#import "TheStoreAppAppDelegate.h"
#import "OTSOperationEngine.h"
#import "OTSOnlinePayNotifier.h"
#import "GroupBuyOrderDetail.h"
#import "DoTracking.h"
#import "OrderInfo.h"
#import "AlixPay.h"

#import <AlipaySDK/Alipay.h>
#import "JSONKit.h"

// literals
#define STR_TOP_TIP_1                       @"我们将保留订单%d小时，请在                              ,\n祝您购物愉快！"
#define STR_TOP_TIP_2                       @"%d小时内完成付款"

#define STR_NEED_PAY                        @"订单已提交，还需支付"
#define STR_NEED_PAY_WHEN_ARRIVE_1            @"订单已生成，会尽快为您发货"
#define STR_NEED_PAY_WHEN_ARRIVE_2            @"还需支付"

#define STR_PAYMENT_FULL                    @"账户支付"

#define STR_TITLE_ONLINE_PAY                @"提交成功"
#define STR_TITLE_PAY_OFFLINE               @"订单生成"

#define STR_BOTTOM_TIP_PAY_ONLINE           @"若稍后支付，您可以在【我的1号药店】的【我的订单】中，继续支付订单。"
#define STR_BOTTOM_TIP_PAY_OFFLINE          @"请在收货时向送货员支付您的款项，祝购物愉快，谢谢。"
#define STR_BOTTOM_TIP_PAY_FULL             @"请在收货时确认商品后再签收，祝购物愉快，谢谢。"

// layout
#define GAP_H   10
#define GAP_V   10
#define FONT_SIZE   13.3f
#define BG_COLOR_VALUE  0xf0f0f0
#define DRAK_RED_VALUE  0xcc0000



#define KEY_REQ_ID_ORDER_DETAIL     @"KEY_REQ_ID_ORDER_DETAIL"
#define KEY_REQ_ID_BANK_LIST        @"KEY_REQ_ID_BANK_LIST"

#define ALIXPAY_CONFIRM             101
#define ALIXPAYGATE                     421

// class extension
@interface OTSOrderSubmitOKVC ()

//@property(retain)OrderV2                    *order;
@property(nonatomic, retain)UIScrollView    *scrollView;
@property(nonatomic, retain)UIView          *topTipView;
@property(nonatomic, retain)UIView          *bottomTipView;
@property(nonatomic, retain)UIView          *bottomButtonView;
@property(nonatomic, retain)UITableView     *infoTV;
@property(nonatomic, retain)UIFont          *normalFont;
@property(nonatomic, retain)UIFont          *largeFont;
@property(nonatomic, retain)UIFont          *boldFont;
@property(nonatomic, retain)UIFont          *largeBoldFont;
@property(nonatomic, retain)OTSNavigationBar    *naviBar;
@property(nonatomic, assign)UILabel             *paymentLabel;
@property(retain)NSArray                        *bankList;
@property(nonatomic, retain)    NSMutableDictionary     *requestIDs;
@property(retain)   OTSLoadingView              *loadingView;

-(CGFloat)totalHeightForTV;
-(void)initUIElements;
-(void)changePaymentAction;
-(void)toOrderDetailAction;
-(void)retrieveBankList;
@end


// implementation
@implementation OTSOrderSubmitOKVC


@synthesize topTipView, bottomTipView, bottomButtonView,infoTV, scrollView, naviBar, paymentLabel;
@synthesize normalFont, boldFont, largeFont, largeBoldFont;
@synthesize bankList, requestIDs = _requestIDs, loadingView = _loadingView;

#pragma mark -
-(UILabel*)labelWithFrame:(CGRect)aFrame text:(NSString*)aText
{
    UILabel* tipLbl = [[[UILabel alloc] initWithFrame:aFrame] autorelease];
    tipLbl.textColor = [UIColor blackColor];
    tipLbl.backgroundColor = [UIColor clearColor];
    tipLbl.font = largeFont;
    tipLbl.text = aText;
    tipLbl.numberOfLines = 0;
    [tipLbl sizeToFit];
    
    return tipLbl;
}

#pragma mark -

- (NSString *)paymentStr
{
    NSString *nameStr = @"";
    switch (_paymentType) {
        case kYaoPaymentAlipay:
            nameStr = @"支付宝客户端支付";
            break;
        case kYaoPaymentPosPay:
            nameStr = @"货到刷卡";
            break;
        case kYaoPaymentReachPay:
            nameStr = @"货到付款";
            break;
        default:
            break;
    }
    return nameStr;
}
/*
-(BOOL)isOrderPayedOK
{
    return [order.paymentAccount floatValue] <= 0;
}
*/
-(BOOL)isOrderDontNeedPay
{
    return _paymentType != kYaoPaymentAlipay;
}



-(NSString*)naviTitle
{
    return /* ? @"订单生成" :*/ @"提交成功";
}

-(void)updateUIElement
{
    if (!isBankListOK || !isOrderDetailOK)
    {
        return;
    }
    
    // 如果没有数据，返回首页
    if (self.order == nil || self.bankList == nil || self.bankList.count <= 0)
    {
        [self toHomePageAction];
    }
    
    [self.loadingView hide];
    
    naviBar.titleLabel.text = [self naviTitle];
    
    [self initUIElements];
    
    [infoTV reloadData];
    scrollView.hidden = NO;
}

-(void)initUIElements
{
    [scrollView removeFromSuperview];
    
    BOOL isOrderDontNeedPay = _paymentType != kYaoPaymentAlipay? YES : NO;
    
    // 导航条
    if (naviBar == nil)
    {
        self.naviBar = [[[OTSNavigationBar alloc] initWithTitle:[self naviTitle]] autorelease];
        [self.view addSubview:naviBar];
    }
    
    if (_order == nil)
    {
        return;
    }
    
    // SCROLL VIEW
    CGRect scrollRc = CGRectMake(0
                                 , naviBar.frame.size.height
                                 , self.view.frame.size.width
                                 , self.view.frame.size.height - naviBar.frame.size.height);
    self.scrollView = [[[UIScrollView alloc] initWithFrame:scrollRc] autorelease];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = OTS_COLOR_FROM_RGB(BG_COLOR_VALUE);
    [self.view addSubview:scrollView];
    
    CGRect theRc = self.view.frame;
    theRc.origin.y = OTS_IPHONE_NAVI_BAR_HEIGHT;
    scrollView.frame = theRc;
    
    scrollView.hidden = YES;
    scrollView.alwaysBounceVertical = YES;
    
    float viewOffsetY = GAP_V;
    
    if (!isOrderDontNeedPay)
    {
        // 顶部提示
        CGRect topTipRc = CGRectMake(GAP_H
                                     , viewOffsetY
                                     , self.view.frame.size.width - 2 * GAP_H
                                     , 38);
        self.topTipView = [[[UIView alloc] initWithFrame:topTipRc] autorelease];
        topTipView.backgroundColor = OTS_COLOR_FROM_RGB(0xfffeee);
        [OTSUtility setCornerRadius:5 borderColor:OTS_COLOR_FROM_RGB(0xffdba7) forView:topTipView];
        
        int leftHours = 24;//order.calculatedHours;
//        leftHours = leftHours > 0 ? leftHours : 24;
        
        CGRect tipRc = topTipView.bounds;
        tipRc.origin.x += 4;
        tipRc.origin.y += 2;
        
        NSString *topTipStr1 = [NSString stringWithFormat:STR_TOP_TIP_1, leftHours];
        UILabel* tipLbl = [self labelWithFrame:tipRc text:topTipStr1];
        tipLbl.font = normalFont;
        [tipLbl sizeToFit];
        [topTipView addSubview:tipLbl];
        
        tipRc.origin.x += 172;
        NSString *topTipStr2 = [NSString stringWithFormat:STR_TOP_TIP_2, leftHours];
        UILabel* tipLbl2 = [self labelWithFrame:tipRc text:topTipStr2];
        tipLbl2.font = normalFont;
        [tipLbl2 sizeToFit];
        tipLbl2.textColor = OTS_COLOR_FROM_RGB(DRAK_RED_VALUE);
        [topTipView addSubview:tipLbl2];
        
        [topTipView layoutSubviews];
        
        [scrollView addSubview:topTipView];
        viewOffsetY = CGRectGetMaxY(topTipView.frame);
    }
    
    // 中部table view
    CGRect infoTvRc = CGRectMake(0
                                 , viewOffsetY
                                 , self.view.frame.size.width
                                 , [self totalHeightForTV]);
    
    self.infoTV = [[[UITableView alloc] initWithFrame:infoTvRc style:UITableViewStyleGrouped] autorelease];
    infoTV.backgroundColor = OTS_COLOR_FROM_RGB(BG_COLOR_VALUE);
    infoTV.scrollEnabled = NO;
    infoTV.delegate = self;
    infoTV.dataSource = self;
    infoTV.backgroundView=nil;
    [scrollView addSubview:infoTV];
    viewOffsetY = CGRectGetMaxY(infoTV.frame);
    
    // 底部提示
    if (isOrderDontNeedPay)
    {
        NSString* bottomTipText = /*[self isOrderPayedOK] */ _paymentType==kYaoPaymentAlipay ? STR_BOTTOM_TIP_PAY_FULL : STR_BOTTOM_TIP_PAY_OFFLINE;
        CGRect bottomTipHeaderRc = CGRectMake(20
                                              , viewOffsetY
                                              , self.view.frame.size.width - 40
                                              , 20);
        UILabel* bottomTipHeaderLbl = [self labelWithFrame:bottomTipHeaderRc text:bottomTipText];
        bottomTipHeaderLbl.textColor = [UIColor grayColor];
        [bottomTipHeaderLbl sizeToFit];
        [scrollView addSubview:bottomTipHeaderLbl];
        
        viewOffsetY = CGRectGetMaxY(bottomTipHeaderLbl.frame);
    }
    else
    {
        CGRect bottomTipHeaderRc = CGRectMake(20
                                              , viewOffsetY
                                              , self.view.frame.size.width - 2 * GAP_H
                                              , 20);
        UILabel* bottomTipHeaderLbl = [self labelWithFrame:bottomTipHeaderRc text:@"提示"];
        [bottomTipHeaderLbl sizeToFit];
        [scrollView addSubview:bottomTipHeaderLbl];
        
        //
        CGRect bottomTipRc = CGRectMake(GAP_H
                                        , CGRectGetMaxY(bottomTipHeaderLbl.frame) + 5
                                        , self.view.frame.size.width - 2 * GAP_H
                                        , 52);
        self.bottomTipView = [[[UIView alloc] initWithFrame:bottomTipRc] autorelease];
        bottomTipView.backgroundColor = [UIColor whiteColor];
        [OTSUtility setCornerRadius:5 borderColor:[UIColor lightGrayColor] forView:bottomTipView];
        
        CGRect bottomLblTipRc = bottomTipView.bounds;
        bottomLblTipRc.origin.x += 10;
        bottomLblTipRc.size.width -= 20;
        bottomLblTipRc.origin.y += 7;
        
        UILabel* bottomTipLbl = [self labelWithFrame:bottomLblTipRc text:STR_BOTTOM_TIP_PAY_ONLINE];
        [bottomTipView addSubview:bottomTipLbl];
        
        [bottomTipView layoutSubviews];
        
        [scrollView addSubview:bottomTipView];
        
        viewOffsetY = CGRectGetMaxY(bottomTipView.frame);
    }
    
    // 底部按钮view
    CGRect bottomButtonViewRc = CGRectMake(0
                                           , viewOffsetY + 10
                                           , self.view.frame.size.width
                                           , 30);
    self.bottomButtonView = [[[UIView alloc] initWithFrame:bottomButtonViewRc] autorelease];
    [scrollView addSubview:bottomButtonView];
    
    if (isOrderDontNeedPay)
    {
        UIButton* toMyHomeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* btnImg = [UIImage imageNamed:@"returnToHomeBtn"];
        toMyHomeBtn.frame = CGRectMake(58
                                       , 0
                                       , btnImg.size.width
                                       , btnImg.size.height);
        [toMyHomeBtn setImage:btnImg forState:UIControlStateNormal];
        [bottomButtonView addSubview:toMyHomeBtn];
        
        [toMyHomeBtn addTarget:self action:@selector(toHomePageAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* toMyStoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        btnImg = [UIImage imageNamed:@"toMyStoreBtn"];
        toMyStoreBtn.frame = CGRectMake(CGRectGetMaxX(toMyHomeBtn.frame) + 20
                                        , 0
                                        , btnImg.size.width
                                        , btnImg.size.height);
        [toMyStoreBtn setImage:btnImg forState:UIControlStateNormal];
        [bottomButtonView addSubview:toMyStoreBtn];
        
        [toMyStoreBtn addTarget:self action:@selector(toMyStoreAction) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        UIButton* payLaterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* btnImg = [UIImage imageNamed:@"payLaterBtn"];
        payLaterBtn.frame = CGRectMake((self.view.frame.size.width - btnImg.size.width) / 2
                                       , 0
                                       , btnImg.size.width
                                       , btnImg.size.height);
        [payLaterBtn setImage:btnImg forState:UIControlStateNormal];
        [bottomButtonView addSubview:payLaterBtn];
        
        [payLaterBtn addTarget:self action:@selector(payLaterAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // 调整scroll View content size
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width
                                          , CGRectGetMaxY(bottomButtonView.frame) + 65)];
}
/*
#pragma mark -
-(void)retrieveOrderDetail
{
    // thread get order detail, invoke order service method
    OrderService* service = [[[OrderService alloc] init] autorelease];
    self.order = [service getOrderDetailByOrderIdEx:[GlobalValue getGlobalValueInstance].token orderId:[NSNumber numberWithLongLong:orderId]];
    
    // 需设置orderCode
    JSTrackingPrama* prama = [[[JSTrackingPrama alloc]initWithJSType:EJStracking_SubmitOrder extraPramaDic:nil] autorelease];
    [prama setOrderCode:order.orderCode];
    [DoTracking doJsTrackingWithParma:prama];
    
    // add local notification
    self.order.siteType = [NSNumber numberWithInt:kSiteTypeStore];
    //[[OTSOnlinePayNotifier sharedInstance] addNotificationForOrder:self.order];
    [[OTSOnlinePayNotifier sharedInstance] retrieveOrders];
}*/

-(int)idForKey:(NSString*)aIdKey
{
    id value = [_requestIDs objectForKey:aIdKey];
    return [value intValue];
}

-(void)retrieveOrderDetailOK
{
    // when finished, init ui elements
    isOrderDetailOK = YES;
    [self performSelectorOnMainThread:@selector(updateUIElement) withObject:nil waitUntilDone:NO];
}

-(void)retrieveBankListOK
{
    // when finished, init ui elements
    isBankListOK = YES;
    [self performSelectorOnMainThread:@selector(updateUIElement) withObject:nil waitUntilDone:NO];
}

-(void)handleOperationFinished:(NSNotification*)aNotification
{
    OTSInvocationOperation* operation = aNotification.object;
    if (operation.caller == self)
    {
        if (operation.operationID == [self idForKey:KEY_REQ_ID_ORDER_DETAIL])
        {
            [self retrieveOrderDetailOK];
        }
        else if (operation.operationID == [self idForKey:KEY_REQ_ID_BANK_LIST])
        {
            [self retrieveBankListOK];
        }
    }
}

-(void)retrieveBankList
{
    self.bankList = [OTSUtility requestBanks];
}

#pragma mark - memory
-(id)initWithOrderId:(long long int)aOrderId
{
    self = [super init];
    if (self)
    {
        orderId = aOrderId;
        _requestIDs = [[NSMutableDictionary alloc] initWithCapacity:2];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifyPaymentChanged:) name:OTS_ONLINEPAY_BANK_CHANGED object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleOperationFinished:)
                                                     name:OTS_NOTIFY_OPERATION_FINISHED
                                                   object:nil];
        
        self.loadingView = [[[OTSLoadingView alloc] init] autorelease];
    }
    return self;
}

//-(id)initWithOrder:(OrderV2*)anOrder
//{
//    self = [super init];
//    if (self)
//    {
//        order = [anOrder retain];
//    }
//    return self;
//}

-(void)dealloc
{
    OTS_SAFE_RELEASE(_order);
    OTS_SAFE_RELEASE(scrollView);
    OTS_SAFE_RELEASE(topTipView);
    OTS_SAFE_RELEASE(bottomTipView);
    OTS_SAFE_RELEASE(bottomButtonView);
    OTS_SAFE_RELEASE(infoTV);
    OTS_SAFE_RELEASE(normalFont);
    OTS_SAFE_RELEASE(boldFont);
    OTS_SAFE_RELEASE(largeFont);
    OTS_SAFE_RELEASE(largeBoldFont);
    //OTS_SAFE_RELEASE(paymentMethods);
    OTS_SAFE_RELEASE(naviBar);
    OTS_SAFE_RELEASE(bankList);
    OTS_SAFE_RELEASE(_requestIDs);
    [_order release];
    [_loadingView release];
    
    [super dealloc];
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view = [[[UIScrollView alloc] initWithFrame:self.view.bounds] autorelease];
    self.view.frame = self.view.bounds;
    self.view.backgroundColor = OTS_COLOR_FROM_RGB(BG_COLOR_VALUE);
    
    self.normalFont = [UIFont systemFontOfSize:FONT_SIZE];
    self.boldFont = [UIFont boldSystemFontOfSize:FONT_SIZE];
    
    self.largeFont = [UIFont systemFontOfSize:FONT_SIZE + 2.f];
    self.largeBoldFont = [UIFont boldSystemFontOfSize:FONT_SIZE + 2.f];
    
    [self initUIElements];
    
    [infoTV reloadData];
    scrollView.hidden = NO;
    
//    int requestID = [[OTSOperationEngine sharedInstance] doOperationForSelector:@selector(retrieveOrderDetail) target:self object:nil caller:self];
//    [_requestIDs setObject:[NSNumber numberWithInt:requestID] forKey:KEY_REQ_ID_ORDER_DETAIL];
    
//    requestID = [[OTSOperationEngine sharedInstance] doOperationForSelector:@selector(retrieveBankList) target:self object:nil caller:self];
//    [_requestIDs setObject:[NSNumber numberWithInt:requestID] forKey:KEY_REQ_ID_BANK_LIST];
    
//    [_loadingView showInView:self.view];
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    
    else if (section == 1)
    {
        return 1;
    }
    
    return 0;
}

-(void)decoratePaymentCell:(UITableViewCell*)aCell
{
    if (_order)
    {
        if ([self isOrderDontNeedPay])
        {// 货到付款
            
            // check mark
            UIImage* checkMarkImg = [UIImage imageNamed:@"greenCheck"];
            UIImageView* iv = [[[UIImageView alloc] initWithImage:checkMarkImg] autorelease];
            
            int offsetYForFullPay = 15;
            if ([self isOrderDontNeedPay]  /*[self isOrderPayedOK]*/)
            {
                iv.frame = CGRectMake(50, 10 + offsetYForFullPay, checkMarkImg.size.width, checkMarkImg.size.height);
            }
            else
            {
                iv.frame = CGRectMake(50, 10, checkMarkImg.size.width, checkMarkImg.size.height);
            }
            [aCell.contentView addSubview:iv];
            
            CGRect lblRc = CGRectMake(CGRectGetMaxX(iv.frame) + 2, 12, 200, 30);
            if ([self isOrderDontNeedPay] /*[self isOrderPayedOK]*/)
            {
                lblRc.origin.y += offsetYForFullPay;
            }
            
            UILabel* lbl = [self labelWithFrame:lblRc text:STR_NEED_PAY_WHEN_ARRIVE_1];
            lbl.font = largeBoldFont;
            [lbl sizeToFit];
            [aCell.contentView addSubview:lbl];
            
            [OTSUtility horizontalCenterViews:[NSArray arrayWithObjects:iv, lbl, nil] inView:aCell margin:2];
            
            if (![self isOrderDontNeedPay] /*![self isOrderPayedOK]*/)
            {
                CGRect secondRc = lblRc;
                secondRc.origin.x += 20;
                secondRc.origin.y = CGRectGetMaxY(lbl.frame) + 5;
                UILabel* secondLbl = [self labelWithFrame:secondRc text:STR_NEED_PAY_WHEN_ARRIVE_2];
                secondLbl.font = largeBoldFont;
                [secondLbl sizeToFit];
                [aCell.contentView addSubview:secondLbl];
                
                CGRect thirfRc = secondRc;
                thirfRc.origin.x = CGRectGetMaxX(secondLbl.frame);
                thirfRc.origin.y += 2;
                UILabel* thirdLbl = [self labelWithFrame:thirfRc text:[NSString stringWithFormat:@"￥%.2f", [_order orderTotalMoney] ]];
                thirdLbl.font = largeBoldFont;
                thirdLbl.textColor = OTS_COLOR_FROM_RGB(DRAK_RED_VALUE);
                [thirdLbl sizeToFit];
                [aCell.contentView addSubview:thirdLbl];
                
                [OTSUtility horizontalCenterViews:[NSArray arrayWithObjects:secondLbl, thirdLbl, nil] inView:aCell margin:2];
            }
        }
        else
        {// 网上支付
            CGRect lblRc = CGRectMake(70, 10, 200, 30);
            UILabel* lbl = [self labelWithFrame:lblRc text:STR_NEED_PAY];
            lbl.font = largeBoldFont;
            [lbl sizeToFit];
            [aCell.contentView addSubview:lbl];
            
            CGRect moneyRc = lblRc;
            moneyRc.origin.x = CGRectGetMaxX(lbl.frame);
            moneyRc.origin.y += 2;
            UILabel* moneyLbl = [self labelWithFrame:moneyRc text:[NSString stringWithFormat:@"￥%.2f", [_order orderTotalMoney]]];
            moneyLbl.textColor = OTS_COLOR_FROM_RGB(DRAK_RED_VALUE);
            moneyLbl.font = boldFont;
            [moneyLbl sizeToFit];
            [aCell.contentView addSubview:moneyLbl];
            
            [OTSUtility horizontalCenterViews:[NSArray arrayWithObjects:lbl, moneyLbl, nil] inView:aCell margin:2];
            
            UIButton* payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage* btnImg = [UIImage imageNamed:@"payNowBtn"];
            payBtn.frame = CGRectMake((300 - btnImg.size.width) / 2, 35, btnImg.size.width, btnImg.size.height);
            [payBtn setImage:btnImg forState:UIControlStateNormal];
            [aCell.contentView addSubview:payBtn];
            [payBtn addTarget:self action:@selector(payNowAction) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    int row = [indexPath row];
    
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    if (section == 0 && row == 1)
    {
        style = UITableViewCellStyleValue1;
    }
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:nil] autorelease];
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.font = largeFont;
    cell.detailTextLabel.font = largeFont;
    
    if (section == 0)
    {
        if (row == 0)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [self decoratePaymentCell:cell];
        }
        
        else if (row == 1)
        {
            if (_order)
            {
                if (_paymentType != kYaoPaymentAlipay)
                {
                    NSString* cellText = [self paymentStr];
                    cell.textLabel.text = [NSString stringWithFormat:@"付款方式：%@", cellText];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                else
                {
                    cell.textLabel.text = [self paymentStr];
                    
//                    for (BankVO* bank in bankList)
//                    {
//                        if ([bank.gateway intValue] == [order.gateway intValue])
//                        {
                            cell.detailTextLabel.text = @"支付宝客户端支付";
                            paymentLabel = cell.detailTextLabel;
//                            break;
//                        }
//                    }
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
        }
    }
    
    else if (section == 1)
    {
        CGRect defaultRc = CGRectMake(10, 10, 250, 20);
        
        UILabel* orderCodeLbl = [self labelWithFrame:defaultRc text:@"订单编号："];
        [orderCodeLbl sizeToFit];
        [cell.contentView addSubview:orderCodeLbl];
        
        int offsetX = CGRectGetMaxX(orderCodeLbl.frame);
//        if ([order isGroupBuyOrder])
//        {
//            UIImage* groupBuyLogoImg = [UIImage imageNamed:@"group_on_logo"];
//            CGRect groupBuyRc = CGRectMake(offsetX
//                                           , orderCodeLbl.frame.origin.y
//                                           , groupBuyLogoImg.size.width
//                                           , groupBuyLogoImg.size.height);
//            UIImageView *iv = [[[UIImageView alloc] initWithImage:groupBuyLogoImg] autorelease];
//            iv.frame = groupBuyRc;
//            [cell.contentView addSubview:iv];
//            
//            offsetX = CGRectGetMaxX(iv.frame) + 2;
//        }
        
        CGRect orderCodeRc = defaultRc;
        orderCodeRc.origin.x = offsetX;
        UILabel* orderCodeLbl2 = [self labelWithFrame:orderCodeRc text:_order.orderId];
        [orderCodeLbl2 sizeToFit];
        [cell.contentView addSubview:orderCodeLbl2];
        
        
        
        CGRect packCountLblRc = defaultRc;
        packCountLblRc.origin.y = CGRectGetMaxY(orderCodeLbl.frame) + 3;
        UILabel* packCountLbl = [self labelWithFrame:packCountLblRc text:[NSString stringWithFormat:@"包裹数量：%d", _packageCount]];
        [cell.contentView addSubview:packCountLbl];
        
        CGRect goodCountLblRc = defaultRc;
        goodCountLblRc.origin.y = CGRectGetMaxY(packCountLbl.frame) + 3;
        NSString *goodCountStr = [NSString stringWithFormat:@"商品数量：%d",_productCount];
        UILabel* goodCountLbl = [self labelWithFrame:goodCountLblRc text:goodCountStr];
        [cell.contentView addSubview:goodCountLbl];
        
        CGRect orderMoneyLblRc = defaultRc;
        orderMoneyLblRc.origin.y = CGRectGetMaxY(goodCountLbl.frame) + 3;
        UILabel *orderMoneyLbl = [self labelWithFrame:orderMoneyLblRc text:@"订单金额："];
        [cell.contentView addSubview:orderMoneyLbl];
        
        CGRect orderMoneyLblRc2 = orderMoneyLblRc;
        orderMoneyLblRc2.origin.x = CGRectGetMaxX(orderMoneyLbl.frame);
        UILabel *orderMoneyLbl2 = [self labelWithFrame:orderMoneyLblRc2 text:[NSString stringWithFormat:@"￥%.2f", [_order orderTotalMoney]]];
        orderMoneyLbl2.textColor = OTS_COLOR_FROM_RGB(DRAK_RED_VALUE);
        [cell.contentView addSubview:orderMoneyLbl2];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(float)firstCellHeight
{
    return [self isOrderDontNeedPay] ? 70 : 90;
}

-(CGFloat)totalHeightForTV
{
    return [self firstCellHeight] + 40 + 110 + 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    int row = [indexPath row];
    
    if (section == 0)
    {
        if (row == 0)
        {
            return [self firstCellHeight];
        }
        
        else if (row == 1)
        {
            return 40;
        }
    }
    
    else if (section == 1)
    {
        return 110;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int section = [indexPath section];
    int row = [indexPath row];
    
    if (section == 0)
    {
        if (row == 1)
        {
            // change payment
            if (![self isOrderDontNeedPay])
            {
                [self onlinePay];
//                [self changePaymentAction];
            }
        }
    }
    
    else if (section == 1)
    {
        // to order detail
        [self toOrderDetailAction];
    }
}

#pragma mark - action
//立即支付
-(void)onlinePay
{
    //检查是否安装了支付宝客户端
//    if (![self checkalixpayClient])
//    {
//        [self showNoAlixWallet];
//    }
//    else
//    {
        //支付宝支付
        NSString *appScheme = @"yhyw";
        //全局记录状态
        [[GlobalValue getGlobalValueInstance] setAlixpayOrderId:_order.orderId];

        [[GlobalValue getGlobalValueInstance] setIsFromMyOrder:NO];
        [[GlobalValue getGlobalValueInstance] setIsFromOrderSuccessForAlix:YES];
        [GlobalValue getGlobalValueInstance].alipayingOrder = _order;
        
        
        //全局记录状态
        [[GlobalValue getGlobalValueInstance] setIsFromOrderDetailForAlix:NO];
        [[GlobalValue getGlobalValueInstance] setIsFromOrderGROUPDetailForAlix:NO];
        [[GlobalValue getGlobalValueInstance] setIsFromMyOrder:YES];
        
        
//        //获取安全支付单例并调用安全支付接口
//        AlixPay * alixpay = [AlixPay shared];
//        [alixpay pay:_order.signInfo applicationScheme:appScheme];
        
        [[Alipay defaultService] pay:_order.signInfo From:appScheme CallbackBlock:^(NSString *resultString) {
            DebugLog(@"result = %@",resultString);
            NSDictionary *resultDic = [[resultString dataUsingEncoding:NSUTF8StringEncoding]  objectFromJSONData];
            
            NSString *status = resultDic[@"ResultStatus"];
            if ([status intValue] == 9000)
            {
                [self toHomePageAction];
            }
            
        }];

//    }
}


-(void)changePaymentAction
{
//    OnlinePay *onlinePay = [[[OnlinePay alloc] initWithNibName:@"OnlinePay" bundle:nil] autorelease];
//    [onlinePay setIsFromOrder:NO];
//    [onlinePay setGatewayId:[order gateway]];
//    [onlinePay setOrderId:[order orderId]];
//    [onlinePay chooseBankCaller:self];
//    
//    [self pushVC:onlinePay animated:YES fullScreen:YES];
}

-(void)toOrderDetailAction
{
    if (_order)
    {
        OTSBaseViewController* orderDetailVC = nil;
        
//        if ([order isGroupBuyOrder])
//        {
//            orderDetailVC = (GroupBuyOrderDetail*)[[[GroupBuyOrderDetail alloc] init] autorelease];
//            ProductVO *productVO=[[[order orderItemList] objectAtIndex:0] product];
//            [(GroupBuyOrderDetail*)orderDetailVC setGroupImageUrl:productVO.miniDefaultProductUrl];
//            [(GroupBuyOrderDetail*)orderDetailVC setM_OrderId:order.orderId];
//        }
//        else
//        {
            orderDetailVC = [[[OrderDetail alloc] initWithNibName:@"OrderDetail" bundle:nil] autorelease];
            [(OrderDetail*)orderDetailVC setM_OrderId:_order.orderId];
//        }
        
        [self pushVC:orderDetailVC animated:YES fullScreen:YES];
    }
}


-(void)toHomePageAction
{
    [self performSelectorOnMainThread:@selector(doToHomePageAction) withObject:nil waitUntilDone:YES];
}

-(void)doToHomePageAction
{
    [self removeSelf];
    
    [SharedDelegate.tabBarController removeViewControllerWithAnimation:[OTSNaviAnimation animationPushFromLeft]];
    [SharedDelegate enterHomePageRoot];
}

-(void)toMyStoreAction
{
    [self removeSelf];
    [SharedDelegate enterMyStoreWithUpdate:NO];
    [SharedDelegate.tabBarController removeViewControllerWithAnimation:[OTSNaviAnimation animationPushFromLeft]];
}

//未安装支付宝钱夹
-(void)showNoAlixWallet
{
    UIAlertView *alert=[[OTSAlertView alloc] initWithTitle:@"提示" message:@"您尚未安装支付宝客户端，或版本过低。建议您下载或更新支付宝客户端。" delegate:self cancelButtonTitle:@"安装" otherButtonTitles:@"取消", nil];
    [alert setTag:ALIXPAY_CONFIRM];
	[alert show];
	[alert release];
}


//检查是否安装了支付宝客户端
-(BOOL) checkalixpayClient{
    
    BOOL ret ;
    
	NSURL *safepayUrl = [NSURL URLWithString:@"safepay://"];
    NSURL *alipayUrl = [NSURL URLWithString:@"alipay://"];
    
    if ([[UIApplication sharedApplication] canOpenURL:alipayUrl]) {
        
        ret = YES;
	}
    else if ([[UIApplication sharedApplication] canOpenURL:safepayUrl]) {
        
        ret = YES;
	}
	else {
        ret = NO;
	}
    
    return ret;
}


-(void)payNowAction
{
    //检查是否安装了支付宝客户端
    if (![self checkalixpayClient]/* && [order.gateway integerValue] == ALIXPAYGATE*/) {
        [self showNoAlixWallet];
    }
    else
    {
        [self removeSubControllerClass:[OnlinePay class]];

        [self onlinePay];
    }
}

-(void)payLaterAction
{
    [self toHomePageAction];
}

-(void)showError:(NSString *)errorInfo
{
    [AlertView showAlertView:nil alertMsg:errorInfo buttonTitles:nil alertTag:ALERTVIEW_TAG_COMMON];
}

/*
-(void)threadRequestSaveGateWay:(BankVO*)aBankVO
{
    BankVO *bankVO=[aBankVO retain];
    if (order)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView showInView:self.view];
        });
        if ([order isGroupBuyOrder])
        {
            // change group buy order bank
            GroupBuyService* service = [[[GroupBuyService alloc] init] autorelease];
            
            int resultFlag = [service saveGateWayToGrouponOrder:[GlobalValue getGlobalValueInstance].token orderId:order.orderId gatewayId:bankVO.gateway];
            
            
            if (resultFlag == 1)
            {
                DebugLog(@"gateway saved OK: %d, bankName:%@", [bankVO.gateway intValue], bankVO.bankname);
                order.gateway = bankVO.gateway;
                dispatch_async(dispatch_get_main_queue(), ^{
                    paymentLabel.text = bankVO.bankname;
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    OTSAlertView* alert = [[OTSAlertView alloc] initWithTitle:@"" message:@"保存支付方式失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [[alert autorelease] show];
                });
            }
            
            
        }
        else
        {
            // change normal order bank
            OrderService* service = [[[OrderService alloc] init] autorelease];
            
            SaveGateWayToOrderResult *result = [service saveGateWayToOrder:[GlobalValue getGlobalValueInstance].token orderId:order.orderId gateWayId:bankVO.gateway];
            
            if (result && ![result isKindOfClass:[NSNull class]])
            {
                if ([result.resultCode intValue] == 1)
                {
                    DebugLog(@"gateway saved OK: %d, bankName:%@", [bankVO.gateway intValue], bankVO.bankname);
                    order.gateway = bankVO.gateway;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        paymentLabel.text = bankVO.bankname;
                    });
                }
                else
                {
                    [self performSelectorOnMainThread:@selector(showError:) withObject:[result errorInfo] waitUntilDone:NO];
                }
                
            }
            else
            {
                [self performSelectorOnMainThread:@selector(showError:) withObject:@"网络异常，请检查网络配置..." waitUntilDone:NO];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView hide];
        });
    }
    [bankVO release];
}

-(void)handleNotifyPaymentChanged:(NSNotification*)aNotification
{
    NSArray* arr = [aNotification object];
    BankVO* bankVO = (BankVO*)([arr objectAtIndex:1]);
    
    [self otsDetatchMemorySafeNewThreadSelector:@selector(threadRequestSaveGateWay:) toTarget:self withObject:bankVO];
}
*/

#pragma mark    alertView的deleaget
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([alertView tag]) {
        case ALIXPAY_CONFIRM:{
            if (buttonIndex==1)
            {
//                [self onlinePay];
//                [self changePaymentAction];
            } else if (buttonIndex==0) {
                NSString * URLString = @"http://itunes.apple.com/cn/app/id333206289?mt=8";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
            }
            break;
        }
        default:
            break;
    }
}

@end
