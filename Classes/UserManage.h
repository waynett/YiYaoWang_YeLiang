//
//  UserManage.h
//  TheStoreApp
//
//  Created by lix on 11-2-22.
//  Copyright 2011 vsc. All rights reserved.
//

typedef enum
{
    kEnterLoginFromWeRock = 101,
    kEnterLoginFromGrouponDetail=102
}OTSEnterLoginFrom;

#import <UIKit/UIKit.h>
#import "VerifyCodeVO.h"
#import "MyStoreViewController.h"
#import "CartService.h"
#import "WBEngine.h"
#import "TencentOAuth.h"
#import "UserManageTool.h"
#import "YWUserLoginHelper.h"


@class Homepage;
@class Trader;
@class OTSAliPayWebView;

#define FROM_TABBAR_CLICK   1


@interface UserManage : OTSBaseViewController<UIScrollViewDelegate, UITextFieldDelegate,WBEngineDelegate,TencentSessionDelegate> {
@public
    NSInteger              CallTag;                   //标记由哪个页面调用此类	
	//用户登录部分控件输出口
	IBOutlet UITextField   *loginTextfieldName;//               //用户名
	IBOutlet UITextField   *loginTextfieldCode;//               //密码
    IBOutlet UIButton      *rememberMeBtn;//                       //记住我
	IBOutlet UIScrollView  *loginScrollView;//	
    
    //手机注册相关
    IBOutlet UIView        *typeView;
    IBOutlet UIButton      *phoneregisteBTN;
    IBOutlet UIButton      *mailregisteBTN;
    IBOutlet UIScrollView  *registmainScrollview; //手机注册－主view
    IBOutlet UIImageView   *phoneregisteImgView;
    IBOutlet UITextField   *phoneregisteNum;
    IBOutlet UILabel       *phoneregisteWarningLbl;
    IBOutlet UIButton      *phoneregisteWarningMask;
    IBOutlet UIButton      *phoneregisteVerifyBTN;
    CGFloat                 _offset;
    BOOL                    _rever; 
    
    //手机注册验证相关
    IBOutlet UIScrollView  *phoneverificationmainScrollview; //手机注册验证－主view
    IBOutlet UIImageView   *phoneverificationImaview;
    IBOutlet UILabel       *phoneverificationNum;
    IBOutlet UITextField   *phoneverificationCode;
    IBOutlet UILabel       *phoneverificationWarningLbl;
    IBOutlet UIButton      *phoneverificationWarningMask;
    IBOutlet UIButton      *phoneverificationCodeSubmit;
    IBOutlet UIButton      *phoneverificationCodeReFetch;
    NSTimer*                _timer;
    int                     expireSeconds;
    int                     currentSeconds;
    
    //手机注册设置密码
    IBOutlet UIView        *passSettingview;
    IBOutlet UIScrollView  *passSettingMainScrollview;
    IBOutlet UITextField   *passSettingPWD;
    IBOutlet UILabel       *passSettingWarningLbl;
    IBOutlet UIButton      *passSettingWarningMask;
    IBOutlet UIButton      *passSettingCheckbox;
    IBOutlet UIButton      *passSettingSubmit;
    
	
	//提交注册部分控件输出口
	IBOutlet UITextField   *user_registeName;//                 //用户名
	IBOutlet UITextField   *user_registePWD;//                  //密码
	IBOutlet UITextField   *user_registeVerifyCode;//			//验证码；
	IBOutlet UIImageView   *registeVerifycodeImgView;//			//存放 获取的 验证码 图片的imgview
    IBOutlet UIScrollView  *user_registeScrollView;//
    IBOutlet UIScrollView  *user_phoneregisteScrollview;
	VerifyCodeVO           *verifycodeVO;					    //存放获取的验证码 VO 实例  
	IBOutlet UIView        *m_ServiceAgreeView;//
    IBOutlet UIView        *m_VarificationView;
    BOOL                   isAgreeAgreement;                    // 是否勾选同意协议
	
	//忘记密码页面的控件输出口；
	IBOutlet UITextField   *forgetpwdNameTextField;//			//用户名或邮箱
	IBOutlet UITextField   *forgetpwdVerifycodeTextField;//     //验证码
	IBOutlet UIImageView   *forgetpwdVerifyImgView;//			//承载验证码图片的imgview
	
	IBOutlet UIView        *loginView;//						//登录页
	IBOutlet UIView        *user_registeView;//					//注册页
	IBOutlet UIView        *forgetpwdView;	//					//忘记密码页
	IBOutlet UIView        *modifyPwdView;//				   //修改密码页
	
	BOOL                   threadRuning;					   //线程控制
	NSInteger              currentState;					   //当前状态  login or registe or forgetPwd
	
	//NSString*  loginResult;									//登录的返回结果
	int                    registeResult;		             //注册的返回结果
	int                    forgetPwdResult;					//忘记密码的返回结果
	int                    modifyPwdResult;				//修改密码的返回结果
    BOOL                   registShowPwd;
    BOOL                   rememberMyAccout;                  //是否记住我的帐户信息
	
	//修改密码
	IBOutlet UITextField   *oldCodeInModifypwd;//			//原始密码 textfield控件
    IBOutlet UITextField   *codeInModifypwd;//				//新密码  textfield控件
    IBOutlet UITextField   *confirmcodeInModify;//			//确认密码 textfield控件
	
	IBOutlet UIButton      *returnBtnInLogin;//					//登录页的返回按钮
	IBOutlet UIButton      *returnBtnInRegiste;//				//注册页的返回按钮
	IBOutlet UIButton      *returnBtnInForget;//					//忘记密码页的返回按钮
	IBOutlet UIButton      *returnBtnInModifyPwd;//				//修改密码页的返回按钮
	IBOutlet UIButton      *loginBtn;//							//登录页的登录按钮
	IBOutlet UIButton      *registeBtn;//							//注册页的提交注册按钮
	IBOutlet UIButton      *forgetBtn;//							//忘记密码页的确认按钮
	IBOutlet UIButton      *modifyBtn;//							//修改密码页的提交修改按钮
    IBOutlet UILabel *usernameLbl;
    IBOutlet UITextField *usernameTF;
    IBOutlet UITextView *_protocol;
    UIImageView            *VerifyCodeImageView;
    NSNumber               *productIdString;
    NSNumber               *merchanID;
    NSNumber               *productNumbers;
    NSString               *notificationString;
    CartService            *carSer;
    UserManageTool         *m_userTool;
    NSArray                *userArray;
    WBEngine               *m_WBEngine;
    TencentOAuth           *m_TencentOAuth;
    NSString               *m_UserName;                      //联合登录用户名
    NSString               *m_NickName;                      //联合登录用户昵称
    NSString               *m_UserImg;                          //联合登录用户头像
    NSString               *m_Cocode;                         //联合登录用户密码
    NSString               *autoLoginStatus;                             //自动登陆的状态 1/0
    
    OTSAliPayWebView       *aliPlayWebView;             // 支付宝登录视图
    int                    m_CurrentTypeIndex;//当前类型按钮的索引值
    
    
    
    YWLoginType _loginType;  //区分 QQ 登录 支付宝登录
    
    
	
}
@property(copy)NSString        *m_UserName;
@property(copy)NSString        *m_NickName;
@property(copy)NSString        *m_UserImg;
@property(copy)NSString        *m_Cocode;


@property(nonatomic)NSInteger                 CallTag;
@property(retain)VerifyCodeVO                 *verifycodeVO;
@property(nonatomic, retain) OTSAliPayWebView *aliPlayWebView;
@property(nonatomic) BOOL                     quitWithAnimation; // 设置退出时是否有动画

-(IBAction)user_registe:(id)sender;						//点击“新用户注册”后的操作
-(IBAction)forgetpwdtest:(id)sender;					//点击“忘记密码操作”进入忘记密码页面
-(IBAction)clickedLoginBtn:(id)sender;					//输入用户名和密码后的登录操作             
-(IBAction)clickedSubmitRegisteBtn:(id)sender;			//提交注册按钮操作
-(IBAction)clickedChangeVerifyCode:(id)sender;			//验证码 “换一张”按钮操作
-(IBAction)clickedForgetpwdConfirm:(id)sender;			//点击忘记密码页面的确认按钮操作 
-(void)mysetCallTag:(NSNumber*)selectTag;				//设置调用标记，表明在什么页面调用了此类
-(IBAction)returnFront:(id)sender;						//点击 登录页或修改密码页的返回按钮
-(IBAction)onRegistePageLogin:(id)sender;				//在 注册页 或忘记密码页 点返回 按钮
-(IBAction)submitModifyPwd:(id)sender;					//提交修改密码

-(IBAction)tencentUnionLogin:(id)sender;
-(IBAction)sinaUnionLogin:(id)sender;
-(void)alipayUnionLogin:(id)sender;

-(IBAction)toggleShowPwd:(id)sender;
-(IBAction)rememberMe:(id)sender;                       //记住我
-(void)setThread;
-(void)startThread;										//线程
-(void)stopThread;
-(void)startLogin;										//本地判断后开始登录
-(void)startRegiste;									//本地判断后开始注册
-(void)startForgetPwd;									//本地判断后开始 忘记密码 提交
-(void)startModify;                                     //本地判断的修改密码操作
-(void)loginResultShow;									//登录结果显示
-(void)forgetPwdResultShow;								//忘记密码结果显示
-(void)modifyPwdShow;									//修改密码结果显示
-(void)showAlertView:(NSString*)alertStr;
-(void)setLoginview;
-(void)fromBuy:(NSNumber*)productIdStr merchanID:(NSNumber*)merchantId productNumber:(NSNumber*)number buyTag:(NSString*)tag MsgNamestr:(NSString*)notificationStr;
-(void)addCartResultShow:(NSString *)strResult;
-(NSMutableArray * )readFile;
-(void)setLoginviewUserName:(NSString*)userName;
//-(void)writeFile;
-(void)synCart:(NSString*)mytoken;
-(void)synCartWithEnterOrder;
-(void)showAlertView:(NSString *)alertTitle alertMsg:(NSString *)alertMsg alertTag:(int)alertTag;	// 显示提示框
-(void)showLoginResultAlertView:(NSString *)result;		// 显示登录结果提示框
-(void)startUnionLogin;
-(void)loginWithSinaAccount;
-(void)loginWithQQAccount;
-(IBAction)toAgreementView;								// 跳转到服务协议页面
-(IBAction)returnInAgreement;
-(IBAction)returninVerification;
-(IBAction)returnInPassSetting;
-(BOOL)validatePhoneNumField;                           //手机注册－检查手机号码
-(BOOL)validateCodeField;                               //手机注册－检查验证码
-(BOOL)validatePassField;                               //手机注册－检查注册用密码
-(void)timerFireMethod:(NSTimer*)theTimer;              //手机注册－重新获取验证码
-(IBAction)phoneregisteVerifyClick:(id)sender;          //手机注册－提交验证
-(IBAction)verificationSubmit:(id)sender;               //手机注册－提交验证码验证
-(IBAction)verificationReFetch:(id)sender;              //手机注册－重新获取验证码
-(IBAction)phoneRegisteSubmit:(id)sender;               //手机注册－提交注册
-(IBAction)toggleShowphoneRegistePwd:(id)sender;        //手机注册－切换显示密码

@end
