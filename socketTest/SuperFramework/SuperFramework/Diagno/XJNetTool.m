//
//  XJNetTool.m
//  XJNetWorkTool
//
//  Created by 曾宪杰 on 2018/8/20.
//  Copyright © 2018年 zengxianjie. All rights reserved.
//

#import "XJNetTool.h"
#include <sys/time.h>

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/socket.h>

#include <resolv.h>
#include <dns.h>

#import <sys/sysctl.h>
#import <netinet/in.h>

#if TARGET_IPHONE_SIMULATOR
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 110000 //iOS11，用数字不用宏定义的原因是低版本XCode不支持110000的宏定义
#include <net/route.h>
#else
#include "Route.h"
#endif
#else
#include "Route.h"
#endif /*the very same from google-code*/


#include <sys/time.h>

#define ROUNDUP(a) ((a) > 0 ? (1 + (((a)-1) | (sizeof(long) - 1))) : sizeof(long))

@interface XJNetTool()
{
    NSString *_appName;
    NSString *_appVersion;
    NSString *_appBuild;
    NSString *_appUUID;
    
    NSString *_carrierName;
    NSString *_carrierCountryCode;
    NSString *_carrierMobileCountryCode;
    NSString *_carrierNetCode;
    
    NSMutableString *_logInfo;  //记录log日志
   
    NSArray *_hostAddress;
    
    NetWork _netWork_Type;
}

@end

@implementation XJNetTool

- (instancetype)initWithAppName:(NSString *)appName Appversion:(NSString *)appVersion Dormain:(NSString *)theDormain {
    if (self = [super init]) {
        _appName = appName;
        _appVersion = appVersion;
        _dormain = theDormain;
        _logInfo = [[NSMutableString alloc] initWithCapacity:20];
    }
    return self;
}

#pragma mark - begin
-(void)begin {
    if ([_dormain isEqualToString:@""] || _dormain) {
        return;
    }
    [_logInfo setString:@""];
    [self appTitle:@"开始诊断" Info:@"..."];
    
    [self showAppInfo];
    
    if (_netWork_Type == 0) {
        [self appTitle:@"\n 未联网,请检查网络" Info:@"诊断结束"];
        if (self.delegate && [self.delegate respondsToSelector:@selector(xjDiagnoEnd:)]) {
            [self.delegate xjDiagnoEnd:_logInfo];
        }
        return;
    }
}

#pragma mark - 基本信息
- (void)showAppInfo {
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    //在plist文件中添加 Bundle display name
    if (!_appName || [_appName isEqualToString:@""]) {
        _appName = info[@"CFBundleDisplayName"];
    }
    [self appTitle:@"AppName" Info:_appName];
    
    if (!_appVersion ||[_appVersion isEqualToString:@""]) {
        _appVersion = info[@"CFBundleShortVersionString"];
    }
    [self appTitle:@"AppVersion" Info:_appVersion];
 
    if (!_appBuild || [_appBuild isEqualToString:@""]) {
        _appBuild = info[@"CFBundleVersion"];
    }
    [self appTitle:@"AppBuild" Info:_appBuild];

    
    //----------------------
    UIDevice *device = [UIDevice currentDevice];
    
    [self appTitle:@"deviceSystem" Info:[device systemName]];
    
    [self appTitle:@"deviceVersion" Info:[device systemVersion]];
    
    if (!_appUUID || [_appUUID isEqualToString:@""]) {
        _appUUID = [self uuid];
    }
    [self appTitle:@"appUUID" Info:_appUUID];
    
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    if (carrier != NULL) {
        _carrierName = carrier.carrierName;
        _carrierCountryCode = carrier.isoCountryCode;
        _carrierMobileCountryCode = carrier.mobileCountryCode;
        _carrierNetCode = carrier.mobileNetworkCode;
    } else {
        _carrierName = @"";
        _carrierCountryCode = @"";
        _carrierMobileCountryCode = @"";
        _carrierNetCode = @"";
    }
    
    [self appTitle:@"carrierName" Info:_carrierName];
    [self appTitle:@"carrierCountryCode" Info:_carrierCountryCode];
    [self appTitle:@"carrierMobileCountryCode" Info:_carrierMobileCountryCode];
    [self appTitle:@"carrierNetCode" Info:_carrierNetCode];
    [self localNetEnvironmet];
    
}

#pragma mark - 网络信号
- (void)localNetEnvironmet {
    NSArray *netArr = [NSArray arrayWithObjects:@"2G",@"3G",@"4G",@"5G",@"wifi", nil];
    _netWork_Type = [XJNetTool getNetWorkTypeFromStatusBar];
    if (_netWork_Type == 0) {
        [self appTitle:@"network type" Info:@"NO connection"];
    } else {
        
        if (_netWork_Type > 0 && _netWork_Type < 6) {
            [self appTitle:@"" Info:netArr[_netWork_Type -1]];
        }
        //判断dns解析
        long time_start = [XJNetTool getMicroSeconds];
//        _hostAddress = [NSArray arrayWithArray:<#(nonnull NSArray *)#>]
    }
    
}

+ (NetWork)getNetWorkTypeFromStatusBar {
    UIApplication *application = [UIApplication sharedApplication];
    NetWork network = NetWork_NONE;
    if ([[application valueForKeyPath:@"_statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        //
        NSArray *views = [[[[application valueForKeyPath:@"statusBar"] valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
        for (UIView *view in views) {
            for (id obj in view.subviews) {
                //wifi
                if ([obj isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                    network = NetWork_WIFI;
                }
                //蜂窝
                if ([obj isKindOfClass:NSClassFromString(@"_UIStatusBarString")]) {
                    if ([[obj valueForKey:@"_originalText"] containsString:@"2G"]) {
                        network = NetWork_2G;
                    }
                    if ([[obj valueForKey:@"_originalText"] containsString:@"3G"]) {
                        network = NetWork_3G;
                    }
                    if ([[obj valueForKey:@"_originalText"] containsString:@"4G"]) {
                        network = NetWork_4G;
                    }
                    if ([[obj valueForKey:@"_originalText"] containsString:@"5G"]) {
                        network = NetWork_5G;
                    }
                }
            }
        }
    }
    else {
        NSArray *subviews = [[[[UIApplication sharedApplication]valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
        NSNumber *dataNetworkItem = nil;
        
        for (id obj in subviews) {
            if ([obj isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
                dataNetworkItem = obj;
                break;
            }
        }
        NSNumber *num = [dataNetworkItem valueForKey:@"dataNetworkType"];
        network = [num intValue];
    }
   
    return network;
    
}

#pragma mark - DNS address

+ (NSArray *)outPutDNSServers {
    res_state res = malloc(sizeof(struct __res_state));
    int result = res_ninit(res);
    
    NSMutableArray *servers = [[NSMutableArray alloc] init];
    if (result == 0) {
        union res_9_sockaddr_union *addr_union = malloc(res->nscount * sizeof(union res_9_sockaddr_union));
        res_getservers(res,addr_union,res->nscount);
        
        for (int i = 0; i < res->nscount; i++) {
            if (addr_union[i].sin.sin_family == AF_INET) {
                char ip[INET_ADDRSTRLEN];
                inet_ntop(AF_INET, &(addr_union[i].sin.sin_addr), ip, INET_ADDRSTRLEN);
                NSString *dnsIP = [NSString stringWithUTF8String:ip];
                [servers addObject:dnsIP];
            }
            else if (addr_union[i].sin6.sin6_family == AF_INET6) {
                char ip[INET6_ADDRSTRLEN];
                inet_ntop(AF_INET6, &(addr_union[i].sin6.sin6_addr),ip, INET6_ADDRSTRLEN);
                NSString *dnsIP = [NSString stringWithUTF8String:ip];
                [servers addObject:dnsIP];
            }
            else {
                NSLog(@"no fanily");
            }
        }
        
    }
    res_9_nclose(res);
    free(res);
    return [NSArray arrayWithArray:servers];
}




#pragma mark - Private Method
- (void)appTitle:(NSString *)title Info:(NSString *)info {
    if (info == nil) info = @"";
    [_logInfo appendString:info];
    [_logInfo appendString:@"\n"];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(xjDiagnoShowInfo:)]) {
        [self.delegate xjDiagnoShowInfo:[NSString stringWithFormat:@"%@-%@",title,info]];
    }
}

- (NSString *)uuid {
    NSString *app_uuid = @"";
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    app_uuid = [NSString stringWithString:(__bridge NSString *)uuidString];
    CFRelease(uuidRef);
    CFRelease(uuidString);
    return app_uuid;
}




@end


