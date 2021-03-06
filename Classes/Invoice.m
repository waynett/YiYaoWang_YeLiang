//
//  Invoice.m
//  TheStoreApp
//
//  Created by yangxd on 11-08-24.
//  Copyright 2011 vsc. All rights reserved.
//

#import "Invoice.h"
#import "InvoiceVO.h"
#import "RegexKitLite.h"
#import "GlobalValue.h"
#import "OrderService.h"
#import <QuartzCore/QuartzCore.h>
#import "OTSActionSheet.h"
#import "OTSAlertView.h"


#import "InvoiceInfo.h"

#define ALERTVIEW_TAG_OTHERS 204            // 其他提示框标识

#define THREAD_STATUS_SAVE_INVOICE 301

#define INDICATORY_BGALERT_MARGINLEFT 0
#define INDICATORY_BGALERT_MARGINTOP 0
#define INDICATORY_BGALERT_WIDTH 320
#define INDICATORY_BGALERT_HEIGHT 413
#define INDICATORY_MARGINLEFT 0
#define INDICATORY_MARGINTOP 0
#define INDICATORY_WIDTH 320
#define INDICATORY_HEIGHT 413

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation Invoice
@synthesize m_InvoiceTitle;
@synthesize m_InvoiceContent;
@synthesize m_InvoiceAmount;
@synthesize m_InvoiceType;

- (void)viewDidLoad 
{
    self.isFullScreen = YES;
	[super viewDidLoad];
    
	DebugLog(@"in invoice view");
	DebugLog(@"self.invoiceTitle : %@", self.m_InvoiceTitle);
	DebugLog(@"self.invoiceContent : %@", self.m_InvoiceContent);
	DebugLog(@"self.invoiceAmount : %@", self.m_InvoiceAmount);
	
	if (m_InvoiceTitle == nil || [m_InvoiceTitle isEqualToString:@""]){
		titleStyle = [NSNumber numberWithInt:0];
	}else {
		titleStyle = [NSNumber numberWithInt:1];
	}
	isNeedInvoice = YES;
	
	addedRowCount = 0;
	
    [self initInvoiceView];
    
}
#pragma mark -
#pragma mark 初始化发票开具界面
-(void)initInvoiceView {
	[self.view setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9294 blue:0.9294 alpha:1.0]];
    frontSelectedItemPicker = 0;
	[UIView setAnimationsEnabled:NO];
	invoiceSelectPicker.tag=0;
	// 发票内容 --- 显示在下拉框中
    if (_isMedicalInstrument)
    {
        invoiceContentArray = [[NSArray alloc] initWithObjects: @"医疗器械", nil]; //如果是医疗器械只能开这个
    }
    else
    {
        invoiceContentArray = [[NSArray alloc] initWithObjects:@"药品", @"医疗器械", @"参茸饮片", @"食品", @"保健品",
                               @"化妆品", @"日用品", @"医疗器械", nil];
    }

    
	
	//选择内容按钮
	invoiceSpinner = [[UIButton alloc]initWithFrame:CGRectMake(9, 0, 302, 45)];
    
    if (!ISIOS7)
    {
        [invoiceSpinner setBackgroundImage:[UIImage imageNamed:@"sizeChonse_btn.png"] forState:0];
    }
	
    if (![invoiceContentArray containsObject:m_InvoiceContent])
    {
        self.m_InvoiceContent = nil;
    }
	if (m_InvoiceContent.length != 0 && [m_InvoiceContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 0)
    {
		[invoiceSpinner setTitle:[NSString stringWithFormat:@"%@▼",m_InvoiceContent] forState:0];
	}
    else
    {
		[invoiceSpinner setTitle:@"请选择▼" forState:0];
	}
	invoiceSpinner.titleLabel.font=[UIFont systemFontOfSize:16.0];
	[invoiceSpinner setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
	[invoiceSpinner setTitleColor:UIColorFromRGB(0x333333) forState:0];
	[invoiceSpinner addTarget:self action:@selector(setInvoiceSpinnerView) forControlEvents:UIControlEventTouchUpInside];
	invoiceSpinner.userInteractionEnabled=YES;
	
	//抬头输入框，无响应，用于显示边框
	invoiceTitleField = [[UITextField alloc]initWithFrame:CGRectMake(0,0, 210, 31)];
	invoiceTitleField.textColor = UIColorFromRGB(0x333333);
	invoiceTitleField.borderStyle = UITextBorderStyleRoundedRect;
	invoiceTitleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	invoiceTitleField.font = [UIFont systemFontOfSize:14];
	invoiceTitleField.userInteractionEnabled = NO;
	
	invoiceTitleTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 190, 58)];
	// invoiceTitleTextView.contentInset = UIEdgeInsetsMake(0, 30, 0, 30);
    
	// 用户输入textview
	invoiceTitleTextView.returnKeyType = UIReturnKeyDone; //just as an example
	invoiceTitleTextView.font = [UIFont systemFontOfSize:15.0f];
	invoiceTitleTextView.delegate = self;
    invoiceTitleTextView.backgroundColor = [UIColor clearColor];
	[invoiceTitleTextView setShowsVerticalScrollIndicator:NO];
	[invoiceTitleTextView setScrollEnabled:NO];
	if (m_InvoiceTitle != nil) {
		[invoiceTitleTextView setText:m_InvoiceTitle];
		[invoiceTitleField setPlaceholder:@""];
	} else{
		[invoiceTitleTextView setText:@""];
		[invoiceTitleField setPlaceholder:@"请输入单位名称"];
	}
	textBgView = [[UIView alloc]initWithFrame:CGRectMake(60, 8, 210, 58)];
	[textBgView setBackgroundColor:[UIColor clearColor]];
	
	// 清空text的按钮
	clearTextBtn = [[UIButton alloc] initWithFrame:CGRectMake(182, 6, 20, 20)];
	[clearTextBtn setBackgroundImage:[UIImage imageNamed:@"clearText.png"] forState:0];
	[clearTextBtn setBackgroundColor:[UIColor clearColor]];
	[clearTextBtn addTarget:self action:@selector(clearText) forControlEvents:UIControlEventTouchUpInside];
	[clearTextBtn setHidden:YES];
	
	[textBgView addSubview:invoiceTitleField];
	[textBgView addSubview:invoiceTitleTextView];
	[textBgView addSubview:clearTextBtn];
	
	warnLabel = [[UILabel alloc] init];
	[warnLabel setTextColor:[UIColor redColor]];
	[warnLabel setFont:[UIFont systemFontOfSize:14]];
	[warnLabel setBackgroundColor:[UIColor clearColor]];
	
	applicationFrame = [[UIScreen mainScreen] applicationFrame];
	
	//选中的勾号
	CheckMarkView =[[UIImageView alloc] initWithFrame:CGRectMake(280, 13, 13, 14)];
	//[CheckMarkView setTag:VIEW_TAG_IMAGEVIEW];
	[CheckMarkView setImage:[UIImage imageNamed:@"filter_tick.png"]];
	
	//说明背景图片
	UIImageView* warnImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 300, 50)];
	[warnImage setImage:[UIImage imageNamed:@"invoice_warn.png"]];
	// 说明内容
	if (invoiceLbl2 != nil) {
		[invoiceLbl2 release];
	}
	invoiceLbl2 = [[UILabel alloc]initWithFrame:CGRectMake(45, 10, 260, 50)];
	invoiceLbl2.text = @"数码、手机、小家电类商品系统将默认打印出商品全称,若您订单中包含其它类商品,请自行填写。";
	[invoiceLbl2 setBackgroundColor:[UIColor clearColor]];
	invoiceLbl2.textColor = UIColorFromRGB(0x333333);
	invoiceLbl2.font = [UIFont boldSystemFontOfSize:12.0];
	invoiceLbl2.lineBreakMode = UILineBreakModeWordWrap; 
	invoiceLbl2.numberOfLines = 0;
	//tableview，显示具体内容
	contentTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 10/*60*/, 320, 320) style:UITableViewStyleGrouped];
	contentTableView.delegate = self;
	contentTableView.dataSource = self;
	[contentTableView setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9294 blue:0.9294 alpha:1.0]];
	[contentTableView setScrollEnabled:NO];
    contentTableView.backgroundView=nil;
	//完成按钮
	doneBtn = [[UIButton alloc]initWithFrame:CGRectMake(25, 367-50, 270, 40)];
	[doneBtn setBackgroundImage:[UIImage imageNamed:@"orange_long_btn.png"] forState:0];
	[doneBtn addTarget:self action:@selector(saveInvoiceToOrder) forControlEvents:UIControlEventTouchUpInside];
	[doneBtn setTitle:@"完成" forState:0];
	[doneBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
	
	//分割线
	separateLine = [[UIView alloc] initWithFrame:CGRectMake(0, 345-50, 320, 1)];
	[separateLine setBackgroundColor:[UIColor lightGrayColor]];
	[separateLine setAlpha:0.5];
	
	//scroll view
	m_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, ApplicationWidth, ApplicationHeight-NAVIGATION_BAR_HEIGHT)];
	//m_scrollView.contentSize = CGSizeMake(320, 420);
    [m_scrollView setAlwaysBounceVertical:YES];
	//scrollViewOriginalSize = m_scrollView.contentSize;
	[m_scrollView setBackgroundColor:[UIColor clearColor]];
	[m_scrollView setDelegate:self];
    [m_scrollView setContentSize:CGSizeMake(ApplicationWidth, ApplicationHeight-NAVIGATION_BAR_HEIGHT)];
	

	[warnImage release];
    
	[m_scrollView addSubview:contentTableView];
	[m_scrollView addSubview:doneBtn];
//	[m_scrollView addSubview:separateLine];
    
	[self.view addSubview:m_scrollView];
    
    if (self.isFullScreen)
    {
        [self strechViewToBottom:m_scrollView];
    }
	
	// 标题图片
	UIImageView * titleBGImg = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,320,44)];
	titleBGImg.image = [UIImage imageNamed:@"title_bg.png"];
	// 标题栏
	UILabel * titleTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(121,0,126,44)];
	titleTextLabel.text = @"开具发票";
	[titleTextLabel setBackgroundColor:[UIColor clearColor]];
	titleTextLabel.textColor = [UIColor whiteColor];
	titleTextLabel.font = [UIFont systemFontOfSize:20.0];
	titleTextLabel.shadowColor = [UIColor darkGrayColor];
	titleTextLabel.shadowOffset = CGSizeMake(1.0, -1.0);
	[titleBGImg addSubview:titleTextLabel];
    [titleTextLabel release];
	// 返回按钮
	UIButton * backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,61,44)];
	//[backBtn setTitle:@" 返回" forState:0];
	[backBtn setTitleColor:[UIColor whiteColor] forState:0];
	backBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
	backBtn.titleLabel.shadowColor = [UIColor darkGrayColor];
	backBtn.titleLabel.shadowOffset = CGSizeMake(1.0, -1.0);
	[backBtn setBackgroundImage:[UIImage imageNamed:@"title_left_btn.png"] forState:0];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"title_left_btn_sel.png"] forState:UIControlStateHighlighted];
	[backBtn addTarget:self action:@selector(backCheckOrderView) forControlEvents:UIControlEventTouchUpInside];
	[titleBGImg addSubview:backBtn];
    [backBtn release];
	
	// 标题栏返回按钮
	titleDoneBtn = [[UIButton alloc]initWithFrame:CGRectMake(259, 0, 61, 44)];
//	[titleDoneBtn setTitle:@"完成" forState:0];
//	[titleDoneBtn setTitleColor:[UIColor whiteColor] forState:0];
//	titleDoneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
//	titleDoneBtn.titleLabel.shadowColor = [UIColor darkGrayColor];
//	titleDoneBtn.titleLabel.shadowOffset = CGSizeMake(1.0, -1.0);
	[titleDoneBtn setBackgroundImage:[UIImage imageNamed:@"title_done.png"] forState:0];
    [titleDoneBtn setBackgroundImage:[UIImage imageNamed:@"title_done_sel.png"] forState:UIControlStateHighlighted];
	[titleDoneBtn addTarget:self action:@selector(saveInvoiceToOrder) forControlEvents:UIControlEventTouchUpInside];
	[titleBGImg addSubview:titleDoneBtn];
	
	titleBGImg.userInteractionEnabled = YES;
	[self.view addSubview:titleBGImg];
    [titleBGImg release];
	
	if (invoiceTitleTextView.contentSize.height > 50) {
		isHaveMoreRow = YES;
		addedRowCount++;
		[self viewMoveDown];
		[invoiceTitleTextView setScrollEnabled:YES];
		[contentTableView reloadData];
	}
	
}
#pragma mark 返回到检查订单页面
-(void)backCheckOrderView {
	if ((invoiceTitleTextView.text != nil && ![invoiceTitleTextView.text isEqualToString:@""]) || m_InvoiceContent != nil) {
		NSMutableArray* tempArray = [NSMutableArray arrayWithCapacity:4];
		InvoiceVO* tempVo = [[[InvoiceVO alloc] init] autorelease];
		if (invoiceTitleTextView.text == nil || [invoiceTitleTextView.text isEqualToString:@""]) {
			[tempVo setTitle:@"个人"];
		}else {
			[tempVo setTitle:invoiceTitleTextView.text];
		}
		
		if ([m_InvoiceType intValue] == 2) {
			[tempVo setContent:@"商品明细"];
		}else {
			[tempVo setContent:m_InvoiceContent];
		}
		[tempArray addObject:tempVo];
		[tempArray addObject:titleStyle];							//抬头的类型
		[tempArray addObject:[NSNumber numberWithInt:1]];			//标帜是从取消返回检查订单页面
		if (!isNeedInvoice) {
			[tempArray addObject:[NSNumber numberWithInt:1]];		//是否需要发票
		}else {
			[tempArray addObject:[NSNumber numberWithInt:0]];
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SaveInvoiceToOrder" object:tempArray];
	}
	CATransition *animation = [CATransition animation]; 
    animation.duration = 0.3f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
	[animation setType:kCATransitionPush];
	[animation setSubtype: kCATransitionFromLeft];
	[self.view.superview.layer addAnimation:animation forKey:@"Reveal"];
    [self removeSelf];
}
#pragma mark 刷新tableview
-(void)updateTableView{
	//textViewIsEditing = NO;
	[contentTableView reloadData];
}

#pragma mark 移动页面，当键盘弹出的时候
-(void)moveScrollView:(UIView*) theView{
	CGFloat viewCenterY =  [theView convertPoint:theView.center toView:nil].y - 49;
	keyboardBounds.size.height = 216;
	CGFloat freeSpaceHeight = (applicationFrame.size.height) - keyboardBounds.size.height;
	CGFloat scrollAmount = viewCenterY - freeSpaceHeight/2.0;
	if (scrollAmount < 0) {
		scrollAmount = 0;
	}
	[UIView setAnimationsEnabled:YES];
	[UIView beginAnimations:@"move" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.3];
	[m_scrollView setFrame:CGRectMake(0, 44-scrollAmount, ApplicationWidth, ApplicationHeight-NAVIGATION_BAR_HEIGHT)];
	[UIView commitAnimations];
	/*m_scrollView.contentSize = CGSizeMake(applicationFrame.size.width, m_scrollView.contentSize.height + keyboardBounds.size.height);
	[m_scrollView setContentOffset:CGPointMake(0, scrollAmount) animated: YES];*/
}

#pragma mark switch按钮值改变
-(IBAction)switchValueChange:(id)sender{
	if (isNeedInvoice) {
		isNeedInvoice = NO;
		//m_scrollView.contentSize = CGSizeMake(320, 150);
		[titleDoneBtn setHidden:YES];
		[warnLabel setHidden:YES];
		[separateLine setHidden:YES];
	}else {
		isNeedInvoice = YES;
		//m_scrollView.contentSize = scrollViewOriginalSize;
		[titleDoneBtn setHidden:NO];
		[warnLabel setHidden:NO];
		[separateLine setHidden:NO];
	}
	textViewIsEditing = NO;
	[self updateTableView];
}
#pragma mark 清空text
-(void)clearText{
	[invoiceTitleTextView setText:@""];
}
#pragma mark 页面尺寸变更
-(void)viewMoveDown {
	int yValue = 35;
	if (addedRowCount == 1) {													//多增加了一行
		if ([warnLabel.text isEqualToString:@"请选择发票内容"]) {					//从发票内容为空增加	
			[warnLabel setFrame:CGRectMake(15, 325-50, 100, 31)];
			[invoiceTitleField setFrame:CGRectMake(0, 0, 210, 31)];
			[clearTextBtn setFrame:CGRectMake(182, 6, 20, 20)];
			[CheckMarkView setFrame:CGRectMake(280, 13, 13, 14)];
		}else if ([warnLabel.text isEqualToString:@"请填写发票抬头"]) {			//从抬头为空增加
			[invoiceTitleField setFrame:CGRectMake(0, 0, 210, 31)];
			[clearTextBtn setFrame:CGRectMake(182, 6, 20, 20)];
			[warnLabel setFrame:CGRectMake(60, 40 , 100, 31)];
			[CheckMarkView setFrame:CGRectMake(280, 30, 13, 14)];
		}else {																	//从textview字数增加
			[invoiceTitleField setFrame:CGRectMake(0, 0, 210, 31+27)];
			[clearTextBtn setFrame:CGRectMake(182, 19, 20, 20)];
			[warnLabel setFrame:CGRectMake(15, 325, 100, 31)];
			[CheckMarkView setFrame:CGRectMake(280, 30, 13, 14)];
		}
	}else if (addedRowCount == 2) {												//多增加了两行，
		[warnLabel setFrame:CGRectMake(15, 325+yValue, 100, 31)];
		[invoiceTitleField setFrame:CGRectMake(0, 0, 210, 31+27)];
		[clearTextBtn setFrame:CGRectMake(182, 19, 20, 20)];
		[CheckMarkView setFrame:CGRectMake(280, 30, 13, 14)];
	}else {
		[invoiceTitleField setFrame:CGRectMake(0, 0, 210, 31)];
		[clearTextBtn setFrame:CGRectMake(182, 6, 20, 20)];
		[CheckMarkView setFrame:CGRectMake(280, 13, 13, 14)];
	}

	[separateLine setFrame:CGRectMake(0, 345+addedRowCount*yValue - 50, 320, 1)];
	[doneBtn setFrame:CGRectMake(25, 367+addedRowCount*yValue  - 50, 270, 40)];
	[contentTableView setFrame:CGRectMake(0, 10/*60*/, 320, 320+addedRowCount*yValue)];
    
	[m_scrollView setContentSize:CGSizeMake(320, ApplicationHeight-NAVIGATION_BAR_HEIGHT+addedRowCount*yValue)];
	//scrollViewOriginalSize = m_scrollView.contentSize;
}
#pragma mark 点击发票内容按钮显示的模态窗口
-(void)setInvoiceSpinnerView
{
    //为了适配iOS7
    if (ISIOS7)
    {
        invoiceSelectActionview = [[/*OTSActionSheet*/ UIActionSheet  alloc]initWithTitle:@" \n\n \n \n \n \n \n \n \n \n   \n \n \n \n \n" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    }
    else
    {
        invoiceSelectActionview = [[/*OTSActionSheet*/ UIActionSheet  alloc]initWithTitle:@" \n\n \n \n \n \n \n \n \n \n" delegate:self cancelButtonTitle:@"" destructiveButtonTitle:nil otherButtonTitles:nil];
    }

	CGRect tempframe = CGRectMake(0, 44, 320, 212);
	[invoiceSelectPicker setFrame:CGRectMake(0, 0, 320, 216)];
	invoiceSelectPicker.opaque = YES;
    
    
	[invoiceSelectPicker selectRow:frontSelectedItemPicker inComponent:0 animated:YES];
	UIButton * tempbutton = [[UIButton alloc]initWithFrame:tempframe];
    
    
    UIButton * finishSetBtn = [[UIButton alloc]initWithFrame:CGRectMake(252, 7, 50, 30)];//右边的完成操作按钮；
	[finishSetBtn setBackgroundImage:[UIImage imageNamed:@"red_short_btn.png"] forState:0];
	[finishSetBtn addTarget:self action:@selector(clickFinishSettingInvoiceSpinner) forControlEvents:UIControlEventTouchUpInside];
	[finishSetBtn setTitle:@"完成" forState:0];
	finishSetBtn.titleLabel.shadowColor = [UIColor darkGrayColor];
	finishSetBtn.titleLabel.shadowOffset = CGSizeMake(1.0, -1.0);
    
    UIButton * cancelSetBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 7, 50, 30)];
	[cancelSetBtn setBackgroundImage:[UIImage imageNamed:@"red_short_btn.png"] forState:0];
	[cancelSetBtn addTarget:self action:@selector(cancelSettingInvoiceSpinner) forControlEvents:UIControlEventTouchUpInside];
	[cancelSetBtn setTitle:@"取消" forState:0];
	cancelSetBtn.titleLabel.shadowColor = [UIColor darkGrayColor];
	cancelSetBtn.titleLabel.shadowOffset = CGSizeMake(1.0, -1.0);
	
    [invoiceSelectActionview addSubview:finishSetBtn];
    [invoiceSelectActionview addSubview:cancelSetBtn];
    [finishSetBtn release];
    [cancelSetBtn release];
    [tempbutton addSubview:invoiceSelectPicker];
    
    //这里的层次很复杂啊， 不是我写的，你就凑活着看吧
    //在iOS7下又加了一层view 做遮挡
//    UIView *bgView = [[UIView alloc] initWithFrame:tempbutton.frame];
//    bgView.backgroundColor = [UIColor whiteColor];
//    [bgView addSubview:tempbutton];
//    [bgView addSubview:tempbutton];
//    [invoiceSelectActionview addSubview:bgView];
//    [bgView release];
    
	[invoiceSelectActionview addSubview:tempbutton];
    [tempbutton release];
	[invoiceSelectActionview showInView:[UIApplication sharedApplication].keyWindow];
}
#pragma mark 在模态窗口点击确定后触发的事件
-(void)clickFinishSettingInvoiceSpinner
{
	frontSelectedItemPicker = invoiceContentRow;
	[invoiceSelectActionview dismissWithClickedButtonIndex:0 animated:NO];
	[self setM_InvoiceContent:[invoiceContentArray objectAtIndex:invoiceContentRow]];
	[invoiceSpinner setTitle:[NSString stringWithFormat:@"%@▼",m_InvoiceContent] forState:0];
	
	if ([warnLabel.text isEqualToString:@"请选择发票内容"])
    {
		[warnLabel setText:@""];
		addedRowCount--;
		[self viewMoveDown];
		textViewIsEditing = NO;
		[self updateTableView];
	}
}
#pragma mark 取消发票内容按钮显示的模态窗口
-(void)cancelSettingInvoiceSpinner {
	[invoiceSelectActionview dismissWithClickedButtonIndex:0 animated:YES];
	//[self viewMoveDown];
}
#pragma mark 保存发票到订单
-(void)saveInvoiceToOrder {

	if ([warnLabel.text isEqualToString:@"请填写发票抬头"] || [warnLabel.text isEqualToString:@"请选择发票内容"])
    { //若已经存在错误提示，什么都不做
	}
    else if (([invoiceTitleTextView.text isEqualToString:@""] || [[invoiceTitleTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0) && ([titleStyle intValue] == 1))
    {
		if (![warnLabel.text isEqualToString:@"请填写发票抬头"]) {
			[warnLabel setText:@"请填写发票抬头"];
			addedRowCount++;
			[self viewMoveDown];
			textViewIsEditing = NO;
			[self updateTableView];
		}
	}
    else if (([invoiceSpinner.currentTitle isEqualToString:@"请选择▼"] || [m_InvoiceContent isEqualToString:@""])&& [m_InvoiceType intValue] != 2)
    {
		if (![warnLabel.text isEqualToString:@"请选择发票内容"]) {
			[warnLabel setText:@"请选择发票内容"];
			addedRowCount++;
			[self viewMoveDown];
			[m_scrollView addSubview:warnLabel];
			textViewIsEditing = NO;
			[self updateTableView];
		}
	}
    else
    {
		[warnLabel setText:@""];
		if ([titleStyle intValue] == 0)
        {
			[invoiceTitleTextView setText:@"个人"];
		}
		NSMutableArray* tempArray = [NSMutableArray arrayWithCapacity:4];
		InvoiceVO* tempVo = [[[InvoiceVO alloc] init] autorelease];
        
        
		if ([m_InvoiceType intValue] == 2)
        {
			[tempVo setContent:@"商品明细"];
		}
        else
        {
			[tempVo setContent:m_InvoiceContent];
		}
		[tempVo setTitle:invoiceTitleTextView.text];
		[tempArray addObject:tempVo];
		[tempArray addObject:titleStyle];							//抬头的类型
		[tempArray addObject:[NSNumber numberWithInt:0]];			//标帜是从保存返回检查订单页面
		if (!isNeedInvoice)
        {
			[tempArray addObject:[NSNumber numberWithInt:1]];		//是否需要发票 0需要，1不需要
		}else {
			[tempArray addObject:[NSNumber numberWithInt:0]];
		}
        
//        
//        InvoiceInfo *invoiceInfo = [[[InvoiceInfo alloc] init] autorelease]; //药网发票对象
//        invoiceInfo.invoiceHeadTypeId = 
//        
        
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SaveInvoiceToOrder" object:tempArray];
		
		CATransition *animation = [CATransition animation]; 
		animation.duration = 0.3f;
		animation.timingFunction = UIViewAnimationCurveEaseInOut;
		[animation setType:kCATransitionPush];
		[animation setSubtype: kCATransitionFromLeft];
		[self.view.superview.layer addAnimation:animation forKey:@"Reveal"];
		[self removeSelf];
		
		/*[self setM_InvoiceTitle:invoiceTitleField.text];
		 currentState = THREAD_STATUS_SAVE_INVOICE;
		 [self setUpThread];*/
	}
    [clearTextBtn setHidden:YES];
    [invoiceTitleTextView resignFirstResponder];
}

#pragma mark -
#pragma mark scrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (scrollView == m_scrollView) {
		textViewIsEditing = NO;
		[invoiceTitleTextView resignFirstResponder];
	}
}

#pragma mark -
#pragma mark 设置滚轴 Delegate
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	return [invoiceContentArray count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
	if(pickerView.tag==0){
		return 200;
	}
	return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	if(pickerView.tag==0){
		if(row==0){
            invoiceContentRow=0;
		}
		return [NSString stringWithString:[invoiceContentArray objectAtIndex:row]];
	}
	return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	if(pickerView.tag==0){
        invoiceContentRow=row;
	}
}
#pragma mark  textview Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
	
	if ([invoiceTitleTextView hasText]) {
		[clearTextBtn setHidden:NO];
	}else {
		[clearTextBtn setHidden:YES];
	}
	if (!textViewIsEditing) {															// 如果正在编辑文字，不滚动。在文字换行时作用
		[self moveScrollView:textView];
	}
	textViewIsEditing = YES;															// 把文字编辑状态改为正在编辑
	if ([warnLabel.text isEqualToString:@"请填写发票抬头"] && addedRowCount > 0) {
		addedRowCount--;
		[self viewMoveDown];
		[warnLabel setText:@""];
		[contentTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
	}
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
	if ([invoiceTitleTextView.text isEqualToString:@""]) {
		[invoiceTitleField setPlaceholder:@"请输入单位名称"];
	}
	if (!textViewIsEditing) {															// 不在文字编辑状态。画面回滚
		[clearTextBtn setHidden:YES];
		[UIView setAnimationsEnabled:YES];
		[UIView beginAnimations:@"move down" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:0.3];
		[m_scrollView setFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, ApplicationWidth, ApplicationHeight-NAVIGATION_BAR_HEIGHT)];
		[UIView commitAnimations];
	}
	return YES; 
}
/*- (void)textViewDidEndEditing:(UITextView *)textView{
	if ([invoiceTitleTextView.text isEqualToString:@""]) {
		[invoiceTitleField setPlaceholder:@"请输入单位名称"];
	}
	[UIView beginAnimations:@"back to original size" context:nil];
	m_scrollView.contentSize = scrollViewOriginalSize;
	[UIView commitAnimations];
}*/
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
	if ([text isEqualToString:@"\n"]) {
		textViewIsEditing = NO;													// done键按下。结束编辑
		[textView resignFirstResponder];
		[clearTextBtn setHidden:YES];
		return NO;
	}
	NSString * toBeString = [textView.text stringByReplacingCharactersInRange:range withString:text]; 
	if (invoiceTitleTextView == textView)  
    {
		if ([toBeString length] > 40) {
            textView.text = [toBeString substringToIndex:40];
			OTSAlertView *alert = [[[OTSAlertView alloc] initWithTitle:nil message:@"发票抬头不可超过50个字，请修改" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] autorelease]; 
			[alert show]; 
			return NO; 
			} 
	} 
	return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
	DebugLog(@"the height is: %f",textView.contentSize.height);
	if ([invoiceTitleTextView hasText]) {
		[clearTextBtn setHidden:NO];
		[invoiceTitleField setPlaceholder:@""];
	}else {
		[clearTextBtn setHidden:YES];
		[invoiceTitleField setPlaceholder:@"请输入单位名称"];
	}
	textViewIsEditing = YES;
	if (!isHaveMoreRow) {
		if (textView.contentSize.height > 50) {
            isHaveMoreRow = YES;
			addedRowCount++;
			[self viewMoveDown];
			[invoiceTitleTextView setScrollEnabled:YES];
			[contentTableView reloadData];
		}
	}else {
		if (textView.contentSize.height <= 50){
            isHaveMoreRow = NO;
			addedRowCount--;
			[self viewMoveDown];
			[invoiceTitleTextView setScrollEnabled:NO];
			[contentTableView reloadData];
			
		}
	}
}

#pragma mark TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	int section = [indexPath section];
	int row = [indexPath row];
	if (textViewIsEditing == YES) {													// 若正处于文字编辑状态，掉起键盘，table的刷新会使textview失去焦点
		[invoiceTitleTextView becomeFirstResponder];
	}
	if (section == 1 && row == 1 && addedRowCount > 0) {
		if (addedRowCount == 1) {													//多增加了一行
			if ([warnLabel.text isEqualToString:@"请选择发票内容"]) {					//从发票为空增加	
				return 44;						
			}else {																	//从textview字数增加
				return 79;
			}
		}
		return 79;
	}
	else {
		return 44;
	}
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if (section == 0) {
		return 0;
	}
	return 25;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	if (section == 0) {
		return nil;
	}
	UIView* sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
	[sectionView setBackgroundColor:[UIColor clearColor]];
	UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(19, 0, 100, 25)];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setFont:[UIFont systemFontOfSize:15]];
	[label setTextColor:[UIColor colorWithRed:0.2980 green:0.3412 blue:0.4196 alpha:1.0]];
	if (section == 1) {
		[label setText:@"发票抬头"];
	}else if(section == 2){
		[label setText:@"发票内容"];
	}
	[sectionView addSubview:label];
	[label release];
	return [sectionView autorelease];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 2;
			break;
		case 2:
			return 1;
			break;
		default:
			return 0;
			break;
	}
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    [cell setBackgroundColor:[UIColor whiteColor]];
	int section = [indexPath section];
	if (section == 0)
    {
		cell.textLabel.text = @"开具发票";
		//是否开具发票开关
		UISwitch* switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(210, 9, 80, 30)];
		[switchBtn setOn:isNeedInvoice];
		[switchBtn addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
		[cell addSubview:switchBtn];
		[switchBtn release];
	}
	if (section == 1)
    {
		int row = [indexPath row];
		if (row == 0)
        {
			cell.textLabel.text = @"个人";
			if ([titleStyle intValue] == 0)
            {
				[cell addSubview:CheckMarkView];
			}
		}
        else if(row == 1)
        {
			cell.textLabel.text = @"单位";
			[cell addSubview:textBgView];
			if ([titleStyle intValue] == 0)
            {
				[textBgView setHidden:YES];
			}
            else
            {
				[textBgView setHidden:NO];
				[cell addSubview:CheckMarkView];
				if ([warnLabel.text isEqualToString:@"请填写发票抬头"])
                {
					[cell addSubview:warnLabel];
				}
			}
			
		}
	}
	if (section == 2)
    {
//		cell.textLabel.text = @"商品明细";
		if ([m_InvoiceType intValue] != 2)
        {
			[cell addSubview:invoiceSpinner];
		}
	}
	[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if ([indexPath section] == 1) {
		UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
		[cell addSubview:CheckMarkView];
		
		if ([indexPath row] == 0) {
			if ([titleStyle intValue] != 0) {   //点击同一cell，不做任何处理
				textViewIsEditing = NO;
				[invoiceTitleTextView resignFirstResponder];
				[clearTextBtn setHidden:YES];
				[textBgView setHidden:YES];
				titleStyle = [NSNumber numberWithInt:0];
				if ([warnLabel.text isEqualToString:@"请填写发票抬头"]|| invoiceTitleTextView.contentSize.height > 50) {
					addedRowCount--;
					[self viewMoveDown];
					if ([warnLabel.text isEqualToString:@"请填写发票抬头"]) {
						[warnLabel setText:@""];
					}
					[self performSelector:@selector(updateTableView) withObject:nil afterDelay:0];
				}
			}
		}else {
			if ([titleStyle intValue] != 1) {
				[textBgView setHidden:NO];
				titleStyle = [NSNumber numberWithInt:1];
				if (invoiceTitleTextView.contentSize.height > 50) {
					addedRowCount++;
					[self viewMoveDown];
					[self moveScrollView:invoiceTitleTextView];
					textViewIsEditing = YES;
					[self performSelector:@selector(updateTableView) withObject:nil afterDelay:0];
				}else {
					[invoiceTitleTextView becomeFirstResponder];
				}

			}
		}
	}
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	if (isNeedInvoice) {
		[doneBtn setHidden:NO];
		return 3;
	}else {
		[doneBtn setHidden:YES];
		return 1;
	}
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
-(void)releaseMyResoures
{
    OTS_SAFE_RELEASE(invoiceSpinner) ;						// 发票内容下拉按钮
    OTS_SAFE_RELEASE(invoiceContentArray);					// 所有发票内容
    OTS_SAFE_RELEASE(invoiceTitleField);                    // 发票抬头输入框
    OTS_SAFE_RELEASE(invoiceSelectActionview);              // 发票滚轴
    OTS_SAFE_RELEASE(invoiceTitleTextView);                 // 抬头输入view
    OTS_SAFE_RELEASE(textBgView);                           // 加载text的view
    OTS_SAFE_RELEASE(contentTableView);                     // 主tableview
    OTS_SAFE_RELEASE(m_scrollView);                         // 底层scrollview
    OTS_SAFE_RELEASE(titleDoneBtn);							// 标题栏完成按钮
    OTS_SAFE_RELEASE(doneBtn);								// 下方的完成按钮
    OTS_SAFE_RELEASE(warnLabel);                            // 输入错误提示label
    OTS_SAFE_RELEASE(CheckMarkView);						// 选中勾号
    OTS_SAFE_RELEASE(separateLine);							// 分割线
    OTS_SAFE_RELEASE(clearTextBtn);							// 清空文字
    OTS_SAFE_RELEASE(invoiceLbl2);							// 说明文字
    
    OTS_SAFE_RELEASE(m_InvoiceContent);
    OTS_SAFE_RELEASE(m_InvoiceTitle);
    OTS_SAFE_RELEASE(m_InvoiceAmount);
    OTS_SAFE_RELEASE(m_InvoiceType);
    
    // release outlet
    OTS_SAFE_RELEASE(invoiceSelectPicker);
    
	// remove vc
}

- (void)viewDidUnload
{
    [self releaseMyResoures];
    [super viewDidUnload];
}

-(void)dealloc
{
    [self releaseMyResoures];
    [super dealloc];
}
@end
