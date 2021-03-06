//
//  HomePageModelACell.m
//  TheStoreApp
//
//  Created by yuan jun on 13-1-15.
//
//

#import "HomePageModelACell.h"
#import "SDImageView+SDWebCache.h"
#import "OTSUtility.h"
#define barHeight 40
#define cellHeight 250
#define advHeight 160
#define cellWidth   320
@implementation HomePageModelACell
-(void)dealloc{
    [keywordsArray release];
    [adBg release];
    [promotionImg release];
    [bigImg release];
    [super dealloc];
}

@synthesize delegate;
@synthesize keywordsArray;
@synthesize isLeft;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        adBg=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, advHeight)];
        adBg.userInteractionEnabled=YES;
        [self.contentView addSubview:adBg];
        
        //大图的图片 文字
        if (!isLeft) {
            bigImg=[[UIImageView alloc] initWithFrame:CGRectMake(160, 0, advHeight-2, advHeight)];
            bigImg.backgroundColor = [UIColor yellowColor];
            bigImg.userInteractionEnabled=YES;
            [adBg addSubview:bigImg];
        }
        else{
            bigImg=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, advHeight-2, advHeight)];
            bigImg.backgroundColor = [UIColor yellowColor];
            bigImg.userInteractionEnabled=YES;
            [adBg addSubview:bigImg];
        }
        
        
        UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(promotionTap:)];
        bigImg.tag=0;
        [bigImg addGestureRecognizer:tap];
        [tap release];
        
        promotionImg=[[UIView alloc] initWithFrame:CGRectMake(160, 0, advHeight, advHeight)];
        
        UIColor *lineColor=[UIColor colorWithRed:(175.0/255.0) green:(175.0/255.0) blue:(175.0/255.0) alpha:1];
        
        [adBg addSubview:promotionImg];
        UIView* line=[[UIView alloc] initWithFrame:CGRectMake(0, 161, 320, 0.5)];
        line.backgroundColor=lineColor;
        [adBg addSubview:line];
        [line release];
        
        UIView*verline=[[UIView alloc] initWithFrame:CGRectMake(160, 0, 0.5, 161)];
        verline.backgroundColor=lineColor;
        [adBg addSubview:verline];
        [verline release];
        
        UIImageView *headBigView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 120, 30)];
        headBigView.backgroundColor = [UIColor colorWithRed:92.0/255.0 green:177.0/255.0 blue:238.0/255.0 alpha:1.0];
        [promotionImg addSubview:headBigView];
        
        UIImageView *headVoView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 5, 20, 30)];
        headVoView.image = [UIImage imageNamed:@"rightV.png"];
        [promotionImg addSubview:headVoView];
        
        headBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 140, 30)];
        [headBtn addTarget:self action:@selector(headAction:) forControlEvents:UIControlEventTouchUpInside];
        [promotionImg addSubview:headBtn];
        
    }
    return self;
}

-(IBAction)headAction:(id)sender{
    [delegate pushHeadBtn:self];

}

-(void)promotionTap:(id)sender{
    int tag;
    UITapGestureRecognizer* ges=(UITapGestureRecognizer*)sender;
    tag=[ges view].tag;
    [delegate promotionTapcell:self withIdenty:tag];
}

- (void)freshCell:(int)tag style:(int)style title:(NSString*)title{
//    //分颜色
//    
//    NSString* btStr=[NSString stringWithFormat:@"modelkeyword%d",tag % 3];
//    
//    UIColor* titColor=nil;
//    if (tag==0) {
//        titColor=[UIColor colorWithRed:(170.0/255.0) green:(53.0/255.0) blue:(1.0/255.0) alpha:1];
//    }else if(tag==1){
//        titColor=[UIColor colorWithRed:(90.0/255.0) green:(101.0/255.0) blue:(1.0/255.0) alpha:1];
//        
//        btStr=@"modelkeyword2.png";
//    }else if(tag==2){
//        titColor=[UIColor colorWithRed:(38.0/255.0) green:(61.0/255.0) blue:(102.0/255.0) alpha:1];
//        btStr=@"modelkeyword1.png";
//    }
//    if (title!=nil&&[title isKindOfClass:[NSString class]]&&title.length>0) {
//        advTitle.text=title;
//    }
//    
//    for (int i=0; i<keywordsArray.count; i++)
//    {
//        UIButton* but=[UIButton buttonWithType:UIButtonTypeCustom];
//        but.titleLabel.font=[UIFont systemFontOfSize:14];
//        but.frame=CGRectMake(160+7+(65+15)*(i%2), 40+((i/2)*25)+12, 65, 25);
//        [self.contentView addSubview:but];
//        /*不从keywordBtns数组拿btn，现在时动态根据keywordsArray来获取*/
//        //        UIButton*bt=[OTSUtility safeObjectAtIndex:i inArray:keywordBtns];
//        UIButton*bt = but;
//        [but release];
//        NSString* keyword=[OTSUtility safeObjectAtIndex:i inArray:keywordsArray];
//        [bt setBackgroundImage:[UIImage imageNamed:btStr] forState:UIControlStateNormal];
//        [bt setTitle:keyword forState:UIControlStateNormal];
//        bt.titleLabel.textColor  = [UIColor blackColor];
//        [bt addTarget:self action:@selector(keywordClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    if(style==1)
//    {
//        //左大图
//        promotionImg.frame=CGRectMake(advHeight, 0, advHeight, advHeight);
//        bigImg.frame=CGRectMake(0, 0, advHeight-2, advHeight);
//    }
//    else if(style==2)
//    {
//        promotionImg.frame=CGRectMake(0, 0, advHeight, advHeight);
//        bigImg.frame=CGRectMake(advHeight+2, 0, advHeight-2, advHeight);
//    }
}


-(void)loadBigImg:(NSString*)bigImgStr title:(NSString*)title subTitle:(NSString*)subtit{
    [bigImg setImageWithURL:[NSURL URLWithString:bigImgStr] refreshCache:NO ];
}
-(void)loadFistImg:(NSString*)firstImgStr title:(NSString*)title subTitle:(NSString*)subtit{
//     [firstImg setImageWithURL:[NSURL URLWithString:firstImgStr] refreshCache:NO];
    //    if (title!=nil&&[title isKindOfClass:[NSString class]]&&title.length>0) {
    ////        firstTit.text=title;
    //    }else{
    //        firstTit.text=@"";
    //    }
    //    if (subtit!=nil&&[subtit isKindOfClass:[NSString class]]&&subtit.length>0) {
    //        firstSubTit.text=subtit;
    //    }else{
    //        firstSubTit.text=@"";
    //    }
}

-(void)loadsecondImg:(NSString*)secondImgStr title:(NSString*)title subTitle:(NSString*)subtit{
    //    [secImg setImageWithURL:[NSURL URLWithString:secondImgStr] refreshCache:NO];
    //    if (title!=nil&&[title isKindOfClass:[NSString class]]&&title.length>0) {
    ////        secTit.text=title;
    //    }else{
    //        secTit.text=@"";
    //    }
    //    if (subtit!=nil&&[subtit isKindOfClass:[NSString class]]&&subtit.length>0) {
    //        secSubTit.text=subtit;
    //    }else{
    //        secSubTit.text=@"";
    //    }
}

-(void)keywordClick:(id)sender{
    if (delegate!=nil) {
        [delegate keywordBtnSelceted:sender type:self.tag];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - 加载楼层的各个方法
-(void)loadBtn:(AdFloorInfo *)floor{
    float btnEndY = 40.0;
    float btnEndX = 10;
    NSArray *proArr = floor.productList;
    for (int i=0; i<proArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [btn.layer setMasksToBounds:YES];//在设置了背景图片或颜色情况下，这里这是为YES，才能显示圆角
//        [btn.layer setCornerRadius:10.0];//设置矩形四个圆角半径
        btn.backgroundColor = [UIColor yellowColor];
        
        SpecialRecommendInfo *specialInfo = [proArr objectAtIndex:i];
        NSString *tempStr = specialInfo.title;
        
        //高度固定不折行，根据字的多少计算btn的宽度
        btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        CGSize size = [tempStr sizeWithFont:btn.titleLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, 40.0)];
        if (size.width+15.0+btnEndX>160.0) {
            btnEndY +=25.0;
            btnEndX = 10;
        }
        btn.Frame = CGRectMake(btnEndX, btnEndY, size.width+15.0, 20);
        btnEndX += size.width+15.0+10;
        btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [btn setTitle:tempStr forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
//        NSString *content = specialInfo.content;
//        int catalogId = [[content substringFromIndex:10] intValue];
        btn.tag = i;
        
        [btn addTarget:self action:@selector(pushToProducts:) forControlEvents:UIControlEventTouchUpInside];
        
        [promotionImg addSubview:btn];
    }
}

-(IBAction)pushToProducts:(id)sender{
    UIButton *btn = [[UIButton alloc] init];
    btn = sender;
    int tag = btn.tag;
    [delegate pushSmallBtn:self withIdent:tag];
}

-(void)loadHeadBtn:(AdFloorInfo *)floor{
    NSDictionary *product = floor.head;
    NSString *strHead = [product objectForKey:@"title"];
    [headBtn setTitle:strHead forState:UIControlStateNormal];
}

@end
