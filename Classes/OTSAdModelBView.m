//
//  OTSAdModelBView.m
//  TheStoreApp
//
//  Created by jiming huang on 12-7-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define TABLEVIEW_MARGIN    14

#import "OTSAdModelBView.h"
#import "AdvertisingPromotionVO.h"
#import "OTSUtility.h"
#import "HotPointNewVO.h"
#import "DataController.h"
#import "GrouponVO.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+MD5Addition.h"
#import "SDImageView+SDWebCache.h"
#import "OTSImageView.h"
@implementation OTSAdModelBView

-(id)initWithFrame:(CGRect)frame delegate:(id)delegate tag:(int)tag
{
    self=[super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_IsFold=YES;
        m_Delegate=delegate;
        [self setTag:tag];
        [self setBackgroundColor:[UIColor clearColor]];
        [self reloadModelBView];
    }
    return self;
}

-(void)reloadModelBView
{
    //获取VO
    if ([m_Delegate respondsToSelector:@selector(adModelBViewData:)]) {
        if (m_AdVO!=nil) {
            [m_AdVO release];
        }
        m_AdVO=[[m_Delegate adModelBViewData:self] retain];
    } else {
        return;
    }
    
    //高度
    CGFloat height;
    if (m_IsFold) {//折叠状态
        height=80.0;
    } else if ([[m_AdVO hotPointNewVOList] count]>1) {
        HotPointNewVO *hotPointVO=[OTSUtility safeObjectAtIndex:1 inArray:[m_AdVO hotPointNewVOList]];
        if (hotPointVO.grouponVOList!=nil || hotPointVO.productVOList!=nil) {
            height=320.0+44.0*([[m_AdVO hotPointNewVOList] count]-2);
        } else {
            height=155.0+44.0*([[m_AdVO hotPointNewVOList] count]-2);
        }
    } else {
        height=155.0;
    }
    
    //table view
    m_TableView=[[UITableView alloc] initWithFrame:CGRectMake(TABLEVIEW_MARGIN, 0, 292, height-25) style:UITableViewStylePlain];
    [m_TableView.layer setBorderWidth:1.0];
    [m_TableView.layer setBorderColor:[[UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0] CGColor]];
    [m_TableView setBackgroundColor:[UIColor colorWithRed:251.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1.0]];
    [m_TableView setScrollsToTop:NO];
    if (m_IsFold) {
        [m_TableView setScrollEnabled:NO];
    } else {
        [m_TableView setScrollEnabled:YES];
    }
    [m_TableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [m_TableView setDelegate:self];
    [m_TableView setDataSource:self];
    [self addSubview:m_TableView];
    
    //底部图片
    m_BottomImageView=[[UIImageView alloc] initWithFrame:CGRectMake(TABLEVIEW_MARGIN, height-26, 292, 26)];
    [m_BottomImageView setImage:[UIImage imageNamed:@"tempC_bottom.png"]];
    [self addSubview:m_BottomImageView];
    //箭头
    m_ArrayImageView=[[UIImageView alloc] initWithFrame:CGRectMake(245, 9, 13, 8)];
    [m_ArrayImageView setImage:[UIImage imageNamed:@"tempC_down.png"]];
    [m_BottomImageView addSubview:m_ArrayImageView];
    
    //展开折叠按钮
    m_FoldButton=[[UIButton alloc] initWithFrame:CGRectMake(TABLEVIEW_MARGIN+230, height-26, 43, 26)];
    [m_FoldButton addTarget:self action:@selector(foldBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:m_FoldButton];
    
    m_BigFoldButton=[[UIButton alloc] initWithFrame:CGRectMake(TABLEVIEW_MARGIN, height-26, 292, 12)];
    [m_BigFoldButton addTarget:self action:@selector(foldBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:m_BigFoldButton];
    if (m_IsFold) {
        [m_BigFoldButton setHidden:NO];
    } else {
        [m_BigFoldButton setHidden:YES];
    }
}

//展开/折叠按钮
-(void)foldBtnClicked:(id)sender
{
    if ([m_Delegate respondsToSelector:@selector(adModelBView:foldBtnClicked:)]) {
        [m_Delegate adModelBView:self foldBtnClicked:sender];
    }
}

//点击大图
-(void)bigImageBtnClicked:(id)sender
{
    HotPointNewVO *hotPointVO=[OTSUtility safeObjectAtIndex:1 inArray:[m_AdVO hotPointNewVOList]];
    if ([hotPointVO grouponVOList]!=nil) {//团购商品列表
        GrouponVO *firstGrouponVO=[OTSUtility safeObjectAtIndex:0 inArray:[hotPointVO grouponVOList]];
        GrouponVO *secondGrouponVO=[OTSUtility safeObjectAtIndex:1 inArray:[hotPointVO grouponVOList]];
        UIButton *button=sender;
        if ([button tag]==1) {
            if ([m_Delegate respondsToSelector:@selector(adModelBView:enterGrouponDetail:)]) {
                [m_Delegate adModelBView:self enterGrouponDetail:firstGrouponVO];
            }
        } else if ([button tag]==2) {
            if ([m_Delegate respondsToSelector:@selector(adModelBView:enterGrouponDetail:)]) {
                [m_Delegate adModelBView:self enterGrouponDetail:secondGrouponVO];
            }
        }
    } else if ([hotPointVO productVOList]!=nil) {
        ProductVO *firstProVO=[OTSUtility safeObjectAtIndex:0 inArray:[hotPointVO productVOList]];
        ProductVO *secondProVO=[OTSUtility safeObjectAtIndex:1 inArray:[hotPointVO productVOList]];
        UIButton *button=sender;
        if ([button tag]==1) {
            if ([m_Delegate respondsToSelector:@selector(adModelBView:enterProductDetail:)]) {
                [m_Delegate adModelBView:self enterProductDetail:firstProVO];
            }
        } else if ([button tag]==2) {
            if ([m_Delegate respondsToSelector:@selector(adModelBView:enterProductDetail:)]) {
                [m_Delegate adModelBView:self enterProductDetail:secondProVO];
            }
        }
    } else {
    }
}

//关键字按钮
-(void)keyWordBtnClicked:(id)sender
{
    if ([m_Delegate respondsToSelector:@selector(adModelBView:keyWordBtnClicked:)]) {
        [m_Delegate adModelBView:self keyWordBtnClicked:sender];
    }
}

-(BOOL)isFold
{
    return m_IsFold;
}

-(void)setIsFold:(BOOL)isFold
{
    m_IsFold=isFold;
    //高度
    CGFloat height;
    if (m_IsFold) {//折叠状态
        height=80.0;
    } else if ([[m_AdVO hotPointNewVOList] count]>1) {
        HotPointNewVO *hotPointVO=[OTSUtility safeObjectAtIndex:1 inArray:[m_AdVO hotPointNewVOList]];
        if (hotPointVO.grouponVOList!=nil || hotPointVO.productVOList!=nil) {
            height=320.0+44.0*([[m_AdVO hotPointNewVOList] count]-2);
        } else {
            height=155.0+44.0*([[m_AdVO hotPointNewVOList] count]-2);
        }
    } else {
        height=155.0;
    }
    [m_TableView setFrame:CGRectMake(TABLEVIEW_MARGIN, 0, 292, height-25)];
    [m_BottomImageView setFrame:CGRectMake(TABLEVIEW_MARGIN, height-26, 292, 26)];
    [m_FoldButton setFrame:CGRectMake(TABLEVIEW_MARGIN+230, height-26, 43, 26)];
    if (m_IsFold) {
        [m_ArrayImageView setImage:[UIImage imageNamed:@"tempC_down.png"]];
        [m_TableView setBackgroundColor:[UIColor colorWithRed:251.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1.0]];
        [m_BottomImageView setImage:[UIImage imageNamed:@"tempC_bottom.png"]];
        [m_BigFoldButton setHidden:NO];
        [m_TableView setScrollEnabled:NO];
    } else {
        [m_ArrayImageView setImage:[UIImage imageNamed:@"tempC_up.png"]];
        [m_TableView setBackgroundColor:[UIColor whiteColor]];
        [m_BottomImageView setImage:[UIImage imageNamed:@"tempC_bottom_white.png"]];
        [m_BigFoldButton setHidden:YES];
        [m_TableView setScrollEnabled:YES];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)tapImage:(UITapGestureRecognizer *)gest{
    UIView*v=[gest view];
    UIButton*tempBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    if (v.tag==1001) {
        tempBtn.tag=1;
    }else{
        tempBtn.tag=2;
    }
    [self bigImageBtnClicked:tempBtn];
}
#pragma mark tableView的datasource和delegate
-(void)tableView:(UITableView * )tableView didSelectRowAtIndexPath:(NSIndexPath * )indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//取消选中颜色
    if ([indexPath row]==0) {
        //展开/折叠
        if ([m_Delegate respondsToSelector:@selector(adModelBView:foldBtnClicked:)]) {
            [m_Delegate adModelBView:self foldBtnClicked:nil];
        }
    } else if ([indexPath row]==1) {
    } else if ([indexPath row]==[[m_AdVO hotPointNewVOList] count]) {
    } else {
        if ([m_Delegate respondsToSelector:@selector(adModelBView:didSelectRowAtIndexPath:)]) {
            [m_Delegate adModelBView:self didSelectRowAtIndexPath:indexPath];
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[m_AdVO hotPointNewVOList] count]+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
    [cell setBackgroundColor:[UIColor colorWithRed:251.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1.0]];
    if ([indexPath row]==0) {
        HotPointNewVO *hotPointVO=[OTSUtility safeObjectAtIndex:0 inArray:[m_AdVO hotPointNewVOList]];
        //小图
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, 19, 30, 30)];
        [imageView setImageWithURL:[NSURL URLWithString:[hotPointVO logoPicUrl]] refreshCache:NO placeholderImage:[UIImage imageNamed:@"defaultimg55.png"]];
        [cell addSubview:imageView];
        [imageView release];
        //名称
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(50, 19, 230, 30)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:[hotPointVO title]];
        [label setFont:[UIFont systemFontOfSize:15.0]];
        [cell addSubview:label];
        [label release];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    else if ([indexPath row]==[[m_AdVO hotPointNewVOList] count]) {
        //关键字
        NSMutableArray *keywordImgArray=[[NSMutableArray alloc] initWithObjects:@"tempC_First.png", @"tempC_Second.png", @"tempC_Third.png", @"tempC_Fourth.png", nil];
        CGFloat xValue=11.0;
        int i;
        for (i=0; i<4; i++) {
            NSString *keyword=[OTSUtility safeObjectAtIndex:i inArray:[m_AdVO keywordList]];
            UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(xValue, 15, 60, 36)];
            [button setTitle:keyword forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [[button titleLabel] setFont:[UIFont systemFontOfSize:15.0]];
            NSString *imageName=[OTSUtility safeObjectAtIndex:i inArray:keywordImgArray];
            [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(keyWordBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            [button release];
            xValue+=68.0;
        }
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    else if ([indexPath row]==1) {
        HotPointNewVO *hotPointVO=[OTSUtility safeObjectAtIndex:1 inArray:[m_AdVO hotPointNewVOList]];
        if (hotPointVO.grouponVOList==nil && hotPointVO.productVOList==nil) {
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.accessoryType=UITableViewCellAccessoryNone;
            return cell;
        }
        NSString *firstImageUrl = nil;
        NSString *firstName;
        NSString *firstPrice;
        NSString *secondImageUrl = nil;
        NSString *secondName;
        NSString *secondPrice;
        if ([hotPointVO grouponVOList]!=nil) {//团购商品列表
            GrouponVO *firstGrouponVO=[OTSUtility safeObjectAtIndex:0 inArray:[hotPointVO grouponVOList]];
            if (firstGrouponVO!=nil) {
                firstImageUrl=[firstGrouponVO miniImageUrl];
                firstName=[firstGrouponVO name];
                firstPrice=[NSString stringWithFormat:@"￥%.2f",[[firstGrouponVO price] doubleValue]];
            } else {
                firstImageUrl=nil;
                firstName=nil;
                firstPrice=nil;
            }
            
            GrouponVO *secondGrouponVO=[OTSUtility safeObjectAtIndex:1 inArray:[hotPointVO grouponVOList]];
            if (secondGrouponVO!=nil) {
                secondImageUrl=[secondGrouponVO miniImageUrl];
                secondName=[secondGrouponVO name];
                secondPrice=[NSString stringWithFormat:@"￥%.2f",[[secondGrouponVO price] doubleValue]];
            } else {
                secondImageUrl=nil;
                secondName=nil;
                secondPrice=nil;
            }
        }
        else if ([hotPointVO productVOList]!=nil) {
            ProductVO *firstProVO=[OTSUtility safeObjectAtIndex:0 inArray:[hotPointVO productVOList]];
            if (firstProVO!=nil) {
                firstImageUrl=[firstProVO midleDefaultProductUrl];
                firstName=[firstProVO cnName];
                firstPrice=[NSString stringWithFormat:@"￥%.2f",[[firstProVO price] doubleValue]];
            } else {
                firstImageUrl=nil;
                firstName=nil;
                firstPrice=nil;
            }
            
            ProductVO *secondProVO=[OTSUtility safeObjectAtIndex:1 inArray:[hotPointVO productVOList]];
            if (secondProVO!=nil) {
                secondImageUrl=[secondProVO midleDefaultProductUrl];
                secondName=[secondProVO cnName];
                secondPrice=[NSString stringWithFormat:@"￥%.2f",[[secondProVO price] doubleValue]];
            } else {
                secondImageUrl=nil;
                secondName=nil;
                secondPrice=nil;
            }
        }
        else {
//            firstImage=[UIImage imageNamed:@"defaultimg85.png"];
            firstName=@"";
            firstPrice=@"￥0.00";
//            secondImage=[UIImage imageNamed:@"defaultimg85.png"];
            secondName=@"";
            secondPrice=@"￥0.00";
        }
        
        //第一个商品
        if (firstImageUrl!=nil) {
            //图片
            //商品名称
            UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(7, 110, 124, 20)];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[UIFont systemFontOfSize:15.0]];
            [label setText:firstName];
            [cell addSubview:label];
            [label release];
            //商品价格
            label=[[UILabel alloc] initWithFrame:CGRectMake(7, 132, 124, 20)];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setTextColor:[UIColor colorWithRed:204.0/255.0 green:0.0 blue:0.0 alpha:1.0]];
            [label setFont:[UIFont systemFontOfSize:15.0]];
            [label setText:firstPrice];
            [cell addSubview:label];
            [label release];
            
            UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(19, 10, 90, 150)];
            [button setTag:1];
            [button addTarget:self action:@selector(bigImageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            [button release];
            
            OTSImageView*firstImg=[[OTSImageView alloc] initWithFrame:CGRectMake(19, 10, 100, 100)];
            firstImg.tag=1001;
            UITapGestureRecognizer* gest=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
            [firstImg addGestureRecognizer:gest];
            firstImg.userInteractionEnabled=YES;
            [firstImg loadImgUrl:firstImageUrl];
            [cell addSubview:firstImg];
            [gest release];
            [firstImg release];
        }
        
        //第2个商品
        if (secondImageUrl!=nil) {
            //图片
            //商品名称
            UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(159, 110, 124, 20)];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[UIFont systemFontOfSize:15.0]];
            [label setText:secondName];
            [cell addSubview:label];
            [label release];
            //商品价格
            label=[[UILabel alloc] initWithFrame:CGRectMake(159, 132, 124, 20)];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setTextColor:[UIColor colorWithRed:204.0/255.0 green:0.0 blue:0.0 alpha:1.0]];
            [label setFont:[UIFont systemFontOfSize:15.0]];
            [label setText:secondPrice];
            [cell addSubview:label];
            [label release];
            
            UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(176, 15, 90, 150)];
            [button setTag:2];
            [button addTarget:self action:@selector(bigImageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            [button release];
            
            OTSImageView*secondImg=[[OTSImageView alloc] initWithFrame:CGRectMake(171, 10, 100, 100)];
            [secondImg loadImgUrl:secondImageUrl];
            secondImg.tag=1002;
            UITapGestureRecognizer* gest=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
            [secondImg addGestureRecognizer:gest];
            secondImg.userInteractionEnabled=YES;
            [cell addSubview:secondImg];
            [secondImg release];
            [gest release];
        }
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.accessoryType=UITableViewCellAccessoryNone;
    } else {
        HotPointNewVO *hotPointVO=[OTSUtility safeObjectAtIndex:[indexPath row] inArray:[m_AdVO hotPointNewVOList]];
        //名称
        [[cell textLabel] setText:[hotPointVO title]];
        [[cell textLabel] setFont:[UIFont systemFontOfSize:15.0]];
        
        cell.selectionStyle=UITableViewCellSelectionStyleBlue;
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //虚线
    CGFloat yValue;
    if ([indexPath row]==0) {
        yValue=65.0;
    } else if ([indexPath row]==1) {
        yValue=165.0;
    } else if ([indexPath row]==[[m_AdVO hotPointNewVOList] count]) {
        yValue=65.0;
    } else {
        yValue=44.0;
    }
    UIImageView *line=[[UIImageView alloc] initWithFrame:CGRectMake(1, yValue-1, 290, 1)];
    [line setImage:[UIImage imageNamed:@"dot_line.png"]];
    [cell addSubview:line];
    [line release];
    
	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row]==0) {
        return 65.0;
    } else if ([indexPath row]==[[m_AdVO hotPointNewVOList] count]) {
        return 65.0;
    } else if ([indexPath row]==1) {
        HotPointNewVO *hotPointVO=[OTSUtility safeObjectAtIndex:1 inArray:[m_AdVO hotPointNewVOList]];
        if (hotPointVO.grouponVOList!=nil || hotPointVO.productVOList!=nil) {
            return 165.0;
        } else {
            return 0.0;
        }
    } else {
        return 44.0;
    }
}

-(void)dealloc
{
    OTS_SAFE_RELEASE(m_AdVO);
    OTS_SAFE_RELEASE(m_TableView);
    OTS_SAFE_RELEASE(m_BottomImageView);
    OTS_SAFE_RELEASE(m_FoldButton);
    OTS_SAFE_RELEASE(m_BigFoldButton);
    OTS_SAFE_RELEASE(m_ArrayImageView);
    [super dealloc];
}

@end
