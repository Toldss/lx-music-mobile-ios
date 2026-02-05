/**
 * UserApiModule.h
 * 
 * 用户自定义 API 模块，使用 JavaScriptCore 执行用户提供的 JavaScript 脚本
 * 继承 RCTEventEmitter 支持事件发送
 * 
 * 需求: 4.1, 4.2, 4.3, 4.4, 9.3, 9.4
 */

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserApiModule : RCTEventEmitter <RCTBridgeModule>

#pragma mark - JavaScript 执行环境属性

/** JavaScript 执行上下文 */
@property (nonatomic, strong, nullable) JSContext *jsContext;

/** 后台执行队列 */
@property (nonatomic, strong, nullable) dispatch_queue_t jsQueue;

/** 脚本唯一标识符 */
@property (nonatomic, strong, nullable) NSString *scriptId;

/** 脚本密钥（用于安全通信） */
@property (nonatomic, strong, nullable) NSString *scriptKey;

/** 是否已初始化 */
@property (nonatomic, assign) BOOL isInitialized;

#pragma mark - 脚本管理方法

/**
 * 加载并执行脚本
 * 需求 4.1: 使用 JavaScriptCore 创建独立的 JavaScript 执行环境
 * 需求 4.2: 脚本加载成功后发送 init 事件通知 JavaScript 层
 * 
 * @param data 脚本信息字典，包含:
 *        - id: 脚本唯一标识符
 *        - name: 脚本名称
 *        - description: 脚本描述
 *        - version: 脚本版本
 *        - author: 脚本作者
 *        - homepage: 脚本主页
 *        - script: 脚本内容
 */
- (void)loadScript:(NSDictionary *)data;

/**
 * 向脚本发送动作
 * 需求 4.3: 将动作和数据传递给脚本执行环境
 * 
 * @param action 动作名称
 * @param info 动作数据（JSON 字符串）
 * @return 是否发送成功
 */
- (BOOL)sendAction:(NSString *)action info:(nullable NSString *)info;

/**
 * 销毁 JavaScript 执行环境
 * 需求 4.4: 销毁 JavaScript 执行环境并释放资源
 */
- (void)destroy;

#pragma mark - 内部方法（供原生方法注入使用）

/**
 * 处理脚本的原生调用
 * 
 * @param key 脚本密钥
 * @param action 动作名称
 * @param data 动作数据（JSON 字符串）
 */
- (void)handleNativeCall:(NSString *)key action:(NSString *)action data:(nullable NSString *)data;

/**
 * 发送事件到 JavaScript 层
 * 
 * @param eventName 事件名称
 * @param body 事件数据
 */
- (void)sendEventWithName:(NSString *)eventName body:(nullable id)body;

@end

NS_ASSUME_NONNULL_END
