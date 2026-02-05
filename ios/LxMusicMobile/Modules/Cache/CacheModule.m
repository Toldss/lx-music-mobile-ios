/**
 * CacheModule.m
 * 
 * iOS 缓存管理模块实现
 * 
 * 需求: 1.1, 1.2, 1.3, 1.4, 9.3, 9.4
 */

#import "CacheModule.h"

@implementation CacheModule

// 使用 RCT_EXPORT_MODULE 宏导出模块 (需求 9.3)
RCT_EXPORT_MODULE();

#pragma mark - Private Methods

/**
 * 计算目录大小
 * 递归遍历目录中的所有文件，计算总大小
 * 
 * @param directoryPath 目录路径
 * @return 目录总大小（字节）
 */
- (unsigned long long)sizeOfDirectory:(NSString *)directoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    unsigned long long totalSize = 0;
    
    // 检查目录是否存在
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory] || !isDirectory) {
        return 0;
    }
    
    NSError *error = nil;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
    
    if (error) {
        NSLog(@"CacheModule: Error reading directory %@: %@", directoryPath, error.localizedDescription);
        return 0;
    }
    
    for (NSString *item in contents) {
        NSString *itemPath = [directoryPath stringByAppendingPathComponent:item];
        
        BOOL isDir = NO;
        if ([fileManager fileExistsAtPath:itemPath isDirectory:&isDir]) {
            if (isDir) {
                // 递归计算子目录大小
                totalSize += [self sizeOfDirectory:itemPath];
            } else {
                // 获取文件大小
                NSDictionary *attributes = [fileManager attributesOfItemAtPath:itemPath error:nil];
                totalSize += [attributes fileSize];
            }
        }
    }
    
    return totalSize;
}

/**
 * 清理目录内容
 * 删除目录中的所有文件和子目录
 * 
 * @param directoryPath 目录路径
 * @param error 错误输出参数
 * @return 是否成功
 */
- (BOOL)clearDirectory:(NSString *)directoryPath error:(NSError **)error {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 检查目录是否存在
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory] || !isDirectory) {
        return YES; // 目录不存在，视为成功
    }
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:directoryPath error:error];
    
    if (*error) {
        return NO;
    }
    
    BOOL success = YES;
    for (NSString *item in contents) {
        NSString *itemPath = [directoryPath stringByAppendingPathComponent:item];
        NSError *removeError = nil;
        
        if (![fileManager removeItemAtPath:itemPath error:&removeError]) {
            NSLog(@"CacheModule: Failed to remove item %@: %@", itemPath, removeError.localizedDescription);
            // 继续尝试删除其他文件，但记录失败
            success = NO;
            if (*error == nil) {
                *error = removeError;
            }
        }
    }
    
    return success;
}

#pragma mark - Exported Methods

/**
 * 获取应用缓存大小 (需求 1.1)
 * 遍历 Caches 和 tmp 目录，返回总大小（字节数字符串）
 */
RCT_EXPORT_METHOD(getAppCacheSize:(RCTPromiseResolveBlock)resolve
                           reject:(RCTPromiseRejectBlock)reject) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            unsigned long long totalSize = 0;
            
            // 获取 Caches 目录路径
            NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            if (cachePaths.count > 0) {
                NSString *cachePath = cachePaths.firstObject;
                totalSize += [self sizeOfDirectory:cachePath];
            }
            
            // 获取 tmp 目录路径
            NSString *tmpPath = NSTemporaryDirectory();
            if (tmpPath) {
                totalSize += [self sizeOfDirectory:tmpPath];
            }
            
            // 返回字节数的字符串格式，与 Android 保持一致
            NSString *sizeString = [NSString stringWithFormat:@"%llu", totalSize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                resolve(sizeString);
            });
        } @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                reject(@"CACHE_SIZE_ERROR", exception.reason, nil);
            });
        }
    });
}

/**
 * 清理应用缓存 (需求 1.2, 1.3, 1.4)
 * 异步清除 Caches 目录和 tmp 目录中的所有文件
 */
RCT_EXPORT_METHOD(clearAppCache:(RCTPromiseResolveBlock)resolve
                         reject:(RCTPromiseRejectBlock)reject) {
    // 异步执行清理操作，避免阻塞主线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        BOOL success = YES;
        
        @try {
            // 清理 Caches 目录
            NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            if (cachePaths.count > 0) {
                NSString *cachePath = cachePaths.firstObject;
                NSError *cacheError = nil;
                if (![self clearDirectory:cachePath error:&cacheError]) {
                    success = NO;
                    if (error == nil) {
                        error = cacheError;
                    }
                }
            }
            
            // 清理 tmp 目录
            NSString *tmpPath = NSTemporaryDirectory();
            if (tmpPath) {
                NSError *tmpError = nil;
                if (![self clearDirectory:tmpPath error:&tmpError]) {
                    success = NO;
                    if (error == nil) {
                        error = tmpError;
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    // 需求 1.3: 清理完成通过 Promise 返回成功结果
                    resolve(@YES);
                } else {
                    // 需求 1.4: 清理过程中发生错误通过 Promise 返回错误信息
                    if (error) {
                        reject(@"CACHE_CLEAR_ERROR", error.localizedDescription, error);
                    } else {
                        reject(@"CACHE_CLEAR_ERROR", @"Failed to clear some cache files", nil);
                    }
                }
            });
        } @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                reject(@"CACHE_CLEAR_ERROR", exception.reason, nil);
            });
        }
    });
}

@end
