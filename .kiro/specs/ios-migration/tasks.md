# 实现计划: iOS 平台迁移

## 概述

本计划将 LxMusicMobile 项目迁移到 iOS 平台，实现所有原生模块并配置构建环境以生成 IPA 文件。任务按模块划分，每个模块完成后进行检查点验证。

## 任务

- [x] 1. 项目结构和基础配置
  - [x] 1.1 创建 iOS 原生模块目录结构
    - 在 `ios/LxMusicMobile/` 下创建 `Modules/` 目录
    - 创建子目录: `Cache/`, `Crypto/`, `Lyric/`, `UserApi/`, `Utils/`
    - _需求: 9.1, 9.2_

  - [x] 1.2 更新 Info.plist 配置
    - 添加 `UIBackgroundModes` 配置 audio 后台播放
    - 配置 `NSAppTransportSecurity` 允许网络访问
    - 添加 `NSLocalNetworkUsageDescription` 本地网络说明
    - 更新 `UIRequiredDeviceCapabilities`
    - _需求: 6.1, 6.2, 6.3, 6.4, 6.5_

  - [x] 1.3 复制预加载脚本资源
    - 将 `user-api-preload.js` 复制到 iOS 资源目录
    - 配置 Xcode 将脚本文件包含到 bundle
    - _需求: 4.5_

- [x] 2. CacheModule 实现
  - [x] 2.1 创建 CacheModule 头文件和实现文件
    - 实现 `getAppCacheSize` 方法，遍历 Caches 和 tmp 目录
    - 实现 `clearAppCache` 方法，异步清理缓存文件
    - 使用 `RCT_EXPORT_MODULE` 和 `RCT_EXPORT_METHOD` 宏导出
    - _需求: 1.1, 1.2, 1.3, 1.4, 9.3, 9.4_

  - [ ]* 2.2 编写 CacheModule 属性测试
    - **Property 3: 缓存清理有效性**
    - **Property 4: 缓存大小计算准确性**
    - **验证: 需求 1.1, 1.2**

- [x] 3. CryptoModule 实现
  - [x] 3.1 创建 RSA 工具类
    - 实现 `generateKeyPair` 生成 2048 位密钥对
    - 实现 `encrypt` 和 `decrypt` 方法
    - 支持 OAEP 和 NoPadding 填充模式
    - 使用 Security.framework API
    - _需求: 2.1, 2.2, 2.3, 2.8_

  - [x] 3.2 创建 AES 工具类
    - 实现 `encrypt` 和 `decrypt` 方法
    - 支持 CBC 和 ECB 模式
    - 使用 CommonCrypto API
    - _需求: 2.5, 2.6, 2.9_

  - [x] 3.3 创建 CryptoModule 主模块
    - 整合 RSA 和 AES 工具类
    - 实现异步方法 (`rsaEncrypt`, `rsaDecrypt`, `aesEncrypt`, `aesDecrypt`)
    - 实现同步方法 (`rsaEncryptSync`, `rsaDecryptSync`, `aesEncryptSync`, `aesDecryptSync`)
    - _需求: 2.4, 2.7, 9.3, 9.4_

  - [ ]* 3.4 编写 CryptoModule 属性测试
    - **Property 1: RSA 加解密往返一致性**
    - **Property 2: AES 加解密往返一致性**
    - **验证: 需求 2.2, 2.3, 2.4, 2.5, 2.6, 2.7**

- [x] 4. 检查点 - 验证 Cache 和 Crypto 模块
  - 确保所有测试通过，如有问题请询问用户

- [x] 5. LyricModule 实现
  - [x] 5.1 创建 LyricModule 模块
    - 继承 `RCTEventEmitter` 支持事件发送
    - 实现歌词数据存储属性
    - 实现 `showDesktopLyric`, `hideDesktopLyric` 方法
    - 实现 `setLyric`, `play`, `pause` 方法
    - 实现 `checkOverlayPermission`, `openOverlayPermissionActivity` 方法（直接返回成功）
    - 实现 `toggleTranslation`, `toggleRoma`, `setPlaybackRate` 方法
    - 实现其他配置方法保持接口兼容
    - _需求: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 9.3, 9.4_

  - [ ]* 5.2 编写 LyricModule 属性测试
    - **Property 5: 歌词状态存储一致性**
    - **验证: 需求 3.3**

- [x] 6. UserApiModule 实现
  - [x] 6.1 创建 UserApiModule 模块
    - 继承 `RCTEventEmitter` 支持事件发送
    - 使用 `JSContext` 创建 JavaScript 执行环境
    - 创建后台队列执行脚本
    - 实现 `loadScript` 方法加载和执行脚本
    - 实现 `sendAction` 方法传递动作到脚本
    - 实现 `destroy` 方法销毁执行环境
    - _需求: 4.1, 4.2, 4.3, 4.4, 9.3, 9.4_

  - [x] 6.2 实现原生方法注入
    - 注入 `__lx_native_call__` 回调函数
    - 注入 `__lx_native_call__utils_str2b64` Base64 编码
    - 注入 `__lx_native_call__utils_b642buf` Base64 解码
    - 注入 `__lx_native_call__utils_str2md5` MD5 计算
    - 注入 `__lx_native_call__utils_aes_encrypt` AES 加密
    - 注入 `__lx_native_call__utils_rsa_encrypt` RSA 加密
    - 注入 `__lx_native_call__set_timeout` 定时器
    - _需求: 4.5, 4.6, 4.7, 4.8_

  - [ ]* 6.3 编写 UserApiModule 属性测试
    - **Property 6: 脚本动作传递完整性**
    - **Property 7: Base64 编解码往返一致性**
    - **验证: 需求 4.3, 4.7**

- [x] 7. 检查点 - 验证 Lyric 和 UserApi 模块
  - 确保所有测试通过，如有问题请询问用户

- [x] 8. UtilsModule 实现
  - [x] 8.1 创建 UtilsModule 模块
    - 继承 `RCTEventEmitter` 支持事件发送
    - 实现 `screenkeepAwake`, `screenUnkeepAwake` 方法
    - 实现 `getWIFIIPV4Address` 方法获取 WiFi IP
    - 实现 `getDeviceName` 方法获取设备名称
    - 实现 `shareText` 方法显示分享面板
    - 实现 `getSystemLocales` 方法获取系统语言
    - 实现 `getWindowSize` 方法获取窗口大小
    - 实现 `getSupportedAbis` 方法返回 CPU 架构
    - 实现 `exitApp` 方法（iOS 提示不支持）
    - 实现 `isNotificationsEnabled`, `openNotificationPermissionActivity` 方法
    - _需求: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 5.11, 5.12, 9.3, 9.4_

  - [x] 8.2 实现屏幕状态监听
    - 注册 `UIApplicationDidBecomeActiveNotification` 通知
    - 注册 `UIApplicationWillResignActiveNotification` 通知
    - 发送屏幕状态事件到 JavaScript 层
    - _需求: 5.10_

  - [ ]* 8.3 编写 UtilsModule 属性测试
    - **Property 8: 窗口大小返回值有效性**
    - **Property 9: WiFi IP 地址格式有效性**
    - **验证: 需求 5.3, 5.7**

- [x] 9. 模块注册和 AppDelegate 更新
  - [x] 9.1 更新 AppDelegate 注册所有原生模块
    - 确保 React Native 桥接正确初始化
    - 验证所有模块可从 JavaScript 层访问
    - _需求: 9.1, 9.2_

  - [ ]* 9.2 编写模块注册属性测试
    - **Property 10: 原生模块可访问性**
    - **验证: 需求 9.2**

- [x] 10. 检查点 - 验证 Utils 模块和模块注册
  - 确保所有测试通过，如有问题请询问用户

- [x] 11. App Icons 和 Launch Screen 配置
  - [x] 11.1 配置 App Icons
    - 在 `Images.xcassets/AppIcon.appiconset/` 添加所有必需尺寸图标
    - 更新 `Contents.json` 配置文件
    - _需求: 7.1_

  - [x] 11.2 更新 LaunchScreen.storyboard
    - 添加应用 Logo 图片
    - 添加应用名称标签
    - 配置自动布局约束支持所有设备
    - _需求: 7.2, 7.3_

- [x] 12. 构建和签名配置
  - [x] 12.1 配置 Xcode 项目设置
    - 设置 Development Team
    - 配置 Bundle Identifier
    - 设置最低部署目标为 iOS 13.4
    - 配置 Debug 和 Release 构建设置
    - _需求: 8.1, 8.2, 8.5_

  - [x] 12.2 配置代码签名
    - 配置 Signing & Capabilities
    - 添加 Background Modes capability (Audio)
    - 配置 Ad Hoc 和 Development 签名
    - _需求: 8.4_

  - [x] 12.3 执行 Pod Install
    - 运行 `pod install` 安装依赖
    - 验证所有依赖正确安装
    - _需求: 8.3_

- [x] 13. 最终检查点 - 构建验证
  - [x] 13.1 执行 Debug 构建
    - 运行 `xcodebuild -scheme LxMusicMobile -configuration Debug build`
    - 验证构建成功无错误
    - _需求: 8.2_

  - [x] 13.2 执行 Release Archive
    - 运行 Archive 构建
    - 验证可成功导出 IPA 文件
    - _需求: 8.3, 8.4_

## 注意事项

- 标记 `*` 的任务为可选任务，可跳过以加快 MVP 开发
- 每个检查点确保当前阶段功能正常后再继续
- 属性测试验证通用正确性，单元测试验证特定示例
- iOS 不支持悬浮窗，LyricModule 使用替代方案
- 构建前需要配置有效的 Apple Developer 账号
