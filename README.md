# MakeDesktopIcon
制作iOS桌面快捷方式图标<br/>
![image](https://github.com/sunmean/MakeDesktopIcon/blob/master/record20191126003.gif)

---
简要介绍
==============
项目中的Demo可以制作iOS桌面快捷方式图标。<br/>

使用方法
==============

### 1.调用头文件
```objc
#import "MakeDesktopIcon.h"
```

### 2.导入方法文件夹
导入MakeDesktopIcon的文件夹，注意导入里面的Web的文件夹要选"Create folder references"

### 3.Cocopods支持
```objc
platform :ios, '10.0'

target 'MakeDesktopIconDemo' do

pod 'CocoaHTTPServer'

end
```

### 4.方法调用
```objc
//最好从接口获取应用名和icon图标及跳转链接,配置添加桌面上的图标和应用名称及scheme符合跳转规则的链接
NSString *sonAppName = @"子应用";
NSString *sonAppIconUrlStr = @"https://inews.gtimg.com/newsapp_bt/0/10710088450/1000";
NSString *sonAppSchemesLink = @"deskAddicon://";

[MakeDesktopIcon makeDesktopIconWithSonAppName:sonAppName andSonAppIconUrlStr:sonAppIconUrlStr andSonAppSchemesLink:sonAppSchemesLink];
```

### 5.方法参数说明
```objc
/**
方法用途:通过传值子App名和图标及跳转url来跳转到Safari浏览器按指引来生成子应用

@sonAppName：子应用显示的名字 -----------------例如:@"子应用"
@sonAppIconUrlStr ：子应用桌面图标-----------------例如:@"http://XXXXX.jpg"
@sonAppSchemesLink ：子应用schemes跳转的路由链接 -----------------例如:@"deskAddicon://"

*/

+ (void)makeDesktopIconWithSonAppName:(NSString *)sonAppName andSonAppIconUrlStr:(NSString *)sonAppIconUrlStr andSonAppSchemesLink:(NSString *)sonAppSchemesLink;
```

### 6.温馨提示
==============
如果由于旧版本Xcode导致无法运行，请在Xcode顶部菜单栏上面选择“File”->"Workspace Settings..."->"Build System"->"Legacy Build System"。设置一下就可以兼容旧版本Xcode生成的项目引起的报错。


### 7.许可证
==============
MSShowBoxAlert 使用 MIT 许可证，详情见 LICENSE 文件。
