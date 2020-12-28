//
//  DPConfig.h
//  MasonryDemo
//
//  Created by Jared on 2020/12/17.
//  Copyright © 2020 Jared. All rights reserved.
//

#ifndef DPConfig_h
#define DPConfig_h

// 宽高
#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height

#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

//iphonex及以上 所有设备宏
#define IPHONE_X \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
((CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size)));})

#define CLFLOAT(num) (SCREEN_W == 320 ? ((num)*0.85) : (num)) * DPCDeviceUtils.scale

#define CL_StatusBarHeight      (IPHONE_X ? 44.f : 20.f)
#define CL_iPhoneXBottomSafeHeight   (IPHONE_X ? 34:0)
#define  LL_StatusBarAndNavigationBarHeight  (IPHONE_X ? 88.f : 64.f)

//weak && strong
#define WS(weakSelf)                      __weak __typeof(&*self)weakSelf = self;
#define SS(strongSelf)                    __strong __typeof(&*self)strongSelf = weakSelf;
#define WD(NP, OP)                      __weak __typeof(&*OP)NP = OP;
#define SD(NP, OP)                      __strong __typeof(&*OP)NP = OP;

#ifdef DEBUG
#define CLog(format, ...) printf("\n[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define CLog(format, ...)
#endif

#endif /* DPConfig_h */
