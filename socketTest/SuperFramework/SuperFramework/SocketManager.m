

#import "SocketManager.h"
#import "HAMLogOutputWindow.h"

@implementation SocketManager
//连接到服务器
+ (BOOL)connectServer:(NSString *)host Port:(uint16_t)port {
    static BOOL success;
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:[SocketManager shareSocketManager] delegateQueue:dispatch_get_global_queue(0, 0)];
    [SocketManager shareSocketManager].socket = socket;
    if ( !socket.isConnected ) {
        NSError *error;
        success = [socket connectToHost:host onPort:port error:&error];
        if ( error != nil ) {
            NSLog(@"%@",error.localizedDescription);
        }
    }
    return success;
}

//连接成功
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [HAMLogOutputWindow printLog:@">>>连接成功"];
    [[SocketManager shareSocketManager].socket readDataWithTimeout:-1 tag:0];
}

//断开连接
+ (void)disConnectServer {
    [HAMLogOutputWindow printLog:@">>>断开连接"];
    [SocketManager shareSocketManager].socket.delegate = nil;
    [[SocketManager shareSocketManager].socket disconnect];
    [SocketManager shareSocketManager].socket = nil;
}

//断开的回调
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    [HAMLogOutputWindow printLog:@">>>断开连接的回调"];
    if ( err ) {
        NSString *er = [NSString stringWithFormat:@">>>断开连接的回调%@",err.localizedDescription];
         [HAMLogOutputWindow printLog:er];
    }
}

//接收信息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ( msg.length > 0 ) {
        if ( self.socketBlock ) {
            self.socketBlock(msg);
        }
    }
    [[SocketManager shareSocketManager].socket readDataWithTimeout:-1 tag:tag];
}

//发送信息
- (void)sendMessageType:(int)type Str:(NSString *)str {
    NSString *obj = [[NSString alloc] initWithString:str];
    NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
    NSString *ob = [NSString stringWithFormat:@">>>发送的消息是 %@",obj];
    if ( obj.length > 0 ) {
        [HAMLogOutputWindow printLog:ob];
        [[SocketManager shareSocketManager].socket writeData:data withTimeout:-1 tag:type];
    }
}

//发送成功回调
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [HAMLogOutputWindow printLog:@">>>发送成功回调"];
}

//收到数据回调
- (void)reciveData:(XJSocketBlock)reciveBlock {
    self.socketBlock = reciveBlock;
}

+ (instancetype)shareSocketManager {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
@end
