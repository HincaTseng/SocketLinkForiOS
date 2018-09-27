//
//  XJNetTool.h
//  XJNetWorkTool
//
//  Created by 曾宪杰 on 2018/8/20.
//  Copyright © 2018年 zengxianjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIKit.h>

@protocol xjDiagnoDelegate <NSObject>
- (void)xjDiagnoBegin;
- (void)xjDiagnoShowInfo:(NSString *)info;//展示UI中
- (void)xjDiagnoEnd:(NSString *)allInfo;

@end

typedef NS_ENUM(NSInteger,NetWork)
{
    NetWork_NONE = 0,
    NetWork_2G,
    NetWork_3G,
    NetWork_4G,
    NetWork_5G,
    NetWork_WIFI
};

@interface XJNetTool : NSObject

@property (nonatomic,weak,readwrite) id <xjDiagnoDelegate> delegate;
@property (nonatomic, retain) NSString *dormain;  //接口域名
///获取其他再说吧。。。
- (instancetype)initWithAppName:(NSString *)appName Appversion:(NSString *)appVersion Dormain:(NSString *)theDormain;
//开始
- (void)begin;

+ (NetWork)getNetWorkTypeFromStatusBar;



@end


@interface XJAddress : NSObject


@end
