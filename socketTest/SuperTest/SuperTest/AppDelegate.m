
#import "AppDelegate.h"
#import "GCDSocketVC.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    XSocksInit(kAppID);
    
    GCDSocketVC *socketVC = [[GCDSocketVC alloc] init];
    self.window.rootViewController = socketVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    XSocksRestore();
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    //关闭端口
    XSocksSave();
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
