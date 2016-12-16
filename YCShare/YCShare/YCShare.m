//
//  MXThridPartyLogIn.m
//  Maxer
//
//  Created by XuYanci on 15/6/4.
//  Copyright (c) 2015年 XuYanci. All rights reserved.
//

#import "YCShare.h"
#import "AppDelegate.h"
#import "WBHttpRequest+WeiboUser.h"
#import "DataSigner.h"
#import "payRequsestHandler.h"


//////////////////////////////// 支付宝 ////////////////////////////////////
NSString * const partner = @"";
NSString * const seller = @"";
NSString * const privateKey = @"";

 
@implementation Product

@end

@implementation AliPayOrder


- (NSString *)description {
    NSMutableString * discription = [NSMutableString string];
    if (self.partner) {
        [discription appendFormat:@"partner=\"%@\"", self.partner];
    }
    
    if (self.seller) {
        [discription appendFormat:@"&seller_id=\"%@\"", self.seller];
    }
    if (self.tradeNO) {
        [discription appendFormat:@"&out_trade_no=\"%@\"", self.tradeNO];
    }
    if (self.productName) {
        [discription appendFormat:@"&subject=\"%@\"", self.productName];
    }
    
    if (self.productDescription) {
        [discription appendFormat:@"&body=\"%@\"", self.productDescription];
    }
    if (self.amount) {
        [discription appendFormat:@"&total_fee=\"%@\"", self.amount];
    }
    if (self.notifyURL) {
        [discription appendFormat:@"&notify_url=\"%@\"", self.notifyURL];
    }
    
    if (self.service) {
        [discription appendFormat:@"&service=\"%@\"",self.service];//mobile.securitypay.pay
    }
    if (self.paymentType) {
        [discription appendFormat:@"&payment_type=\"%@\"",self.paymentType];//1
    }
    
    if (self.inputCharset) {
        [discription appendFormat:@"&_input_charset=\"%@\"",self.inputCharset];//utf-8
    }
    if (self.itBPay) {
        [discription appendFormat:@"&it_b_pay=\"%@\"",self.itBPay];//30m
    }
    if (self.showUrl) {
        [discription appendFormat:@"&show_url=\"%@\"",self.showUrl];//m.alipay.com
    }
    if (self.rsaDate) {
        [discription appendFormat:@"&sign_date=\"%@\"",self.rsaDate];
    }
    if (self.appID) {
        [discription appendFormat:@"&app_id=\"%@\"",self.appID];
    }
    for (NSString * key in [self.extraParams allKeys]) {
        [discription appendFormat:@"&%@=\"%@\"", key, [self.extraParams objectForKey:key]];
    }
    return discription;
}

@end


@implementation YCShare {
    TencentOAuth *tencentOAuth;
}

- (BOOL)isWXInstall {
    if (![WXApi isWXAppInstalled]) {
        return false;
    }
    return true;
}

- (BOOL)isQQInstall {
    if (![TencentOAuth iphoneQQInstalled]) {
        return false;
    }
    return true;
}



+ (YCShare *)shareInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        
            
    });
    return _sharedObject;
}

// 发送微信认证请求
// return   -1 - 未安装 ,  -2 - 不支持Api , 0 - 成功
- (int)sendWXAuthRequest {
    if (![WXApi isWXAppInstalled]) {
        return -1;
    }
    
    if (![WXApi isWXAppSupportApi]) {
        return -2;
    }
    
    [WXApi registerApp:MX_WEIXIN_APP_ID withDescription:@"com.weixin"];
 
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"0744";
    [WXApi sendReq:req];
    
    return 0;
}

- (void)getWXAccessToken:(NSString *)appID appSecret:(NSString *)appSecret Code:(NSString *)code callback:(TPAccessTokenCallback)callback {
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",appID,appSecret,code];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                callback(0,dic);
            }
        });
    });
}

- (void)getWXUserInfo:(NSString *)openID accessToke:(NSString*)accessToken callback:(TPUserInfoCallback)callback {

    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openID];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                callback(0,dic);
            }
        });
    });
}

- (void)shareWXContent:(NSString *)imageUrl title:(NSString *)title subTitle:(NSString *)subTitle shareUrl:(NSString *)url scene:(int)scene{
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = subTitle;
    // !!! 图片会阻塞、因为微信已经发送了网址、不能再包含mediaObject
    UIImage *oriImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
    message.thumbData  = UIImageJPEGRepresentation(oriImage,0.2);
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = [NSString stringWithFormat:@"%@",url];
    message.mediaObject = ext;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    [WXApi sendReq:req];
}

- (int)sendQQAuthRequest {
    if (![TencentOAuth iphoneQQInstalled]) {
        return -1;
    }
    if (!tencentOAuth)
        tencentOAuth = [[TencentOAuth alloc]initWithAppId:MX_QQ_APP_ID andDelegate:self];
    [tencentOAuth authorize:@[kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,kOPEN_PERMISSION_ADD_SHARE]];
    return 0;
}

- (void)getQQUserInfo:(NSString *)openID accessToken:(NSString *)accessToken key:(NSString *)oauth_consumer_key callback:(TPUserInfoCallback )callback {
    NSString *url =[NSString stringWithFormat:@"https://graph.qq.com/user/get_simple_userinfo?access_token=%@&oauth_consumer_key=%@&openid=%@",accessToken,oauth_consumer_key,openID];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                callback(0,dic);
            }
            else {
                callback(-1,@"获取用户基本信息失败");
            }
        });
    });
}


/// 分享QQ内容
/// return   0 － 成功 , -1 - 失败
- (int)shareQQContent:(NSString *)imageUrl
                 title:(NSString *)_title
              subTitle:(NSString *)_subTitle
              shareUrl:(NSString *)url
                 where:(NSUInteger)where {
    
    if (!tencentOAuth)
        tencentOAuth = [[TencentOAuth alloc]initWithAppId:MX_QQ_APP_ID andDelegate:self];
    
    NSString *utf8String = url;
    NSString *title = _title;
    NSString *description = _subTitle;
    NSString *previewImageUrl = imageUrl;
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:utf8String]
                                title:title
                                description:description
                                previewImageURL:[NSURL URLWithString:previewImageUrl]];
    
    int result = -1;
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
   
    if (where == 0) {
       QQApiSendResultCode  sent = [QQApiInterface sendReq:req];
        if (sent == EQQAPISENDSUCESS || sent == EQQAPIAPPSHAREASYNC) {
            result = 0;
        }
    }
    else {
       QQApiSendResultCode  sent = [QQApiInterface SendReqToQZone:req];
        if (sent == EQQAPISENDSUCESS || sent == EQQAPIAPPSHAREASYNC) {
            result = 0;
        }
    }
    return result;
}

- (int)sendWBAuthRequest {
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = MAX_SINA_WEIBO_REDIRECT_URL;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"MXLoginIndexViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
    return 0;
}

- (void)getWBUserInfo:(NSString *)source accessToken:(NSString *)accessToken uid:(NSString *)uid screen_name:(NSString *)name callback:(TPUserInfoCallback)callback {
    NSString *url =[NSString stringWithFormat:@"https://api.weibo.com/2/users/show.json?source=%@&access_token=%@&uid=%@",source,accessToken,uid];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error ;
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:&error];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                callback(0,dic);
            }
            else {
                callback(-1,@"获取用户基本信息失败");
            }
        });
    });
}

- (void)shareWBContent:(NSString *)imageUrl title:(NSString *)title subTitle:(NSString *)subTitle shareUrl:(NSString *)url {
 
    WBMessageObject *message = [WBMessageObject message];
    message.text = [NSString stringWithFormat:@"%@ %@",title,url];
    
    WBImageObject *image = [WBImageObject object];
    image.imageData =  [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    message.imageObject = image;
 
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = MAX_SINA_WEIBO_REDIRECT_URL;
    authRequest.scope = @"all";
    
    AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message
                                                                                  authInfo:authRequest
                                                                              access_token:myDelegate.wbtoken];
    request.userInfo = @{@"ShareMessageFrom": @"MXLoginIndexViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};

    // request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    [WeiboSDK sendRequest:request];
}

- (AliPayOrder *)buildDefaultPayOrderWithProduct:(Product *)product {
    AliPayOrder *order = [[AliPayOrder alloc]init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO =  product.orderId; //订单ID（由商家自行制定）
    order.productName = product.subject;
    order.productDescription = product.body;
    order.amount = [NSString stringWithFormat:@"%.2f",product.price];
    order.notifyURL = ALIPAY_NOTIFY_URL;
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    return order;
}

- (void)sendWXPayRequest:(NSString*)orderName orderPrice:(NSString *)orderPrice orderNo:(NSString *)orderNo {
 
    
    payRequsestHandler *handler = [[payRequsestHandler alloc]init];
    [handler init:APP_ID mch_id:MCH_ID];
    [handler setKey:PARTNER_ID];
    
    NSMutableDictionary *dict = [handler sendPay:orderName orderPrice:orderPrice oriderNO:orderNo];
    if(dict == nil){
        //错误提示
        NSString *debug = [handler getDebugifo];
        NSLog(@"%@\n\n",debug);
    }else{
        NSLog(@"%@\n\n",[handler getDebugifo]);

        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        
        [WXApi sendReq:req];
    }
    
}

// 支付宝支付
- (void)sendAliPayRequest:(Product *)product {
    AliPayOrder *order = [self buildDefaultPayOrderWithProduct:product];
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appSceme = @"alisdkxozaa";
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appSceme callback:^(NSDictionary *resultDic) {
             // 支付结果的提取，必须通过CompletionBlock获取，禁止开发者私自解析支付结果返回的URL。获取值的Key对应resultStatus、memo与result（result中的值，开发者可以自行解析）
            //NSString *resultStatus = [resultDic stringForKey:@"resultStatus"];
            //NSString *resultString = [resultDic stringForKey:@"result"];
            //NSArray *resultArray = [resultString componentsSeparatedByString:@"&"];
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(sendAliPayRequestResponse:)]) {
                [self.delegate sendAliPayRequestResponse:resultDic];
            }
        }];
    }
}

#pragma mark -- TencentSessionDelegate
- (void)tencentDidLogin
{
    if (tencentOAuth.accessToken && 0 != [tencentOAuth.accessToken length]){
        //  记录登录用户的OpenID、Token以及过期时间
        if (self.delegate != nil) {
            [self.delegate sendQQAuthRequestReponse:0 result:tencentOAuth];
        }
        
    }else{
        if (self.delegate != nil) {
            [self.delegate sendQQAuthRequestReponse:-1 result:@"用户登录失败"];
        }
    }
}

-(void)tencentDidNotLogin:(BOOL)cancelled
{
    if (self.delegate != nil) {
        [self.delegate sendQQAuthRequestReponse:-1 result:@"用户未登录"];
    }
}

-(void)tencentDidNotNetWork
{
    if (self.delegate != nil) {
        [self.delegate sendQQAuthRequestReponse:-1 result:@"网络未连接"];
    }
}

- (void)tencentDidLogout {
    
}

- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth withPermissions:(NSArray *)permissions {
    return TRUE;
}

- (BOOL)tencentNeedPerformReAuth:(TencentOAuth *)tencentOAuth {
    return TRUE;
}
- (void)tencentDidUpdate:(TencentOAuth *)tencentOAuth { }
- (void)tencentFailedUpdate:(UpdateFailType)reason { }


@end
