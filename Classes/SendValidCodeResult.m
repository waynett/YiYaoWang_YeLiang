//
//  SendValidCodeResult.m
//  TheStoreApp
//
//  Created by yiming dong on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SendValidCodeResult.h"

@implementation SendValidCodeResult
@synthesize resultCode, errorInfo;

-(void)dealloc
{
    [resultCode release];
    [errorInfo release];
    
    [super dealloc];
}

@end
