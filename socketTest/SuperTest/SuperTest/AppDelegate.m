
#import "AppDelegate.h"
#import "GCDSocketVC.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //在第一行添加
    XSocksInit(kAppID);
    
    GCDSocketVC *socketVC = [[GCDSocketVC alloc] init];
    self.window.rootViewController = socketVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //在第一行添加
    XSocksRestore();
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    //在第一行添加
    XSocksSave();
}

@end

