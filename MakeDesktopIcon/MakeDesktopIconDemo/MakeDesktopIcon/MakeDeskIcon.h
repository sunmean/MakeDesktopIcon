//
//  MakeDeskIcon.h
//  DeskIcon
//
//  Created by SongMin on 2019/11/8.
//  Copyright © 2019 lovsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MakeDeskIcon : NSObject

/**
 方法用途:通过传值子App名和图标及跳转url来跳转到Safari浏览器按指引来生成子应用
 
 @sonAppName：子应用显示的名字 -----------------例如:@"子应用"
 @sonAppIconUrlStr ：子应用桌面图标-----------------例如:@"http://XXXXX.jpg"
 @sonAppSchemesLink ：子应用schemes跳转的路由链接 -----------------例如:@"deskAddicon://"
 
 */

+ (void)makeDeskIconWithSonAppName:(NSString *)sonAppName andSonAppIconUrlStr:(NSString *)sonAppIconUrlStr andSonAppSchemesLink:(NSString *)sonAppSchemesLink;

@end

NS_ASSUME_NONNULL_END
