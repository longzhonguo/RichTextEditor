//
//  DPCFontStyleBar.h
//  VJRichTextEditor
//
//  Created by Jared on 2020/12/29.
//  Copyright © 2020 vj. All rights reserved.
//

#import <UIKit/UIKit.h>

//当前view高度
#define DPCFontBar_Height 257

@class DPCFontStyleBar;
@protocol DPCFontStyleBarDelegate<NSObject>
- (void)fontBar:(DPCFontStyleBar *)fontBar didClickBtn:(UIButton *)button;
- (void)fontBarResetNormalFontSize;
@end
@interface DPCFontStyleBar : UIView
@property (nonatomic,weak) id<DPCFontStyleBarDelegate> delegate;

@property (nonatomic,strong) UIButton *boldItem;
@property (nonatomic,strong) UIButton *underlineItem;
@property (nonatomic,strong) UIButton *italicItem;
//@property (nonatomic,strong) UIButton *justifyLeftItem;
//@property (nonatomic,strong) UIButton *justifyCenterItem;
//@property (nonatomic,strong) UIButton *justifyRightItem;
//@property (nonatomic,strong) UIButton *indentItem;
//@property (nonatomic,strong) UIButton *outdentItem;
//@property (nonatomic,strong) UIButton *unorderlistItem;
//@property (nonatomic,strong) UIButton *heading1Item;
//@property (nonatomic,strong) UIButton *heading2Item;
//@property (nonatomic,strong) UIButton *heading3Item;
@property (nonatomic, strong) UIButton *color_black;
@property (nonatomic, strong) UIButton *color_gray;
@property (nonatomic, strong) UIButton *color_orange;
@property (nonatomic, strong) UIButton *color_red;
@property (nonatomic, strong) UIButton *color_green;
@property (nonatomic, strong) UIButton *color_blue;
@property (nonatomic, strong) UIButton *color_purple;


- (void)updateFontBarWithButtonName:(NSString *)name;
@end
