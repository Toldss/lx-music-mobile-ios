/**
 * CryptoModule.m
 * 
 * 加密模块实现，整合 RSA 和 AES 工具类
 * 提供异步和同步加解密方法
 * 
 * 需求: 2.4, 2.7, 9.3, 9.4
 */

#import "CryptoModule.h"
#import "RSAUtils.h"
#import "AESUtils.h"
#import <React/RCTLog.h>

@implementation CryptoModule

// 使用 RCT_EXPORT_MODULE 宏导出模块 (需求 9.3)
RCT_EXPORT_MODULE();

#pragma mark - RSA 异步方法

/**
 * 生成 RSA 密钥对
 * 使用 RCT_EXPORT_METHOD 宏导出 (需求 9.4)
 */
RCT_EXPORT_METHOD(generateRsaKey:(RCTPromiseResolveBlock)resolve
                          reject:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *keyPair = [RSAUtils generateKeyPair];
        
        if (keyPair) {
            resolve(keyPair);
        } else {
            reject(@"RSA_KEY_GEN_ERROR", @"Failed to generate RSA key pair", nil);
        }
    });
}

/**
 * RSA 加密（异步）
 * 使用 RCT_EXPORT_METHOD 宏导出 (需求 9.4)
 */
RCT_EXPORT_METHOD(rsaEncrypt:(NSString *)text
                         key:(NSString *)key
                     padding:(NSString *)padding
                     resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *result = [RSAUtils encrypt:text publicKey:key padding:padding];
        resolve(result);
    });
}

/**
 * RSA 解密（异步）
 * 使用 RCT_EXPORT_METHOD 宏导出 (需求 9.4)
 */
RCT_EXPORT_METHOD(rsaDecrypt:(NSString *)text
                         key:(NSString *)key
                     padding:(NSString *)padding
                     resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *result = [RSAUtils decrypt:text privateKey:key padding:padding];
        resolve(result);
    });
}

#pragma mark - RSA 同步方法 (需求 2.4)

/**
 * RSA 加密（同步）
 * 使用 RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD 宏导出 (需求 9.4)
 */
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(rsaEncryptSync:(NSString *)text
                                                  key:(NSString *)key
                                              padding:(NSString *)padding)
{
    return [RSAUtils encrypt:text publicKey:key padding:padding];
}

/**
 * RSA 解密（同步）
 * 使用 RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD 宏导出 (需求 9.4)
 */
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(rsaDecryptSync:(NSString *)text
                                                  key:(NSString *)key
                                              padding:(NSString *)padding)
{
    return [RSAUtils decrypt:text privateKey:key padding:padding];
}

#pragma mark - AES 异步方法

/**
 * AES 加密（异步）
 * 使用 RCT_EXPORT_METHOD 宏导出 (需求 9.4)
 */
RCT_EXPORT_METHOD(aesEncrypt:(NSString *)text
                         key:(NSString *)key
                          iv:(NSString *)iv
                        mode:(NSString *)mode
                     resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *result = [AESUtils encrypt:text key:key iv:iv mode:mode];
        resolve(result);
    });
}

/**
 * AES 解密（异步）
 * 使用 RCT_EXPORT_METHOD 宏导出 (需求 9.4)
 */
RCT_EXPORT_METHOD(aesDecrypt:(NSString *)text
                         key:(NSString *)key
                          iv:(NSString *)iv
                        mode:(NSString *)mode
                     resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *result = [AESUtils decrypt:text key:key iv:iv mode:mode];
        resolve(result);
    });
}

#pragma mark - AES 同步方法 (需求 2.7)

/**
 * AES 加密（同步）
 * 使用 RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD 宏导出 (需求 9.4)
 */
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(aesEncryptSync:(NSString *)text
                                                  key:(NSString *)key
                                                   iv:(NSString *)iv
                                                 mode:(NSString *)mode)
{
    return [AESUtils encrypt:text key:key iv:iv mode:mode];
}

/**
 * AES 解密（同步）
 * 使用 RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD 宏导出 (需求 9.4)
 */
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(aesDecryptSync:(NSString *)text
                                                  key:(NSString *)key
                                                   iv:(NSString *)iv
                                                 mode:(NSString *)mode)
{
    return [AESUtils decrypt:text key:key iv:iv mode:mode];
}

@end
