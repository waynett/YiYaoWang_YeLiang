//
//  OTSOrderMfVC.h
//  TheStoreApp
//
//  Created by yiming dong on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderV2;
@class OTSOrderMfServant;
@class OTSMfData;

@class OrderDetailInfo;

@interface OTSOrderMfVC : OTSBaseViewController
<UITableViewDelegate
, UITableViewDataSource
, UIActionSheetDelegate>
{
    OrderV2         *theOrder;
    NSUInteger      subPackIndex;
}

@property(retain)OrderV2*   theOrder;
@property(nonatomic, retain)OTSOrderMfServant* servant;


@property (retain, nonatomic) OrderDetailInfo *orderDetail;
@property(nonatomic, retain)NSString *orderId; //orderDetail 没有的时候用这个id去获取订单详情


@property(nonatomic, retain)IBOutlet UIImageView        *groupLogoIV;   // 团购logo
@property(nonatomic, retain)IBOutlet UILabel            *orderCodeLbl;  // 订单编号
@property(nonatomic, retain)IBOutlet UILabel            *packNameLbl;   // 包裹一
@property(nonatomic, retain)IBOutlet UILabel            *packStatusLbl; // 包裹状态
@property(nonatomic, retain)IBOutlet UILabel            *orderDateLbl;  // 下单时间
@property(nonatomic, retain)IBOutlet UIButton           *leftPackBtn;   // 上一个包裹
@property(nonatomic, retain)IBOutlet UIButton           *rightPackBtn;  // 下一个包裹
@property(nonatomic, retain)IBOutlet UIView             *packStatusListView;    // 包裹状态列表
@property(nonatomic, retain)IBOutlet UITableView             *packInfoTV;    // 包裹信息 table view
@property(nonatomic, retain)IBOutlet UIScrollView             *scrollView;  

@property(nonatomic, retain)OTSMfData                    *selectedMfData;
@property(nonatomic, retain)NSMutableArray              *materialFlowDatas; // 配送信息数组
@property NSUInteger      subPackIndex;

-(IBAction)prevPackAction:(id)sender;
-(IBAction)nextPackAction:(id)sender;
@end


