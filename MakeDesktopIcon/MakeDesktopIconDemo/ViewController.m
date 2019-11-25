//
//  ViewController.m
//  MakeDesktopIcon
//
//  Created by SongMin on 2019/11/25.
//  Copyright © 2019 lovsoft. All rights reserved.
//

#import "ViewController.h"
#import "MakeDesktopIcon.h"

@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *shareIconLocalBtn = [[UIButton alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 120 ) / 2, ([UIScreen mainScreen].bounds.size.height - 50 ) / 2 , 120, 50)];
    [shareIconLocalBtn setTitle:@"web在本地" forState:UIControlStateNormal];
    [shareIconLocalBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareIconLocalBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    shareIconLocalBtn.backgroundColor = [UIColor redColor];
    shareIconLocalBtn.layer.cornerRadius = 8;
    shareIconLocalBtn.layer.masksToBounds = YES;
    [self.view addSubview:shareIconLocalBtn];
    [shareIconLocalBtn addTarget:self action:@selector(shareLocalClick) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)shareLocalClick {
    //最好从接口获取应用名和icon图标及跳转链接,配置添加桌面上的图标和应用名称及scheme符合跳转规则的链接
    NSString *sonAppName = @"子应用";
    NSString *sonAppIconUrlStr = @"https://inews.gtimg.com/newsapp_bt/0/10710088450/1000";
    NSString *sonAppSchemesLink = @"deskAddicon://";
    
    [MakeDesktopIcon makeDesktopIconWithSonAppName:sonAppName andSonAppIconUrlStr:sonAppIconUrlStr andSonAppSchemesLink:sonAppSchemesLink];
}


@end
