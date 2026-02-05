/**
 * UtilsModule.h
 * 
 * iOS 工具模块，提供屏幕常亮、网络信息、分享等实用功能
 * 
 * 需求: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 5.11, 5.12, 9.3, 9.4
 */

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface UtilsModule : RCTEventEmitter <RCTBridgeModule>

#pragma mark - 屏幕常亮方法

/**
 * 禁用屏幕自动锁定
 * 需求 5.1
 */
- (void)screenkeepAwake;

/**
 * 恢复屏幕自动锁定
 * 需求 5.2
 */
- (void)screenUnkeepAwake;

#pragma mark - 网络信息方法

/**
 * 获取设备的 WiFi IPv4 地址
 * 需求 5.3
 * 
 * @param resolve Promise 成功回调，返回 IP 地址字符串
 * @param reject Promise 失败回调
 */
- (void)getWIFIIPV4Address:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject;

#pragma mark - 设备信息方法

/**
 * 获取设备名称
 * 需求 5.4
 * 
 * @param resolve Promise 成功回调，返回设备名称
 * @param reject Promise 失败回调
 */
- (void)getDeviceName:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject;

/**
 * 获取支持的 CPU 架构列表
 * 需求 5.8
 * 
 * @param resolve Promise 成功回调，返回架构数组
 * @param reject Promise 失败回调
 */
- (void)getSupportedAbis:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject;

#pragma mark - 分享方法

/**
 * 显示系统分享面板
 * 需求 5.5
 * 
 * @param shareTitle 分享对话框标题
 * @param title 分享内容标题
 * @param text 分享文本内容
 */
- (void)shareText:(NSString *)shareTitle
            title:(NSString *)title
             text:(NSString *)text;

#pragma mark - 系统信息方法

/**
 * 获取系统语言设置
 * 需求 5.6
 * 
 * @param resolve Promise 成功回调，返回语言代码（如 zh_cn）
 * @param reject Promise 失败回调
 */
- (void)getSystemLocales:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject;

/**
 * 获取当前窗口的宽度和高度
 * 需求 5.7
 * 
 * @param resolve Promise 成功回调，返回 {width, height} 对象
 * @param reject Promise 失败回调
 */
- (void)getWindowSize:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject;

#pragma mark - 应用控制方法

/**
 * 退出应用（iOS 不支持，提示用户）
 * 需求 5.9
 */
- (void)exitApp;

#pragma mark - 通知权限方法

/**
 * 检查通知权限是否已启用
 * 需求 5.11
 * 
 * @param resolve Promise 成功回调，返回布尔值
 * @param reject Promise 失败回调
 */
- (void)isNotificationsEnabled:(RCTPromiseResolveBlock)resolve
                        reject:(RCTPromiseRejectBlock)reject;

/**
 * 打开系统设置的通知权限页面
 * 需求 5.12
 * 
 * @param resolve Promise 成功回调
 * @param reject Promise 失败回调
 */
- (void)openNotificationPermissionActivity:(RCTPromiseResolveBlock)resolve
                                    reject:(RCTPromiseRejectBlock)reject;

@end
