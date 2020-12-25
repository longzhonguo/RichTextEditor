//
//  DPCChooseCoverView.h
//  VJRichTextEditor
//
//  Created by Jared on 2020/12/25.
//  Copyright © 2020 vj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DPCChooseCoverView : UIView

@property (nonatomic, strong) UILabel *numLab;
//学院列表
@property(nonatomic, copy) NSArray *category_list;

@end

NS_ASSUME_NONNULL_END
