//
//  CategorySecondAndThirdViewController.h
//  TheStoreApp
//
//  Created by YaoWang on 14-4-30.
//
//

#import "OTSBaseViewController.h"
#import "NSMutableArray+Stack.h"

@interface CategorySecondAndThirdViewController : OTSBaseViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView*    cateTable; //显示列表
    NSNumber*       categoryId; //当前分类id
    NSMutableArray* categoryArray;//数据
    UILabel* infoLabel;
    NSString* titleText;
    NSNumber* cateLevel;//分类级数，从0开始到2后，再点非全部就进入商品列表
    NSMutableArray* cateLeveltrackArray;//跟踪分类筛选的层级
    
    UIAlertView *_errorAlert;
    
    NSNumber* categoryIdSec; //第二级id,根据此id拿到第三级分类
    NSMutableArray* categoryArrayThird;//第三级分类的数据
    NSMutableArray* categoryBtnThirdArray;//第三极分类按钮数组
}

@property(nonatomic,retain)NSNumber* cateLevel;
@property(nonatomic,retain)NSNumber* categoryId;
@property(nonatomic ,retain)NSString* titleText;
@property(nonatomic,retain)NSNumber* categoryIdSec;
@property(nonatomic,retain)UIView *thirdCateBtnView;
- (void)initViews;
-(void)enterTopCategory:(BOOL)inCategory;
-(void)refreshCategory;
@end
