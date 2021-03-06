//
//  GroupBuyProductDetail.m
//  TheStoreApp
//
//  Created by jiming huang on 12-2-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GroupBuyProductDetail.h"
#import "GroupBuyService.h"
#import "BrowseService.h"
#import "GlobalValue.h"
#import "StrikeThroughLabel.h"
#import "GroupBuyCheckOrder.h"
#import <QuartzCore/QuartzCore.h>
#import "AlertView.h"
#import "DataController.h"
#import "RegexKitLite.h"
#import "ShareActionSheet.h"
#import "JiePang.h"
#import "OTSAlertView.h"
#import "OTSActionSheet.h"
#import "OTSNaviAnimation.h"
#import "TheStoreAppAppDelegate.h"
#import "OTSLoadingView.h"
#import "UIScrollView+OTS.h"
#import "NSString+MD5Addition.h"
#import "OTSImageView.h"
#import "DoTracking.h"
#define THREAD_STATUS_GET_PRODUCT_DETAIL        1

#define TAG_PAGE_VIEW                           50

#define TAG_GET_DETAIL_ALERTVIEW                1

@implementation GroupBuyProductDetail

@synthesize m_AreaId;
@synthesize m_Products;
@synthesize m_CurrentIndex, m_grouponVO, m_FromTag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 屏蔽左右滑动功能，因自营和1MALL商品同时存在可能导致的BUG
 //   [m_ScrollView setContentSize:CGSizeMake(320*[m_Products count], ApplicationHeight-NAVIGATION_BAR_HEIGHT-58)];
 //   [m_ScrollView setContentOffset:CGPointMake(320.0*m_CurrentIndex, 0) animated:NO];
    [m_ScrollView setContentSize:CGSizeMake(320, ApplicationHeight-NAVIGATION_BAR_HEIGHT-58)];
    [m_ScrollView setContentOffset:CGPointMake(320.0, 0) animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.isFullScreen)
    {
        [self strechViewToBottom:m_DetailWebView.superview];
        [self strechViewToBottom:m_DetailWebView];
    }
    
    [m_DetailView setFrame:CGRectMake(0, 0, ApplicationWidth, ApplicationHeight)];
    [m_DetailWebView setFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, ApplicationWidth, ApplicationHeight-NAVIGATION_BAR_HEIGHT)];
    // Do any additional setup after loading the view from its nib.
    [self initProductDetail];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addJiePangView:) name:@"AddJiePangView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBottomView:) name:@"ProductDetailShowBottom" object:nil];
    

    [m_BottomView setFrame:CGRectMake(0, self.view.frame.size.height - 58, 320, 58)];
    [self.view addSubview:m_BottomView];
    m_BuyBtn.enabled=NO;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)initProductDetail
{
    //团购省份id
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *filename=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"GroupBuyLocation.plist"];
    NSMutableArray *mArray=[[NSMutableArray alloc] initWithContentsOfFile:filename];
    if (m_FromTag==FROM_CMS_TO_DETAIL || [mArray count]==0) {
        NSNumber *grouponProvinceId=[GlobalValue getGlobalValueInstance].provinceId;
        m_ProvinceId=[[NSNumber alloc] initWithInt:[grouponProvinceId intValue]];
    } else {
        NSDictionary *dictionary=[mArray objectAtIndex:0];
        NSNumber *grouponProvinceId=[dictionary valueForKey:@"ProvinceId"];
        m_ProvinceId=[[NSNumber alloc] initWithInt:[grouponProvinceId intValue]];
    }
    [mArray release];
    
    m_Dictionary=[[NSMutableDictionary alloc] init];
    [self.view setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]];
    //scroll view
    m_ScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, ApplicationHeight-NAVIGATION_BAR_HEIGHT-58)];
   // [m_ScrollView setContentSize:CGSizeMake(320*[m_Products count], ApplicationHeight-NAVIGATION_BAR_HEIGHT-58)];
    [m_ScrollView setContentSize:CGSizeMake(320, ApplicationHeight-NAVIGATION_BAR_HEIGHT-58)];
    //[m_ScrollView setAlwaysBounceVertical:YES];
    [m_ScrollView setPagingEnabled:YES];
    [m_ScrollView setShowsHorizontalScrollIndicator:NO];
    [m_ScrollView setDelegate:self];
    [self.view addSubview:m_ScrollView];
    [self.view sendSubviewToBack:m_ScrollView];
    
    [m_ScrollView setContentOffset:CGPointMake(320.0*m_CurrentIndex, 0) animated:NO];
    m_ThreadIsRunning=NO;
    m_CurrentState=THREAD_STATUS_GET_PRODUCT_DETAIL;
    [self setUpThread];
}

-(void)closeView
{
    if (m_Timer!=nil) {
        if ([m_Timer isValid]) {
            [m_Timer invalidate];
        }
        [m_Timer release];
        m_Timer=nil;
    }
    if ([self view]!=nil && [[self view] superview]!=nil) {
        [self removeSelf];
    }
    m_BottomView.hidden = YES;
}

-(void)showBottomView:(NSNotification *)notification
{
    m_BottomView.hidden = NO;
}

//返回
-(IBAction)returnBtnClicked:(id)sender
{
    if (self.m_FromTag == FROM_ROCKBUY_TO_DETAIL) {
        [super popSelfAnimated:YES];
    }else{
        if (m_Timer!=nil) {
            if ([m_Timer isValid]) {
                [m_Timer invalidate];
            }
            [m_Timer release];
            m_Timer=nil;
        }
        [self.view.superview.layer addAnimation:[OTSNaviAnimation animationPushFromLeft] forKey:@"Reveal"];
        
        [self removeSelf];
        [SharedDelegate.tabBarController removeViewControllerWithAnimation:[OTSNaviAnimation animationPushFromLeft]];
        m_BottomView.hidden = YES;
    }
}

//分享
-(IBAction)shareBtnClicked:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toMyOrderViewAfterWeiboShare) name:@"toMyOrderViewAfterWeiboShare" object:nil];
    GrouponVO *grouponVO=[m_Dictionary objectForKey:[[m_Products objectAtIndex:m_CurrentIndex] nid]];
    if (m_Share==nil) {
        m_Share=[[ShareActionSheet alloc] init];
    }
    BOOL isExclusive=NO;
    if ([[grouponVO categoryId] intValue]==101) {
        isExclusive=YES;
    }
    [m_Share shareProduct:[grouponVO name] price:[grouponVO price] productId:[grouponVO nid] provinceId:[[GlobalValue getGlobalValueInstance] provinceId] isExclusive:isExclusive];
}

#pragma mark 微博分享成功后执行界面跳转
-(void)toMyOrderViewAfterWeiboShare {
	
	static int i=-1;
	i++;
	while(i>=0){
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"toMyOrderViewAfterWeiboShare" object:nil];
		i--;
		if(i==-1){
            UIAlertView *alert=[[OTSAlertView alloc] initWithTitle:nil 
                                                           message:@"分享新浪微博成功!"
                                                          delegate:self 
                                                 cancelButtonTitle:nil 
                                                 otherButtonTitles:@"确定",nil];
            [alert show];
            [alert release];
		}
	}
}

//上一个
-(IBAction)previousBtnClicked:(id)sender
{
    CGPoint point=[m_ScrollView contentOffset];
    if (point.x>=320.0) 
    {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"GrouponShowLoading" object:[NSNumber numberWithBool:NO]];
        [[OTSGlobalLoadingView sharedInstance] hide];
        
        point.x-=320.0;
        
        if (m_CurrentIndex-1>=0) 
        {
            m_CurrentIndex--;
            [m_ScrollView setContentOffset:point animated:YES];
        }
    }
}

//下一个
-(IBAction)nextBtnClicked:(id)sender
{
    CGPoint point=[m_ScrollView contentOffset];
    if (point.x<=320.0*([m_Products count]-2)) 
    {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"GrouponShowLoading" object:[NSNumber numberWithBool:NO]];
        [[OTSGlobalLoadingView sharedInstance] hide];
        
        point.x+=320.0;
        if (m_CurrentIndex+1<=[m_Products count]-1) 
        {
            m_CurrentIndex++;
            [m_ScrollView setContentOffset:point animated:YES];
        }
    }
}

-(void)updateProductDetail
{

    if (m_ScrollView==nil) {
        return;
    }
    //当前view
    m_BuyBtn.enabled=YES;
    m_CurrentScrollView=(UIScrollView *)[m_ScrollView viewWithTag:100+m_CurrentIndex];
    if (m_CurrentScrollView==nil) {
        m_CurrentScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake([m_ScrollView contentOffset].x, 0, 320, ApplicationHeight-NAVIGATION_BAR_HEIGHT-58)];
        [m_CurrentScrollView setTag:100+m_CurrentIndex];
        [m_CurrentScrollView setShowsVerticalScrollIndicator:NO];
        [m_ScrollView addSubview:m_CurrentScrollView];
        [m_CurrentScrollView release];
    }
    
    CGFloat xValue=22.0;//控件的x值
    CGFloat yValue=13.0;//控件的y值
    CGFloat width=276.0;
    
    //商品图片bg
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(xValue, yValue, width, 186)];
    [view.layer setCornerRadius:5.0];
    [view setBackgroundColor:[UIColor whiteColor]];
    [m_CurrentScrollView addSubview:view];
    [view release];
    //商品图片
    OTSImageView *imgView=[[OTSImageView alloc] initWithFrame:CGRectMake(3, 3, 270, 180)];
    [imgView loadImgUrl:[m_grouponVO middleImageUrl]];
//    NSString *fileName=[[m_grouponVO middleImageUrl] stringFromMD5];
//    NSData *data=[DataController applicationDataFromFile:fileName];
//    if (data!=nil) {
//        UIImage *image=[UIImage imageWithData:data];
//        [imageView setImage:image];
//    } else {
//        NSData *netData=[NSData dataWithContentsOfURL:[NSURL URLWithString:[m_grouponVO middleImageUrl]]];
//        if (netData!=nil) {
//            [imageView setImage:[UIImage imageWithData:netData]];
//            [DataController writeApplicationData:netData name:fileName];
//        } else {
//            [imageView setImage:[UIImage imageNamed:@"defaultimg320x120.png"]];
//        }
//    }
    [view addSubview:imgView];
    [imgView release];
    //折扣图片
   UIImageView* imageView=[[UIImageView alloc] initWithFrame:CGRectMake(xValue-3, yValue+10, 60, 25)];
    [imageView setImage:[UIImage imageNamed:@"red_flag.png"]];
    [m_CurrentScrollView addSubview:imageView];
    [imageView release];
    //折扣
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(xValue+4, yValue+10, 45, 25)];
    [label setText:[NSString stringWithFormat:@"%.1f折",[[m_grouponVO discount] floatValue]]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont systemFontOfSize:15.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [m_CurrentScrollView addSubview:label];
    [label release];
    
    yValue+=186.0+5.0;
    
    //商品名称label
    NSString *string=[m_grouponVO name];
    CGFloat stringWidth=[string sizeWithFont:[UIFont systemFontOfSize:15.0]].width;
    NSInteger lineCount=stringWidth/width;
    if (stringWidth/width>lineCount) {
        lineCount++;
    }
    label=[[UILabel alloc] initWithFrame:CGRectMake(xValue, yValue, width, lineCount*20)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:15.0]];
    [label setText:string];
    [label setNumberOfLines:lineCount];
    [m_CurrentScrollView addSubview:label];
    [label release];
    yValue+=lineCount*20+5.0;
    
    //颜色尺码
    if ([[m_grouponVO isGrouponSerial] intValue]==1) {
        m_ColorSizeBtn=[[UIButton alloc] initWithFrame:CGRectMake(24, yValue, 272, 39)];
        [m_ColorSizeBtn setBackgroundColor:[UIColor clearColor]];
        [m_ColorSizeBtn setBackgroundImage:[UIImage imageNamed:@"sizeChonse_btn.png"] forState:UIControlStateNormal];
        [m_ColorSizeBtn setTitle:@"请选择颜色尺码 ▼" forState:UIControlStateNormal];
        [m_ColorSizeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [[m_ColorSizeBtn titleLabel] setFont:[UIFont systemFontOfSize:16.0]];
        [m_ColorSizeBtn addTarget:self action:@selector(chooseColorAndSize:) forControlEvents:UIControlEventTouchUpInside];
        [m_CurrentScrollView addSubview:m_ColorSizeBtn];
        [m_ColorSizeBtn release];
        yValue+=50.0;
    }
    
    //购买数量label
    int productNumber=0;
    if ([m_grouponVO peopleNumber]!=nil) {
        productNumber=[[m_grouponVO peopleNumber] intValue];
    }
    label=[[UILabel alloc] initWithFrame:CGRectMake(xValue, yValue, 130, 30)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:[NSString stringWithFormat:@"%d人已购买",productNumber]];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setFont:[UIFont systemFontOfSize:15.0]];
    [m_CurrentScrollView addSubview:label];
    [label release];
    
    //剩余时间
    Float64 remainTime=[[m_grouponVO remainTime] doubleValue];
    NSInteger dayValue=remainTime/1000/60/60/24;//天数
    if (dayValue<0) {
        dayValue=0;
    }
    NSInteger hourValue=((int)(remainTime/1000/60/60)) % 24;//小时数
    if (hourValue<0) {
        hourValue=0;
    }
    NSInteger minuteValue = ((int)(remainTime/1000/60)) % 60;//分钟数
    if (minuteValue<0) {
        minuteValue=0;
    }
    NSString* remineTime;
    label=[[UILabel alloc] initWithFrame:CGRectMake(100+xValue, yValue, 180, 30)];
    [label setBackgroundColor:[UIColor clearColor]];
    if ([m_grouponVO.status intValue]<100) {
        remineTime=[NSString stringWithFormat:@"离开始还有%d天%d时%d分",dayValue,hourValue,minuteValue];
        m_BuyBtn.enabled=NO;
        [m_BuyBtn setTitle:@"即将开始" forState:UIControlStateNormal];
    }else if ([m_grouponVO.status intValue]>=200) {
        remineTime=[NSString stringWithFormat:@"团购已经结束"];
        m_BuyBtn.enabled=NO;
        [m_BuyBtn setTitle:@"已经结束" forState:UIControlStateNormal];
    }else {
        remineTime=[NSString stringWithFormat:@"剩余%d天%d时%d分",dayValue,hourValue,minuteValue];
    }
    [label setText:remineTime];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setFont:[UIFont systemFontOfSize:15.0]];
    [m_CurrentScrollView addSubview:label];
    [label release];
    
    //查看详情
    yValue+=40.0;
    UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(9, yValue, 302, 45)];
    [button setTitle:@"   查看详情" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"table_btn.png"] forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont systemFontOfSize:16.0]];
	[button addTarget:self action:@selector(enterGrouponDetail) forControlEvents:UIControlEventTouchUpInside];
    [m_CurrentScrollView addSubview:button];
    [button release];
    yValue+=65.0;
    
    //虚线+备注
	//虚线
	UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, yValue, 320, 1)];
	[line setBackgroundColor:[UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0]];
	[m_CurrentScrollView addSubview:line];
	[line release];
	[textView setFrame:CGRectMake(0, yValue, 290, 320)];
	[textView setBackgroundColor:[UIColor clearColor]];
	[m_CurrentScrollView addSubview:textView];
    
    [m_CurrentScrollView setContentSize:CGSizeMake(320, yValue+330.0)];
    
    //底部view
    [m_BottomView setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:254.0/255.0 blue:238.0/255.0 alpha:1.0]];
    //价格
    [m_PriceLabel setText:[NSString stringWithFormat:@"￥%.2f",[[m_grouponVO price] floatValue]]];
    [m_PriceLabel setTextColor:[UIColor colorWithRed:204.0/255.0 green:0.0 blue:0.0 alpha:1.0]];
    //市场价
  //  [m_MarketPriceLabel setText:[NSString stringWithFormat:@"￥%.2f",[[[m_grouponVO productVO] maketPrice] floatValue]]];
  //  [m_MarketPriceLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
    if ([[m_grouponVO productVO].price floatValue] > 0) {
        [m_MarketPriceLabel setText:[NSString stringWithFormat:@"￥%.2f",[[m_grouponVO productVO].price floatValue]]];
        [m_MarketPriceLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
    }
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"AddTabBarForGroupBuyTabBar" object:m_BottomView];
    m_BottomView.hidden = NO;
    
	[m_CurrentScrollView ScrollMeToTopOnly];
}


-(void)enterGrouponDetail {
    GrouponVO *grouponVO=[m_Dictionary objectForKey:[[m_Products objectAtIndex:m_CurrentIndex] nid]];
	CATransition *animation=[CATransition animation];
    animation.duration=0.3f;
    animation.timingFunction=UIViewAnimationCurveEaseInOut;
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [self.view.superview.layer addAnimation:animation forKey:@"Reveal"];
    [self.view addSubview:m_DetailView];
    //NSString *htmlString=[[grouponVO prompt] stringByReplacingOccurrencesOfRegex:@"<table.*</table>" withString:@""];
    [m_DetailWebView loadHTMLString:[grouponVO prompt] baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

-(IBAction)returnToMainView:(id)sender {
	CATransition * animation = [CATransition animation];
	animation.duration = 0.3f;
	animation.timingFunction = UIViewAnimationCurveEaseInOut;
	[animation setType:kCATransitionPush];
	[animation setSubtype: kCATransitionFromLeft];
	[self.view.layer addAnimation:animation forKey:@"Reveal"];
    [m_DetailView removeFromSuperview];
	[m_CurrentScrollView ScrollMeToTopOnly];
}

-(void)updateRemainTime:(NSTimer *)timer
{
    m_RemainTime-=1000;
}

-(void)chooseColorAndSize:(id)sender
{
    m_ActionSheet = [[OTSActionSheet alloc]initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
                                               delegate:self
                                      cancelButtonTitle:nil
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:nil];
    UIButton *tempButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 40, 320, 216)];
    [m_ActionSheet addSubview:tempButton];
    [tempButton release];
    
    UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(18, 5, 50, 30)];//取消按钮
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"red_short_btn.png"] forState:0];
    [cancelBtn addTarget:self action:@selector(closeActionSheet) forControlEvents:1];
    [cancelBtn setTitle:@"取消" forState:0];
    [m_ActionSheet addSubview:cancelBtn];
    [cancelBtn release];
    
    UIButton *finishBtn = [[UIButton alloc]initWithFrame:CGRectMake(252, 5, 50, 30)];//完成按钮
    finishBtn.tag=11011;
    [finishBtn setBackgroundImage:[UIImage imageNamed:@"red_short_btn.png"] forState:0];
    [finishBtn addTarget:self action:@selector(finishBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [finishBtn setTitle:@"完成" forState:0];
    [m_ActionSheet addSubview:finishBtn];
    [finishBtn release];
    
    [m_PickerView setFrame:CGRectMake(0, 0, 320, 216)];
    [tempButton addSubview:m_PickerView];
    [self initPickerView:m_PickerView];
    
    [m_ActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    [UIView setAnimationsEnabled:NO];
    [m_ActionSheet release];
}

//立即抢购
-(IBAction)buyBtnClicked:(id)sender
{
    if ([GlobalValue getGlobalValueInstance].token==nil) 
    {
        [SharedDelegate enterUserManageWithTag:kEnterLoginFromGrouponDetail];
    }
    else
    {
        GrouponVO *grouponVO=[m_Dictionary objectForKey:[[m_Products objectAtIndex:m_CurrentIndex] nid]];
        NSNumber *serialId=nil;
        if ([[grouponVO isGrouponSerial] intValue]==1)
        {
            if (m_CurColor==nil || m_CurSize==nil) {
                isDirectOrder = YES;
				[self chooseColorAndSize:nil];
				return;
            } else {
                BOOL canBuy=NO;
                //获取所选的系列商品id
                NSArray *grouponSerials=[grouponVO grouponSerials];
                int i;
                for (i=0; i<[grouponSerials count]; i++) {
                    GrouponSerialVO *serialVO=[grouponSerials objectAtIndex:i];
                    if ([[serialVO productSize] isEqualToString:m_SelSize] && [[serialVO productColor] isEqualToString:m_SelCorlor] && [[serialVO upperSaleNum] intValue]>0) {
                        canBuy=YES;
                        serialId=[serialVO nid];
                        break;
                    }
                }
                if (!canBuy) {
                    [AlertView showAlertView:nil alertMsg:@"此颜色和尺码的商品已售完" buttonTitles:nil alertTag:ALERTVIEW_TAG_COMMON];
                    return;
                }
            }
        }
        
        [self removeSubControllerClass:[GroupBuyCheckOrder class]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CheckOrderReleased" object:nil];
        
        GroupBuyCheckOrder* checkOrderVC = [[[GroupBuyCheckOrder alloc] initWithNibName:@"GroupBuyCheckOrder" bundle:nil] autorelease];
        [checkOrderVC setM_GrouponId:[[m_Products objectAtIndex:m_CurrentIndex] nid]];
        int isSerialProduct=[[grouponVO isGrouponSerial] intValue];
        if (isSerialProduct==1) {
            [checkOrderVC setM_SerialId:serialId];
        } else {
            [checkOrderVC setM_SerialId:nil];
        }
        [checkOrderVC setM_ProductName:[grouponVO name]];
        [checkOrderVC setM_SelectedStr:[NSString stringWithFormat:@"%@/%@",m_SelCorlor,m_SelSize]];
        [checkOrderVC setM_SinglePrice:[grouponVO price]];
        [checkOrderVC setM_AreaId:[m_AreaId intValue]];
        [checkOrderVC setM_ToDetailTag:m_FromTag];
        
        if (self.m_FromTag == FROM_ROCKBUY_TO_DETAIL) {
            [self pushVC:checkOrderVC animated:YES fullScreen:YES];
        }else{
            [SharedDelegate.tabBarController addViewController:checkOrderVC withAnimation:[OTSNaviAnimation animationPushFromRight]];
            m_BottomView.hidden = YES;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCheckOrderNull:) name:@"CheckOrderReleased" object:checkOrderVC];
        
    }
}

-(void)setCheckOrderNull:(NSNotification *)notification
{
    [self removeSubControllerClass:[GroupBuyCheckOrder class]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CheckOrderReleased" object:nil];
}

-(void)addJiePangView:(NSNotification *)notification
{
    JiePang *jiePang=[notification object];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddSubViewForGroupBuyMask" object:jiePang.view];
}

-(void)productDetailIsNull
{
    OTSAlertView *alert = [[OTSAlertView alloc]initWithTitle:nil message:@"该团购在当前地区不可用" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alert setTag:TAG_GET_DETAIL_ALERTVIEW];
    [alert show];
    [alert release];
    alert=nil;
}
-(void)initPickerView:(UIPickerView *)pickerView
{
    GrouponVO *grouponVO=[m_Dictionary objectForKey:[[m_Products objectAtIndex:m_CurrentIndex] nid]];
    if (m_CurColor==nil || m_CurSize==nil) {
        [pickerView reloadComponent:0];
        m_ColorIndex=0;
        [pickerView selectRow:0 inComponent:m_ColorIndex animated:YES];
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        m_SelCorlor=[[grouponVO colorList] objectAtIndex:0];
        m_SelSize=nil;
        NSString *selectedColor=[[grouponVO colorList] objectAtIndex:0];
        int i=0;
        BOOL hasFind=NO;
        for (NSString *sizeStr in [grouponVO sizeList]) {
            if (hasFind) {
                break;
            }
            for (GrouponSerialVO *serialVO in [grouponVO grouponSerials]) {
                if ([[serialVO productSize] isEqualToString:sizeStr] && [[serialVO productColor] isEqualToString:selectedColor] && [[serialVO upperSaleNum] intValue]>0) {
                    if (i==0) {
                        m_SelSize=sizeStr;
                        hasFind=YES;
                        break;
                    }
                    i++;
                }
            }
        }
    } else {
        m_SelCorlor=m_CurColor;
        m_SelSize=m_CurSize;
        [pickerView reloadComponent:0];
        int i;
        for (i=0; i<[[grouponVO colorList] count]; i++) {
            NSString *color=[[grouponVO colorList] objectAtIndex:i];
            if ([color isEqualToString:m_SelCorlor]) {
                m_ColorIndex=i;
                [pickerView selectRow:m_ColorIndex inComponent:0 animated:YES];
                [pickerView reloadComponent:1];
                break;
            }
        }
        i=0;
        BOOL hasFind=NO;
        for (NSString *sizeStr in [grouponVO sizeList]) {
            if (hasFind) {
                break;
            }
            for (GrouponSerialVO *serialVO in [grouponVO grouponSerials]) {
                if ([[serialVO productSize] isEqualToString:sizeStr] && [[serialVO productColor] isEqualToString:m_SelCorlor] && [[serialVO upperSaleNum] intValue]>0) {
                    if ([sizeStr isEqualToString:m_SelSize]) {
                        [pickerView selectRow:i inComponent:1 animated:YES];
                        hasFind=YES;
                        break;
                    }
                    i++;
                }
            }
        }
    }
}

//取消
-(void)closeActionSheet
{
    [m_ActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

//完成
-(void)finishBtnClicked:(id)sender
{
    if (m_SelCorlor==nil || m_SelSize==nil || [m_SelSize isEqualToString:@"尺码(已售完)"]) {
    } else {
        [m_ActionSheet dismissWithClickedButtonIndex:0 animated:YES];
        m_CurColor=m_SelCorlor;
        m_CurSize=m_SelSize;
        [m_ColorSizeBtn setTitle:[NSString stringWithFormat:@"%@/%@",m_CurColor,m_CurSize] forState:UIControlStateNormal];
        if (isDirectOrder == YES ) {
            [self buyBtnClicked:sender];
            isDirectOrder = NO;
        }
    }
}

#pragma mark 线程相关部分
//建立线程
-(void)setUpThread {
	if (!m_ThreadIsRunning) 
    {
        m_BuyBtn.enabled=NO;
		m_ThreadIsRunning = YES;
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"GrouponShowLoading" object:[NSNumber numberWithBool:YES]];
        [[OTSGlobalLoadingView sharedInstance] showInView:self.view offsetY:50];
        
		[self otsDetatchMemorySafeNewThreadSelector:@selector(startThread) toTarget:self withObject:nil];
	}
}

//开启线程
-(void)startThread {
	while (m_ThreadIsRunning) {
		@synchronized(self) {
            switch (m_CurrentState) {
                case THREAD_STATUS_GET_PRODUCT_DETAIL: {//获取团购商品详情
//                    NSLog(@">>>获取团购商品详情:thread start");
                    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
                    if (m_Service!=nil) {
                        [m_Service release];
                    }
                    m_Service=[[GroupBuyService alloc] init];
                    @try {
//                        NSLog(@">>>m_AreaId%@", m_AreaId);
                        if (m_AreaId==nil) 
                        {
                            NSNumber *tempNumber=[m_Service getGrouponAreaIdByProvinceId:[GlobalValue getGlobalValueInstance].trader provinceId:m_ProvinceId];
                            if (tempNumber==nil || [tempNumber isKindOfClass:[NSNull class]]) {
                                [self performSelectorOnMainThread:@selector(productDetailIsNull) withObject:nil waitUntilDone:NO];
                            } else {
                                self.m_grouponVO =[m_Service getGrouponDetail:[GlobalValue getGlobalValueInstance].trader grouponId:[[m_Products objectAtIndex:m_CurrentIndex] nid] areaId:tempNumber];
                            }
                        } 
                        else 
                        {
                            self.m_grouponVO = [m_Service getGrouponDetail:[GlobalValue getGlobalValueInstance].trader grouponId:[[m_Products objectAtIndex:m_CurrentIndex] nid] areaId:m_AreaId];
//                            if (m_grouponVO!=nil) {
//                                [m_grouponVO release];
//                            }
                            
                        }
                    } 
                    @catch (NSException * e) 
                    {
                    } 
                    @finally 
                    {
                        self.m_grouponVO = [self.m_grouponVO isKindOfClass:[NSNull class]] ? nil : self.m_grouponVO;
                        if (self.m_grouponVO && self.m_grouponVO.nid)
                        {
                            [m_Dictionary setObject:m_grouponVO forKey:[self.m_grouponVO nid]];
                            [self performSelectorOnMainThread:@selector(updateProductDetail) withObject:nil waitUntilDone:NO];
                            //更新团购最新浏览信息
                            [self otsDetatchMemorySafeNewThreadSelector:@selector(newThreadAddGrouponBrowse:) toTarget:self withObject:self.m_grouponVO];
                            
                            // 需传入额外的areaId, categoryId, grouponId,设置 merchant_id
                            JSTrackingPrama* prama = [[[JSTrackingPrama alloc]initWithJSType:EJStracking_GroupDetail extraPrama: m_AreaId, [m_grouponVO categoryId],[[m_Products objectAtIndex:m_CurrentIndex] nid], nil]autorelease];
                            [prama setMerchant_id:[NSString stringWithFormat:@"%@",m_grouponVO.merchantId]];
                            [DoTracking doJsTrackingWithParma:prama];
                        }
                        else
                        {
                            [self performSelectorOnMainThread:@selector(productDetailIsNull) withObject:nil waitUntilDone:NO];
                        }
                        
                        
                        [NSThread sleepForTimeInterval:1.0];
                        [self stopThread];
                    }
//                    NSLog(@">>>获取团购商品详情:thread end");
                    [pool drain];
                    break;
                }
                default:
                    break;
            }
		}
	}
}

//停止线程
-(void)stopThread {
	m_ThreadIsRunning = NO;
	m_CurrentState = -1;
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"GrouponHideLoading" object:nil];
    [[OTSGlobalLoadingView sharedInstance] hide];
}

#pragma mark alertView相关delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([alertView tag]) {
        case TAG_GET_DETAIL_ALERTVIEW: {
            [self returnBtnClicked:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark    webview相关delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    switch (navigationType) {
        case UIWebViewNavigationTypeOther:
			for (UIView* tpView in [webView subviews]) {
				if ([tpView isKindOfClass:[UIScrollView class]]) {
					UIScrollView *tpScrollView = (UIScrollView*)tpView;
					[tpScrollView ScrollMeToTopOnly];
				}
			}
            return YES;
            break;
        default:
            return NO;
            break;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    switch ([webView tag]) {
        case 1: {
            for (UIView *subView in [webView subviews]) {
                if ([subView isKindOfClass:[UIScrollView class]]) {
                    UIScrollView *scrollView=(UIScrollView *)subView;
                    [scrollView setScrollEnabled:NO];
                    CGFloat height=[m_CurrentScrollView contentSize].height-1.0+[scrollView contentSize].height;
                    [m_CurrentScrollView setContentSize:CGSizeMake(320, height)];
                    CGRect rect=[webView frame];
                    rect.size.height=[scrollView contentSize].height;
                    [webView setFrame:CGRectMake(15, rect.origin.y, 290, rect.size.height)];
                    break;
                }
            }
        }
        default:
            break;
    }
}

#pragma mark scrollview相关
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int pageIndex=[[NSNumber numberWithFloat:[scrollView contentOffset].x/320.0] intValue];
    if (pageIndex==m_CurrentIndex) {
        return;
    } else {
        [m_CurrentScrollView setContentOffset:CGPointMake(0, 0)];
        m_CurrentIndex=pageIndex;
        if ([m_ScrollView viewWithTag:100+pageIndex]!=nil) {
            m_CurrentScrollView=(UIScrollView *)[m_ScrollView viewWithTag:100+pageIndex];
            
            //底部价格市场价更改
            GrouponVO *grouponVO=[m_Products objectAtIndex:m_CurrentIndex];
            [m_PriceLabel setText:[NSString stringWithFormat:@"￥%.2f",[[grouponVO price] floatValue]]];
            //[m_MarketPriceLabel setText:[NSString stringWithFormat:@"￥%.2f",[[[grouponVO productVO] maketPrice] floatValue]]];
            
            return;
        } else {
            m_CurrentState=THREAD_STATUS_GET_PRODUCT_DETAIL;
            [self setUpThread];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [m_CurrentScrollView setContentOffset:CGPointMake(0, 0)];
    if ([m_ScrollView viewWithTag:100+m_CurrentIndex]!=nil) {
        m_CurrentScrollView=(UIScrollView *)[m_ScrollView viewWithTag:100+m_CurrentIndex];
        
        //底部价格市场价更改
        GrouponVO *grouponVO=[m_Products objectAtIndex:m_CurrentIndex];
        [m_PriceLabel setText:[NSString stringWithFormat:@"￥%.2f",[[grouponVO price] floatValue]]];
       // [m_MarketPriceLabel setText:[NSString stringWithFormat:@"￥%.2f",[[[grouponVO productVO] maketPrice] floatValue]]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GrouponHideLoading" object:nil];
        return;
    } else {
        m_CurrentState=THREAD_STATUS_GET_PRODUCT_DETAIL;
        [self setUpThread];
    }
}

#pragma mark pickerView相关delegate和datasource
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    GrouponVO *grouponVO=[m_Dictionary objectForKey:[[m_Products objectAtIndex:m_CurrentIndex] nid]];
    if (component==0) {
        return [[grouponVO colorList] objectAtIndex:row];
    } else {
        NSString *selectedColor=[[grouponVO colorList] objectAtIndex:m_ColorIndex];
        int i=0;
        for (NSString *sizeStr in [grouponVO sizeList]) {
            for (GrouponSerialVO *serialVO in [grouponVO grouponSerials]) {
                if ([[serialVO productSize] isEqualToString:sizeStr] && [[serialVO productColor] isEqualToString:selectedColor] && [[serialVO upperSaleNum] intValue]>0&&[[serialVO upperSaleNum] intValue]>[[serialVO boughtNum] intValue]) {
                    if (i==row) {
                        return sizeStr;
                    }
                    i++;
                }
            }
        }
        return @"尺码(已售完)";
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    GrouponVO *grouponVO=[m_Dictionary objectForKey:[[m_Products objectAtIndex:m_CurrentIndex] nid]];
    if (component==0) {
        return [[grouponVO colorList] count];
    } else {
        NSString *selectedColor=[[grouponVO colorList] objectAtIndex:m_ColorIndex];
        int i=0;
        for (NSString *sizeStr in [grouponVO sizeList]) {
            for (GrouponSerialVO *serialVO in [grouponVO grouponSerials]) {
                if ([[serialVO productSize] isEqualToString:sizeStr] && [[serialVO productColor] isEqualToString:selectedColor] && [[serialVO upperSaleNum] intValue]>0) {
                    i++;
                }
            }
        }
        if (i==0) {//没有尺码，显示"尺码(已售完)"
            i=1;
        }
        return i;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
	return 140;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UIButton* btn=(UIButton*)[m_ActionSheet viewWithTag:11011];
    GrouponVO *grouponVO=[m_Dictionary objectForKey:[[m_Products objectAtIndex:m_CurrentIndex] nid]];
    if (component==0) {
        m_ColorIndex=row;
        [pickerView selectRow:0 inComponent:1 animated:NO];
        [pickerView reloadComponent:1];
        m_SelCorlor=[[grouponVO colorList] objectAtIndex:row];
        m_SelSize=nil;
        NSString *selectedColor=[[grouponVO colorList] objectAtIndex:row];
        int i=0;
        BOOL hasFind=NO;
        for (NSString *sizeStr in [grouponVO sizeList]) {
            if (hasFind) {
                break;
            }
            for (GrouponSerialVO *serialVO in [grouponVO grouponSerials]) {
                if ([[serialVO productSize] isEqualToString:sizeStr] && [[serialVO productColor] isEqualToString:selectedColor] && [[serialVO upperSaleNum] intValue]>0&&([[serialVO upperSaleNum] intValue]>[[serialVO boughtNum] intValue])) {
                    if (i==0) {
                        m_SelSize=sizeStr;
                        hasFind=YES;
                        break;
                    }
                    i++;
                }
            }
        }
        if (!hasFind) {//没有尺码，默认为"尺码(已售完)"
            m_SelSize=@"尺码(已售完)";
            btn.enabled=NO;
        }else {
            btn.enabled=YES;
        }
    } else {
        NSInteger selectedColorRow=[pickerView selectedRowInComponent:0];
        m_SelCorlor=[[grouponVO colorList] objectAtIndex:selectedColorRow];
        m_SelSize=nil;
        NSString *selectedColor=[[grouponVO colorList] objectAtIndex:selectedColorRow];
        int i=0;
        BOOL hasFind=NO;
        for (NSString *sizeStr in [grouponVO sizeList]) {
            if (hasFind) {
                break;
            }
            for (GrouponSerialVO *serialVO in [grouponVO grouponSerials]) {
                if ([[serialVO productSize] isEqualToString:sizeStr] && [[serialVO productColor] isEqualToString:selectedColor] && [[serialVO upperSaleNum] intValue]>0&&([[serialVO upperSaleNum] intValue]>[[serialVO boughtNum] intValue])) {
                    if (i==row) {
                        m_SelSize=sizeStr;
                        hasFind=YES;
                        break;
                    }
                    i++;
                }
            }
        }
        if (!hasFind) {//没有尺码，默认为"尺码(已售完)"
            m_SelSize=@"尺码(已售完)";
            btn.enabled=NO;
        }else {
            btn.enabled=YES;
        }
    }
}

-(void)newThreadAddGrouponBrowse:(GrouponVO *)groupon
{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    BrowseService *bServ=[[[BrowseService alloc] init] autorelease];
    int rowcount = [bServ queryGrouponBrowseHistoryByIdCount:groupon.nid];
    @try {
        if (rowcount) {
            //存在则更新
            [bServ updateGrouponBrowseHistory:groupon provice:PROVINCE_ID];
            
        }
        else {
            [bServ saveGrouponBrowseHistory:groupon province:PROVINCE_ID];
        }
        [bServ savefkToBrowse:groupon.nid];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefleshImmediately" object:nil];
    [pool drain];
}

#pragma mark -
-(void)releaseMyResoures
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    OTS_SAFE_RELEASE(m_AreaId);
    OTS_SAFE_RELEASE(m_Products);
    OTS_SAFE_RELEASE(m_grouponVO);
    OTS_SAFE_RELEASE(m_ScrollView);
    
    OTS_SAFE_RELEASE(m_Dictionary);
    OTS_SAFE_RELEASE(m_Share);
    OTS_SAFE_RELEASE(m_Timer);
    //OTS_SAFE_RELEASE(m_UserManager);
    OTS_SAFE_RELEASE(m_Service);
    
    // release outlet
    m_DetailWebView.delegate = nil;
    OTS_SAFE_RELEASE(m_DetailWebView);
    
    OTS_SAFE_RELEASE(m_ReturnBtn);
    OTS_SAFE_RELEASE(m_ShareBtn);
    OTS_SAFE_RELEASE(m_PreviousBtn);
    OTS_SAFE_RELEASE(m_NextBtn);
    OTS_SAFE_RELEASE(m_BottomView);
    OTS_SAFE_RELEASE(m_PriceLabel);
    OTS_SAFE_RELEASE(m_MarketPriceLabel);
    OTS_SAFE_RELEASE(m_BuyBtn);
    OTS_SAFE_RELEASE(m_PickerView);
    OTS_SAFE_RELEASE(m_DetailView);
	
    
    // remove vc
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseMyResoures];
}

-(void)dealloc
{
    [self releaseMyResoures];
    [super dealloc];
}
@end
