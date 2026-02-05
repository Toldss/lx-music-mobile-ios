/**
 * RSAUtils.m
 * 
 * RSA 加解密工具类实现
 * 使用 Security.framework API 实现
 * 
 * 需求: 2.1, 2.2, 2.3, 2.8
 */

#import "RSAUtils.h"
#import <Security/Security.h>

// 填充模式常量 (需求 2.8)
NSString * const RSAPaddingOAEP = @"RSA/ECB/OAEPWithSHA1AndMGF1Padding";
NSString * const RSAPaddingNoPadding = @"RSA/ECB/NoPadding";

// RSA 密钥大小
static const size_t kRSAKeySize = 2048;

@implementation RSAUtils

#pragma mark - Private Helper Methods

/**
 * 获取 SecPadding 类型
 */
+ (SecPadding)secPaddingForMode:(NSString *)padding {
    if ([padding isEqualToString:RSAPaddingOAEP]) {
        return kSecPaddingOAEP;
    } else if ([padding isEqualToString:RSAPaddingNoPadding]) {
        return kSecPaddingNone;
    }
    // 默认使用 OAEP
    return kSecPaddingOAEP;
}

/**
 * 从 Base64 编码的公钥创建 SecKeyRef
 */
+ (SecKeyRef)createPublicKeyFromBase64:(NSString *)base64Key {
    if (!base64Key || base64Key.length == 0) {
        return NULL;
    }
    
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:base64Key 
                                                          options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (!keyData) {
        return NULL;
    }
    
    NSDictionary *attributes = @{
        (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
        (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPublic,
        (__bridge id)kSecAttrKeySizeInBits: @(kRSAKeySize)
    };
    
    CFErrorRef error = NULL;
    SecKeyRef key = SecKeyCreateWithData((__bridge CFDataRef)keyData,
                                         (__bridge CFDictionaryRef)attributes,
                                         &error);
    
    if (error) {
        NSLog(@"RSAUtils: Failed to create public key: %@", (__bridge NSError *)error);
        CFRelease(error);
        return NULL;
    }
    
    return key;
}

/**
 * 从 Base64 编码的私钥创建 SecKeyRef
 */
+ (SecKeyRef)createPrivateKeyFromBase64:(NSString *)base64Key {
    if (!base64Key || base64Key.length == 0) {
        return NULL;
    }
    
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:base64Key 
                                                          options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (!keyData) {
        return NULL;
    }
    
    NSDictionary *attributes = @{
        (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
        (__bridge id)kSecAttrKeyClass: (__bridge id)kSecAttrKeyClassPrivate,
        (__bridge id)kSecAttrKeySizeInBits: @(kRSAKeySize)
    };
    
    CFErrorRef error = NULL;
    SecKeyRef key = SecKeyCreateWithData((__bridge CFDataRef)keyData,
                                         (__bridge CFDictionaryRef)attributes,
                                         &error);
    
    if (error) {
        NSLog(@"RSAUtils: Failed to create private key: %@", (__bridge NSError *)error);
        CFRelease(error);
        return NULL;
    }
    
    return key;
}

/**
 * 获取加密算法
 */
+ (SecKeyAlgorithm)encryptAlgorithmForPadding:(NSString *)padding {
    if ([padding isEqualToString:RSAPaddingOAEP]) {
        return kSecKeyAlgorithmRSAEncryptionOAEPSHA1;
    } else if ([padding isEqualToString:RSAPaddingNoPadding]) {
        return kSecKeyAlgorithmRSAEncryptionRaw;
    }
    return kSecKeyAlgorithmRSAEncryptionOAEPSHA1;
}

#pragma mark - Public Methods

+ (NSDictionary<NSString *, NSString *> *)generateKeyPair {
    @try {
        // 密钥生成参数
        NSDictionary *attributes = @{
            (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
            (__bridge id)kSecAttrKeySizeInBits: @(kRSAKeySize)
        };
        
        CFErrorRef error = NULL;
        
        // 生成私钥
        SecKeyRef privateKey = SecKeyCreateRandomKey((__bridge CFDictionaryRef)attributes, &error);
        
        if (!privateKey || error) {
            if (error) {
                NSLog(@"RSAUtils: Key generation failed: %@", (__bridge NSError *)error);
                CFRelease(error);
            }
            return nil;
        }
        
        // 从私钥获取公钥
        SecKeyRef publicKey = SecKeyCopyPublicKey(privateKey);
        
        if (!publicKey) {
            CFRelease(privateKey);
            NSLog(@"RSAUtils: Failed to get public key from private key");
            return nil;
        }
        
        // 导出公钥数据
        CFDataRef publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error);
        if (!publicKeyData || error) {
            if (error) {
                NSLog(@"RSAUtils: Failed to export public key: %@", (__bridge NSError *)error);
                CFRelease(error);
            }
            CFRelease(publicKey);
            CFRelease(privateKey);
            return nil;
        }
        
        // 导出私钥数据
        CFDataRef privateKeyData = SecKeyCopyExternalRepresentation(privateKey, &error);
        if (!privateKeyData || error) {
            if (error) {
                NSLog(@"RSAUtils: Failed to export private key: %@", (__bridge NSError *)error);
                CFRelease(error);
            }
            CFRelease(publicKeyData);
            CFRelease(publicKey);
            CFRelease(privateKey);
            return nil;
        }
        
        // Base64 编码
        NSString *publicKeyBase64 = [(__bridge NSData *)publicKeyData base64EncodedStringWithOptions:0];
        NSString *privateKeyBase64 = [(__bridge NSData *)privateKeyData base64EncodedStringWithOptions:0];
        
        // 清理
        CFRelease(publicKeyData);
        CFRelease(privateKeyData);
        CFRelease(publicKey);
        CFRelease(privateKey);
        
        return @{
            @"publicKey": publicKeyBase64 ?: @"",
            @"privateKey": privateKeyBase64 ?: @""
        };
        
    } @catch (NSException *exception) {
        NSLog(@"RSAUtils: Key generation exception: %@", exception);
        return nil;
    }
}

+ (NSString *)encrypt:(NSString *)plainTextBase64
            publicKey:(NSString *)publicKeyBase64
              padding:(NSString *)padding {
    
    if (!plainTextBase64 || !publicKeyBase64 || 
        plainTextBase64.length == 0 || publicKeyBase64.length == 0) {
        return @"";
    }
    
    @try {
        // 解码明文
        NSData *plainData = [[NSData alloc] initWithBase64EncodedString:plainTextBase64 
                                                               options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (!plainData) {
            NSLog(@"RSAUtils: Failed to decode plaintext base64");
            return @"";
        }
        
        // 创建公钥
        SecKeyRef publicKey = [self createPublicKeyFromBase64:publicKeyBase64];
        if (!publicKey) {
            NSLog(@"RSAUtils: Failed to create public key");
            return @"";
        }
        
        // 获取加密算法
        SecKeyAlgorithm algorithm = [self encryptAlgorithmForPadding:padding];
        
        // 检查是否支持该算法
        if (!SecKeyIsAlgorithmSupported(publicKey, kSecKeyOperationTypeEncrypt, algorithm)) {
            NSLog(@"RSAUtils: Algorithm not supported for encryption");
            CFRelease(publicKey);
            return @"";
        }
        
        // 执行加密
        CFErrorRef error = NULL;
        CFDataRef encryptedData = SecKeyCreateEncryptedData(publicKey, algorithm,
                                                            (__bridge CFDataRef)plainData, &error);
        
        CFRelease(publicKey);
        
        if (!encryptedData || error) {
            if (error) {
                NSLog(@"RSAUtils: Encryption failed: %@", (__bridge NSError *)error);
                CFRelease(error);
            }
            return @"";
        }
        
        // Base64 编码结果
        NSString *result = [(__bridge NSData *)encryptedData base64EncodedStringWithOptions:0];
        CFRelease(encryptedData);
        
        return result ?: @"";
        
    } @catch (NSException *exception) {
        NSLog(@"RSAUtils: Encryption exception: %@", exception);
        return @"";
    }
}

+ (NSString *)decrypt:(NSString *)cipherTextBase64
           privateKey:(NSString *)privateKeyBase64
              padding:(NSString *)padding {
    
    if (!cipherTextBase64 || !privateKeyBase64 || 
        cipherTextBase64.length == 0 || privateKeyBase64.length == 0) {
        return @"";
    }
    
    @try {
        // 解码密文
        NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:cipherTextBase64 
                                                                options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (!cipherData) {
            NSLog(@"RSAUtils: Failed to decode ciphertext base64");
            return @"";
        }
        
        // 创建私钥
        SecKeyRef privateKey = [self createPrivateKeyFromBase64:privateKeyBase64];
        if (!privateKey) {
            NSLog(@"RSAUtils: Failed to create private key");
            return @"";
        }
        
        // 获取解密算法
        SecKeyAlgorithm algorithm = [self encryptAlgorithmForPadding:padding];
        
        // 检查是否支持该算法
        if (!SecKeyIsAlgorithmSupported(privateKey, kSecKeyOperationTypeDecrypt, algorithm)) {
            NSLog(@"RSAUtils: Algorithm not supported for decryption");
            CFRelease(privateKey);
            return @"";
        }
        
        // 执行解密
        CFErrorRef error = NULL;
        CFDataRef decryptedData = SecKeyCreateDecryptedData(privateKey, algorithm,
                                                            (__bridge CFDataRef)cipherData, &error);
        
        CFRelease(privateKey);
        
        if (!decryptedData || error) {
            if (error) {
                NSLog(@"RSAUtils: Decryption failed: %@", (__bridge NSError *)error);
                CFRelease(error);
            }
            return @"";
        }
        
        // 转换为字符串
        NSString *result = [[NSString alloc] initWithData:(__bridge NSData *)decryptedData 
                                                 encoding:NSUTF8StringEncoding];
        CFRelease(decryptedData);
        
        return result ?: @"";
        
    } @catch (NSException *exception) {
        NSLog(@"RSAUtils: Decryption exception: %@", exception);
        return @"";
    }
}

@end
