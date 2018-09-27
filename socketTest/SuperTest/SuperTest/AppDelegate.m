

#import "AppDelegate.h"
#import "GCDSocketVC.h"



//#import "xsocks.h"

@interface AppDelegate ()
{
    NSString *appId;
    int port;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //启动SDK并初始化
    //    XSocksInit(@"");
    
//    XSocksInit(kAppID);
    //可在此处打开所有app中用到的源机端口，也可在调用的页面打开
    //此测试程序只用到了5678端口，执行一次XSocksOpen方法即可
    //如果有多个端口需执行多次，端口打开失败返回-1，
    //调用方式：127.0.0.1:[port]，调用前判断port是否获取到正确的端口值（不等于-1）
//    int port = XSocksOpen(0, kPort, kSuggest);//0,80,5678
//    NSLog(@"port is %d",port);
    
    GCDSocketVC *socketVC = [[GCDSocketVC alloc] init];
    self.window.rootViewController = socketVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    int port = XSocksOpen(0, kPort, kSuggest);
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    //关闭端口
//    XSocksClose(0, kPort);
}
@end

/*
 //要测试的各种状态
 wifi open 后没网，点连接显示连接又断开一直重复
 wifi open 后台断网 wifi 能发送
 wifi open 后台断网 4g 不能发送
 
 4G open 后没网 点连接 显示连接又断开一直重复
 4G open 后台 4G 能发送
 4G open 后台 wifi 能发送
 
 没网 open 点连接 显示连接又断开一直重复
 没网 open 后有网 点连接 能发送
 */
