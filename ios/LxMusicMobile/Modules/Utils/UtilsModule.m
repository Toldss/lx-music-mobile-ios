/**
 * UtilsModule.m
 * 
 * iOS 工具模块实现
 * 提供屏幕常亮、网络信息、分享等实用功能
 * 
 * 需求: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 5.11, 5.12, 9.3, 9.4
 */

#import "UtilsModule.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <sys/utsname.h>

@interface UtilsModule ()

/** 事件监听器计数 */
@property (nonatomic, assign) NSInteger listenerCount;

@end

@implementation UtilsModule

// 使用 RCT_EXPORT_MODULE 宏导出模块 (需求 9.3)
RCT_EXPORT_MODULE();

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _listenerCount = 0;
        
        // 注册屏幕状态通知 (需求 5.10)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - RCTEventEmitter Required Methods

/**
 * 返回支持的事件名称列表
 */
- (NSArray<NSString *> *)supportedEvents {
    return @[@"screen_state"];
}

/**
 * 在主队列上执行
 */
+ (BOOL)requiresMainQueueSetup {
    return YES;
}

#pragma mark - Event Listener Methods

/**
 * 添加事件监听器
 */
RCT_EXPORT_METHOD(addListener:(NSString *)eventName) {
    self.listenerCount += 1;
}

/**
 * 移除事件监听器
 */
RCT_EXPORT_METHOD(removeListeners:(NSInteger)count) {
    self.listenerCount -= count;
    if (self.listenerCount < 0) {
        self.listenerCount = 0;
    }
}

#pragma mark - Screen State Notifications (需求 5.10)

/**
 * 应用变为活跃状态（屏幕开启）
 */
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (self.listenerCount > 0) {
        [self sendEventWithName:@"screen_state" body:@{@"state": @"ON"}];
    }
}

/**
 * 应用即将进入非活跃状态（屏幕关闭）
 */
- (void)applicationWillResignActive:(NSNotification *)notification {
    if (self.listenerCount > 0) {
        [self sendEventWithName:@"screen_state" body:@{@"state": @"OFF"}];
    }
}

#pragma mark - Screen Keep Awake Methods

/**
 * 禁用屏幕自动锁定 (需求 5.1)
 */
RCT_EXPORT_METHOD(screenkeepAwake) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        NSLog(@"UtilsModule: Screen keep awake enabled");
    });
}

/**
 * 恢复屏幕自动锁定 (需求 5.2)
 */
RCT_EXPORT_METHOD(screenUnkeepAwake) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        NSLog(@"UtilsModule: Screen keep awake disabled");
    });
}

#pragma mark - Network Information Methods

/**
 * 获取设备的 WiFi IPv4 地址 (需求 5.3)
 * 使用 getifaddrs 获取网络接口信息
 */
RCT_EXPORT_METHOD(getWIFIIPV4Address:(RCTPromiseResolveBlock)resolve
                              reject:(RCTPromiseRejectBlock)reject) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *address = [self getWiFiIPAddress];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (address) {
                resolve(address);
            } else {
                // 如果无法获取 WiFi IP，返回 "0.0.0.0"
                resolve(@"0.0.0.0");
            }
        });
    });
}

/**
 * 获取 WiFi IP 地址的内部实现
 */
- (NSString *)getWiFiIPAddress {
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // 获取所有网络接口
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // 检查是否是 WiFi 接口 (en0)
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // 获取 IP 地址
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // 释放内存
    freeifaddrs(interfaces);
    
    return address;
}

#pragma mark - Device Information Methods

/**
 * 获取设备名称 (需求 5.4)
 */
RCT_EXPORT_METHOD(getDeviceName:(RCTPromiseResolveBlock)resolve
                         reject:(RCTPromiseRejectBlock)reject) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *deviceName = [[UIDevice currentDevice] name];
        resolve(deviceName);
    });
}

/**
 * 获取支持的 CPU 架构列表 (需求 5.8)
 */
RCT_EXPORT_METHOD(getSupportedAbis:(RCTPromiseResolveBlock)resolve
                            reject:(RCTPromiseRejectBlock)reject) {
    NSMutableArray *abis = [NSMutableArray array];
    
    // 获取当前设备的 CPU 架构
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    // iOS 设备支持的架构
    // 现代 iOS 设备都是 arm64
    #if defined(__arm64__)
        [abis addObject:@"arm64"];
    #endif
    
    #if defined(__arm__)
        [abis addObject:@"armv7"];
        [abis addObject:@"armv7s"];
    #endif
    
    // 模拟器架构
    #if TARGET_IPHONE_SIMULATOR
        #if defined(__x86_64__)
            [abis addObject:@"x86_64"];
        #endif
        #if defined(__i386__)
            [abis addObject:@"i386"];
        #endif
        #if defined(__arm64__)
            [abis addObject:@"arm64"];
        #endif
    #endif
    
    // 如果没有检测到任何架构，添加默认值
    if (abis.count == 0) {
        [abis addObject:@"arm64"];
    }
    
    resolve(abis);
}

#pragma mark - Share Methods

/**
 * 显示系统分享面板 (需求 5.5)
 */
RCT_EXPORT_METHOD(shareText:(NSString *)shareTitle
                      title:(NSString *)title
                       text:(NSString *)text) {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 准备分享内容
        NSMutableArray *activityItems = [NSMutableArray array];
        
        if (text && text.length > 0) {
            [activityItems addObject:text];
        }
        
        if (activityItems.count == 0) {
            NSLog(@"UtilsModule: shareText called with empty content");
            return;
        }
        
        // 创建分享控制器
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] 
            initWithActivityItems:activityItems 
            applicationActivities:nil];
        
        // 设置标题（iOS 不直接支持分享标题，但可以通过 subject 设置）
        if (title && title.length > 0) {
            [activityViewController setValue:title forKey:@"subject"];
        }
        
        // 获取当前视图控制器并显示分享面板
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        
        // 处理 iPad 上的 popover 显示
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            activityViewController.popoverPresentationController.sourceView = rootViewController.view;
            activityViewController.popoverPresentationController.sourceRect = CGRectMake(
                rootViewController.view.bounds.size.width / 2,
                rootViewController.view.bounds.size.height / 2,
                0, 0
            );
        }
        
        [rootViewController presentViewController:activityViewController animated:YES completion:nil];
        
        NSLog(@"UtilsModule: shareText displayed share panel");
    });
}

#pragma mark - System Information Methods

/**
 * 获取系统语言设置 (需求 5.6)
 * 返回格式如 zh_cn、en_us
 */
RCT_EXPORT_METHOD(getSystemLocales:(RCTPromiseResolveBlock)resolve
                            reject:(RCTPromiseRejectBlock)reject) {
    // 获取首选语言
    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    
    if (preferredLanguages.count == 0) {
        resolve(@"");
        return;
    }
    
    NSString *preferredLanguage = preferredLanguages.firstObject;
    
    // 将语言标识符转换为 Android 格式 (zh_cn, en_us)
    // iOS 格式通常是 zh-Hans-CN 或 en-US
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:preferredLanguage];
    NSString *languageCode = [locale objectForKey:NSLocaleLanguageCode];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    
    NSString *localeString;
    if (countryCode && countryCode.length > 0) {
        localeString = [NSString stringWithFormat:@"%@_%@", 
                        [languageCode lowercaseString], 
                        [countryCode lowercaseString]];
    } else {
        localeString = [languageCode lowercaseString];
    }
    
    resolve(localeString ?: @"");
}

/**
 * 获取当前窗口的宽度和高度 (需求 5.7)
 */
RCT_EXPORT_METHOD(getWindowSize:(RCTPromiseResolveBlock)resolve
                         reject:(RCTPromiseRejectBlock)reject) {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        CGFloat scale = [UIScreen mainScreen].scale;
        
        // 返回点单位的尺寸（与 Android 保持一致）
        NSDictionary *size = @{
            @"width": @((int)screenBounds.size.width),
            @"height": @((int)screenBounds.size.height)
        };
        
        resolve(size);
    });
}

#pragma mark - App Control Methods

/**
 * 退出应用 (需求 5.9)
 * iOS 不支持程序化退出应用，提示用户
 */
RCT_EXPORT_METHOD(exitApp) {
    NSLog(@"UtilsModule: exitApp called - iOS does not support programmatic app exit");
    
    // iOS 不允许应用程序化退出
    // 根据 Apple 的 Human Interface Guidelines，应用不应该提供退出按钮
    // 这里只记录日志，不执行任何操作
    
    // 可选：发送事件通知 JavaScript 层
    if (self.listenerCount > 0) {
        [self sendEventWithName:@"screen_state" body:@{
            @"state": @"EXIT_NOT_SUPPORTED",
            @"message": @"iOS does not support programmatic app exit"
        }];
    }
}

#pragma mark - Notification Permission Methods

/**
 * 检查通知权限是否已启用 (需求 5.11)
 */
RCT_EXPORT_METHOD(isNotificationsEnabled:(RCTPromiseResolveBlock)resolve
                                  reject:(RCTPromiseRejectBlock)reject) {
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        BOOL enabled = (settings.authorizationStatus == UNAuthorizationStatusAuthorized ||
                       settings.authorizationStatus == UNAuthorizationStatusProvisional);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            resolve(@(enabled));
        });
    }];
}

/**
 * 打开系统设置的通知权限页面 (需求 5.12)
 */
RCT_EXPORT_METHOD(openNotificationPermissionActivity:(RCTPromiseResolveBlock)resolve
                                              reject:(RCTPromiseRejectBlock)reject) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if ([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
            [[UIApplication sharedApplication] openURL:settingsURL 
                                               options:@{} 
                                     completionHandler:^(BOOL success) {
                resolve(@(success));
            }];
        } else {
            NSLog(@"UtilsModule: Cannot open settings URL");
            resolve(@(NO));
        }
    });
}

@end
