//
//  ViewController.m
//  VJRichTextEditor
//
//  Created by 侯卫嘉 on 2019/6/26.
//  Copyright © 2019 vj. All rights reserved.
//

#import "ViewController.h"
#import "RichTextEditorDemo.h"
#import "DPCCustomScrollView.h"

#define EditorHeight 320

@interface ViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) DPCCustomScrollView *scrollV;
@property (nonatomic, strong) RichTextEditorDemo *demoVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    RichTextEditorDemo *vc = [[RichTextEditorDemo alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(100, 100, 100, 60);
//    [btn setTitle:@"测试" forState:UIControlStateNormal];
//    btn.backgroundColor = [UIColor cyanColor];
//    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];

    self.scrollV = [[DPCCustomScrollView alloc] initWithFrame:CGRectMake(0, LL_StatusBarAndNavigationBarHeight, SCREEN_W, SCREEN_H)];
    self.scrollV.contentSize = CGSizeMake(SCREEN_W, EditorHeight+414+44+LL_StatusBarAndNavigationBarHeight);
//    self.scrollV.contentOffset = CGPointMake([UIScreen mainScreen].bounds.size.width, 0);
//    self.scrollV.pagingEnabled = YES;
    self.scrollV.delegate = self;
    self.scrollV.bounces = NO;
    self.scrollV.showsVerticalScrollIndicator = NO;
    self.scrollV.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.scrollV];

    self.demoVC = [[RichTextEditorDemo alloc]init];
    [self addChildViewController:self.demoVC];
    [self.scrollV addSubview:self.demoVC.view];
//    [self didMoveToParentViewController:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.demoVC.isEditorScrollEnd) {
        [self.scrollV setContentOffset:scrollView.contentOffset];
    }else{
        [self.scrollV setContentOffset:CGPointZero];
    }
}


@end
