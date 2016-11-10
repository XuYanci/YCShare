//
//  MXThridPartyLogIn.h
//  Maxer
//
//  Created by XuYanci on 15/6/4.
//  Copyright (c) 2015年 XuYanci. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <AlipaySDK/AlipaySDK.h>
#import "YCShareConfig.h"

@interface Product : NSObject{
@private
    float     _price;
    NSString *_subject;
    NSString *_body;
    NSString *_orderId;
}

@property (nonatomic, assign) float price;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *orderId;

@end

@interface AliPayOrder : NSObject

@property(nonatomic, copy) NSString * partner;
@property(nonatomic, copy) NSString * seller;
@property(nonatomic, copy) NSString * tradeNO;
@property(nonatomic, copy) NSString * productName;
@property(nonatomic, copy) NSString * productDescription;
@property(nonatomic, copy) NSString * amount;
@property(nonatomic, copy) NSString * notifyURL;

@property(nonatomic, copy) NSString * service;
@property(nonatomic, copy) NSString * paymentType;
@property(nonatomic, copy) NSString * inputCharset;
@property(nonatomic, copy) NSString * itBPay;
@property(nonatomic, copy) NSString * showUrl;


@property(nonatomic, copy) NSString * rsaDate;//可选
@property(nonatomic, copy) NSString * appID;//可选

@property(nonatomic, readonly) NSMutableDictionary * extraParams;


@end

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

@interface YCShare : NSObject<WXApiDelegate,TencentSessionDelegate>
@property (nonatomic,weak)id <MXThirdPartyLoginDelegate,MXThirdPartyPayDelegate>delegate;

+ (YCShare *)shareInstance;

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
