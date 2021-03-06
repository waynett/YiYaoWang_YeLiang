//
//  PhoneSplash.m
//  TheStoreApp
//
//  Created by yuan jun on 13-4-16.
//
//

#import "PhoneSplash.h"
#import "CentralMobileFacadeService.h"
#import "GlobalValue.h"
#import "TheStoreAppAppDelegate.h"
#import "StartupPicVO.h"

static PhoneSplash * singleton;

@implementation PhoneSplash
@synthesize launchIv;
+ (PhoneSplash *)sharedInstance
{
    if (singleton==nil) {
        singleton = [[PhoneSplash alloc] init]; ;
    }
    return singleton; 
}
-(void)dealloc{
    [launchIv release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self != nil) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        NSString *splashName;
        if (screenBounds.size.height <= 480.0) {
            splashName = @"Default";
        } else {
            splashName = @"Default-568h";
        }
        
        launchIv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:splashName]];
        launchIv.userInteractionEnabled=YES;
        launchIv.backgroundColor = [UIColor blackColor];
        launchIv.frame = screenBounds;
        
//        [NSThread detachNewThreadSelector:@selector(fetchResource) toTarget:self withObject:nil];
        [self delayRemove:[NSNumber numberWithInt:6]];
    }
    return self;
}

-(void)fetchResource{
    NSAutoreleasePool* pool=[[NSAutoreleasePool alloc] init];
    CentralMobileFacadeService* ser=[[[CentralMobileFacadeService alloc] init] autorelease];
  UIScreenMode* preferredMode= [UIScreen mainScreen].preferredMode;
    int h=(int)preferredMode.size.height;
    int w=(int)preferredMode.size.width;
    NSArray* ar=[ser getStartupPicVOList:[GlobalValue getGlobalValueInstance].trader Size:[NSString stringWithFormat:@"%d*%d",h,w] SiteType:[NSNumber numberWithInt:1]];
    if (ar!=nil) {
        StartupPicVO*vo=[OTSUtility safeObjectAtIndex:0 inArray:ar];
        [self performSelectorOnMainThread:@selector(applyData:) withObject:vo.picUrl waitUntilDone:NO];
    }else{
        [self performSelectorOnMainThread:@selector(delayRemove:) withObject:[NSNumber numberWithInt:4] waitUntilDone:NO];
    }
    [pool release];
}

-(void)applyData:(NSString*)picUrl{
//    [[SDWebDataManager sharedManager] downloadWithURL:[NSURL URLWithString:@"http://d6.yihaodianimg.com/N02/M0A/2C/97/CgQCsFEsdkmAR5PqAACSvvsvXbk73000.jpg"] delegate:self];
    [[SDWebDataManager sharedManager] downloadWithURL:[NSURL URLWithString:picUrl] delegate:self];
    [self delayRemove:[NSNumber numberWithInt:4]];
}
-(void)delayRemove:(NSNumber*)delayTime{
    [self performSelector:@selector(removeSplash) withObject:nil afterDelay:delayTime.intValue];
}


-(void)recoverSplash{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    NSString *splashName;
    if (screenBounds.size.height <= 480.0) {
        splashName = @"Default";
    } else {
        splashName = @"Default-568h";
    }
    launchIv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:splashName]];
    launchIv.backgroundColor = [UIColor blackColor];
    launchIv.frame = screenBounds;

     [self showSplash];
//     [self delayRemove:[NSNumber numberWithInt:3]];
}
/**
 *  功能:显示渐变画面
 */
- (void)showSplash
{
    [SharedDelegate.tabBarController.view addSubview:launchIv];
}

/**
 *  功能:移出渐变画面
 */
- (void)removeSplash
{
    if (launchIv != nil) {
        CATransition *animation = [CATransition animation];
        animation.duration = 1.0f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        [animation setType:kCATransitionFade];
        [SharedDelegate.window.layer addAnimation:animation forKey:nil];
        [launchIv removeFromSuperview];
        launchIv = nil;
    }
}

#pragma mark - SDWebDataManagerDelegate
- (void)webDataManager:(SDWebDataManager *)dataManager didFinishWithData:(NSData *)aData isCache:(BOOL)isCache
{
    CATransition *animation = [CATransition animation];
	animation.duration = 2.0f;
	animation.timingFunction = UIViewAnimationCurveEaseInOut;
	[animation setType:kCATransitionFade];
    
    [launchIv.layer addAnimation:animation forKey:nil];
    UIImage* img=[[UIImage alloc] initWithData:aData];
    if (img!=nil) {
        [launchIv setImage:img];
    }
    
    [self performSelector:@selector(removeSplash) withObject:nil afterDelay:4];
}

- (void)webDataManager:(SDWebDataManager *)dataManager didFailWithError:(NSError *)error
{
    [self performSelector:@selector(removeSplash) withObject:nil afterDelay:4];
}

@end
