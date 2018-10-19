

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>
//固定的头部长度
//起始符(1Byte) + 目标地址(2byte) + 源地址(2byte) + 应用层数据长度(2byte) = 7Byte
#define kHeaderLength 7

typedef NS_ENUM(NSInteger,ServiceState) {
    ServiceStateOffLineByServer = 0, //服务器掉线
    ServiceStateOffLineByUser = 1, //用户主动
};


typedef void(^XJSocketBlock) (NSString *data);

@interface SocketManager : NSObject <GCDAsyncSocketDelegate>
@property (nonatomic,copy) XJSocketBlock socketBlock;
@property (nonatomic,strong) GCDAsyncSocket *socket;

+ (instancetype)shareSocketManager;

/**
 连接
 @param host 地址
 @param port 端口
 */
+  (BOOL)connectServer:(NSString *)host Port:(uint16_t)port;
//断开连接
+ (void)disConnectServer;

/**
 发送数据
 @param type tag值
 @param str 字符串
 */
- (void)sendMessageType:(int)type Str:(NSString *)str;

/**
 回调
 @param reciveBlock 接收到的数据
 */
- (void)reciveData:(XJSocketBlock)reciveBlock;


@end
