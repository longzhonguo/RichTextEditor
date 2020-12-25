//
//  DPCCustomScrollView.m
//  VJRichTextEditor
//
//  Created by Jared on 2020/12/25.
//  Copyright © 2020 vj. All rights reserved.
//

#import "DPCCustomScrollView.h"

@implementation DPCCustomScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES; // 透传
}

@end
