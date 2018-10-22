
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

