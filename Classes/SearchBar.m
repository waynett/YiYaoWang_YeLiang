//
//  SearchBar.m
//  TheStoreApp
//
//  Created by jiming huang on 12-4-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SearchBar.h"

@implementation SearchBar

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self!=nil) {
//        [self setBackgroundColor:[UIColor clearColor]];
//        for (UIView *subview in self.subviews) {
//            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
//                [subview removeFromSuperview];
//                break;
//            }
//        }

        float version = [[[ UIDevice currentDevice ] systemVersion ] floatValue ];
        
        if ([ self respondsToSelector : @selector (barTintColor)]) {
            
            float  iosversion7_1 = 7.1 ;
            
            if (version >= iosversion7_1)
                
            {
                
                //iOS7.1
                
                [[[[ self . subviews objectAtIndex : 0 ] subviews ] objectAtIndex : 0 ] removeFromSuperview ];
                
                [ self setBackgroundColor :[ UIColor clearColor ]];
                
            }
            
            else
                
            {
                
                //iOS7.0
                
                [ self setBarTintColor :[ UIColor clearColor ]];
                
                [ self setBackgroundColor :[ UIColor clearColor ]];
                
            }
            
        }
        
        else
            
        {
            
            //iOS7.0 以下
            
            [[ self . subviews objectAtIndex : 0 ] removeFromSuperview ];
            
            [ self setBackgroundColor :[ UIColor clearColor ]];
            
        }
    }
    return self;
}

@end
