/**
 * CacheModule.h
 * 
 * iOS 缓存管理模块，提供获取缓存大小和清理缓存功能
 * 
 * 需求: 1.1, 1.2, 1.3, 1.4, 9.3, 9.4
 */

#import <React/RCTBridgeModule.h>

@interface CacheModule : NSObject <RCTBridgeModule>

/**
 * 获取应用缓存大小
 * 遍历 Caches 和 tmp 目录，返回总大小（字节数字符串）
 * 
 * @param resolve Promise 成功回调，返回字节数字符串
 * @param reject Promise 失败回调
 */
- (void)getAppCacheSize:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject;

/**
 * 清理应用缓存
 * 异步清除 Caches 目录和 tmp 目录中的所有文件
 * 
 * @param resolve Promise 成功回调
 * @param reject Promise 失败回调
 */
- (void)clearAppCache:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject;

@end
