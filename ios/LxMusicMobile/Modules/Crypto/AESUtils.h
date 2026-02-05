/**
 * AESUtils.h
 * 
 * AES 加解密工具类，提供加密和解密功能
 * 使用 CommonCrypto API 实现
 * 
 * 需求: 2.5, 2.6, 2.9
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * AES 加密模式常量
 */
extern NSString * const AESModeCBCPKCS7;   // AES/CBC/PKCS7Padding
extern NSString * const AESModeECBNoPadding; // AES/ECB/NoPadding

/**
 * AES 工具类
 * 
 * 提供 AES 加密和解密功能
 * 支持 CBC/PKCS7Padding 和 ECB/NoPadding 两种模式
 */
@interface AESUtils : NSObject

/**
 * AES 加密 (需求 2.5)
 * 
 * @param dataBase64 Base64 编码的明文数据
 * @param keyBase64 Base64 编码的密钥
 * @param ivBase64 Base64 编码的初始化向量 (CBC 模式需要，ECB 模式可为空字符串)
 * @param mode 加密模式 (AESModeCBCPKCS7 或 AESModeECBNoPadding)
 * @return Base64 编码的密文，失败返回空字符串
 */
+ (NSString *)encrypt:(NSString *)dataBase64
                  key:(NSString *)keyBase64
                   iv:(NSString *)ivBase64
                 mode:(NSString *)mode;

/**
 * AES 解密 (需求 2.6)
 * 
 * @param cipherTextBase64 Base64 编码的密文
 * @param keyBase64 Base64 编码的密钥
 * @param ivBase64 Base64 编码的初始化向量 (CBC 模式需要，ECB 模式可为空字符串)
 * @param mode 加密模式 (AESModeCBCPKCS7 或 AESModeECBNoPadding)
 * @return 解密后的明文字符串，失败返回空字符串
 */
+ (NSString *)decrypt:(NSString *)cipherTextBase64
                  key:(NSString *)keyBase64
                   iv:(NSString *)ivBase64
                 mode:(NSString *)mode;

@end

NS_ASSUME_NONNULL_END
