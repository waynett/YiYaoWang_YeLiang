//
//  OTSClassInvoker.h
//  TheStoreApp
//
//  Created by yiming dong on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTSClassInvoker : NSObject
{
    NSArray*        invokeClasses;
    Class           theRespondClass;
}
@property(copy)NSArray*        invokeClasses;
@end
