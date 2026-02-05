/**
 * AESUtils.m
 * 
 * AES 加解密工具类实现
 * 使用 CommonCrypto API 实现
 * 
 * 需求: 2.5, 2.6, 2.9
 */

#import "AESUtils.h"
#import <CommonCrypto/CommonCrypto.h>

// 加密模式常量 (需求 2.9)
NSString * const AESModeCBCPKCS7 = @"AES/CBC/PKCS7Padding";
NSString * const AESModeECBNoPadding = @"AES/ECB/NoPadding";

// AES 块大小
static const size_t kAESBlockSize = kCCBlockSizeAES128;

@implementation AESUtils

#pragma mark - Private Helper Methods

/**
 * 判断是否为 CBC 模式
 */
+ (BOOL)isCBCMode:(NSString *)mode {
    return [mode isEqualToString:AESModeCBCPKCS7];
}

/**
 * 判断是否为 ECB 模式
 * 支持 "AES/ECB/NoPadding" 和 "AES" 两种格式
 */
+ (BOOL)isECBMode:(NSString *)mode {
    return [mode isEqualToString:AESModeECBNoPadding] || [mode isEqualToString:@"AES"];
}

/**
 * 获取 CCOptions 选项
 */
+ (CCOptions)optionsForMode:(NSString *)mode {
    if ([self isCBCMode:mode]) {
        // CBC 模式使用 PKCS7 填充
        return kCCOptionPKCS7Padding;
    } else if ([self isECBMode:mode]) {
        // ECB 模式无填充
        return kCCOptionECBMode;
    }
    // 默认使用 CBC + PKCS7
    return kCCOptionPKCS7Padding;
}

/**
 * 准备 IV 数据，确保长度为 16 字节
 */
+ (NSData *)prepareIV:(NSData *)ivData {
    if (!ivData || ivData.length == 0) {
        // 返回全零 IV
        return [NSMutableData dataWithLength:kAESBlockSize];
    }
    
    NSMutableData *finalIV = [NSMutableData dataWithLength:kAESBlockSize];
    NSUInteger copyLength = MIN(ivData.length, kAESBlockSize);
    memcpy(finalIV.mutableBytes, ivData.bytes, copyLength);
    
    return finalIV;
}

#pragma mark - Public Methods

+ (NSString *)encrypt:(NSString *)dataBase64
                  key:(NSString *)keyBase64
                   iv:(NSString *)ivBase64
                 mode:(NSString *)mode {
    
    if (!dataBase64 || !keyBase64 || dataBase64.length == 0 || keyBase64.length == 0) {
        return @"";
    }
    
    @try {
        // 解码 Base64 数据
        NSData *plainData = [[NSData alloc] initWithBase64EncodedString:dataBase64 
                                                                options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (!plainData) {
            NSLog(@"AESUtils: Failed to decode data base64");
            return @"";
        }
        
        // 解码 Base64 密钥
        NSData *keyData = [[NSData alloc] initWithBase64EncodedString:keyBase64 
                                                              options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (!keyData) {
            NSLog(@"AESUtils: Failed to decode key base64");
            return @"";
        }
        
        // 解码 Base64 IV (如果提供)
        NSData *ivData = nil;
        if (ivBase64 && ivBase64.length > 0) {
            ivData = [[NSData alloc] initWithBase64EncodedString:ivBase64 
                                                         options:NSDataBase64DecodingIgnoreUnknownCharacters];
        }
        
        // 获取加密选项
        CCOptions options = [self optionsForMode:mode];
        
        // 准备 IV
        NSData *finalIV = [self prepareIV:ivData];
        
        // 计算输出缓冲区大小
        // 对于 PKCS7 填充，输出可能比输入大一个块
        size_t bufferSize = plainData.length + kAESBlockSize;
        NSMutableData *encryptedData = [NSMutableData dataWithLength:bufferSize];
        
        size_t numBytesEncrypted = 0;
        
        // 执行加密
        CCCryptorStatus status;
        
        if ([self isECBMode:mode]) {
            // ECB 模式不使用 IV
            status = CCCrypt(kCCEncrypt,
                            kCCAlgorithmAES,
                            options,
                            keyData.bytes,
                            keyData.length,
                            NULL,  // ECB 模式不需要 IV
                            plainData.bytes,
                            plainData.length,
                            encryptedData.mutableBytes,
                            bufferSize,
                            &numBytesEncrypted);
        } else {
            // CBC 模式使用 IV
            status = CCCrypt(kCCEncrypt,
                            kCCAlgorithmAES,
                            options,
                            keyData.bytes,
                            keyData.length,
                            finalIV.bytes,
                            plainData.bytes,
                            plainData.length,
                            encryptedData.mutableBytes,
                            bufferSize,
                            &numBytesEncrypted);
        }
        
        if (status != kCCSuccess) {
            NSLog(@"AESUtils: Encryption failed with status: %d", status);
            return @"";
        }
        
        // 调整数据长度为实际加密后的长度
        encryptedData.length = numBytesEncrypted;
        
        // Base64 编码结果
        NSString *result = [encryptedData base64EncodedStringWithOptions:0];
        
        return result ?: @"";
        
    } @catch (NSException *exception) {
        NSLog(@"AESUtils: Encryption exception: %@", exception);
        return @"";
    }
}

+ (NSString *)decrypt:(NSString *)cipherTextBase64
                  key:(NSString *)keyBase64
                   iv:(NSString *)ivBase64
                 mode:(NSString *)mode {
    
    if (!cipherTextBase64 || !keyBase64 || cipherTextBase64.length == 0 || keyBase64.length == 0) {
        return @"";
    }
    
    @try {
        // 解码 Base64 密文
        NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:cipherTextBase64 
                                                                 options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (!cipherData) {
            NSLog(@"AESUtils: Failed to decode ciphertext base64");
            return @"";
        }
        
        // 解码 Base64 密钥
        NSData *keyData = [[NSData alloc] initWithBase64EncodedString:keyBase64 
                                                              options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (!keyData) {
            NSLog(@"AESUtils: Failed to decode key base64");
            return @"";
        }
        
        // 解码 Base64 IV (如果提供)
        NSData *ivData = nil;
        if (ivBase64 && ivBase64.length > 0) {
            ivData = [[NSData alloc] initWithBase64EncodedString:ivBase64 
                                                         options:NSDataBase64DecodingIgnoreUnknownCharacters];
        }
        
        // 获取解密选项
        CCOptions options = [self optionsForMode:mode];
        
        // 准备 IV
        NSData *finalIV = [self prepareIV:ivData];
        
        // 计算输出缓冲区大小
        size_t bufferSize = cipherData.length + kAESBlockSize;
        NSMutableData *decryptedData = [NSMutableData dataWithLength:bufferSize];
        
        size_t numBytesDecrypted = 0;
        
        // 执行解密
        CCCryptorStatus status;
        
        if ([self isECBMode:mode]) {
            // ECB 模式不使用 IV
            status = CCCrypt(kCCDecrypt,
                            kCCAlgorithmAES,
                            options,
                            keyData.bytes,
                            keyData.length,
                            NULL,  // ECB 模式不需要 IV
                            cipherData.bytes,
                            cipherData.length,
                            decryptedData.mutableBytes,
                            bufferSize,
                            &numBytesDecrypted);
        } else {
            // CBC 模式使用 IV
            status = CCCrypt(kCCDecrypt,
                            kCCAlgorithmAES,
                            options,
                            keyData.bytes,
                            keyData.length,
                            finalIV.bytes,
                            cipherData.bytes,
                            cipherData.length,
                            decryptedData.mutableBytes,
                            bufferSize,
                            &numBytesDecrypted);
        }
        
        if (status != kCCSuccess) {
            NSLog(@"AESUtils: Decryption failed with status: %d", status);
            return @"";
        }
        
        // 调整数据长度为实际解密后的长度
        decryptedData.length = numBytesDecrypted;
        
        // 转换为 UTF-8 字符串
        NSString *result = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
        
        return result ?: @"";
        
    } @catch (NSException *exception) {
        NSLog(@"AESUtils: Decryption exception: %@", exception);
        return @"";
    }
}

@end
