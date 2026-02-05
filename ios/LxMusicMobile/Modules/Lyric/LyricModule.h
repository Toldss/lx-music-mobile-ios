/**
 * LyricModule.h
 * 
 * iOS 歌词模块，提供与 Android 版本相同的 JavaScript 接口
 * iOS 不支持悬浮窗功能，使用内部状态管理和可选的 Now Playing Info 更新
 * 
 * 需求: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 9.3, 9.4
 */

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface LyricModule : RCTEventEmitter <RCTBridgeModule>

#pragma mark - 歌词数据存储属性

/** 当前歌词文本 */
@property (nonatomic, strong) NSString *currentLyric;

/** 翻译歌词 */
@property (nonatomic, strong) NSString *translation;

/** 罗马音歌词 */
@property (nonatomic, strong) NSString *romaLyric;

/** 是否显示翻译 */
@property (nonatomic, assign) BOOL isShowTranslation;

/** 是否显示罗马音 */
@property (nonatomic, assign) BOOL isShowRoma;

/** 播放速率 */
@property (nonatomic, assign) float playbackRate;

/** 是否正在播放 */
@property (nonatomic, assign) BOOL isPlaying;

/** 当前播放时间（毫秒） */
@property (nonatomic, assign) int currentTime;

#pragma mark - 显示/隐藏方法

/**
 * 显示桌面歌词（iOS 替代方案：更新 Now Playing Info）
 * 需求 3.2
 */
- (void)showDesktopLyric:(NSDictionary *)data
                 resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject;

/**
 * 隐藏桌面歌词
 */
- (void)hideDesktopLyric:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject;

#pragma mark - 歌词控制方法

/**
 * 设置歌词数据
 * 需求 3.3
 */
- (void)setLyric:(NSString *)lyric
     translation:(NSString *)translation
       romaLyric:(NSString *)romaLyric
         resolve:(RCTPromiseResolveBlock)resolve
          reject:(RCTPromiseRejectBlock)reject;

/**
 * 播放歌词（根据时间戳更新当前歌词行）
 * 需求 3.4
 */
- (void)play:(int)time
     resolve:(RCTPromiseResolveBlock)resolve
      reject:(RCTPromiseRejectBlock)reject;

/**
 * 暂停歌词更新
 * 需求 3.5
 */
- (void)pause:(RCTPromiseResolveBlock)resolve
       reject:(RCTPromiseRejectBlock)reject;

#pragma mark - 权限方法（iOS 直接返回成功）

/**
 * 检查悬浮窗权限（iOS 不需要，直接返回成功）
 * 需求 3.6
 */
- (void)checkOverlayPermission:(RCTPromiseResolveBlock)resolve
                        reject:(RCTPromiseRejectBlock)reject;

/**
 * 打开悬浮窗权限设置（iOS 无需操作，直接返回成功）
 * 需求 3.7
 */
- (void)openOverlayPermissionActivity:(RCTPromiseResolveBlock)resolve
                               reject:(RCTPromiseRejectBlock)reject;

#pragma mark - 显示切换方法

/**
 * 切换翻译显示
 * 需求 3.8
 */
- (void)toggleTranslation:(BOOL)isShowTranslation
                  resolve:(RCTPromiseResolveBlock)resolve
                   reject:(RCTPromiseRejectBlock)reject;

/**
 * 切换罗马音显示
 * 需求 3.8
 */
- (void)toggleRoma:(BOOL)isShowRoma
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject;

/**
 * 设置播放速率
 * 需求 3.9
 */
- (void)setPlaybackRate:(float)playbackRate
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject;

#pragma mark - 其他配置方法（保持接口兼容）

/**
 * 设置是否发送歌词文本事件
 */
- (void)setSendLyricTextEvent:(BOOL)isSend
                      resolve:(RCTPromiseResolveBlock)resolve
                       reject:(RCTPromiseRejectBlock)reject;

/**
 * 切换锁定状态
 */
- (void)toggleLock:(BOOL)isLock
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject;

/**
 * 设置歌词颜色
 */
- (void)setColor:(NSString *)unplayColor
     playedColor:(NSString *)playedColor
     shadowColor:(NSString *)shadowColor
         resolve:(RCTPromiseResolveBlock)resolve
          reject:(RCTPromiseRejectBlock)reject;

/**
 * 设置透明度
 */
- (void)setAlpha:(float)alpha
         resolve:(RCTPromiseResolveBlock)resolve
          reject:(RCTPromiseRejectBlock)reject;

/**
 * 设置文字大小
 */
- (void)setTextSize:(float)size
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject;

/**
 * 设置最大行数
 */
- (void)setMaxLineNum:(int)maxLineNum
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject;

/**
 * 设置单行显示
 */
- (void)setSingleLine:(BOOL)singleLine
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject;

/**
 * 设置是否显示切换动画
 */
- (void)setShowToggleAnima:(BOOL)showToggleAnima
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject;

/**
 * 设置宽度
 */
- (void)setWidth:(int)width
         resolve:(RCTPromiseResolveBlock)resolve
          reject:(RCTPromiseRejectBlock)reject;

/**
 * 设置歌词文本位置
 */
- (void)setLyricTextPosition:(NSString *)positionX
                   positionY:(NSString *)positionY
                     resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject;

@end
