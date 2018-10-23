

#import "GCDSocketVC.h"
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>
#import "NSTimer+XJWeakTimer.h"
#import <SuperFramework/HAMLogOutputWindow.h>
#import <SuperFramework/SocketManager.h>


typedef NS_ENUM(NSInteger,SocketState) {
    SocketStateOffLineByServer = 0, //服务器掉线
    SocketStateOffLineByUser = 1, //用户主动
};
//#import <sys/errno.h> 错误码
@interface GCDSocketVC ()<GCDAsyncSocketDelegate>
@property (nonatomic,strong) GCDAsyncSocket *socket;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) NSTimer *heartTime;//心跳

@property (weak, nonatomic) IBOutlet UITextField *msgTF;
@property (weak, nonatomic) IBOutlet UITextField *localTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (nonatomic,assign) BOOL isOpen; //是否连接
@property (weak, nonatomic) IBOutlet UITextView *teLog;
@property (nonatomic,assign) int port;

@end

@implementation GCDSocketVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataArr = [NSMutableArray array];
    self.localTF.text = @"127.0.0.1";//localhost 127.0.0.1

    _isOpen = NO;
    
}
//创建
- (void)createSocket {
    
//    _port = XSocksOpenBySuggest(0, kPort, kSuggest);
    
    _port = XSocksOpen(0, kPort);
    
    self.portTF.text = [NSString stringWithFormat:@"%d",_port] ;
    _isOpen = YES;
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    BOOL isContent = [_socket connectToHost:self.localTF.text onPort:_port withTimeout:10 error:&error];
    if (isContent) {
        self.teLog.text = @">>>>>>>>已连接服务器";
    } else {
        NSLog(@"error %@",error.description);
    }
    //心跳
    [self addTimer];
}

//心跳 保持长链接
- (void)upupupheart {
    NSString *longContent = @"心跳";
    NSData *dataStream = [longContent dataUsingEncoding:NSUTF8StringEncoding];
    SocketManager * manager = [SocketManager shareSocketManager];
    [manager.socket writeData:dataStream withTimeout:1 tag:1];
   
}
//断开
- (void)disconnect {
    SocketManager *manager = [SocketManager shareSocketManager];
    [manager.socket setDelegate:nil];
    [manager.socket disconnect];
    [self removeTimer];
    NSLog(@"<<<<<断开连接");
    self.teLog.text = [self.teLog.text stringByAppendingString:@"<<<<<断开连接"];
}

#pragma mark - GCDAsyncSocket delegate
//成功回调
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    //单例
    SocketManager *manager = [SocketManager shareSocketManager];
    manager.socket = sock;

    [manager.socket readDataWithTimeout:-1 tag:0];
    self.teLog.text = [NSString stringWithFormat:@">>>>>>>>已连接到 %@，%d",host,port];
   NSLog(@">>>>>>>>已连接到 %@，%d",host,port);
}

//被动断开
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
   //error code 57
     [self disconnect];
    SocketManager *manager = [SocketManager shareSocketManager];
        if ( manager.socket.userData == SocketStateOffLineByServer ) {
                [self createSocket];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HAMLogOutputWindow printLog:@"用户自己断开"];
            });
            return;
        }
}

// wirte成功
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // 持续接收数据
    // 超时设置为附属，表示不会使用超时
    SocketManager * manager = [SocketManager shareSocketManager];
    [manager.socket readDataWithTimeout:-1 tag:tag];
    
}
//读消息
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // 在这里处理消息
    NSString *msg = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
  

    //持续接收服务端的数据
     SocketManager * manager = [SocketManager shareSocketManager];
    [manager.socket readDataWithTimeout:-1 tag:tag];
    [self showMessageWithStr:msg];
    NSLog(@"<<<<<<收到数据 %@",msg);
}

#pragma mark - 点击事件
- (IBAction)contentBtn:(id)sender {
    if ( _isOpen == NO ) {
        //连接
        [self createSocket];
    }
}

- (IBAction)disContentBtn:(id)sender {
    _isOpen = NO;
    [self disconnect];
}

- (IBAction)getPostBtn:(id)sender {
    [self get];
}

// 发消息
- (IBAction)sendBtn:(id)sender {
     [self.view endEditing:YES];
    NSData *data = [self.msgTF.text dataUsingEncoding:NSUTF8StringEncoding];
     SocketManager * manager = [SocketManager shareSocketManager];
      [manager.socket writeData:data withTimeout:10 tag:10];
}

-(void)addMessage:(NSString *)str{
    dispatch_async(dispatch_get_main_queue(), ^{
        [HAMLogOutputWindow printLog:self.msgTF.text];
    });
}

#pragma mark - 心跳
- (void)addTimer {
    __weak typeof(self) weakSelf = self;
    self.heartTime = [NSTimer xj_scheduledTimerWithTimeInterval:30 repeats:YES handlerBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf upupupheart];
    }];
}

- (void)removeTimer {
    [self.heartTime invalidate];
    self.heartTime = nil;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)dealloc {
    NSLog(@"释放 %@",[self class]);
    [self.heartTime invalidate];
}


#pragma mark - get post
- (void)postS {
    XSocksOpenBySuggest(0,80,8080);
    //1.确定请求路径
    NSURL *url = [NSURL URLWithString:KURL];
    //2.创建请求对象
    //请求对象内部默认已经包含了请求头和请求方法（GET）
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"post";
    //3.获得会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSInteger statusCode = [self showResoonseCode:response];
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        NSString *obj = [NSString stringWithFormat:@"post: statusCode %ld\n error:%@\n dic %@",statusCode,error.description,dict];
        
        [self showMessageWithStr:obj];
        
    }];
    
    //5.执行任务
    [dataTask resume];
}

- (void)post {
    XSocksOpenBySuggest(0,80,8080);
    NSURL *url = [NSURL URLWithString:KURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"post";
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            NSLog(@"连接错误 %@",connectionError);
            return;
        }
        NSInteger i = [self showResoonseCode:response];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *obj = [NSString stringWithFormat:@"postS: statusCode %ld\n error:%@\n dic %@",i,connectionError.description,dic];
        
        [self showMessageWithStr:obj];
                  
    }];
}

- (void)get {
    XSocksOpenBySuggest(0,80,8080);
    NSURL *url = [NSURL URLWithString:KURL];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            NSLog(@"连接错误 %@",connectionError);
            return;
        }
        NSInteger i = [self showResoonseCode:response];
        NSLog(@"state code %ld",i);
        
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&connectionError];
        
        NSString *obj = [NSString stringWithFormat:@"get: statusCode %ld\n error:%@\n dic %@",i,connectionError.description,dic];
        
        [self showMessageWithStr:obj];
        
    }];
}

//HTTP错误码
- (NSInteger)showResoonseCode:(NSURLResponse *)resp {
    NSHTTPURLResponse *http = (NSHTTPURLResponse *)resp;
    NSInteger respCode = [http statusCode];
    return respCode;
}

- (void)showMessageWithStr:(NSString *)obj {
    self.teLog.text = [self.teLog.text stringByAppendingFormat:@"%@\n", obj];
    
    NSLog(@"message: %@\n",obj);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
