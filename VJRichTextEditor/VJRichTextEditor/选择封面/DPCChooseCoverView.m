//
//  DPCChooseCoverView.m
//  VJRichTextEditor
//
//  Created by Jared on 2020/12/25.
//  Copyright © 2020 vj. All rights reserved.
//

#import "DPCChooseCoverView.h"
#import "UIViewExt.h"
#import "UIFont+fontNameHeavity.h"

@implementation DPCChooseCoverView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews{
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(16, 0, 24, 24)];
    imgV.image = [UIImage imageNamed:@"fbyd_xuanzefengmian"];
    [self addSubview:imgV];
    
    UILabel *aLabel = [[UILabel alloc]initWithFrame:CGRectMake(imgV.right+4, 0, 56, 24)];
    aLabel.text = [NSString stringWithFormat:@"选择封面"];
    aLabel.font = [UIFont getPingFangSCFontSemiBoldWithSize:14];
    aLabel.textColor = UIColorFromRGBA(0x36404A, 1);
    [self addSubview:aLabel];
    
    self.numLab = [[UILabel alloc]initWithFrame:CGRectMake(aLabel.right+4, 0, 181, 24)];
    self.numLab.text = [NSString stringWithFormat:@"（可选取1张、3张图片设为封面）"];
    self.numLab.font = [UIFont getPingFangSCFontRegularWithSize:12];
    self.numLab.textColor = UIColorFromRGBA(0xA3A8AB, 1);
    [self addSubview:self.numLab];
    
    UIView *addCoverImgV = [[UIView alloc] initWithFrame:CGRectMake(16, imgV.bottom + 16, SCREEN_W-32, 82)];
    [self addSubview:addCoverImgV];
    
    UIButton *addImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addImgBtn.frame = CGRectMake(0, 0, 82, 82);
    addImgBtn.backgroundColor = UIColorFromRGBA(0xEFEFEF, 1);
    addImgBtn.layer.masksToBounds = YES;
    addImgBtn.layer.cornerRadius = 8;
    [addImgBtn setImage:[UIImage imageNamed:@"fbyd_addImg"] forState:UIControlStateNormal];
    [addImgBtn addTarget:self action:@selector(addBiaoQian) forControlEvents:UIControlEventTouchUpInside];
    [addCoverImgV addSubview:addImgBtn];
    
    UIImageView *imgV1 = [[UIImageView alloc] initWithFrame:CGRectMake(16, addCoverImgV.bottom+20, 24, 24)];
    imgV1.image = [UIImage imageNamed:@"fbyd_xuanzefengmian"];
    [self addSubview:imgV1];
    
    UILabel *aLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(imgV1.right+4, imgV1.top, 56, 24)];
    aLabel1.text = [NSString stringWithFormat:@"添加学院"];
    aLabel1.font = [UIFont getPingFangSCFontSemiBoldWithSize:14];
    aLabel1.textColor = UIColorFromRGBA(0x36404A, 1);
    [self addSubview:aLabel1];
    
    UIView *collegeBgV = [[UIView alloc] initWithFrame:CGRectMake(0, imgV1.bottom+7, SCREEN_W, 83)];
    collegeBgV.userInteractionEnabled=YES;
    collegeBgV.backgroundColor=[UIColor yellowColor];//test
    [self addSubview:collegeBgV];
    
    self.category_list = @[@"设计", @"美术", @"国画", @"书法", @"短视频", @"篆刻", @"公益", @"兴趣"];
    for (int i = 0; i<self.category_list.count; i++) {
//        NSDictionary *dic  = self.category_list[i];
//        NSString *collegeName =[dic objectForKey:@"collegeName"];
//
//        UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(6+(i%5)*(76-12),(button.bottom+5)+(i/5)*(47), 76, 47)];
//        [but addTarget:self action:@selector(clickedIndex:) forControlEvents:UIControlEventTouchUpInside];
//        but.tag = 120+i;
//        collegeName= [collegeName stringByReplacingOccurrencesOfString:@"学院" withString:@""];
//        [but setImage:[UIImage imageNamed:@"发布矩形备份 5"] forState:UIControlStateNormal];
//
//        NSString *collegeid=[NSString stringWithFormat:@"%@",[dic objectForKey:@"collegeId"]];
//        if (self.categoryId.length>0&&self.categoryId!=nil) {
//            if ([self.categoryId isEqualToString:collegeid]) {
//                [but setImage:[UIImage imageNamed:@"发布矩形备份 7"] forState:UIControlStateNormal];
//                school_but = but;
//
//            }
//        }
//
//        but.adjustsImageWhenDisabled=NO;
//        but.adjustsImageWhenHighlighted=NO;
//        UILabel *butlable = [[UILabel alloc] initWithFrame:CGRectMake(26, 0, 76, 46)];
//        butlable.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
//        butlable.text =collegeName;
//        butlable.textColor = UIColorFromRGBA(0x36404A, 1);
//        [but addSubview:butlable];
//        butlable.userInteractionEnabled=NO;
//
//        if ([collegeName isEqualToString:@"短视频"]) {
//            butlable.frame=CGRectMake(20, 0, 76, 46);
//        }
//
//        [_SchoolView addSubview:but];
//
//        if (i==self.category_list.count-1) {
//            _SchoolView.frame=CGRectMake(0,  _imageBgView.bottom+7, ScreenWidth, but.bottom+39);
//        }
    }
    
    UIImageView *imgV2 = [[UIImageView alloc] initWithFrame:CGRectMake(16, collegeBgV.bottom+13, 24, 24)];
    imgV2.image = [UIImage imageNamed:@"fbyd_xuanzefengmian"];
    [self addSubview:imgV2];
    
    UILabel *aLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(imgV2.right+4, imgV2.top, 56, 24)];
    aLabel2.text = [NSString stringWithFormat:@"添加标签"];
    aLabel2.font = [UIFont getPingFangSCFontSemiBoldWithSize:14];
    aLabel2.textColor = UIColorFromRGBA(0x36404A, 1);
    [self addSubview:aLabel2];
    
    UIImageView *bq_rightImgV = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_W-16-12, imgV2.top+6, 12, 12)];
    bq_rightImgV.image = [UIImage imageNamed:@"fbyd_进入"];
    bq_rightImgV.userInteractionEnabled = YES;
    [bq_rightImgV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addBiaoQian)]];
    [self addSubview:bq_rightImgV];
    
    UILabel *aLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_W-32-144, imgV2.top, 144, 24)];
    aLabel3.text = [NSString stringWithFormat:@"快去添加你感兴趣的标签吧"];
    aLabel3.font = [UIFont getPingFangSCFontRegularWithSize:12];
    aLabel3.textAlignment = NSTextAlignmentRight;
    aLabel3.textColor = UIColorFromRGBA(0xA3A8AB, 1);
    aLabel3.backgroundColor = [UIColor clearColor];
    aLabel3.userInteractionEnabled = YES;
    [aLabel3 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addBiaoQian)]];
    [self addSubview:aLabel3];

}

- (void)addBiaoQian{
    NSLog(@"添加标签");
}

@end
