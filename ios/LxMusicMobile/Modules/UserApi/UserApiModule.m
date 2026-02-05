/**
 * UserApiModule.m
 * 
 * 用户自定义 API 模块实现
 * 使用 JavaScriptCore 执行用户提供的 JavaScript 脚本
 * 
 * 需求: 4.1, 4.2, 4.3, 4.4, 9.3, 9.4
 */

#import "UserApiModule.h"
#import <React/RCTLog.h>
#import <CommonCrypto/CommonDigest.h>

// 导入加密工具类（用于 Task 6.2 的原生方法注入）
#import "../Crypto/AESUtils.h"
#import "../Crypto/RSAUtils.h"

@interface UserApiModule ()

/** 事件监听器计数 */
@property (nonatomic, assign) NSInteger listenerCount;

/** 定时器字典，存储 setTimeout 的回调 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, dispatch_source_t> *timers;

/** 定时器 ID 计数器 */
@property (nonatomic, assign) NSInteger timerIdCounter;

@end

@implementation UserApiModule

// 使用 RCT_EXPORT_MODULE 宏导出模块 (需求 9.3)
RCT_EXPORT_MODULE();

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _jsContext = nil;
        _jsQueue = nil;
        _scriptId = nil;
        _scriptKey = nil;
        _isInitialized = NO;
        _listenerCount = 0;
        _timers = [NSMutableDictionary dictionary];
        _timerIdCounter = 0;
    }
    return self;
}

- (void)dealloc {
    [self destroy];
}

#pragma mark - RCTEventEmitter Required Methods

/**
 * 返回支持的事件名称列表
 */
- (NSArray<NSString *> *)supportedEvents {
    return @[
        @"user-api-init",      // 初始化完成事件
        @"user-api-action",    // 动作事件
        @"user-api-error",     // 错误事件
        @"user-api-response"   // 响应事件
    ];
}

/**
 * 在主队列上执行
 */
+ (BOOL)requiresMainQueueSetup {
    return NO;
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

#pragma mark - Script Management Methods

/**
 * 加载并执行脚本
 * 需求 4.1: 使用 JavaScriptCore 创建独立的 JavaScript 执行环境
 * 需求 4.2: 脚本加载成功后发送 init 事件通知 JavaScript 层
 * 使用 RCT_EXPORT_METHOD 宏导出 (需求 9.4)
 */
RCT_EXPORT_METHOD(loadScript:(NSDictionary *)data) {
    // 如果已经初始化，先销毁旧环境
    if (self.isInitialized) {
        [self destroy];
    }
    
    // 提取脚本信息
    NSString *scriptId = data[@"id"] ?: @"";
    NSString *name = data[@"name"] ?: @"";
    NSString *description = data[@"description"] ?: @"";
    NSString *version = data[@"version"] ?: @"";
    NSString *author = data[@"author"] ?: @"";
    NSString *homepage = data[@"homepage"] ?: @"";
    NSString *script = data[@"script"] ?: @"";
    
    self.scriptId = scriptId;
    
    // 生成唯一密钥用于安全通信
    self.scriptKey = [self generateScriptKey];
    
    // 创建后台队列执行脚本，避免阻塞主线程
    NSString *queueName = [NSString stringWithFormat:@"com.lxmusic.userapi.%@", scriptId];
    self.jsQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
    
    // 在后台队列中创建和配置 JSContext
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.jsQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        // 需求 4.1: 创建独立的 JavaScript 执行环境
        strongSelf.jsContext = [[JSContext alloc] init];
        
        // 配置异常处理
        strongSelf.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            NSString *errorMessage = [exception toString];
            RCTLogError(@"UserApiModule: JavaScript exception: %@", errorMessage);
            
            // 发送错误事件到 JavaScript 层
            [strongSelf sendErrorEvent:errorMessage];
        };
        
        // 注入原生方法（Task 6.2 将完善这部分）
        [strongSelf injectNativeMethods];
        
        // 加载预加载脚本
        BOOL preloadSuccess = [strongSelf loadPreloadScript];
        if (!preloadSuccess) {
            RCTLogError(@"UserApiModule: Failed to load preload script");
            [strongSelf sendErrorEvent:@"Failed to load preload script"];
            return;
        }
        
        // 调用 lx_setup 初始化脚本环境
        NSString *setupScript = [NSString stringWithFormat:
            @"if (typeof lx_setup === 'function') { "
            @"  lx_setup('%@', '%@', '%@', '%@', '%@', '%@', '%@', %@); "
            @"}",
            [strongSelf escapeJSString:strongSelf.scriptKey],
            [strongSelf escapeJSString:scriptId],
            [strongSelf escapeJSString:name],
            [strongSelf escapeJSString:description],
            [strongSelf escapeJSString:version],
            [strongSelf escapeJSString:author],
            [strongSelf escapeJSString:homepage],
            [strongSelf escapeJSString:script]
        ];
        
        [strongSelf.jsContext evaluateScript:setupScript];
        
        // 执行用户脚本
        JSValue *result = [strongSelf.jsContext evaluateScript:script];
        
        // 检查脚本执行是否有异常
        if (strongSelf.jsContext.exception) {
            NSString *errorMessage = [strongSelf.jsContext.exception toString];
            RCTLogError(@"UserApiModule: Script execution error: %@", errorMessage);
            [strongSelf sendErrorEvent:errorMessage];
            strongSelf.jsContext.exception = nil;
            return;
        }
        
        strongSelf.isInitialized = YES;
        
        RCTLogInfo(@"UserApiModule: Script loaded successfully, id: %@", scriptId);
        
        // 需求 4.2: 发送 init 事件通知 JavaScript 层
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf sendEventWithName:@"user-api-init" body:@{
                @"id": scriptId,
                @"status": @YES
            }];
        });
    });
}

/**
 * 向脚本发送动作
 * 需求 4.3: 将动作和数据传递给脚本执行环境
 * 使用 RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD 宏导出 (需求 9.4)
 */
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(sendAction:(NSString *)action info:(NSString *)info) {
    if (!self.isInitialized || !self.jsContext || !self.jsQueue) {
        RCTLogWarn(@"UserApiModule: Cannot send action, script not initialized");
        return @(NO);
    }
    
    __block BOOL success = NO;
    
    // 在 JS 队列中同步执行
    dispatch_sync(self.jsQueue, ^{
        @try {
            // 调用脚本中的 __lx_native__ 函数
            NSString *callScript = [NSString stringWithFormat:
                @"(function() { "
                @"  if (typeof __lx_native__ === 'function') { "
                @"    return __lx_native__('%@', '%@', %@); "
                @"  } "
                @"  return 'Script not initialized'; "
                @"})()",
                [self escapeJSString:self.scriptKey],
                [self escapeJSString:action],
                info ? [NSString stringWithFormat:@"'%@'", [self escapeJSString:info]] : @"null"
            ];
            
            JSValue *result = [self.jsContext evaluateScript:callScript];
            
            // 检查执行结果
            if (self.jsContext.exception) {
                NSString *errorMessage = [self.jsContext.exception toString];
                RCTLogError(@"UserApiModule: sendAction error: %@", errorMessage);
                self.jsContext.exception = nil;
                success = NO;
            } else {
                // 如果返回值不是错误字符串，则认为成功
                NSString *resultStr = [result toString];
                success = ![resultStr hasPrefix:@"Invalid"] && ![resultStr hasPrefix:@"Unknown"];
            }
        } @catch (NSException *exception) {
            RCTLogError(@"UserApiModule: sendAction exception: %@", exception.reason);
            success = NO;
        }
    });
    
    return @(success);
}

/**
 * 销毁 JavaScript 执行环境
 * 需求 4.4: 销毁 JavaScript 执行环境并释放资源
 * 使用 RCT_EXPORT_METHOD 宏导出 (需求 9.4)
 */
RCT_EXPORT_METHOD(destroy) {
    RCTLogInfo(@"UserApiModule: Destroying script environment, id: %@", self.scriptId);
    
    // 取消所有定时器
    [self cancelAllTimers];
    
    // 清理 JSContext
    if (self.jsContext) {
        // 在 JS 队列中清理
        if (self.jsQueue) {
            dispatch_sync(self.jsQueue, ^{
                self.jsContext.exceptionHandler = nil;
                self.jsContext = nil;
            });
        } else {
            self.jsContext.exceptionHandler = nil;
            self.jsContext = nil;
        }
    }
    
    // 清理队列
    self.jsQueue = nil;
    
    // 重置状态
    self.scriptId = nil;
    self.scriptKey = nil;
    self.isInitialized = NO;
    
    RCTLogInfo(@"UserApiModule: Script environment destroyed");
}

#pragma mark - Native Call Handler

/**
 * 处理脚本的原生调用
 */
- (void)handleNativeCall:(NSString *)key action:(NSString *)action data:(NSString *)data {
    // 验证密钥
    if (![key isEqualToString:self.scriptKey]) {
        RCTLogWarn(@"UserApiModule: Invalid script key");
        return;
    }
    
    // 发送事件到 JavaScript 层
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendEventWithName:@"user-api-action" body:@{
            @"id": self.scriptId ?: @"",
            @"action": action ?: @"",
            @"data": data ?: @""
        }];
    });
}

#pragma mark - Private Methods

/**
 * 生成脚本密钥
 */
- (NSString *)generateScriptKey {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    NSString *combined = [NSString stringWithFormat:@"%@_%@", uuid, timestamp];
    
    // 使用 MD5 生成密钥
    const char *cStr = [combined UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

/**
 * 加载预加载脚本
 */
- (BOOL)loadPreloadScript {
    // 从 bundle 中加载 user-api-preload.js
    NSString *preloadPath = [[NSBundle mainBundle] pathForResource:@"user-api-preload" ofType:@"js"];
    
    if (!preloadPath) {
        RCTLogError(@"UserApiModule: Preload script not found in bundle");
        return NO;
    }
    
    NSError *error = nil;
    NSString *preloadScript = [NSString stringWithContentsOfFile:preloadPath
                                                        encoding:NSUTF8StringEncoding
                                                           error:&error];
    
    if (error || !preloadScript) {
        RCTLogError(@"UserApiModule: Failed to read preload script: %@", error.localizedDescription);
        return NO;
    }
    
    // 执行预加载脚本
    [self.jsContext evaluateScript:preloadScript];
    
    if (self.jsContext.exception) {
        NSString *errorMessage = [self.jsContext.exception toString];
        RCTLogError(@"UserApiModule: Preload script error: %@", errorMessage);
        self.jsContext.exception = nil;
        return NO;
    }
    
    RCTLogInfo(@"UserApiModule: Preload script loaded successfully");
    return YES;
}

/**
 * 注入原生方法到 JSContext
 * 
 * 需求 4.5: 提供与 Android 版本相同的预加载脚本环境
 * 需求 4.6: 支持脚本调用原生加密方法（AES、RSA、MD5）
 * 需求 4.7: 支持 Base64 编解码功能
 * 需求 4.8: 支持 setTimeout 定时器功能
 * 
 * 注入的方法:
 * - __lx_native_call__: 回调函数，用于脚本与原生层通信
 * - __lx_native_call__set_timeout: 定时器功能
 * - __lx_native_call__utils_str2b64: Base64 编码
 * - __lx_native_call__utils_b642buf: Base64 解码
 * - __lx_native_call__utils_str2md5: MD5 计算
 * - __lx_native_call__utils_aes_encrypt: AES 加密
 * - __lx_native_call__utils_rsa_encrypt: RSA 加密
 */
- (void)injectNativeMethods {
    __weak typeof(self) weakSelf = self;
    
    // 注入 __lx_native_call__ 回调函数
    self.jsContext[@"__lx_native_call__"] = ^(NSString *key, NSString *action, NSString *data) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf handleNativeCall:key action:action data:data];
        }
    };
    
    // 注入 setTimeout 定时器功能
    self.jsContext[@"__lx_native_call__set_timeout"] = ^(NSNumber *timerId, NSNumber *timeout) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setupTimer:timerId timeout:timeout];
        }
    };
    
    // 注入 Base64 编码功能
    self.jsContext[@"__lx_native_call__utils_str2b64"] = ^NSString *(NSString *str) {
        if (!str) return @"";
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        return [data base64EncodedStringWithOptions:0];
    };
    
    // 注入 Base64 解码功能（返回字节数组的 JSON 字符串）
    self.jsContext[@"__lx_native_call__utils_b642buf"] = ^NSString *(NSString *base64Str) {
        if (!base64Str) return @"[]";
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64Str options:0];
        if (!data) return @"[]";
        
        NSMutableArray *bytes = [NSMutableArray arrayWithCapacity:data.length];
        const uint8_t *bytePtr = data.bytes;
        for (NSUInteger i = 0; i < data.length; i++) {
            [bytes addObject:@(bytePtr[i])];
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bytes options:0 error:&error];
        if (error) return @"[]";
        
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    };
    
    // 注入 MD5 计算功能
    self.jsContext[@"__lx_native_call__utils_str2md5"] = ^NSString *(NSString *str) {
        if (!str) return @"";
        
        // URL 解码（因为 JS 端会先 encodeURIComponent）
        NSString *decodedStr = [str stringByRemovingPercentEncoding];
        if (!decodedStr) decodedStr = str;
        
        const char *cStr = [decodedStr UTF8String];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", digest[i]];
        }
        
        return output;
    };
    
    // 注入 AES 加密功能
    self.jsContext[@"__lx_native_call__utils_aes_encrypt"] = ^NSString *(NSString *dataBase64, NSString *keyBase64, NSString *ivBase64, NSString *mode) {
        return [AESUtils encrypt:dataBase64 key:keyBase64 iv:ivBase64 mode:mode];
    };
    
    // 注入 RSA 加密功能
    self.jsContext[@"__lx_native_call__utils_rsa_encrypt"] = ^NSString *(NSString *dataBase64, NSString *keyBase64, NSString *padding) {
        return [RSAUtils encrypt:dataBase64 publicKey:keyBase64 padding:padding];
    };
    
    // 注入 console.log
    self.jsContext[@"console"][@"log"] = ^(NSString *message) {
        RCTLogInfo(@"UserApiModule [JS]: %@", message);
    };
    
    self.jsContext[@"console"][@"error"] = ^(NSString *message) {
        RCTLogError(@"UserApiModule [JS Error]: %@", message);
    };
    
    self.jsContext[@"console"][@"warn"] = ^(NSString *message) {
        RCTLogWarn(@"UserApiModule [JS Warn]: %@", message);
    };
}

/**
 * 设置定时器
 */
- (void)setupTimer:(NSNumber *)timerId timeout:(NSNumber *)timeout {
    if (!self.jsQueue) return;
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.jsQueue);
    
    uint64_t interval = (uint64_t)([timeout doubleValue] * NSEC_PER_MSEC);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval), DISPATCH_TIME_FOREVER, 0);
    
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || !strongSelf.jsContext) return;
        
        // 移除定时器
        [strongSelf.timers removeObjectForKey:timerId];
        dispatch_source_cancel(timer);
        
        // 调用 JS 中的 __lx_native__ 处理定时器回调
        NSString *callScript = [NSString stringWithFormat:
            @"if (typeof __lx_native__ === 'function') { "
            @"  __lx_native__('%@', '__set_timeout__', %@); "
            @"}",
            [strongSelf escapeJSString:strongSelf.scriptKey],
            timerId
        ];
        
        [strongSelf.jsContext evaluateScript:callScript];
    });
    
    // 存储定时器
    self.timers[timerId] = timer;
    
    // 启动定时器
    dispatch_resume(timer);
}

/**
 * 取消所有定时器
 */
- (void)cancelAllTimers {
    for (NSNumber *timerId in self.timers.allKeys) {
        dispatch_source_t timer = self.timers[timerId];
        if (timer) {
            dispatch_source_cancel(timer);
        }
    }
    [self.timers removeAllObjects];
}

/**
 * 发送错误事件
 */
- (void)sendErrorEvent:(NSString *)errorMessage {
    // 截断过长的错误信息
    if (errorMessage.length > 1024) {
        errorMessage = [[errorMessage substringToIndex:1024] stringByAppendingString:@"..."];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendEventWithName:@"user-api-error" body:@{
            @"id": self.scriptId ?: @"",
            @"error": errorMessage ?: @"Unknown error"
        }];
    });
}

/**
 * 转义 JavaScript 字符串
 */
- (NSString *)escapeJSString:(NSString *)str {
    if (!str) return @"";
    
    NSMutableString *escaped = [NSMutableString stringWithString:str];
    
    // 转义反斜杠
    [escaped replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, escaped.length)];
    // 转义单引号
    [escaped replaceOccurrencesOfString:@"'" withString:@"\\'" options:0 range:NSMakeRange(0, escaped.length)];
    // 转义双引号
    [escaped replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, escaped.length)];
    // 转义换行符
    [escaped replaceOccurrencesOfString:@"\n" withString:@"\\n" options:0 range:NSMakeRange(0, escaped.length)];
    // 转义回车符
    [escaped replaceOccurrencesOfString:@"\r" withString:@"\\r" options:0 range:NSMakeRange(0, escaped.length)];
    // 转义制表符
    [escaped replaceOccurrencesOfString:@"\t" withString:@"\\t" options:0 range:NSMakeRange(0, escaped.length)];
    
    return escaped;
}

@end
