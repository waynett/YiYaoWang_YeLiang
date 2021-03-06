//
//  CartCell.m
//  TheStoreApp
//
//  Created by yuan jun on 12-10-25.
//
//

#import "CartCell.h"
#import "DataController.h"
#import "SDImageView+SDWebCache.h"
@implementation CartCell
@synthesize priceLab,mountBtn,tittleLabel,productIcon,giftLabel,shakeLabel,giftlog,productId,promotionLab,promotionCountLab,priceHeadLabel,separateLine,NNArrow,pointLab,seckillLab;
-(void)dealloc{
    [productId release];
    [promotionCountLab release];
    [promotionLab release];
    [giftlog release];
    [shakeLabel release];
    [seckillLab release];
    [giftLabel release];
    [priceLab release];
    [tittleLabel release];
    [mountBtn release];
    [productIcon release];
    OTS_SAFE_RELEASE(priceHeadLabel);
    OTS_SAFE_RELEASE(separateLine);
    OTS_SAFE_RELEASE(NNArrow);
    OTS_SAFE_RELEASE(pointLab);
    [super dealloc];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        productIcon=[[OTSImageView alloc] initWithFrame:CGRectMake(11, 10, 60, 60)];
        [self.contentView addSubview:productIcon];
        
        shakeLabel=[[UILabel alloc] initWithFrame:CGRectMake(21, 75, 38, 16)];
        shakeLabel.text=@"1起摇";
        shakeLabel.adjustsFontSizeToFitWidth=YES;
        shakeLabel.font=[UIFont systemFontOfSize:14];
        shakeLabel.textColor=[UIColor whiteColor];
        shakeLabel.textAlignment=NSTextAlignmentCenter;
        shakeLabel.backgroundColor=[UIColor colorWithRed:0.898 green:0.325 blue:0.01 alpha:0.8];
        [self.contentView addSubview:shakeLabel];
        shakeLabel.hidden=YES;
        
        seckillLab=[[UILabel alloc] initWithFrame:CGRectMake(21, 75, 38, 16)];
        seckillLab.text=@"秒杀";
        seckillLab.adjustsFontSizeToFitWidth=YES;
        seckillLab.font=[UIFont systemFontOfSize:14];
        seckillLab.textColor=[UIColor whiteColor];
        seckillLab.textAlignment=NSTextAlignmentCenter;
        seckillLab.backgroundColor=[UIColor colorWithRed:0.686 green:0.078 blue:0.01 alpha:1];
        [self.contentView addSubview:seckillLab];
        seckillLab.hidden=YES;
        
        promotionLab=[[UILabel alloc] initWithFrame:CGRectMake(21, 75, 38, 16)];
        promotionLab.text=@"换购";
        promotionLab.adjustsFontSizeToFitWidth=YES;
        promotionLab.font=[UIFont systemFontOfSize:14];
        promotionLab.textColor=[UIColor whiteColor];
        promotionLab.textAlignment=NSTextAlignmentCenter;
        promotionLab.backgroundColor=[UIColor colorWithRed:0.863 green:0.408 blue:0.01 alpha:0.8];
        [self.contentView addSubview:promotionLab];

        giftLabel=[[UILabel alloc] initWithFrame:CGRectMake(21, 75, 38, 16)];
        giftLabel.text=@"赠品";
        giftLabel.adjustsFontSizeToFitWidth=YES;
        giftLabel.font=[UIFont systemFontOfSize:14];
        giftLabel.textColor=[UIColor whiteColor];
        giftLabel.textAlignment=NSTextAlignmentCenter;
        giftLabel.backgroundColor=[UIColor colorWithRed:0.686 green:0.078 blue:0.01 alpha:1];
        [self.contentView addSubview:giftLabel];
        
        tittleLabel=[[UILabel alloc] initWithFrame:CGRectMake(80, 5, 200, 40)];
        tittleLabel.font=[UIFont systemFontOfSize:15];
        tittleLabel.textColor=[UIColor blackColor];
        tittleLabel.numberOfLines=2;
        tittleLabel.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:tittleLabel];
        
        UILabel* mount=[[UILabel alloc] initWithFrame:CGRectMake(80, 60, 32, 21)];
        mount.text=@"数量";
        mount.backgroundColor=[UIColor clearColor];
        mount.font=[UIFont systemFontOfSize:15];
        [self.contentView addSubview:mount];
        [mount release];
        
        promotionCountLab=[[UILabel alloc] initWithFrame:CGRectMake(113, 55, 56, 31)];
        promotionCountLab.backgroundColor=[UIColor clearColor];
        promotionCountLab.font=[UIFont boldSystemFontOfSize:15];
        promotionCountLab.textColor=[UIColor blackColor];
        promotionCountLab.textAlignment=NSTextAlignmentCenter;
        [self.contentView addSubview:promotionCountLab];
        promotionCountLab.hidden=YES;
        
        mountBtn=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
        mountBtn.frame=CGRectMake(113, 55, 56, 31);
        [mountBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        mountBtn.titleLabel.font=[UIFont boldSystemFontOfSize:15];
        mountBtn.titleLabel.shadowColor=[UIColor grayColor];
        [mountBtn setBackgroundImage:[UIImage imageNamed:@"cart_number.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:mountBtn];
        
        priceHeadLabel=[[UILabel alloc] initWithFrame:CGRectMake(174, 60, 50, 21)];
        priceHeadLabel.text=@"单价：";
        priceHeadLabel.tag=10002;
        priceHeadLabel.font=[UIFont systemFontOfSize:15];
        priceHeadLabel.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:priceHeadLabel];
        [priceHeadLabel release];
        
        priceLab=[[UILabel alloc] initWithFrame:CGRectMake(214, 60, 90, 21)];
        priceLab.textColor=[UIColor colorWithRed:0.686 green:0.078 blue:0.01 alpha:1];
        priceLab.font=[UIFont systemFontOfSize:15];
        priceLab.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:priceLab];
        
        pointLab=[[UILabel alloc] initWithFrame:CGRectMake(214, 80, 90, 20)];
        pointLab.font=[UIFont systemFontOfSize:15];
        [pointLab setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:pointLab];
        
        self.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        giftlog=[[UIImageView alloc] initWithFrame:CGRectMake(320-32, 0, 32, 32)];
        giftlog.image=[UIImage imageNamed:@"giftLog.png"];
//        [self.contentView addSubview:giftlog];
        
        UIView* cover=[[UIView alloc] initWithFrame:CGRectMake(113, 60, 56, 31)];
        cover.backgroundColor=[UIColor blackColor];
        cover.alpha=0.2;
        cover.tag=1001;
        [self.contentView addSubview:cover];
        [cover release];
        cover.hidden=YES;
        
        separateLine = [[UIView alloc]initWithFrame:CGRectMake(0, 101.0, self.frame.size.width, 1)];
        //[separateLine setBackgroundColor:[UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0]];
        [separateLine setBackgroundColor:[UIColor lightGrayColor]];
        [separateLine setAlpha:0.3];
        [self.contentView  addSubview:separateLine];
        
        NNArrow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 92.0, self.frame.size.width, 10)];
        [NNArrow setBackgroundColor:[UIColor clearColor]];
        [self.contentView  addSubview:NNArrow];
    }
    return self;
}
-(void)isGiftCell{
    mountBtn.hidden=YES;
    promotionCountLab.hidden=NO;
    giftlog.hidden=YES;
    self.accessoryType=UITableViewCellAccessoryNone;
    self.userInteractionEnabled=NO;
}
- (void)isRockBuy{
    shakeLabel.hidden=NO;
}
- (void)hasGift{
    giftlog.hidden=NO;
    mountBtn.hidden=NO;
    promotionCountLab.hidden=YES;
}
-(void)isPromotionCell{
    mountBtn.hidden=YES;
    promotionCountLab.hidden=NO;
}
- (void)downloadProductIcon:(NSString*)iconUrl{
    [productIcon loadImgUrl:iconUrl];
}

- (void)addcover{
    UIView* v=[self.contentView viewWithTag:1001];
    v.hidden=NO;
}
- (void)editingStatus:(BOOL)editing{
    UILabel* l=(UILabel*)[self.contentView viewWithTag:10002];
    if (!editing) {
        [l setFrame:CGRectMake(174, 65, 50, 21)];
        [priceLab setFrame:CGRectMake(214, 65, 90, 21)];
    } else {
        [l setFrame:CGRectMake(204, 65, 50, 21)];
        [priceLab setFrame:CGRectMake(244, 65, 90, 21)];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
