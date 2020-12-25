//
//  UIFont+fontNameHeavity.h
//  DPEduProject
//
//  Created by 边广生 on 2019/12/18.
//  Copyright © 2019 bianguangsheng. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (fontNameHeavity)
+ (UIFont *)getPingFangSCFontRegularWithSize:(CGFloat)ftSize;
+ (UIFont *)getPingFangSCFontMediumWithSize:(CGFloat)ftSize;
+ (UIFont *)getPingFangSCFontSemiBoldWithSize:(CGFloat)ftSize;
//纤细
+ (UIFont *)getPingFangSCFontThinWithSize:(CGFloat)ftSize;
//Helvetica-Bold粗
+ (UIFont *)getHelveticaFontBoldWithSize:(CGFloat)ftSize;
@end

NS_ASSUME_NONNULL_END
