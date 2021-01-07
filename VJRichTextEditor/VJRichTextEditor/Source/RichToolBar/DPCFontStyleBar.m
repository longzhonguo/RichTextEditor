//
//  DPCFontStyleBar.m
//  VJRichTextEditor
//
//  Created by Jared on 2020/12/29.
//  Copyright © 2020 vj. All rights reserved.
//

#import "DPCFontStyleBar.h"
#import "UIControl+KWButtonExtension.h"
////最右边按钮宽度
//#define KWRightButton_Width 44
//
////所有按钮宽度
//#define KWItems_Width 46
//
//#define COLOR(r,g,b,a) ([UIColor colorWithRed:(float)r/255.f green:(float)g/255.f blue:(float)b/255.f alpha:a])
@interface DPCFontStyleBar()
//@property (nonatomic,strong) UIView *scroBarView;
//@property (nonatomic,strong) UIButton *autoScroBtn;
//@property (nonatomic,strong) NSArray *items;
@property (nonatomic, strong) UIView *wzys_bgV;
@property (nonatomic, copy) NSString *lastSelectOrderTag;

@end

@implementation DPCFontStyleBar

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupViews:frame];
    }
    return self;
}

- (void)setupViews:(CGRect)frame{
    self.backgroundColor = UIColor.yellowColor;
    
    UILabel *wzgsLab = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, 48, 17)];
    wzgsLab.text = [NSString stringWithFormat:@"文字格式"];
    wzgsLab.font = [UIFont getPingFangSCFontRegularWithSize:12];
    wzgsLab.textColor = UIColorFromRGBA(0x4F5C61, 1);
    [self addSubview:wzgsLab];
    
    UIView *wzgs_bgV = [[UIView alloc] initWithFrame:CGRectMake(16, wzgsLab.bottom+16, SCREEN_W-32, 50)];
    wzgs_bgV.backgroundColor = UIColorFromRGBA(0xF7F7F7, 1);
//    UIRectCorner rectCorner = UIRectCornerAllCorners;
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:wzgs_bgV.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(14,14)];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = wzgs_bgV.frame;
//    maskLayer.path = maskPath.CGPath;
//    wzgs_bgV.layer.mask = maskLayer;
    wzgs_bgV.layer.cornerRadius = 4;
    wzgs_bgV.layer.masksToBounds = YES;
    [self addSubview:wzgs_bgV];

    NSArray *wzgsArr = @[self.boldItem, self.italicItem, self.underlineItem];
    NSInteger itemsCount = wzgsArr.count;
    CGFloat w = 110;
    CGFloat h = 50;
    CGFloat gap = (SCREEN_W-16-16-w*itemsCount)/(itemsCount-1);
    for (int i = 0; i < itemsCount; i++) {
        UIButton *button = wzgsArr[i];
        button.frame = CGRectMake(i*(w+gap), 0, w, h);
        button.tag = i;
//        UIRectCorner rectCorner = UIRectCornerAllCorners;
//        CGSize cornerSize = CGSizeMake(4,4);
//        if (i==0) {
//            rectCorner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
//        }else if (i==itemsCount-1){
//            rectCorner = UIRectCornerTopRight | UIRectCornerBottomRight;
//        }else{
//            cornerSize = CGSizeZero;
//        }
//        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds byRoundingCorners:rectCorner cornerRadii:cornerSize];
//        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//        maskLayer.frame = button.bounds;
//        maskLayer.path = maskPath.CGPath;
//        button.layer.mask = maskLayer;
        [wzgs_bgV addSubview:button];
    }
    
    UILabel *wzysLab = [[UILabel alloc] initWithFrame:CGRectMake(16, wzgs_bgV.bottom+12, 48, 17)];
    wzysLab.text = [NSString stringWithFormat:@"文字颜色"];
    wzysLab.font = [UIFont getPingFangSCFontRegularWithSize:12];
    wzysLab.textColor = UIColorFromRGBA(0x4F5C61, 1);
    [self addSubview:wzysLab];
    
    self.wzys_bgV = [[UIView alloc] initWithFrame:CGRectMake(16, wzysLab.bottom+12, SCREEN_W-32, 50)];
    self.wzys_bgV.backgroundColor = UIColorFromRGBA(0xF7F7F7, 1);
    self.wzys_bgV.layer.cornerRadius = 4;
    self.wzys_bgV.layer.masksToBounds = YES;
    [self addSubview:self.wzys_bgV];
    
    NSArray *wzysArr = @[self.color_black, self.color_gray, self.color_orange, self.color_red, self.color_green, self.color_blue, self.color_purple];
    NSInteger itemsCount1 = wzysArr.count;
    CGFloat ww = self.wzys_bgV.width/itemsCount1;
    CGFloat hh = 50;
    for (int i = 0; i < itemsCount1; i++) {
        UIButton *button = wzysArr[i];
        button.frame = CGRectMake(i*ww, 0, ww, hh);
        button.tag = i;
        [self.wzys_bgV addSubview:button];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!self.color_black.selected && !self.color_gray.selected && !self.color_orange.selected && !self.color_red.selected && !self.color_green.selected && !self.color_blue.selected && !self.color_purple.selected) {
        self.color_black.selected = YES;
    }
    
}

#pragma mark - 自定义方法
- (void)clickButton:(UIButton *)button{
    //处理字体颜色样式
    if (button == self.color_black || button == self.color_gray || button == self.color_orange || button == self.color_red || button == self.color_green || button == self.color_blue || button == self.color_purple) {
        if (!button.isSelected) {
            button.selected = !button.selected;
            for (UIButton *btn in self.wzys_bgV.subviews) {
                btn.selected = btn!=button ? NO : YES;
            }
        }
    }
    
    if (button == self.boldItem || button == self.italicItem || button == self.underlineItem) {
        button.selected = !button.selected;
    }
    
    CLog(@"点击了button %@",button.orderTag);

    if ([self.delegate respondsToSelector:@selector(fontBar:didClickBtn:)]) {
        [self.delegate fontBar:self didClickBtn:button];
    }
}

#pragma mark - 代理方法
- (void)updateFontBarWithButtonName:(NSString *)name{
    
     CLog(@"name = %@",name);
    
//    NSArray *itemNames = [name componentsSeparatedByString:@","];
//    NSMutableArray *tempArr = [NSMutableArray array];
//    for (NSString *orderTag in itemNames) {
//            for (UIButton *btn in self.items) {
//                if (![tempArr containsObject:btn] && btn.orderTag.length > 0) {
//                    if ([btn.orderTag isEqualToString:orderTag]) {
//                        btn.selected = YES;
//                         [tempArr addObject:btn];
//                    }
//                    else{
//                        btn.selected = NO;
//                    }
//                }
//            }
//    }
//
//
//    if (!self.heading1Item.selected && !self.heading2Item.selected && !self.heading3Item.selected) {
//        self.heading2Item.selected = YES;
//    }
    
}

#pragma mark - 懒加载
- (UIButton *)boldItem{
    if (!_boldItem) {
        _boldItem = [UIButton buttonWithType:UIButtonTypeCustom];
        [_boldItem setImage:[UIImage imageNamed:@"B"] forState:UIControlStateNormal];
        [_boldItem setImage:[UIImage imageNamed:@"BHOVER"] forState:UIControlStateSelected];
        _boldItem.orderTag = @"bold";
        _boldItem.backgroundColor = UIColorFromRGBA(0xEFEFEF, 1);
        [_boldItem addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _boldItem;
}
- (UIButton *)underlineItem{
    if (!_underlineItem) {
        _underlineItem = [UIButton buttonWithType:UIButtonTypeCustom];
        [_underlineItem setImage:[UIImage imageNamed:@"u"] forState:UIControlStateNormal];
        [_underlineItem setImage:[UIImage imageNamed:@"uHOVER"] forState:UIControlStateSelected];
        _underlineItem.orderTag = @"underline";
        _underlineItem.backgroundColor = UIColorFromRGBA(0xEFEFEF, 1);
        [_underlineItem addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _underlineItem;
}

- (UIButton *)italicItem{
    if (!_italicItem) {
        _italicItem = [UIButton buttonWithType:UIButtonTypeCustom];
        [_italicItem setImage:[UIImage imageNamed:@"I"] forState:UIControlStateNormal];
        [_italicItem setImage:[UIImage imageNamed:@"IHOVER"] forState:UIControlStateSelected];
        _italicItem.orderTag = @"italic";
        _italicItem.backgroundColor = UIColorFromRGBA(0xEFEFEF, 1);
        [_italicItem addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _italicItem;
}

- (UIButton *)color_black{
    if (!_color_black) {
        _color_black = [UIButton buttonWithType:UIButtonTypeCustom];
        [_color_black setImage:[UIImage imageNamed:@"bjqcolor_black"] forState:UIControlStateNormal];
        [_color_black setImage:[UIImage imageNamed:@"bjqcolor_blackhover"] forState:UIControlStateSelected];
        _color_black.orderTag = @"black";
        [_color_black addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _color_black;
}

- (UIButton *)color_gray{
    if (!_color_gray) {
        _color_gray = [UIButton buttonWithType:UIButtonTypeCustom];
        [_color_gray setImage:[UIImage imageNamed:@"bjqcolor_gray"] forState:UIControlStateNormal];
        [_color_gray setImage:[UIImage imageNamed:@"bjqcolor_grayhover"] forState:UIControlStateSelected];
        _color_gray.orderTag = @"gray";
        [_color_gray addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _color_gray;
}
- (UIButton *)color_orange{
    if (!_color_orange) {//14
        _color_orange = [UIButton buttonWithType:UIButtonTypeCustom];
        [_color_orange setImage:[UIImage imageNamed:@"bjqcolor_orange"] forState:UIControlStateNormal];
        [_color_orange setImage:[UIImage imageNamed:@"bjqcolor_orangehover"] forState:UIControlStateSelected];
        _color_orange.orderTag = @"orange";
        [_color_orange addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _color_orange;
}

- (UIButton *)color_red{
    if (!_color_red) {
        _color_red = [UIButton buttonWithType:UIButtonTypeCustom];
        [_color_red setImage:[UIImage imageNamed:@"bjqcolor_red"] forState:UIControlStateNormal];
        [_color_red setImage:[UIImage imageNamed:@"bjqcolor_redhover"] forState:UIControlStateSelected];
        _color_red.orderTag = @"red";
        [_color_red addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _color_red;
}

- (UIButton *)color_green{
    if (!_color_green) {
        _color_green = [UIButton buttonWithType:UIButtonTypeCustom];
        [_color_green setImage:[UIImage imageNamed:@"bjqcolor_green"] forState:UIControlStateNormal];
        [_color_green setImage:[UIImage imageNamed:@"bjqcolor_greenhover"] forState:UIControlStateSelected];
        _color_green.orderTag = @"green";
        [_color_green addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _color_green;
}
- (UIButton *)color_blue{
    if (!_color_blue) {
        _color_blue = [UIButton buttonWithType:UIButtonTypeCustom];
        [_color_blue setImage:[UIImage imageNamed:@"bjqcolor_blue"] forState:UIControlStateNormal];
        [_color_blue setImage:[UIImage imageNamed:@"bjqcolor_bluehover"] forState:UIControlStateSelected];
        _color_blue.orderTag = @"blue";
        [_color_blue addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _color_blue;
}

- (UIButton *)color_purple{
    if (!_color_purple) {
        _color_purple = [UIButton buttonWithType:UIButtonTypeCustom];
        [_color_purple setImage:[UIImage imageNamed:@"bjqcolor_purple"] forState:UIControlStateNormal];
        [_color_purple setImage:[UIImage imageNamed:@"bjqcolor_purplehover"] forState:UIControlStateSelected];
        _color_purple.orderTag = @"purple";
        [_color_purple addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _color_purple;
}
@end
