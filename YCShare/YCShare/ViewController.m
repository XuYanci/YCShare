//
//  ViewController.m
//  YCShare
//
//  Created by Yanci on 16/1/16.
//  Copyright © 2016年 Yanci. All rights reserved.
//

#import "ViewController.h"
#import "Global.h"
#import "MXThridPartyLogIn.h"

@interface ViewController ()<MXThirdPartyLoginDelegate,MXThirdPartyPayDelegate>

@end

@implementation ViewController

#pragma mark - event response
/*!微信登陆*/
- (IBAction)WeChatLogin:(id)sender {
    int ret = [[MXThridPartyLogIn shareInstance]sendWXAuthRequest];
    [[MXThridPartyLogIn shareInstance]setDelegate:self];
    
    if (ret == -1) {
        NSLog(@"需要安装微信才能使用这功能");
    }
    else if(ret == -2) {
        NSLog(@"微信不支持");
    }
}

/*!QQ登陆*/
- (IBAction)QQLogin:(id)sender {
    int ret = [[MXThridPartyLogIn shareInstance]sendQQAuthRequest];
    [[MXThridPartyLogIn shareInstance]setDelegate:self];
    
    if (ret == -1) {
        NSLog(@"需要安装QQ才能使用这功能");
    }
}

/*!微博登陆*/
- (IBAction)WeiBoLogin:(id)sender {
    int ret =  [[MXThridPartyLogIn shareInstance] sendWBAuthRequest];
    [[MXThridPartyLogIn shareInstance]setDelegate:self];
    if (ret == -1) {
        NSLog(@"微博未安装");
    }
}

/*!微信联系人分享*/
- (IBAction)WeChatShare:(id)sender {
    NSString *thumb = @"";
    NSString *title = @"";
    NSString *sub = @"";
    NSString *share = @"";
    [MXThridPartyLogIn shareInstance].delegate = self;
    [[MXThridPartyLogIn shareInstance]shareWXContent:thumb
                                               title:title
                                            subTitle:sub
                                            shareUrl:share scene:0];
}

/*!微信朋友圈分享*/
- (IBAction)WeChatFriendCycleShare:(id)sender {
    NSString *thumb = @"";
    NSString *title = @"";
    NSString *sub = @"";
    NSString *share = @"";
    [MXThridPartyLogIn shareInstance].delegate = self;
    [[MXThridPartyLogIn shareInstance]shareWXContent:thumb
                                               title:title
                                            subTitle:sub
                                            shareUrl:share scene:1];
}

/*!QQ分享*/
- (IBAction)QQShare:(id)sender {
    NSString *thumb = @"";
    NSString *title = @"";
    NSString *sub = @"";
    NSString *share = @"";
    [MXThridPartyLogIn shareInstance].delegate = self;
    int ret =  [[MXThridPartyLogIn shareInstance]shareQQContent:thumb
                                                          title:title
                                                       subTitle:sub
                                                       shareUrl:share
                                                          where:0];
    if (ret == -1) {
        NSLog(@"分享失败");
    }
    else {
        NSLog(@"分享成功");
    }

}

/*!QQZone分享*/
- (IBAction)QQZoneShare:(id)sender {
    NSString *thumb = @"";
    NSString *title = @"";
    NSString *sub = @"";
    NSString *share = @"";
    [MXThridPartyLogIn shareInstance].delegate = self;
    int ret =   [[MXThridPartyLogIn shareInstance]shareQQContent:thumb
                                                           title:title
                                                        subTitle:sub
                                                        shareUrl:share where:1];
    if (ret == -1) {
        NSLog(@"分享成功");
    }
    else {
        NSLog(@"分享失败");
    }

}

/*!WeiBo分享*/
- (IBAction)WeiBOShare:(id)sender {
    NSString *thumb = @"";
    NSString *title = @"";
    NSString *sub = @"";
    NSString *share = @"";
    [MXThridPartyLogIn shareInstance].delegate = self;
    [[MXThridPartyLogIn shareInstance]shareWBContent:thumb
                                               title:title
                                            subTitle:sub
                                            shareUrl:share];
}

/*!微信支付*/
- (IBAction)WeChatPay:(id)sender {
    NSString *orderNo = @"";
    NSString *title = @"";
    NSString *cash = @"";
    [[MXThridPartyLogIn shareInstance]sendWXPayRequest:title orderPrice:cash orderNo:orderNo];
    [[MXThridPartyLogIn shareInstance]setDelegate:self];
}

/*!支付宝支付*/
- (IBAction)AliPay:(id)sender {
    NSString *orderNo = @"";
    NSString *title = @"";
    NSString *cash = @"";
    Product *product = [[Product alloc]init];
    product.subject = title;
    product.body = title;
    product.price = cash.intValue;
    product.orderId = orderNo;
    [[MXThridPartyLogIn shareInstance]sendAliPayRequest:product];
    [[MXThridPartyLogIn shareInstance]setDelegate:self];
}

#pragma mark -- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate
- (void)sendWXAuthRequestReponse:(BaseResp *)resp {
    SendAuthResp *_resp = (SendAuthResp *)resp;
    if (_resp.errCode != 0) { NSLog(@"ERROR"); return; }
    
    NSString *code = _resp.code;
    // ... 获取AccessToken
    [[MXThridPartyLogIn shareInstance]getWXAccessToken:MX_WEIXIN_APP_ID_LOGIN
                                             appSecret:MX_WEIXIN_APP_ID_LOGIN_SECRET
                                                  Code:code
                                              callback:^(NSInteger error, id result)
    {
        if(error == 0) {
            NSDictionary *dict = (NSDictionary *)result;
            NSString *openid = [dict objectForKey:@"openid"];
            NSString *accesstoken = [dict objectForKey:@"access_token"];
            // ... 获取用户信息
            [[MXThridPartyLogIn shareInstance]getWXUserInfo:openid accessToke:accesstoken callback:^(NSInteger error, id result) {
                NSDictionary *userInfoDict = (NSDictionary *)result;
                NSLog(@"USERINFO = %@",userInfoDict);
            }];
        }
    }];
}

- (void)sendWXContentReponse:(BaseResp *)resp {
    SendMessageToWXResp *_resp = (SendMessageToWXResp *)resp ;
    
    if (_resp.errCode == 0) {
        NSLog(@"分享成功");
    }
    else if(resp.errCode == WXErrCodeSentFail || resp.errCode == WXErrCodeAuthDeny || resp.errCode == WXErrCodeUnsupport) {
       NSLog(@"%@",[NSString stringWithFormat:@"分享失败,errCode = %@",_resp.errStr]);
    }
    else { }
}

- (void)sendQQAuthRequestReponse:(int)error result:(id) result {
    
    if (error != 0) {
        NSLog(@"ERROR"); return;
    }
    
    TencentOAuth *auth = (TencentOAuth *)result;
    NSString *accessToken = auth.accessToken;
    NSString *openID = auth.openId;
    NSString *appID = auth.appId;

    [[MXThridPartyLogIn shareInstance]getQQUserInfo:openID
                                        accessToken:accessToken
                                                key:appID
                                           callback:^(NSInteger error, id result)
    {
        if (error == 0) {
            
            NSDictionary *userInfoDict = (NSDictionary *)result;
            NSLog(@"%@",userInfoDict);
    
        }
    }];

}

- (void)sendQQContentResponse:(BaseResp *)resp {
    SendMessageToQQResp *sendMessageToQQResp =(SendMessageToQQResp*) resp;
    if ([sendMessageToQQResp.result isEqualToString:@"0"]) {
        NSLog(@"分享成功");
    }
    else {
        NSLog(@"分享失败, Error = %@",sendMessageToQQResp.errorDescription);
    }
}

- (void)sendWBAuthRequestReponse:(WBBaseResponse *)resp {
    WBAuthorizeResponse *response = (WBAuthorizeResponse *)resp;
    
    if (resp.statusCode != WeiboSDKResponseStatusCodeSuccess) {
        NSLog(@"ERROR");
        return;
    }
    
    NSString *accessToken = [(WBAuthorizeResponse *)response accessToken];
    NSString *userID = [(WBAuthorizeResponse *)response userID];
    [[MXThridPartyLogIn shareInstance] getWBUserInfo:MAX_SINA_WEIBO_APP_ID
                                         accessToken:accessToken
                                                 uid:userID
                                         screen_name:@""
                                            callback:^(NSInteger error, id result)
     {
         if (error == 0) {
             NSDictionary *userInfoDict = (NSDictionary *)result;
             NSLog(@"USERINFO = %@",userInfoDict);
         }
     }];
}

- (void)sendWBContentReponse:(WBBaseResponse *)resp {
    WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)resp;
    if (sendMessageToWeiboResponse.statusCode == WeiboSDKResponseStatusCodeSuccess) {
        NSLog(@"分享成功");
    }else if(resp.statusCode == WeiboSDKResponseStatusCodeShareInSDKFailed){
        NSLog(@"分享失败");
    }
}
@end
