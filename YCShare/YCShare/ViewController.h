//
//  ViewController.h
//  YCShare
//
//  Created by Yanci on 16/1/16.
//  Copyright © 2016年 Yanci. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

/*!微信登陆*/
- (IBAction)WeChatLogin:(id)sender;
/*!QQ登陆*/
- (IBAction)QQLogin:(id)sender;
/*!微博登陆*/
- (IBAction)WeiBoLogin:(id)sender;
/*!微信联系人分享*/
- (IBAction)WeChatShare:(id)sender;
/*!微信朋友圈分享*/
- (IBAction)WeChatFriendCycleShare:(id)sender;
/*!QQ分享*/
- (IBAction)QQShare:(id)sender;
/*!QQZone分享*/
- (IBAction)QQZoneShare:(id)sender;
/*!WeiBo分享*/
- (IBAction)WeiBOShare:(id)sender;
/*!微信支付*/
- (IBAction)WeChatPay:(id)sender;
/*!支付宝支付*/
- (IBAction)AliPay:(id)sender;
@end

