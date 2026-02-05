# GitHub Actions iOS 构建指南

本文档详细说明如何使用 GitHub Actions 在云端构建 iOS IPA 文件。

## 概述

由于 iOS 应用只能在 macOS 上编译，我们使用 GitHub Actions 提供的 macOS 运行器来完成构建。这样你可以在 Windows 上开发，通过 Git push 触发云端构建。

---

## 🚀 快速开始：无证书构建（推荐）

如果你只需要生成未签名的 IPA（用于自签名安装），可以直接使用 `ios-build-unsigned.yml` 工作流，**无需任何 Apple 证书或付费账号**。

### 使用方法

1. 将代码推送到 GitHub
2. 进入仓库的 **Actions** 页面
3. 选择 **iOS Build (Unsigned)** 工作流
4. 点击 **Run workflow**
5. 选择构建配置（Release 或 Debug）
6. 等待构建完成（约 15-20 分钟）
7. 在 **Artifacts** 部分下载 IPA

### 安装未签名 IPA

下载的 IPA 需要签名后才能安装到 iPhone，推荐以下免费工具：

| 工具 | 平台 | 说明 |
|------|------|------|
| **AltStore** | Windows/Mac | 使用个人 Apple ID 签名，7天有效期，需定期刷新 |
| **Sideloadly** | Windows/Mac | 功能丰富，支持多种签名方式 |
| **3uTools** | Windows | 中文界面，操作简单 |
| **TrollStore** | iOS 14.0-16.6.1 | 永久签名，无需电脑，但需要特定 iOS 版本 |

#### AltStore 安装步骤（Windows）

1. 下载安装 [AltServer for Windows](https://altstore.io/)
2. 安装 iTunes 和 iCloud（从 Apple 官网下载，不是 Microsoft Store 版本）
3. 运行 AltServer，在系统托盘找到图标
4. 连接 iPhone 到电脑，信任此电脑
5. 点击 AltServer 图标 → Install AltStore → 选择你的设备
6. 输入 Apple ID 和密码
7. 在 iPhone 上打开 AltStore
8. 点击 **My Apps** → **+** → 选择下载的 IPA 文件

> ⚠️ 使用个人 Apple ID 签名的应用每 7 天需要重新签名。保持 AltServer 运行并定期连接 iPhone 可自动刷新。

---

## 完整构建（需要 Apple Developer 账号）

如果你需要正式分发或避免 7 天重签，需要 Apple Developer 账号（$99/年）。

## 前置条件

1. **Apple Developer 账号** (付费，$99/年)
2. **GitHub 账号**
3. **项目已推送到 GitHub**

## 配置步骤

### 第一步：准备 Apple 开发者证书

#### 1.1 创建 iOS Distribution 证书

1. 登录 [Apple Developer Portal](https://developer.apple.com/account)
2. 进入 **Certificates, Identifiers & Profiles**
3. 点击 **Certificates** → **+** 创建新证书
4. 选择 **iOS Distribution (App Store and Ad Hoc)**
5. 按照指引创建 CSR 文件并上传
6. 下载生成的 `.cer` 证书

#### 1.2 导出 .p12 证书文件

在 macOS 上（可以借用朋友的 Mac 或使用云 Mac 服务）：

```bash
# 1. 双击 .cer 文件导入到钥匙串
# 2. 打开 "钥匙串访问" 应用
# 3. 找到导入的证书，右键选择 "导出..."
# 4. 选择 .p12 格式，设置密码
# 5. 保存文件
```

#### 1.3 将证书转换为 Base64

```bash
# macOS/Linux
base64 -i certificate.p12 | pbcopy
# 或
base64 -i certificate.p12 > certificate_base64.txt

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.p12")) | Set-Clipboard
```

### 第二步：创建 Provisioning Profile

#### 2.1 注册 App ID

1. 在 Apple Developer Portal 进入 **Identifiers**
2. 点击 **+** 创建新的 App ID
3. 选择 **App IDs** → **App**
4. 填写：
   - Description: `LxMusicMobile`
   - Bundle ID: `com.lxmusic.mobile` (Explicit)
5. 勾选需要的 Capabilities（如 Background Modes）
6. 点击 **Continue** → **Register**

#### 2.2 注册测试设备 (Ad Hoc 分发需要)

1. 进入 **Devices**
2. 点击 **+** 添加设备
3. 填写设备名称和 UDID
4. 获取 UDID 的方法：
   - 连接 iPhone 到电脑
   - 打开 iTunes/Finder
   - 点击设备信息区域直到显示 UDID
   - 复制 UDID

#### 2.3 创建 Provisioning Profile

1. 进入 **Profiles**
2. 点击 **+** 创建新 Profile
3. 选择 **Ad Hoc** (用于测试分发)
4. 选择之前创建的 App ID
5. 选择 Distribution 证书
6. 选择要包含的测试设备
7. 命名并下载 `.mobileprovision` 文件

#### 2.4 将 Profile 转换为 Base64

```bash
# macOS/Linux
base64 -i profile.mobileprovision | pbcopy

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("profile.mobileprovision")) | Set-Clipboard
```

### 第三步：获取 Team ID

1. 登录 [Apple Developer Portal](https://developer.apple.com/account)
2. 点击 **Membership** 或 **Account**
3. 找到 **Team ID**（10位字母数字组合，如 `ABCD1234EF`）

### 第四步：配置 GitHub Secrets

1. 打开你的 GitHub 仓库
2. 进入 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret** 添加以下 Secrets：

| Secret 名称 | 值 | 说明 |
|------------|---|------|
| `APPLE_CERTIFICATE_BASE64` | 证书的 Base64 | 第 1.3 步获取 |
| `APPLE_CERTIFICATE_PASSWORD` | 证书密码 | 导出 .p12 时设置的密码 |
| `APPLE_PROVISIONING_PROFILE_BASE64` | Profile 的 Base64 | 第 2.4 步获取 |
| `KEYCHAIN_PASSWORD` | 任意字符串 | 如 `github-actions-keychain` |
| `APPLE_TEAM_ID` | Team ID | 第三步获取 |

### 第五步：触发构建

#### 方式一：手动触发

1. 进入 GitHub 仓库的 **Actions** 标签
2. 选择 **iOS Build** workflow
3. 点击 **Run workflow**
4. 选择构建类型（ad-hoc 或 development）
5. 点击 **Run workflow** 开始构建

#### 方式二：自动触发

推送代码到 `main` 分支时自动触发：

```bash
git add .
git commit -m "Trigger iOS build"
git push origin main
```

### 第六步：下载 IPA

1. 构建完成后，进入 **Actions** 标签
2. 点击完成的 workflow run
3. 在 **Artifacts** 部分下载 IPA 文件
4. 解压下载的 zip 文件获取 `.ipa`

## 安装 IPA 到设备

### 方法一：使用 AltStore (推荐)

1. 在 Windows 上安装 [AltServer](https://altstore.io/)
2. 在 iPhone 上安装 AltStore
3. 将 IPA 文件通过 AltStore 安装

### 方法二：使用 Sideloadly

1. 下载 [Sideloadly](https://sideloadly.io/)
2. 连接 iPhone 到电脑
3. 拖拽 IPA 到 Sideloadly
4. 输入 Apple ID 进行签名安装

### 方法三：使用 Apple Configurator 2 (需要 Mac)

1. 在 Mac 上打开 Apple Configurator 2
2. 连接 iPhone
3. 拖拽 IPA 到设备

## 常见问题

### Q: 构建失败，提示证书问题？

检查：
1. 证书是否过期
2. Base64 编码是否完整（没有换行符）
3. 证书密码是否正确

### Q: 构建失败，提示 Provisioning Profile 问题？

检查：
1. Profile 是否包含正确的 App ID
2. Profile 是否包含目标设备的 UDID
3. Profile 是否与证书匹配

### Q: 如何更新证书或 Profile？

1. 在 Apple Developer Portal 创建新的证书/Profile
2. 转换为 Base64
3. 更新 GitHub Secrets 中对应的值

### Q: 构建时间太长？

GitHub Actions 的 macOS 运行器构建 React Native 项目通常需要 15-30 分钟。可以通过以下方式优化：
1. 使用缓存（workflow 已配置）
2. 减少不必要的依赖

### Q: 免费额度用完了怎么办？

GitHub 免费账户每月有 2000 分钟的 Actions 时间（macOS 按 10 倍计算，即约 200 分钟）。
- 升级到 GitHub Pro 获得更多额度
- 使用其他 CI 服务如 Codemagic（有免费额度）

## 费用说明

| 项目 | 费用 |
|------|------|
| Apple Developer Program | $99/年 |
| GitHub Actions (免费额度) | 2000 分钟/月 |
| GitHub Actions (超出部分) | $0.08/分钟 (macOS) |

## 参考链接

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Apple Developer 文档](https://developer.apple.com/documentation/)
- [React Native iOS 构建](https://reactnative.dev/docs/publishing-to-app-store)
