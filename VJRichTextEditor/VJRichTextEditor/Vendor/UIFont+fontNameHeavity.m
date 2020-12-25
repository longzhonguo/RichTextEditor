//
//  UIFont+fontNameHeavity.m
//  DPEduProject
//
//  Created by 边广生 on 2019/12/18.
//  Copyright © 2019 bianguangsheng. All rights reserved.
//

#import "UIFont+fontNameHeavity.h"




@implementation UIFont (fontNameHeavity)
//常规
+ (UIFont *)getPingFangSCFontRegularWithSize:(CGFloat)ftSize{
    UIFont *font =  [UIFont fontWithName:@"PingFangSC-Regular" size: ftSize];
    return font;
}
//中等
+ (UIFont *)getPingFangSCFontMediumWithSize:(CGFloat)ftSize{
    UIFont *font =  [UIFont fontWithName:@"PingFangSC-Medium" size: ftSize];
;
    return font;
}
//中粗
+ (UIFont *)getPingFangSCFontSemiBoldWithSize:(CGFloat)ftSize{
    UIFont *font =   [UIFont fontWithName:@"PingFangSC-Semibold" size: ftSize];
;
    return font;
}
//纤细
+ (UIFont *)getPingFangSCFontThinWithSize:(CGFloat)ftSize{
    UIFont *font =   [UIFont fontWithName:@"PingFangSC-Thin" size: ftSize];
;
    return font;
}
//Helvetica-Bold粗
+ (UIFont *)getHelveticaFontBoldWithSize:(CGFloat)ftSize{
    UIFont *font =   [UIFont fontWithName:@"Helvetica-Bold" size:ftSize];
    
    return font;
}


@end
