/**
 * RSAUtils.h
 * 
 * RSA 加解密工具类，提供密钥生成、加密和解密功能
 * 使用 Security.framework API 实现
 * 
 * 需求: 2.1, 2.2, 2.3, 2.8
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * RSA 填充模式常量
 */
extern NSString * const RSAPaddingOAEP;      // RSA/ECB/OAEPWithSHA1AndMGF1Padding
extern NSString * const RSAPaddingNoPadding; // RSA/ECB/NoPadding

/**
 * RSA 工具类
 * 
 * 提供 RSA 密钥对生成、加密和解密功能
 * 支持 OAEP 和 NoPadding 两种填充模式
 */
@interface RSAUtils : NSObject

/**
 * 生成 2048 位 RSA 密钥对 (需求 2.1)
 * 
 * @return 包含 publicKey 和 privateKey 的字典，均为 Base64 编码
 *         publicKey: X.509/SPKI 格式的公钥
 *         privateKey: PKCS#8 格式的私钥
 *         如果生成失败返回 nil
 */
+ (nullable NSDictionary<NSString *, NSString *> *)generateKeyPair;

/**
 * RSA 加密 (需求 2.2)
 * 
 * @param plainTextBase64 Base64 编码的明文数据
 * @param publicKeyBase64 Base64 编码的公钥 (X.509/SPKI 格式)
 * @param padding 填充模式 (RSAPaddingOAEP 或 RSAPaddingNoPadding)
 * @return Base64 编码的密文，失败返回空字符串
 */
+ (NSString *)encrypt:(NSString *)plainTextBase64
            publicKey:(NSString *)publicKeyBase64
              padding:(NSString *)padding;

/**
 * RSA 解密 (需求 2.3)
 * 
 * @param cipherTextBase64 Base64 编码的密文
 * @param privateKeyBase64 Base64 编码的私钥 (PKCS#8 格式)
 * @param padding 填充模式 (RSAPaddingOAEP 或 RSAPaddingNoPadding)
 * @return 解密后的明文字符串，失败返回空字符串
 */
+ (NSString *)decrypt:(NSString *)cipherTextBase64
           privateKey:(NSString *)privateKeyBase64
              padding:(NSString *)padding;

@end

NS_ASSUME_NONNULL_END
