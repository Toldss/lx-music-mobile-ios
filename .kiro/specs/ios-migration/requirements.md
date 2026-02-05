# 需求文档

## 简介

本文档定义了将 LxMusicMobile 项目完整迁移到 iOS 平台的需求。LxMusicMobile 是一个基于 React Native 0.73.11 的音乐播放器应用，当前 Android 版本已完整实现，iOS 版本需要迁移所有原生模块并配置构建环境以生成 IPA 文件。

## 术语表

- **Native_Module**: React Native 原生模块，用于桥接 JavaScript 和原生平台代码
- **CacheModule**: 缓存管理模块，负责获取和清理应用缓存
- **CryptoModule**: 加密模块，提供 RSA 和 AES 加解密功能
- **LyricModule**: 歌词模块，在 Android 上提供桌面悬浮歌词功能
- **UserApiModule**: 用户自定义 API 模块，执行用户提供的 JavaScript 脚本
- **UtilsModule**: 工具模块，提供屏幕常亮、网络信息、分享等功能
- **IPA**: iOS App Store Package，iOS 应用的安装包格式
- **CocoaPods**: iOS 依赖管理工具
- **JavaScriptCore**: iOS 内置的 JavaScript 引擎
- **Now_Playing_Info**: iOS 锁屏和控制中心显示的当前播放信息

## 需求

### 需求 1：CacheModule iOS 实现

**用户故事：** 作为用户，我希望能够查看和清理应用缓存，以便释放设备存储空间。

#### 验收标准

1. WHEN 调用 getAppCacheSize 方法 THEN CacheModule SHALL 返回应用缓存目录的总大小（字节数字符串）
2. WHEN 调用 clearAppCache 方法 THEN CacheModule SHALL 清除 Caches 目录和 tmp 目录中的所有文件
3. WHEN 清理缓存完成 THEN CacheModule SHALL 通过 Promise 返回成功结果
4. IF 清理缓存过程中发生错误 THEN CacheModule SHALL 通过 Promise 返回错误信息

### 需求 2：CryptoModule iOS 实现

**用户故事：** 作为用户，我希望应用能够安全地加解密数据，以便保护敏感信息。

#### 验收标准

1. WHEN 调用 generateRsaKey 方法 THEN CryptoModule SHALL 生成 2048 位 RSA 密钥对并返回 Base64 编码的公钥和私钥
2. WHEN 调用 rsaEncrypt 方法并提供明文、公钥和填充模式 THEN CryptoModule SHALL 返回 Base64 编码的密文
3. WHEN 调用 rsaDecrypt 方法并提供密文、私钥和填充模式 THEN CryptoModule SHALL 返回解密后的明文
4. WHEN 调用 rsaEncryptSync 或 rsaDecryptSync 方法 THEN CryptoModule SHALL 同步执行加解密操作
5. WHEN 调用 aesEncrypt 方法并提供明文、密钥、IV 和模式 THEN CryptoModule SHALL 返回 Base64 编码的密文
6. WHEN 调用 aesDecrypt 方法并提供密文、密钥、IV 和模式 THEN CryptoModule SHALL 返回解密后的明文
7. WHEN 调用 aesEncryptSync 或 aesDecryptSync 方法 THEN CryptoModule SHALL 同步执行加解密操作
8. THE CryptoModule SHALL 支持 RSA/ECB/OAEPWithSHA1AndMGF1Padding 和 RSA/ECB/NoPadding 填充模式
9. THE CryptoModule SHALL 支持 AES/CBC/PKCS7Padding 和 AES/ECB/NoPadding 加密模式

### 需求 3：LyricModule iOS 实现（替代方案）

**用户故事：** 作为用户，我希望在 iOS 上能够查看歌词，即使无法使用悬浮窗功能。

#### 验收标准

1. THE LyricModule SHALL 提供与 Android 版本相同的 JavaScript 接口以保持代码兼容性
2. WHEN 调用 showDesktopLyric 方法 THEN LyricModule SHALL 更新 Now Playing Info 中的歌词信息
3. WHEN 调用 setLyric 方法 THEN LyricModule SHALL 存储歌词文本、翻译和罗马音
4. WHEN 调用 play 方法并提供时间戳 THEN LyricModule SHALL 根据时间戳更新当前歌词行
5. WHEN 调用 pause 方法 THEN LyricModule SHALL 暂停歌词更新
6. WHEN 调用 checkOverlayPermission 方法 THEN LyricModule SHALL 返回成功（iOS 不需要悬浮窗权限）
7. WHEN 调用 openOverlayPermissionActivity 方法 THEN LyricModule SHALL 返回成功（iOS 无需操作）
8. THE LyricModule SHALL 支持 toggleTranslation 和 toggleRoma 方法来切换翻译和罗马音显示
9. THE LyricModule SHALL 支持 setPlaybackRate 方法来调整播放速率

### 需求 4：UserApiModule iOS 实现

**用户故事：** 作为用户，我希望能够加载和执行自定义 API 脚本，以便扩展应用功能。

#### 验收标准

1. WHEN 调用 loadScript 方法并提供脚本信息 THEN UserApiModule SHALL 使用 JavaScriptCore 创建独立的 JavaScript 执行环境
2. WHEN 脚本加载成功 THEN UserApiModule SHALL 发送 init 事件通知 JavaScript 层
3. WHEN 调用 sendAction 方法 THEN UserApiModule SHALL 将动作和数据传递给脚本执行环境
4. WHEN 调用 destroy 方法 THEN UserApiModule SHALL 销毁 JavaScript 执行环境并释放资源
5. THE UserApiModule SHALL 提供与 Android 版本相同的预加载脚本环境
6. THE UserApiModule SHALL 支持脚本调用原生加密方法（AES、RSA、MD5）
7. THE UserApiModule SHALL 支持 Base64 编解码功能
8. THE UserApiModule SHALL 支持 setTimeout 定时器功能
9. IF 脚本执行过程中发生错误 THEN UserApiModule SHALL 通过事件通知 JavaScript 层

### 需求 5：UtilsModule iOS 实现

**用户故事：** 作为用户，我希望应用能够提供各种实用功能，如屏幕常亮、网络信息和分享。

#### 验收标准

1. WHEN 调用 screenkeepAwake 方法 THEN UtilsModule SHALL 禁用屏幕自动锁定
2. WHEN 调用 screenUnkeepAwake 方法 THEN UtilsModule SHALL 恢复屏幕自动锁定
3. WHEN 调用 getWIFIIPV4Address 方法 THEN UtilsModule SHALL 返回设备的 WiFi IPv4 地址
4. WHEN 调用 getDeviceName 方法 THEN UtilsModule SHALL 返回设备名称
5. WHEN 调用 shareText 方法 THEN UtilsModule SHALL 显示系统分享面板
6. WHEN 调用 getSystemLocales 方法 THEN UtilsModule SHALL 返回系统语言设置
7. WHEN 调用 getWindowSize 方法 THEN UtilsModule SHALL 返回当前窗口的宽度和高度
8. WHEN 调用 getSupportedAbis 方法 THEN UtilsModule SHALL 返回支持的 CPU 架构列表
9. WHEN 调用 exitApp 方法 THEN UtilsModule SHALL 提示用户 iOS 不支持程序化退出应用
10. THE UtilsModule SHALL 监听屏幕开关状态并发送事件通知
11. WHEN 调用 isNotificationsEnabled 方法 THEN UtilsModule SHALL 返回通知权限状态
12. WHEN 调用 openNotificationPermissionActivity 方法 THEN UtilsModule SHALL 打开系统设置的通知权限页面

### 需求 6：Info.plist 权限配置

**用户故事：** 作为用户，我希望应用能够正常使用音频播放、网络访问等功能。

#### 验收标准

1. THE Info.plist SHALL 配置 UIBackgroundModes 包含 audio 以支持后台音频播放
2. THE Info.plist SHALL 配置 NSAppTransportSecurity 允许必要的网络访问
3. THE Info.plist SHALL 配置 NSLocalNetworkUsageDescription 说明本地网络访问用途
4. THE Info.plist SHALL 配置 UIRequiredDeviceCapabilities 指定设备要求
5. THE Info.plist SHALL 配置正确的 Bundle Identifier 和版本信息

### 需求 7：App Icons 和 Launch Screen 配置

**用户故事：** 作为用户，我希望应用有专业的图标和启动画面。

#### 验收标准

1. THE Images.xcassets SHALL 包含所有必需尺寸的 App Icon（20pt 到 1024pt）
2. THE LaunchScreen.storyboard SHALL 显示应用 Logo 和名称
3. THE LaunchScreen SHALL 支持所有 iOS 设备尺寸和方向

### 需求 8：构建和签名配置

**用户故事：** 作为开发者，我希望能够构建和导出 IPA 文件以便分发应用。

#### 验收标准

1. THE Xcode 项目 SHALL 配置正确的 Development Team 和 Bundle Identifier
2. THE Xcode 项目 SHALL 支持 Debug 和 Release 构建配置
3. WHEN 执行 Archive 构建 THEN 项目 SHALL 成功生成可导出的 Archive
4. THE 项目 SHALL 支持 Ad Hoc 和 Development 签名导出 IPA
5. THE 最低部署目标 SHALL 设置为 iOS 13.4

### 需求 9：原生模块注册

**用户故事：** 作为开发者，我希望所有原生模块能够正确注册到 React Native 桥接层。

#### 验收标准

1. THE AppDelegate SHALL 正确初始化 React Native 桥接
2. WHEN React Native 初始化完成 THEN 所有原生模块 SHALL 可从 JavaScript 层访问
3. THE 每个原生模块 SHALL 使用 RCT_EXPORT_MODULE 宏导出
4. THE 每个原生方法 SHALL 使用 RCT_EXPORT_METHOD 或 RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD 宏导出
