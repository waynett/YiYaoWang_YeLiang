//
//  OrderTrackViewController.m
//  yhd
//
//  Created by  on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OrderTrackViewController.h"
#import "OrderTrackCell.h"
#import "OrderV2.h"
#import "GoodReceiverVO.h"
#import "OrderItemVO.h"
#import "ProductVO.h"
#import "SDImageView+SDWebCache.h"
#import "OrderTrackView.h"
#import "Page.h"
#import "OrderStatusTrackVO.h"
#import "OrderTrackDetailCell.h"
#import "ProductListViewController.h"
#import "InvoiceVO.h"
#define kTrackTableViewTag 100
#define kTrackTag1 201
#define kTrackTag2 202
#define kTrackTag3 203
#define kTrackTag4 204
#define kTrackTag5 205
@interface OrderTrackViewController ()
- (void)loadTrackStatus:(NSString *)outTime finishTime:(NSString *)finishTime;
@end

@implementation OrderTrackViewController
@synthesize orderDetail,trackData,childOrder;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    [orderDetail release];
    [trackData release];
    [childOrder release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(dataHandler.screenWidth==768){
        topView=[[TopView alloc] initWithFrame:CGRectMake(0, 0,768,kTopHeight)];
        productListTopView=[[ProductListTopView alloc] initWithFrame:CGRectMake(0, kTopHeight-2,1024,kProducrListTopHeight)];
    }else {
        
        topView=[[TopView alloc] initWithFrame:CGRectMake(0, 0,1024,kTopHeight)];
        
        productListTopView=[[ProductListTopView alloc] initWithFrame:CGRectMake(0, kTopHeight-2,1024,kProducrListTopHeight)];
        orderDetailTableView.frame=CGRectMake(635, 111, kOrderDetailTableViewWidth, 615);
        orderDetailTableFootView.frame=CGRectMake(635, 726, kOrderDetailTableViewWidth, 7);
        trackView.frame=CGRectMake(20, 111, 556, 615);
        
       
    }
    orderDetailTableView.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0].CGColor;
    orderDetailTableView.layer.borderWidth =1;
    
    trackView.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0].CGColor;
    trackView.layer.borderWidth =1;
    
    [self.view addSubview:topView];
    //topView.rootViewController=self;
    [topView release];
    
        
    [self.view addSubview:productListTopView];
    [productListTopView release];
    [self.view sendSubviewToBack:productListTopView];
    
//加载包裹状态
    //[self loadTrackStatus];

    [self loadProductListTop];
    if (orderDetail.childOrderList&&orderDetail.childOrderList.count>0) {
        NSLog(@"%i",orderDetail.childOrderList.count);
         self.childOrder=[orderDetail.childOrderList objectAtIndex:childOrderIndex];
        //childOrderIndex=0;
        if (orderDetail.childOrderList.count>1) {
            nextBut=[UIButton buttonWithType:UIButtonTypeCustom];
            [nextBut setTitleColor:kBlackColor forState:UIControlStateNormal];
            
            [nextBut setImage:[UIImage imageNamed:@"track_next1.png"] forState:UIControlStateNormal];
            [nextBut setImage:[UIImage imageNamed:@"track_nex2.png"] forState:UIControlStateHighlighted];
             [nextBut setImage:[UIImage imageNamed:@"track_next3.png"] forState:UIControlStateDisabled];
            [nextBut addTarget:self action:@selector(nextTrack:) forControlEvents:UIControlEventTouchUpInside];
            [nextBut setFrame:CGRectMake(466, 6, 71, 30)];//
            [trackView addSubview:nextBut];
            
            previousBut=[UIButton buttonWithType:UIButtonTypeCustom];
            [previousBut setTitleColor:kBlackColor forState:UIControlStateNormal];
            
            [previousBut setImage:[UIImage imageNamed:@"track_pre1.png"] forState:UIControlStateNormal];
            [previousBut setImage:[UIImage imageNamed:@"track_pre2.png"] forState:UIControlStateHighlighted];
            [previousBut setImage:[UIImage imageNamed:@"track_pre3.png"] forState:UIControlStateDisabled];
            [previousBut addTarget:self action:@selector(previousTrack:) forControlEvents:UIControlEventTouchUpInside];
            [previousBut setFrame:CGRectMake(395, 6, 71, 30)];//
            previousBut.enabled=NO;
            [trackView addSubview:previousBut];
             statusLabe.text=[NSString stringWithFormat:@"包裹%i状态：%@", childOrderIndex+1,childOrder.orderStatusForString];

        }else {
             statusLabe.text=[NSString stringWithFormat:@"包裹状态：%@", childOrder.orderStatusForString];
        }
        
       // self.childOrder=[orderDetail.childOrderList objectAtIndex:childOrderIndex];
    }
    [self otsDetatchMemorySafeNewThreadSelector:@selector(getTrackDetailService) toTarget:self withObject:nil];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [topView setCartCount:dataHandler.cart.totalquantity.intValue];
    [MobClick beginLogPageView:@"order_detail"];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"order_detail"];
}
- (void)loadTrackStatus:(NSString *)outTime finishTime:(NSString *)finishTime{
    for (UIView *subView in self.view.subviews) {
        if (subView.tag>200) {
            [subView removeFromSuperview];
        }
    }
    OrderTrackView *orderTrackView1=[[OrderTrackView alloc]initWithFrame:CGRectMake(120, 170, 86, 90) title:@"提交订单" time:orderDetail.orderCreateTime isFinish:YES];
    orderTrackView1.tag=kTrackTag1;
    [self.view addSubview:orderTrackView1];
    [orderTrackView1 release];
    
    UIImageView *jian1=[[UIImageView alloc] initWithFrame:CGRectMake(177, 178, 110, 13)];
	jian1.tag=kTrackTag2;
    if (isOut) {
        jian1.image=[UIImage imageNamed:@"track_jiangreen.png"];
    }else {
        jian1.image=[UIImage imageNamed:@"track_jianblue.png"];
    }
	[self.view addSubview:jian1];
	[jian1 release];
    
    OrderTrackView *orderTrackView2=[[OrderTrackView alloc]initWithFrame:CGRectMake(265, 170, 86, 90) title:@"包裹出库" time:outTime  isFinish:isOut];
    orderTrackView2.tag=kTrackTag3;
    [self.view addSubview:orderTrackView2];
    [orderTrackView2 release];
   
    UIImageView *jian2=[[UIImageView alloc] initWithFrame:CGRectMake(322, 178, 110, 13)];
    jian2.tag=kTrackTag4;
    if (isFinish) {
        jian2.image=[UIImage imageNamed:@"track_jiangreen.png"];
    }else {
        jian2.image=[UIImage imageNamed:@"track_jianblue.png"];
    }
    [self.view addSubview:jian2 ];
	[jian2 release];
    OrderTrackView *orderTrackView3=[[OrderTrackView alloc]initWithFrame:CGRectMake(410, 170, 86, 90) title:@"包裹送达" time:finishTime isFinish:isFinish];
    orderTrackView3.tag=kTrackTag5;
    [self.view addSubview:orderTrackView3];
    [orderTrackView3 release];
}
- (void)loadProductListTop{
    UIButton *userBut=[UIButton buttonWithType:UIButtonTypeCustom];
    userBut.titleLabel.lineBreakMode=UILineBreakModeClip;
    userBut.titleLabel.font=[userBut.titleLabel.font fontWithSize:kCateButFontSize];
    [userBut setTitle:@"个人中心"  forState:UIControlStateNormal];
    [userBut setTitleColor:kBlackColor forState:UIControlStateNormal];
    //[myOrderBut setImage:[UIImage imageNamed:@"top_back2.png"] forState:UIControlStateHighlighted];
    [userBut addTarget:self action:@selector(openUser:) forControlEvents:UIControlEventTouchUpInside];
    [userBut setFrame:CGRectMake(25, 0, 85,40)];
    [productListTopView addSubview:userBut];
    
    UIImageView *jian=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"proli_topjian.png"]];
    jian.frame=CGRectMake(110, 0, 20, 42);
    [productListTopView addSubview:jian];
    [jian release];
    
    UIButton *myOrderBut=[UIButton buttonWithType:UIButtonTypeCustom];
    
    myOrderBut.titleLabel.lineBreakMode=UILineBreakModeClip;
    [myOrderBut setTitle:@"订单详情"  forState:UIControlStateNormal];
    [myOrderBut setTitleColor:kBlackColor forState:UIControlStateNormal];
    myOrderBut.titleLabel.font=[myOrderBut.titleLabel.font fontWithSize:kCateButFontSize];
    //[myOrderBut addTarget:self action:@selector(openMyOrder:) forControlEvents:UIControlEventTouchUpInside];
    [myOrderBut setFrame:CGRectMake(140, 0, 80,40)];
    [productListTopView addSubview:myOrderBut];
    
//    UIImageView *jian1=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"proli_topjian.png"]];
//    jian1.frame=CGRectMake(220, 0, 20, 42);
//    [productListTopView addSubview:jian1];
//   
//    
//    
//    UIButton *OrderDetailBut=[UIButton buttonWithType:UIButtonTypeCustom];
//    OrderDetailBut.titleLabel.lineBreakMode=UILineBreakModeClip;
//    [OrderDetailBut setTitle:@"订单详情"  forState:UIControlStateNormal];
//    [OrderDetailBut setTitleColor:kBlackColor forState:UIControlStateNormal];
//    OrderDetailBut.titleLabel.font=[OrderDetailBut.titleLabel.font fontWithSize:kCateButFontSize];
//    //[OrderDetailBut addTarget:self action:@selector(openOrderDetail:) forControlEvents:UIControlEventTouchUpInside];
//    [OrderDetailBut setFrame:CGRectMake(245, 0, 75,40)];
//    [productListTopView addSubview:OrderDetailBut];
   
        
}
-(void)openUser:(id)sender{
    CATransition *transition = [CATransition animation];
    transition.duration = OTSP_TRANS_DURATION;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type =kCATransitionFade; //@"cube";
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)openMyOrder:(id)sender{
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type =kCATransitionFade; //@"cube";
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
}
//-(void)openOrderDetail:(id)sender{
//    CATransition *transition = [CATransition animation];
//    transition.duration = OTSP_TRANS_DURATION;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type =kCATransitionFade; //@"cube";
//    transition.subtype = kCATransitionFromRight;
//    transition.delegate = self;
//    [self.navigationController.view.layer addAnimation:transition forKey:nil];
//    
//    [self.navigationController popViewControllerAnimated:NO];
//}
-(void)nextTrack:(id)sender{
    if (childOrderIndex<orderDetail.childOrderList.count-1) {
        childOrderIndex++;
        self.childOrder=[orderDetail.childOrderList objectAtIndex:childOrderIndex];
        statusLabe.text=[NSString stringWithFormat:@"包裹%i状态：%@", childOrderIndex+1,childOrder.orderStatusForString];
         [self otsDetatchMemorySafeNewThreadSelector:@selector(getTrackDetailService) toTarget:self withObject:nil];
    }
    if (childOrderIndex==orderDetail.childOrderList.count-1) {
        nextBut.enabled=NO;
    }
    previousBut.enabled=YES;
}
-(void)previousTrack:(id)sender{
    if (childOrderIndex>0) {
        childOrderIndex--;
        self.childOrder=[orderDetail.childOrderList objectAtIndex:childOrderIndex];
        statusLabe.text=[NSString stringWithFormat:@"包裹%i状态：%@", childOrderIndex+1,childOrder.orderStatusForString];
        [self otsDetatchMemorySafeNewThreadSelector:@selector(getTrackDetailService) toTarget:self withObject:nil];
    }
    if (childOrderIndex==0) {
        previousBut.enabled=NO;
    }
    nextBut.enabled=YES;
}


-(void)search:(id)sender
{
    [SharedPadDelegate goSearch:sender];
}
#pragma mark -
#pragma mark CartView Delegate
- (void)openCartViewController
{
    [SharedPadDelegate enterCart];
}

#pragma mark -
#pragma mark yhd Service
-(void)getTrackDetailService
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    
    Page *page= [[OTSServiceHelper sharedInstance] getOrderStatusTrack:[GlobalValue getGlobalValueInstance].token orderId:childOrder.orderId currentPage:[NSNumber numberWithInt:1] pageSize:[NSNumber numberWithInt:50]];
    
    [self performSelectorOnMainThread:@selector(handleTrackDetail:) withObject:page waitUntilDone:YES];
    
    

    [pool drain];
    
}
-(void)handleTrackDetail:(Page *)page
{
    if (page.objList) {
        self.trackData=page.objList;
    }
    //判断当前物流状态
    NSString *outTime=nil;
    NSString *FinishTime=nil;
    isOut=NO;
    isFinish=NO;
    for (OrderStatusTrackVO *track in self.trackData) {
        if ([track.oprNum intValue]==24) {
            isOut=YES;
            outTime=track.oprCreatetime;
        }
        if ([track.oprNum intValue]==54) {
            isFinish=YES;
            FinishTime=track.oprCreatetime;
        }
    }
//    if ([track.oprNum intValue]>=54) {
//        isFinish=YES;
//        isOut=YES;
//    }else if ([track.oprNum intValue]>=24) {
//        isFinish=NO;
//        isOut=YES;
//    }else {
//        isFinish=NO;
//        isOut=NO;
//    }
    [self loadTrackStatus:outTime finishTime:FinishTime];
    [trackTableView reloadData];
}

#pragma mark -
#pragma mark Table Data Source Methods
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView.tag==kTrackTableViewTag) {
        return 0.0;
    }
    return 42.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kOrderDetailTableViewWidth,60)];
    headView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"track_detailtop.png"]];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,kOrderDetailTableViewWidth, 45.0) ];
    label1.textColor = kBlackColor;  
    label1.backgroundColor=[UIColor clearColor];
    label1.font=[label1.font fontWithSize:22.0];
    label1.textAlignment=NSTextAlignmentCenter;
    label1.text=@"订单详情";
    [headView insertSubview:label1 atIndex:1];
    [label1 release];
    
    
    return [headView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag==kTrackTableViewTag) {
        OrderTrackDetailCell *cell=(OrderTrackDetailCell *) [self tableView: tableView cellForRowAtIndexPath: indexPath];
        return cell.height+14;
        //return 30;
    }
    OrderTrackCell *cell=(OrderTrackCell *) [self tableView: tableView cellForRowAtIndexPath: indexPath];
    return cell.height;
}
- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==kTrackTableViewTag) {
        return [self.trackData  count];
    }
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (tableView.tag==kTrackTableViewTag) {
         NSUInteger row = [indexPath row];
        static NSString *CustomCellIdentifier = @"OrderTrackDetailIdentifier ";
        
        OrderTrackDetailCell *cell=[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
        if (cell==nil) {
            cell=[[[OrderTrackDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CustomCellIdentifier]autorelease];
        }
        for (UIView*v in cell.subviews) {
            [v removeFromSuperview];
        }
        cell.orderTrack=[self.trackData objectAtIndex:row];
        if(row>0){
            OrderStatusTrackVO *track=[self.trackData objectAtIndex:row-1];
            if ([track.oprCreatetime length]>19) {
                cell.preDate=[track.oprCreatetime substringToIndex:10];

            }

        }
         NSLog(@"cell.orderTrack==%@=%@==%@",cell.orderTrack.oprNum,cell.orderTrack.oprContent,cell.orderTrack.oprEvent);
        
        UIFont *font=[UIFont fontWithName:@"Helvetica" size:13];
        CGSize remarkSize =[cell.orderTrack.oprRemark  sizeWithFont:font constrainedToSize:CGSizeMake(150, 200)];
        int remarkRowCount=(remarkSize.height/16)>0?(remarkSize.height/16):1;
        
        CGSize contentSize =[cell.orderTrack.oprContent  sizeWithFont:font constrainedToSize:CGSizeMake(190, 200)];
        int contentRowCount=(contentSize.height/16)>0?(contentSize.height/16):1;
        
        int rowCount=remarkRowCount>contentRowCount?remarkRowCount:contentRowCount;
        // NSLog(@"cell.orderTrack==%f=%i",contentSize.height,contentRowCount);
        
        if (row==self.trackData.count-1) {
            cell.isLast=YES;
        }
        cell.height=rowCount*20;
        [cell freshCell];
        return cell;
        
    }
    static NSString *CustomCellIdentifier = @"OrderTrackCellIdentifier ";
    OrderTrackCell*cell=[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    if (cell==nil) {
        cell=[[[OrderTrackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CustomCellIdentifier]autorelease];
    }
    for (UIView
         *v in cell.subviews) {
        if (v!=cell.nameLabel) {
            [v removeFromSuperview];
        }
    }
    cell.nameLabel.frame = CGRectMake(15, 10, 100.0, 30.0);
    switch (indexPath.row) {
        case 0:
            cell.height=78;
            cell.nameLabel.text=@"收货人信息";// 收货人信息
            UILabel *goodReceiverLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 222.0, 70.0) ];
            goodReceiverLabel.textColor = kBlackColor;
            goodReceiverLabel.backgroundColor=[UIColor clearColor];
            goodReceiverLabel.numberOfLines=2;
            goodReceiverLabel.text=[NSString stringWithFormat:@"%@,%@,%@,%@,%@",orderDetail.goodReceiver.receiveName,
                                    orderDetail.goodReceiver.provinceName,
                                    orderDetail.goodReceiver.cityName,
                                    orderDetail.goodReceiver.address1,
                                    orderDetail.goodReceiver.postCode];
            
            [cell addSubview:goodReceiverLabel];
            [goodReceiverLabel release];
            break;
        case 1:                 // 发票信息
            cell.nameLabel.text=@"发票信息";
            if ([orderDetail.invoiceList count] > 0) {
                InvoiceVO *invoiceVo = [orderDetail.invoiceList objectAtIndex:0];
                if ([invoiceVo.title isEqualToString:@"发票索要中"]) {
                    cell.height = 47;
                }else {
                    cell.height = 78;
                }
            }else {
                cell.height = 47;
            }
            UILabel *invoiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 10, 230.0, 30.0) ];
            invoiceLabel.textColor = kBlackColor;
            invoiceLabel.backgroundColor=[UIColor clearColor];
            
            if ([orderDetail.invoiceList count] > 0) {
                InvoiceVO *invoiceVo = [orderDetail.invoiceList objectAtIndex:0];
                invoiceLabel.text = invoiceVo.title;
                if (![invoiceVo.title isEqualToString:@"发票索要中"]) {
                    UILabel *invoiceContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 45, 230.0, 30.0) ];
                    invoiceContentLabel.textColor = kBlackColor;
                    invoiceContentLabel.backgroundColor=[UIColor clearColor];
                    invoiceContentLabel.text = invoiceVo.content;
                    [cell addSubview:invoiceContentLabel];
                    [invoiceContentLabel release];
                }
            }else {
                invoiceLabel.text = @"不开发票";
            }
            [cell addSubview:invoiceLabel];
            [invoiceLabel release];

            break;
        case 2:
            cell.nameLabel.text=@"商品信息";
            cell.height=12+orderDetail.orderItemList.count*70; // 商品信息
            int i=0;
            for (OrderItemVO * orderItem in orderDetail.orderItemList) {
                UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(120, 10+i*70, 60, 60)];
                
                imageView.userInteractionEnabled=YES;
                [imageView setImageWithURL:[NSURL URLWithString:orderItem.product.miniDefaultProductUrl]];
                [cell insertSubview:imageView atIndex:1];
                [imageView release];
                
                if (orderItem.product.isGift.intValue) {
                    UIImageView* freeLogo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
                    [freeLogo setImage:[UIImage imageNamed:@"free"]];
                    [imageView addSubview:freeLogo];
                    [freeLogo release];
                }
                
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 10+i*70, 160.0, 60.0) ];
                nameLabel.textColor = kBlackColor;
                nameLabel.backgroundColor=[UIColor clearColor];
                nameLabel.adjustsFontSizeToFitWidth=YES;
                nameLabel.minimumFontSize=12;
                nameLabel.numberOfLines=4;
                nameLabel.font=[nameLabel.font fontWithSize:16.0];
                nameLabel.text=[NSString stringWithFormat:@"%@x%@",orderItem.product.cnName,orderItem.buyQuantity];
                [cell addSubview:nameLabel];
                [nameLabel release];
                i++;
            }
            break;
        case 3:
        {
            cell.height=172;  // 金额总计
            cell.nameLabel.text=@"金额总计";
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(120, 10, 100.0, 30.0) ];
            label1.textColor = kBlackColor;
            label1.backgroundColor=[UIColor clearColor];
            label1.text=@"商品数量：";
            [cell addSubview:label1];
            [label1 release];
            
            
            UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(120, 40, 100.0, 30.0) ];
            label3.textColor = kBlackColor;
            label3.backgroundColor=[UIColor clearColor];
            label3.text=@"运费：";
            [cell addSubview:label3];
            [label3 release];
            
            UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(120, 70, 130.0, 30.0) ];
            label4.textColor = kBlackColor;
            label4.backgroundColor=[UIColor clearColor];
            label4.text=@"商品总金额：";
            [cell addSubview:label4];
            [label4 release];
            
            UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(120, 100, 130.0, 30.0) ];
            label5.textColor = kBlackColor;
            label5.backgroundColor=[UIColor clearColor];
            label5.text=@"帐户余额支付：";
            [cell addSubview:label5];
            [label5 release];
            
            UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(120, 130, 130.0, 30.0) ];
            label6.textColor = kBlackColor;
            label6.backgroundColor=[UIColor clearColor];
            label6.text=@"抵用券：";
            [cell addSubview:label6];
            [label6 release];
                
                UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(245, 10, 100.0, 30.0) ];
                countLabel.textColor = kBlackColor;
                countLabel.backgroundColor=[UIColor clearColor];
                countLabel.textAlignment=NSTextAlignmentRight;
                countLabel.text=[NSString stringWithFormat:@"%i件",orderDetail.orderItemList.count];
                [cell addSubview:countLabel];
                [countLabel release];
                
                
                UILabel *deliveryAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(245, 40, 100.0, 30.0) ];
                deliveryAmountLabel.textColor = kBlackColor;
                deliveryAmountLabel.backgroundColor=[UIColor clearColor];
                deliveryAmountLabel.textAlignment=NSTextAlignmentRight;
                deliveryAmountLabel.text=[NSString stringWithFormat:@"¥ %.2f",[orderDetail.deliveryAmount doubleValue]];
                [cell addSubview:deliveryAmountLabel];
                [deliveryAmountLabel release];
                
                UILabel *orderAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(245,70, 100.0, 30.0) ];
                orderAmountLabel.textColor =kBlackColor;
                orderAmountLabel.backgroundColor=[UIColor clearColor];
                orderAmountLabel.textAlignment=NSTextAlignmentRight;
                orderAmountLabel.text=[NSString stringWithFormat:@"¥ %.2f",[orderDetail.productAmount doubleValue]];
                [cell addSubview:orderAmountLabel];
                [orderAmountLabel release];
                
                UILabel *accountAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(245,100, 100.0, 30.0) ];
                accountAmountLabel.textColor = kBlackColor;
                accountAmountLabel.backgroundColor=[UIColor clearColor];
                accountAmountLabel.textAlignment=NSTextAlignmentRight;
                accountAmountLabel.text=[NSString stringWithFormat:@"¥ %.2f",[orderDetail.accountAmount doubleValue]];
                [cell addSubview:accountAmountLabel];
                [accountAmountLabel release];
                
                UILabel *couponAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(245,130, 100.0, 30.0) ];
                couponAmountLabel.textColor =kBlackColor;
                couponAmountLabel.backgroundColor=[UIColor clearColor];
                couponAmountLabel.textAlignment=NSTextAlignmentRight;
                couponAmountLabel.text=[NSString stringWithFormat:@"¥ %.2f",[orderDetail.couponAmount doubleValue]];
                [cell addSubview:couponAmountLabel];
                [couponAmountLabel release];
        }
            break;
        case 4:
        {
            cell.height=47;
            [cell.nameLabel setFrame:CGRectMake(120, 10, 130.0, 30.0)];
            cell.nameLabel.text=@"共需支付：";
                UILabel *totlaAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(245,10, 100.0, 30.0) ];
                totlaAmountLabel.textColor = kRedColor;
                totlaAmountLabel.backgroundColor=[UIColor clearColor];
                totlaAmountLabel.textAlignment=NSTextAlignmentRight;
                totlaAmountLabel.font=[totlaAmountLabel.font fontWithSize:22.0];
                float total=[orderDetail.deliveryAmount floatValue]+[orderDetail.productAmount floatValue]-[orderDetail.accountAmount floatValue]-[orderDetail.couponAmount floatValue];
                totlaAmountLabel.text=[NSString stringWithFormat:@"¥ %.2f",total];
                [totlaAmountLabel sizeToFit];
                [cell addSubview:totlaAmountLabel];
                [totlaAmountLabel release];
        }
            break;
        default:
            break;
            
    }
       return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
        
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    orderDetailTableView=nil;
    trackTableView=nil;
}

@end