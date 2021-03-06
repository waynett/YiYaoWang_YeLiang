//
//  OrderDetail.h
//  TheStoreApp
//
//  Created by jiming huang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OrderV2;
@class ProductVO;
@class OTSChangePayButton;

@class OrderDetailInfo;
@class OrderProductInfo; 

@interface OrderDetail : OTSBaseViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate> {
    IBOutlet UIScrollView *m_ScrollView;
    IBOutlet UILabel *m_OrderCodeLabel;
    IBOutlet UILabel *m_PackageCountLabel;
    IBOutlet UILabel *m_OrderTimeLabel;
    IBOutlet UIButton *m_TopBtn;
    IBOutlet UIView *m_DetailView;
    IBOutlet UIScrollView *m_DetailScrollView;
    IBOutlet UIView *m_DetailGiftView;
    IBOutlet UIScrollView *m_DetailGiftScrollView;
    IBOutlet UITableView *m_DetailTable;
    IBOutlet UILabel *m_DetailTotalMoneyLabel;
    IBOutlet UILabel *m_DetailCountLabel;
    UIButton *m_ConfirmBtn;
    UITableView *m_MoneyTable;
    UITableView *m_ReceiverTable;
    UITableView *m_PaymentTable;
    UITableView *m_ArriveTimeTable;
    UITableView *m_DeliverTable;
    UITableView *m_InvoiceTable;
    
    NSString /*NSNumber*/ *m_OrderId;//传入参数，订单id
    
    int m_ThreadStatus;
    BOOL m_ThreadRunning;
    
    OrderV2 *m_OrderV2;
    BOOL m_RefreshMyOrder;//返回时是否需要刷新我的订单
    OrderV2 *m_CurrentSubOrder;//当前选中的子订单
    ProductVO *m_DetailProduct;//商品明细当前选中的product
    BOOL m_AnimationStop;//购物车动画是否停止
    
    
    //YaoWang
    OrderDetailInfo *_orderDetail;
    int _selectedPackageIndex; //选中的用于显示商品详细的包裹的index

}

@property(nonatomic, retain) NSString /*NSNumber*/ *m_OrderId;//传入参数，订单id
@property(nonatomic, retain) OTSChangePayButton     *changePayBtn;

@property(nonatomic, retain) NSArray *productInfoArr; //这个数组从我的订单列表中传过来，里面元素为OrderProductInfo。本来用于展示订单列表中的商品。由于订单详情中没有商品图片，就把这个数组传过来，通过productId 来识别找图片。。。。fuck。。。


-(void)initOrderDetail;
-(void)updateOrderDetail;
-(void)initDetailView;
-(void)setUpThread:(BOOL)showLoading;
-(void)stopThread;
-(void)showNoAlixWallet;
@end
