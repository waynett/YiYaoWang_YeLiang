//
//  CategorySecondAndThirdViewController.m
//  TheStoreApp
//
//  Created by YaoWang on 14-4-30.
//
//

#import "CategorySecondAndThirdViewController.h"
#import "Page.h"
#import "GlobalValue.h"
#import "ProductService.h"
#import "CategoryVO.h"
#import "CategoryProductsViewController.h"
#import "OTSAlertView.h"
#import "OTSViewControllerManager.h"
#import "TheStoreAppAppDelegate.h"
#import "DoTracking.h"
#import "YWProductService.h"
#import "CategoryInfo.h"
#import "GlobalValue.h"

#define SHOWALLPRODUCT @"查看全部"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface CategorySecondAndThirdViewController ()
@property(nonatomic, retain)NSMutableDictionary* cachedCategoryDic;
@end

@implementation CategorySecondAndThirdViewController
@synthesize categoryId;
@synthesize titleText;
@synthesize cateLevel;
@synthesize cachedCategoryDic;
- (void)dealloc{
    DebugLog(@"categoryVc Dealloc");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    OTS_SAFE_RELEASE(categoryId);
    OTS_SAFE_RELEASE(cateLevel);
    OTS_SAFE_RELEASE(titleText);
    OTS_SAFE_RELEASE(categoryArray);
    OTS_SAFE_RELEASE(cachedCategoryDic);
    
    _errorAlert.delegate = nil;
    [_errorAlert release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isComeSecond = YES;
    [self initSelf];
    [self initViews];
    [self refreshCategory];
}

- (void)initSelf
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(provinceChanged:) name:@"ProvinceChanged" object:nil];
    categoryArray=[[NSMutableArray alloc] init];
    DebugLog(@"%@",cateLevel);
}

-(void)provinceChanged:(NSNotification *)notification{
    if (![cateLevel intValue])
    {
        [self enterTopCategory:YES];
    }
}

-(void)enterTopCategory:(BOOL)inCategory{
    NSMutableArray* controllers=[OTSViewControllerManager sharedInstance].controllers;
    DebugLog(@"%@",controllers);
    for (int i=0;i<controllers.count;i++)
    {
        OTSBaseViewController* vc=[controllers objectAtIndex:i];
        if ([vc isKindOfClass:[self class]])
        {
            CategorySecondAndThirdViewController *cateVc=(CategorySecondAndThirdViewController*)vc;
            if ([cateVc.cateLevel intValue])
            {
                [cateVc.view removeFromSuperview];
                //发现如果这里使用popSelfAnimated，就会立马释放，产生崩溃，移出视图的view，等待切换视图后自动释放
            }
        }
        if ([vc isKindOfClass:[CategoryProductsViewController class]])
        {
            [vc.view removeFromSuperview];
        }
    }
    DebugLog(@"%@",controllers);
}


-(void)refreshCategory{
    //    [categoryArray removeAllObjects];
    [self showLoading:YES];
    [self otsDetatchMemorySafeNewThreadSelector:@selector(requestCateData) toTarget:self withObject:nil];
}

#pragma mark 初始化table及加载中提示Label
- (void)initViews{
    [self.view setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
    //假nav
    UIImageView* topNav=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    topNav.userInteractionEnabled=YES;
    topNav.image=[UIImage imageNamed:@"title_bg.png"];
    [self.view addSubview:topNav];
    [topNav release];
    //标题
    UILabel* titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 44)];
    titleLabel.font=[UIFont boldSystemFontOfSize:20];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.shadowColor=[UIColor darkGrayColor];
    titleLabel.shadowOffset=CGSizeMake(1, -1);
    titleLabel.text=titleText;
    titleLabel.backgroundColor=[UIColor clearColor];
    [topNav addSubview:titleLabel];
    [titleLabel release];
    if ([self.categoryId intValue]!= 0)
    {
        UIButton* backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame=CGRectMake(0,0,61,44);
        backBtn.titleLabel.font=[UIFont boldSystemFontOfSize:13];
        backBtn.titleLabel.shadowColor=[UIColor darkGrayColor];
        backBtn.titleLabel.shadowOffset=CGSizeMake(1, -1);
        [backBtn setBackgroundImage:[UIImage imageNamed:@"title_left_btn.png"] forState:UIControlStateNormal];
        [backBtn setBackgroundImage:[UIImage imageNamed:@"title_left_btn_sel.png"] forState:UIControlStateHighlighted];
        backBtn.titleEdgeInsets=UIEdgeInsetsMake(0, 4, 0, 0);
        [backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
        // [backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [topNav addSubview:backBtn];
    }
    //分类列表
    CGRect rect;
    //此处需要注意的是，当前程序结构下，tabbar上的vc是自动减掉了tabbar的高度，但是由此vc推出的新的vc的高度是不自动减去tabbar高度的
    if (cateLevel.intValue)
    {
        rect=CGRectMake(0, 44, 120, self.view.frame.size.height-44-49);
    }
    else
    {
        rect=CGRectMake(0, 44, 120, self.view.frame.size.height-44);
    }
    cateTable=[[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    cateTable.backgroundView=nil;
    cateTable.backgroundColor=[UIColor clearColor];
    cateTable.delegate=self;
    cateTable.dataSource=self;
    [self.view addSubview:cateTable];
    [cateTable release];
    cateTable.hidden=YES;
    cateTable.scrollsToTop=NO;
    if (ISIOS7)
    {
        cateTable.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0,cateTable.bounds.size.width, 1.0f)] autorelease];
    }
    
    //加载提示
    infoLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 60, 320, 40)];
    [infoLabel setText:@"商品分类信息加载中，请稍候..."];
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    [infoLabel setTextColor:UIColorFromRGB(0x333333)];
    [infoLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    [infoLabel setTextAlignment:NSTextAlignmentCenter];
    [infoLabel setNumberOfLines:10];
    [self.view addSubview:infoLabel];
    [infoLabel release];
}

- (void)backClick:(id)sender{
    cateLeveltrackArray = [GlobalValue getGlobalValueInstance].cateLeveltrackArray;
    [cateLeveltrackArray pop];
    [self popSelfAnimated:YES];
}
#pragma mark requsetData
-(void)saveCateToLocal:(NSMutableArray*)arr byRootId:(NSNumber*)aRootId
{
    if (cachedCategoryDic==nil || cachedCategoryDic.count == 0) {
        self.cachedCategoryDic = [NSMutableDictionary dictionary];
    }
    [cachedCategoryDic setSafeObject:arr forKey:[NSString stringWithFormat:@"%@",aRootId]];
    NSString *filename=[OTSUtility documentDirectoryWithFileName:@"SaveRootCate_130508.plist"];
    NSData* arrData = [NSKeyedArchiver archivedDataWithRootObject:cachedCategoryDic];
    [arrData writeToFile:filename atomically:NO];
}
//针对药店接口,直接把所有的分类以数组的形式存档 --- Linpan
- (void)saveCategoryToLocal:(NSMutableArray *)arr
{
    NSString *filename=[OTSUtility documentDirectoryWithFileName:@"SaveRootCate_130508.plist"];
    NSData* arrData = [NSKeyedArchiver archivedDataWithRootObject:arr];
    [arrData writeToFile:filename atomically:NO];
}

-(NSMutableArray*)getCateFromLocalByRootId:(NSString *)aRootId
{
    
    NSString *filename=[OTSUtility documentDirectoryWithFileName:@"SaveRootCate_130508.plist"];
    NSMutableArray *cateArr = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
    DebugLog(@"cate from Local %@",cateArr);
    if (cateArr.count > 0)
    {
        NSMutableArray *resultArr = [NSMutableArray arrayWithArray:cateArr];
        [self filterCategory:resultArr rootId:aRootId];
        DebugLog(@"filer cate %@",resultArr);
        return resultArr;
    }
    return nil;
}

//Linpan filter Category
- (void)filterCategory:(NSMutableArray *)categoryArr rootId:(NSString *)aRootId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.parentId == %@",aRootId];
    [categoryArr filterUsingPredicate:predicate];
}

- (void)requestCateData{
    //    NSAutoreleasePool* pool=[[NSAutoreleasePool alloc] init];
    
    // 先读缓存，如果没有缓存才显示loading
    NSMutableArray* arr = [self getCateFromLocalByRootId:[self.categoryId intValue] == 0? @"-1" : [self.categoryId stringValue]];  //等于0时是根目录，否则根据分类id来
    
    if (arr.count>0)
    {
        
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval inerval = [date timeIntervalSince1970];
        DebugLog(@"当前时间戳 %lf",inerval);
        NSTimeInterval lastGetCategoryTime = [[NSUserDefaults standardUserDefaults] doubleForKey:@"kGetCategoryTime"];
        DebugLog(@"上次获取分类时间 %lf",lastGetCategoryTime);
        
        NSInteger dur = 1*24*60*60;
#ifdef DEBUG
        dur = 1;
#endif
        
        if (inerval - lastGetCategoryTime > dur)
        {
            //这个分类1天取一次
            //            [self startGetCategoryFromService];
            [self performSelectorOnMainThread:@selector(startGetCategoryFromService) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
        }
        else
        {
            [categoryArray removeAllObjects];
            [categoryArray addObjectsFromArray:arr];
            if (isComeSecond) {//判断是“进入第二级分类时更新tableview”还是 “点击第二级分类出现第三季分类”
                [self performSelectorOnMainThread:@selector(updateCateTable) withObject:nil waitUntilDone:[NSThread isMainThread]];
            }else{
                [self performSelectorOnMainThread:@selector(updateThirdCate) withObject:nil waitUntilDone:[NSThread isMainThread]];
            }
            
        }
        
    }
    else
    {
        // 显示Loading
        [self performSelectorOnMainThread:@selector(makeLoadingVisible:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(startGetCategoryFromService) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
        //        [self startGetCategoryFromService];
    }
}

- (void)startGetCategoryFromService
{
    YWProductService *productSer = [[YWProductService alloc] init];
    Page* tempPage = [productSer getCategory];
    if (tempPage != nil)
    {
        [categoryArray removeAllObjects];
        [categoryArray addObjectsFromArray:tempPage.objList];
        
        //过滤一些不要的
        //过滤分类
        NSMutableArray *deletingCategoryArr = [[NSMutableArray alloc] init];
        for (id cateObj in categoryArray)
        {
            CategoryInfo *cate = (CategoryInfo *)cateObj;
            if ([cate.cid intValue] == 971229 || [cate.cid intValue] == 971246 || [cate.cid intValue] == 971258 || [cate.cid intValue]==965550 || [cate.cid intValue] == 965452 || [cate.cid intValue] == 965279 || [cate.cid intValue] == 965272 || [cate.cid intValue] == 965302 ||[cate.cid intValue] == 965311 ||[cate.cid intValue] == 971249 ||[cate.cid intValue] == 5009 ||[cate.cid intValue] == 965338 ||[cate.cid intValue] == 964287 ||[cate.cid intValue] == 964291 ||[cate.cid intValue] == 964294 ||[cate.cid intValue] == 965415 ||[cate.cid intValue] == 965426||[cate.cid intValue] ==965441||[cate.cid intValue] == 970015|| [cate.cid intValue] == 970030 || [cate.cid intValue] == 970041 || [cate.cid intValue] == 970898 || [cate.name rangeOfString:@"赠品"].location != NSNotFound || [cate.name rangeOfString:@"作废"].location != NSNotFound)
            {
                [deletingCategoryArr addObject:cate];
            }
            
            //去掉成人用品  cid＝955306
            if (![GlobalValue getGlobalValueInstance].bShowAdultCategory)
            {
                if ([cate.cid intValue] == 955306)
                {
                    [deletingCategoryArr addObject:cate];
                }
            }
        }
        
        for (CategoryInfo *cate in deletingCategoryArr)
        {
            [categoryArray removeObject:cate];
        }
        [deletingCategoryArr release];
        
        
        [self saveCategoryToLocal:categoryArray];
        
        [self filterCategory:categoryArray rootId:[self.categoryId intValue]==0? @"-1" : [self.categoryId stringValue]];
        
        if (isComeSecond) { //判断是“进入第二级分类时更新tableview”还是 “点击第二级分类出现第三季分类”
            [self performSelectorOnMainThread:@selector(updateCateTable) withObject:nil waitUntilDone:[NSThread isMainThread]];
        }
        else{
            [self performSelectorOnMainThread:@selector(updateThirdCate) withObject:nil waitUntilDone:[NSThread isMainThread]];
        }
        
        //保存时间
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval inerval = [date timeIntervalSince1970];
        DebugLog(@"存储时间戳 %lf",inerval);
        [[NSUserDefaults standardUserDefaults] setDouble:inerval forKey:@"kGetCategoryTime"];
    }
}

- (NSMutableArray *)queryCategoryByRootCategoryId:(NSNumber *)rootId{
    
    NSMutableArray* arr = [[NSMutableArray alloc]init];
    Sqlite3Handle *_handle = [Sqlite3Handle sharedInstance];
    NSString *query = @"SELECT ROW, nid, categoryName FROM categoryIds where rootId=?";
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:_handle.dbPath];
    [queue inDatabase:^(FMDatabase *_db){
        FMResultSet *rs = [_db executeQuery:query,rootId];
        while ([rs next])
        {
            int nid = [rs intForColumn:@"nid"];
            NSString *categoryName = [rs stringForColumn:@"categoryName"];
            
            CategoryVO *cate=[[[CategoryVO alloc]init]autorelease];
            cate.nid = [NSNumber numberWithInt:nid];
            cate.categoryName = categoryName;
            
            [arr addObject:cate];
        }
    }];
    return [arr autorelease];
}

- (BOOL)saveCategoryByRootCategoryId:(NSNumber *)rootId categoryArray:(NSMutableArray *)cateArray{
    __block BOOL result = NO;
    
    if (!cateArray||[cateArray isKindOfClass:[NSNull class]] ) {
        return 0;
    }
    Sqlite3Handle *_handle = [Sqlite3Handle sharedInstance];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:_handle.dbPath];
    
    // 删除之前缓存的rootId下的数据
    NSString * update = @"DELETE FROM categoryIds where rootId = ?";
    [queue inDatabase:^(FMDatabase *_db){
        result = [_db executeUpdate:update, rootId];
    }];
    if (!result) {
        return NO;
    }
    
    // 更新缓存
    update = @"INSERT OR REPLACE INTO categoryIds (nid, categoryName, rootId)VALUES (?,?,?);";
    for (CategoryVO* cateVO in cateArray) {
        [queue inDatabase:^(FMDatabase *_db){
            result = [_db executeUpdate:update,
                      cateVO.nid,
                      cateVO.categoryName,
                      rootId
                      ];
        }];
        if (!result) {
            return NO;
        }
    }
    return result;
}

-(void)updateCateTable{
    infoLabel.hidden=YES;
    cateTable.hidden=NO;
    [cateTable reloadData];
    [self hideLoading];
}
#pragma mark error
// 网络异常提示
-(void)showNetAlert:(NSInteger)theTag {
    [[GlobalValue getGlobalValueInstance] setHaveAlertViewInShow:YES];
	UIAlertView * alertView = [[OTSAlertView alloc] initWithTitle:nil message:@"网络异常,请检查网络配置..." delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
	alertView.tag = theTag;
    
    _errorAlert = [alertView retain];
    
	[alertView show];
	[alertView release];
	alertView = nil;
}

-(void)showNetErrer
{
    [self hideLoading];
    [self showNetAlert:302];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
//    DebugLog(@"%@",cateLevel);
//    if ([cateLevel intValue]==0) {
//        SharedDelegate.m_UpdateCategory=YES;
//        [SharedDelegate.tabBarController selectItemAtIndex:0];
//        [SharedDelegate.tabBarController setSelectedIndex:0];
//    }else {
//        CategoryViewController* cateVC= (CategoryViewController*)[ SharedDelegate.tabBarController.viewControllers objectAtIndex:1];
//        [cateVC enterTopCategory:YES];
//    }
}

#pragma mark table
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identify=@"cateCell";
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:identify];
    if (cell==nil)
    {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify] autorelease];
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    cell.accessoryType=UITableViewCellAccessoryNone;
    
    if([self.categoryId intValue] != 0)
    {
        CategoryInfo* cateVO=(CategoryInfo *)[categoryArray objectAtIndex:indexPath.row];
        cell.textLabel.text = cateVO ? [NSString stringWithFormat:@"%@",cateVO.name] : @"";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        cell.textLabel.textColor = UIColorFromRGB(0x333333);
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return categoryArray.count;
}

-(void)pushToProductsView:(CategoryInfo*)categoryVO
{
    CategoryProductsViewController*cateProduct=[[[CategoryProductsViewController alloc] init] autorelease] ;
    cateProduct.cateId=categoryVO.cid;
    cateProduct.currentCategory = categoryVO;
    cateProduct.titleText=categoryVO.name;
    cateProduct.isLastLevel=YES;
    
    CategoryVO *allVO=[[CategoryVO alloc] init];
    allVO.categoryName=[NSString stringWithFormat:@"全部(%@)",titleText];
    allVO.nid=self.categoryId;
    NSMutableArray* tempArray=[[NSMutableArray alloc] init];
    [tempArray addObjectsFromArray:categoryArray];
    
    [tempArray insertObject:allVO atIndex:0];
    
    [allVO release];
    cateProduct.categoryTypeArray=tempArray;
    
    [self pushVC:cateProduct animated:YES fullScreen:YES];
    [tempArray release];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CategoryInfo* cateVO=nil;
    cateLeveltrackArray = [GlobalValue getGlobalValueInstance].cateLeveltrackArray;


//    //下面是第二，三级分类
//    if (indexPath.row==0)
//    {
//        //第一行特殊
//        cateVO=[[[CategoryInfo alloc] init] autorelease];
//        cateVO.name=[NSString stringWithFormat:@"全部(%@)",titleText];
//        cateVO.cid=[categoryId stringValue];
//        [self pushCateLevel:[[cateVO.cid copy] autorelease]];
//        [self pushToProductsView:cateVO];
//        return;
//    }
//    else
//    {
    
    
        cateVO=(CategoryInfo *)[categoryArray objectAtIndex:indexPath.row];
        [self pushCateLevel:[[cateVO.cid copy] autorelease]];
        
        //确定是不是有子分类，如有那么继续。。。。。这里按照有没有子分类来判断，
        NSMutableArray *sonCateArr = [self getCateFromLocalByRootId:cateVO.cid];
        if (sonCateArr.count > 0)
        {
            /////显示子分类
            [self pushCateLevel:[[cateVO.cid copy] autorelease]];
            isComeSecond = NO;
            //更新categoryId，才能直接用二级分类的[self refreshCategory]，否则得写三级分类自己的refreshCategory
            self.categoryId = [NSNumber numberWithInt:[cateVO.cid intValue]];
            [self refreshCategory];//点击二级分类以后，获取三级分类的数据
            
            
//            CategoryViewController* cateVC=[[[CategoryViewController alloc] init] autorelease];
//            cateVC.titleText=cateVO.name;
//            cateVC.categoryId= [NSNumber numberWithInt:[cateVO.cid intValue]];
//            cateVC.cateLevel=[NSNumber numberWithInt:[cateLevel intValue]+1];
//            [self pushCateLevel:[[cateVO.cid copy] autorelease]];
//            [self pushVC:cateVC animated:YES fullScreen:YES];
        }
        else
        {
            [self pushToProductsView:cateVO];
        }
//    }
    
}


#pragma mark - 点击第二级分类后，在界面右边显示第三级分类
-(void)updateThirdCate{
    for (int i=0; i<categoryArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btn.layer setMasksToBounds:YES];//在设置了背景图片或颜色情况下，这里这是为YES，才能显示圆角
        [btn.layer setCornerRadius:10.0];//设置矩形四个圆角半径
        btn.Frame = CGRectMake(150, 80*(i+1), 50, 20);
        btn.backgroundColor = [UIColor whiteColor];
        CategoryInfo* cateVO=(CategoryInfo *)[categoryArray objectAtIndex:i];
        NSString *tempStr = cateVO.name;
        [btn setTitle:tempStr forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        [btn release];
    }
    [self hideLoading];
}

#pragma mark --
-(void)pushCateLevel:(NSNumber *)cateId;
{
    if ([self.categoryId intValue]==0)
    {
        //点第一级分类的时候初始化
        [[GlobalValue getGlobalValueInstance].cateLeveltrackArray removeAllObjects];
        [[GlobalValue getGlobalValueInstance].cateLeveltrackArray addObject:self.categoryId];
    }
    cateLeveltrackArray = [GlobalValue getGlobalValueInstance].cateLeveltrackArray;
    if(!([[cateLeveltrackArray peek] intValue] == [cateId intValue])||[cateLeveltrackArray count]==0)
    {
        [cateLeveltrackArray push:cateId];
    }
}


#pragma mark --lifecycle
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
