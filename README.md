# YCShare

I Think You Can Know About How To Use It !

@protocol MXThirdPartyLoginDelegate
- (void)sendWXAuthRequestReponse:(BaseResp *)resp;
- (void)sendWXContentReponse:(BaseResp *)resp;
- (void)sendQQAuthRequestReponse:(int)error result:(id) result;
- (void)sendQQContentResponse:(BaseResp *)resp;
- (void)sendWBAuthRequestReponse:(WBBaseResponse *)resp;
- (void)sendWBContentReponse:(WBBaseResponse *)resp;
@end

@protocol MXThirdPartyPayDelegate <NSObject>
- (void)sendWXPayRequestResponse:(BaseResp *)resp;
- (void)sendAliPayRequestResponse:(NSDictionary *)resp;
@end

typedef void (^TPAccessTokenCallback)(NSInteger error,id result);
typedef void (^TPUserInfoCallback)(NSInteger error,id result);

@interface MXThridPartyLogIn : NSObject<WXApiDelegate,TencentSessionDelegate>
@property (nonatomic,weak)id <MXThirdPartyLoginDelegate,MXThirdPartyPayDelegate>delegate;

+ (MXThridPartyLogIn *)shareInstance;

// 微信是否安装
- (BOOL)isWXInstall;
// QQ是否安装
- (BOOL)isQQInstall;
// 微信发送第三方认证请求
- (int)sendWXAuthRequest;
// 获取微信AccessToken
- (void)getWXAccessToken:(NSString *)appID
               appSecret:(NSString *)appSecret
                    Code:(NSString *)code
                callback:(TPAccessTokenCallback)callback;
// 获取微信用户信息
- (void)getWXUserInfo:(NSString *)openID
           accessToke:(NSString*)accessToken
             callback:(TPUserInfoCallback)callback;
// 分享微信
- (void)shareWXContent:(NSString *)imageUrl
                 title:(NSString *)title
              subTitle:(NSString *)subTitle
              shareUrl:(NSString *)url
                 scene:(int)scene;

// QQ第三方认证请求
- (int)sendQQAuthRequest;
// 获取QQ用户信息
- (void)getQQUserInfo:(NSString *)openID
          accessToken:(NSString *)accessToken
                  key:(NSString *)oauth_consumer_key
             callback:(TPUserInfoCallback )callback;
// 分享QQ
// where:   0 - qq好友 ,  1 - qq空间
- (int)shareQQContent:(NSString *)imageUrl
                title:(NSString *)title
             subTitle:(NSString *)subTitle
             shareUrl:(NSString *)url
                where:(NSUInteger)where;

// 新浪微博第三方认证请求
- (int)sendWBAuthRequest;
// 获取微博用户信息
- (void)getWBUserInfo:(NSString *)source
          accessToken:(NSString *)accessToken
                  uid:(NSString *)uid
          screen_name:(NSString *)name
             callback:(TPUserInfoCallback)callback;
// 分享微博
- (void)shareWBContent:(NSString *)imageUrl
                 title:(NSString *)title
              subTitle:(NSString *)subTitle
              shareUrl:(NSString *)url;
// 微信支付
- (void)sendWXPayRequest:(NSString*)orderName
              orderPrice:(NSString *)orderPrice
                 orderNo:(NSString *)orderNo;
// 支付宝支付
- (void)sendAliPayRequest:(Product *)product;



@end
