/**
 * CryptoModule.h
 * 
 * 加密模块，提供 RSA 和 AES 加解密功能
 * 整合 RSAUtils 和 AESUtils 工具类
 * 
 * 需求: 2.4, 2.7, 9.3, 9.4
 */

#import <React/RCTBridgeModule.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * CryptoModule
 * 
 * React Native 原生模块，提供加密功能
 * - RSA 密钥生成、加密、解密（异步和同步）
 * - AES 加密、解密（异步和同步）
 */
@interface CryptoModule : NSObject <RCTBridgeModule>

#pragma mark - RSA 异步方法

/**
 * 生成 RSA 密钥对
 * @param resolve Promise 成功回调，返回包含 publicKey 和 privateKey 的字典
 * @param reject Promise 失败回调
 */
- (void)generateRsaKey:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject;

/**
 * RSA 加密（异步）
 * @param text Base64 编码的明文
 * @param key Base64 编码的公钥
 * @param padding 填充模式
 * @param resolve Promise 成功回调，返回 Base64 编码的密文
 * @param reject Promise 失败回调
 */
- (void)rsaEncrypt:(NSString *)text
               key:(NSString *)key
           padding:(NSString *)padding
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject;

/**
 * RSA 解密（异步）
 * @param text Base64 编码的密文
 * @param key Base64 编码的私钥
 * @param padding 填充模式
 * @param resolve Promise 成功回调，返回解密后的明文
 * @param reject Promise 失败回调
 */
- (void)rsaDecrypt:(NSString *)text
               key:(NSString *)key
           padding:(NSString *)padding
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject;

#pragma mark - RSA 同步方法 (需求 2.4)

/**
 * RSA 加密（同步）
 * @param text Base64 编码的明文
 * @param key Base64 编码的公钥
 * @param padding 填充模式
 * @return Base64 编码的密文，失败返回空字符串
 */
- (NSString *)rsaEncryptSync:(NSString *)text
                         key:(NSString *)key
                     padding:(NSString *)padding;

/**
 * RSA 解密（同步）
 * @param text Base64 编码的密文
 * @param key Base64 编码的私钥
 * @param padding 填充模式
 * @return 解密后的明文，失败返回空字符串
 */
- (NSString *)rsaDecryptSync:(NSString *)text
                         key:(NSString *)key
                     padding:(NSString *)padding;

#pragma mark - AES 异步方法

/**
 * AES 加密（异步）
 * @param text Base64 编码的明文
 * @param key Base64 编码的密钥
 * @param iv Base64 编码的初始化向量
 * @param mode 加密模式
 * @param resolve Promise 成功回调，返回 Base64 编码的密文
 * @param reject Promise 失败回调
 */
- (void)aesEncrypt:(NSString *)text
               key:(NSString *)key
                iv:(NSString *)iv
              mode:(NSString *)mode
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject;

/**
 * AES 解密（异步）
 * @param text Base64 编码的密文
 * @param key Base64 编码的密钥
 * @param iv Base64 编码的初始化向量
 * @param mode 加密模式
 * @param resolve Promise 成功回调，返回解密后的明文
 * @param reject Promise 失败回调
 */
- (void)aesDecrypt:(NSString *)text
               key:(NSString *)key
                iv:(NSString *)iv
              mode:(NSString *)mode
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject;

#pragma mark - AES 同步方法 (需求 2.7)

/**
 * AES 加密（同步）
 * @param text Base64 编码的明文
 * @param key Base64 编码的密钥
 * @param iv Base64 编码的初始化向量
 * @param mode 加密模式
 * @return Base64 编码的密文，失败返回空字符串
 */
- (NSString *)aesEncryptSync:(NSString *)text
                         key:(NSString *)key
                          iv:(NSString *)iv
                        mode:(NSString *)mode;

/**
 * AES 解密（同步）
 * @param text Base64 编码的密文
 * @param key Base64 编码的密钥
 * @param iv Base64 编码的初始化向量
 * @param mode 加密模式
 * @return 解密后的明文，失败返回空字符串
 */
- (NSString *)aesDecryptSync:(NSString *)text
                         key:(NSString *)key
                          iv:(NSString *)iv
                        mode:(NSString *)mode;

@end

NS_ASSUME_NONNULL_END
