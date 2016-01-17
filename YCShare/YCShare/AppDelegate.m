//
//  AppDelegate.m
//  YCShare
//
//  Created by Yanci on 16/1/16.
//  Copyright © 2016年 Yanci. All rights reserved.
//

#import "AppDelegate.h"

/*！导入头文件 QQ , 微信 , 微博 , 支付宝等 */
#import "WXApi.h"
#import "WeiboSDK.h"
#import <AlipaySDK/AlipaySDK.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "MXThridPartyLogIn.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark -- 第三方登录

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self]
    || [TencentOAuth HandleOpenURL:url]
    || [QQApiInterface handleOpenURL:url delegate:self]
    || [WeiboSDK handleOpenURL:url delegate:self];
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    // 支付宝支付回调接口
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        
    }];
    
    return [WXApi handleOpenURL:url delegate:self]
    || [TencentOAuth HandleOpenURL:url]
    || [QQApiInterface handleOpenURL:url delegate:self]
    || [WeiboSDK handleOpenURL:url delegate:self];
}

#pragma mark --
#pragma mark WXApiDelegate

/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
-(void) onReq:(BaseReq*)req {
    
    
}
/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
-(void) onResp:(BaseResp*)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if ([MXThridPartyLogIn shareInstance].delegate != nil) {
            [[MXThridPartyLogIn shareInstance].delegate sendWXAuthRequestReponse:resp];
        }
    }
    else if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if ([MXThridPartyLogIn shareInstance].delegate != nil) {
            [[MXThridPartyLogIn shareInstance].delegate sendWXContentReponse:resp];
        }
    }
    else if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        if ([MXThridPartyLogIn shareInstance].delegate != nil) {
            [[MXThridPartyLogIn shareInstance].delegate sendQQContentResponse:resp];
        }
    }
    else if([resp isKindOfClass:[PayResp class]]) {
        if ([MXThridPartyLogIn shareInstance].delegate != nil) {
            [[MXThridPartyLogIn shareInstance].delegate sendWXPayRequestResponse:resp];
        }
    }
}

#pragma mark --
#pragma mark WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        if ([MXThridPartyLogIn shareInstance].delegate != nil) {
            [[MXThridPartyLogIn shareInstance].delegate sendWBAuthRequestReponse:response];
        }
        
        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
        self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
        //self.wbRefreshToken = [(WBAuthorizeResponse *)response refreshToken];
    }
    else if([response isKindOfClass:WBSendMessageToWeiboResponse.class]) {
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken)
        {
            self.wbtoken = accessToken;
        }
        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            self.wbCurrentUserID = userID;
        }
        
        if ([MXThridPartyLogIn shareInstance].delegate != nil) {
            [[MXThridPartyLogIn shareInstance].delegate sendWBContentReponse:sendMessageToWeiboResponse];
        }
    }
}



@end
