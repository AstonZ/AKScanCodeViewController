//
//  AKScanCodeViewController.h
//  AKScanCodeViewController
//
//  Created by Aston on 15/11/17.
//  Copyright © 2015年 Aston. All rights reserved.
//



/*
 项目功能代码和图片来自开源项目: http://code4app.com/ios/529c2e95cb7e843c0a8b4c40
 自己需求与源码有点差异就改造了一下，主要改造
 1.适配iPhone设备
 2.取消timer动画，自定义了扫描动画
 3.覆盖黑色背景
 4.全屏取景，并且设置扫描热点在框框内
 
 */

#import <UIKit/UIKit.h>

@interface AKScanCodeViewController : UIViewController
/** 扫描结束回调  Block called when get result string from code **/
@property (nonatomic, copy) void(^blockEndScanWithText)(NSString *resultText);

@end
