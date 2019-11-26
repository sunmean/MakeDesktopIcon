//
//  MakeDesktopIcon.m
//  MakeDesktopIcon
//
//  Created by SongMin on 2019/11/8.
//  Copyright © 2019 lovsoft. All rights reserved.
//

#import "MakeDesktopIcon.h"
#import "FileUtils.h"
#import "HTTPServer.h"

@interface MakeDesktopIcon ()
{
    HTTPServer *httpServer;
}
@end

@implementation MakeDesktopIcon

static MakeDesktopIcon *manager = nil;
+ (instancetype)defaultShareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MakeDesktopIcon new];
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    
    return manager;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[self class] defaultShareManager];
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    return [[self class] defaultShareManager];
}


#pragma mark - 通过传子App名和图标及跳转url来生成子应用
+ (void)makeDesktopIconWithSonAppName:(NSString *)sonAppName andSonAppIconUrlStr:(NSString *)sonAppIconUrlStr andSonAppSchemesLink:(NSString *)sonAppSchemesLink {
    
    // 从Web文件夹拿到index网页的模板进行修改
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    NSString *filePath = [webPath stringByAppendingPathComponent:@"index.html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    // 获取内嵌网页内容
    NSString *getHtmlStr = [MakeDesktopIcon getRefreshHtmlDataWithSonAppName:sonAppName andSonAppIconUrlStr:sonAppIconUrlStr andSonAppSchemesLink:sonAppSchemesLink];
    
    // 更改网页head内容
    NSString *searchStr = htmlString;
    NSString *regExpStr = @"<meta http-equiv='refresh' content=''>";
    NSString *replacement = [NSString stringWithFormat:@"<meta http-equiv='refresh' content='0;URL= %@'>",getHtmlStr];
    
    NSString *resultStr = searchStr;
    // 替换匹配的字符串为 searchStr
    resultStr = [MakeDesktopIcon replacingMatchesInSearchStr:htmlString andReplacingStr:replacement andRegExpStr:regExpStr];
    
    NSData *saveData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
    
    //在对应文件保存数据
    BOOL isSaveSecess = [FileUtils writeDataToFile:@"index.html" data:saveData];
    
    if (isSaveSecess) {
        [[MakeDesktopIcon defaultShareManager] shareLocalClick];
    }else{
        NSLog(@"保存index.html到本地文件夹失败");
    }
    
}

#pragma mark - 开启HTTPServer本地服务
- (void)shareLocalClick
{
    // Create server using our custom MyHTTPServer class
    httpServer = [[HTTPServer alloc] init];
    
    [httpServer setType:@"_http._tcp."];
    
    [httpServer setPort:6888];
    
    //获取文件夹的路径
    NSString *filePath = [FileUtils getFilePath:@"index.html"];
    NSString *webPath = [filePath stringByDeletingLastPathComponent];
    NSLog(@"Setting document root: %@", webPath);
    
    //配置Root文件夹
    [httpServer setDocumentRoot:webPath];
    
    [self startServer];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://127.0.0.1:6888"] options:@{} completionHandler:nil];
}

- (void)startServer
{
    NSError *error;
    if([httpServer start:&error])
    {
        NSLog(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
    }
    else
    {
        NSLog(@"Error starting HTTP Server: %@", error);
    }
}


#pragma mark - 处理内嵌网页内容,即分出的子应用内容
+ (NSString *)getRefreshHtmlDataWithSonAppName:(NSString *)sonAppName andSonAppIconUrlStr:(NSString *)sonAppIconUrlStr andSonAppSchemesLink:(NSString *)sonAppSchemesLink{
    //处理网页
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    
    NSString *filePath = [webPath stringByAppendingPathComponent:@"content.html"];
    NSString *fromHtmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    // 更改网页title即App名称
    NSString *searchStr = fromHtmlString;
    NSString *regExpStr = @"<title>[\\s\\S]*</title>";
    NSString *replacement = [NSString stringWithFormat:@"<title>%@</title>",sonAppName];
    NSString *resultStr = searchStr;
    if (![MakeDesktopIcon isBlankString:sonAppName]) {
        NSString *result = [self replacingMatchesInSearchStr:searchStr andReplacingStr:replacement andRegExpStr:regExpStr];
        NSString *nameRegExpStr = @"<h3 id='appName'>[\\s\\S]*</h3>";
        NSString *nameReplacement = [NSString stringWithFormat:@"<h3 id='appName'>%@</h3>",sonAppName];
        resultStr = [self replacingMatchesInSearchStr:result andReplacingStr:nameReplacement andRegExpStr:nameRegExpStr];
    }
    
    // 替换icon内容
    NSString *iconSearchStr = resultStr;
    NSString *iconResultStr = iconSearchStr;
    UIImage *originImage = [self getImageFromURL:sonAppIconUrlStr];// 取得图片
    NSString *encodedImageStr = [NSString stringWithFormat:@"data:image/jpeg;base64,%@",[self encodedImageStrWithImage:originImage]];
    if (![MakeDesktopIcon isBlankString:sonAppIconUrlStr]) {
        NSString *iconRegExpStr = @"<link rel='apple-touch-icon' href=''>";
        NSString *iconReplacement = [NSString stringWithFormat:@"<link rel='apple-touch-icon' href='%@'>",encodedImageStr];
        NSString *iconResult = [self replacingMatchesInSearchStr:iconSearchStr andReplacingStr:iconReplacement andRegExpStr:iconRegExpStr];
        
        NSString *logoRegExpStr = @"<img id='logo' src='#' />";
        NSString *logoReplacement = [NSString stringWithFormat:@"<img id='logo' src='%@' />",encodedImageStr];
        iconResultStr = [self replacingMatchesInSearchStr:iconResult andReplacingStr:logoReplacement andRegExpStr:logoRegExpStr];

    }
    
    // 替换schemeLink
    NSString *linkSearchStr = iconResultStr;
    NSString *linkResultStr = linkSearchStr;
    if (![MakeDesktopIcon isBlankString:sonAppSchemesLink]) {
        NSString *linkRegExpStr = @"<a id='qbt' style='display:none' href='#'>[\\s\\S]*</a>";
        NSString *linkReplacement = [NSString stringWithFormat:@"<a id='qbt' style='display:none' href='%@'></a>",sonAppSchemesLink];
        linkResultStr = [self replacingMatchesInSearchStr:linkSearchStr andReplacingStr:linkReplacement andRegExpStr:linkRegExpStr];
    }
    
    // URL编码
    NSString *encodingStr = [self URLEncodedString:linkResultStr];
    NSString *htmlStr = [NSString stringWithFormat:@"data:text/html;charset=utf-8,%@",encodingStr];
    
    return htmlStr;
}

#pragma mark - 正则搜索进行内容替换
+ (NSString *)replacingMatchesInSearchStr:(NSString *)searchStr andReplacingStr:(NSString *)replacingStr andRegExpStr:(NSString *)regExpStr {
    NSRegularExpression *regExp = [[NSRegularExpression alloc] initWithPattern:regExpStr
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];
    NSString *resultStr = searchStr;
    // 替换匹配的字符串
    resultStr = [regExp stringByReplacingMatchesInString:searchStr
                                                 options:NSMatchingReportProgress
                                                   range:NSMakeRange(0, searchStr.length)
                                            withTemplate:replacingStr];
    return resultStr;
}

#pragma mark - 进行URL编码
+ (NSString *)URLEncodedString:(NSString *)str {
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)str,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

#pragma mark - 根据url获取图片
+ (UIImage *)getImageFromURL:(NSString *)fileURL
{
    UIImage *result;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}

#pragma mark - UIImage图片转成Base64字符串
+ (NSString *)encodedImageStrWithImage:(UIImage *)originImage{
    NSData *data = UIImageJPEGRepresentation(originImage, 1.0f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}

#pragma mark - 字符串判空方法
+ (BOOL)isBlankString:(NSString *)aStr {
    if (!aStr) {
        return YES;
    }
    if ([aStr isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!aStr.length) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [aStr stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}

@end
