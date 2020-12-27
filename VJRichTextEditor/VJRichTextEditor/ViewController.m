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

@interface ViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) DPCCustomScrollView *scrollV;
@property (nonatomic, strong) RichTextEditorDemo *demoVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(100, 100, 100, 60);
//    [btn setTitle:@"测试" forState:UIControlStateNormal];
//    btn.backgroundColor = [UIColor cyanColor];
//    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
//
//    [self performSelector:@selector(btnAction)];
    self.scrollV = [[DPCCustomScrollView alloc] initWithFrame:self.view.frame];
    self.scrollV.contentSize = CGSizeMake(SCREEN_W, SCREEN_H*2);
//    self.scrollV.contentOffset = CGPointMake([UIScreen mainScreen].bounds.size.width, 0);
//    self.scrollV.pagingEnabled = YES;
    self.scrollV.delegate = self;
    self.scrollV.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.scrollV];
    
    self.demoVC = [[RichTextEditorDemo alloc]init];
    [self addChildViewController:self.demoVC];
    [self.scrollV addSubview:self.demoVC.view];
//    [self didMoveToParentViewController:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.scrollV setContentOffset:CGPointZero];
}


@end
