

#import "GCDSocketVC.h"

#import "NSTimer+XJWeakTimer.h"

//#import <sys/errno.h> 错误码
@interface GCDSocketVC ()<GCDAsyncSocketDelegate,XJSocketBackDelegate>
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
    
    [SocketManager shareSocketManager];
    [SocketManager shareSocketManager].delegate = self;
    [SocketManager connectServer:self.localTF.text Port:_port];
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
    [SocketManager disConnectServer];
}

#pragma mark - 点击事件
#pragma mark 连接
- (IBAction)contentBtn:(id)sender {
    //这样d再点连接就是断开重连。。。
//    if ( _isOpen == NO ) {
        //连接
        [self createSocket];
//    }
}

#pragma mark 断开连接
- (IBAction)disContentBtn:(id)sender {
//    _isOpen = NO;
    [self disconnect];
}

#pragma mark GET/POST连接
- (IBAction)getPostBtn:(id)sender {
    [self get];
}

#pragma mark 发消息
- (IBAction)sendBtn:(id)sender {
     [self.view endEditing:YES];
    NSData *data = [self.msgTF.text dataUsingEncoding:NSUTF8StringEncoding];
     SocketManager * manager = [SocketManager shareSocketManager];
      [manager.socket writeData:data withTimeout:10 tag:10];
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
        
        NSString *obj = [NSString stringWithFormat:@"post: statusCode %ld\n",statusCode];
        
        [self showMessageWithStr:obj];
        
    }];
    
    //5.执行任务
    [dataTask resume];
}

- (void)post {
    XSocksOpenBySuggest(0,80,8080);
//    XSocksOpen(0, kPort);
    
//    NSString *pr = [NSString stringWithFormat:@"%d",port];
//    NSString *ob = [NSString stringWithFormat:@"%@%@%@",@"http://127.0.0.1:",pr,@"/minaData/update/list/XcmjResLitst64"];
//
//    NSLog(@"Post \n port is %d\n pr is %@\n ob is %@\n",port,pr,ob);
    
    NSURL *url = [NSURL URLWithString:KURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"post";
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
#pragma clang diagnostic pop
        if (connectionError) {
            NSLog(@"连接错误 %@",connectionError);
            return;
        }
        NSInteger i = [self showResoonseCode:response];
        NSString *obj = [NSString stringWithFormat:@"postS: statusCode %ld\n",i];
        
        [self showMessageWithStr:obj];
                  
    }];
}

- (void)get {
    XSocksOpenBySuggest(0,80,8080);
//   int port = XSocksOpen(0, kPort);
    
//    NSString *pr = [NSString stringWithFormat:@"%d",port];
//    NSString *ob = [NSString stringWithFormat:@"%@%@%@",@"http://127.0.0.1:",pr,@"/minaData/update/list/XcmjResLitst64"];
//
//    NSLog(@"GET \n port is %d\n pr is %@\n ob is %@\n",port,pr,ob);
    
    NSURL *url = [NSURL URLWithString:KURL];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
#pragma clang diagnostic pop
        if (connectionError) {
            NSLog(@"连接错误 %@",connectionError);
            return;
        }
        NSInteger i = [self showResoonseCode:response];
        NSLog(@"state code %ld",i);
        
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&connectionError];
        
        NSString *obj = [NSString stringWithFormat:@"get: statusCode %ld\n",i];
        
        [self showMessageWithStr:obj];
        
    }];
}

//HTTP错误码
- (NSInteger)showResoonseCode:(NSURLResponse *)resp {
    NSHTTPURLResponse *http = (NSHTTPURLResponse *)resp;
    NSInteger respCode = [http statusCode];
    return respCode;
}

#pragma mark - 打印同意回调 XJSocketBackDelegate
- (void)XJSocketBackMessage:(NSString *)msg {
    [self showMessageWithStr:msg];
}

//拼接打印
- (void)showMessageWithStr:(NSString *)obj {
    self.teLog.text = [self.teLog.text stringByAppendingFormat:@"%@\n", obj];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
