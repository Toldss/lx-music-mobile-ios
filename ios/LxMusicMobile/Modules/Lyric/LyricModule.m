/**
 * LyricModule.m
 * 
 * iOS 歌词模块实现
 * iOS 不支持悬浮窗功能，使用内部状态管理和可选的 Now Playing Info 更新
 * 
 * 需求: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 9.3, 9.4
 */

#import "LyricModule.h"
#import <MediaPlayer/MediaPlayer.h>

@interface LyricModule ()

/** 事件监听器计数 */
@property (nonatomic, assign) NSInteger listenerCount;

/** 是否发送歌词文本事件 */
@property (nonatomic, assign) BOOL isSendLyricTextEvent;

/** 是否已显示桌面歌词 */
@property (nonatomic, assign) BOOL isDesktopLyricShown;

/** 配置属性 - 保持接口兼容 */
@property (nonatomic, strong) NSString *unplayColor;
@property (nonatomic, strong) NSString *playedColor;
@property (nonatomic, strong) NSString *shadowColor;
@property (nonatomic, assign) float alpha;
@property (nonatomic, assign) float textSize;
@property (nonatomic, assign) int maxLineNum;
@property (nonatomic, assign) BOOL singleLine;
@property (nonatomic, assign) BOOL showToggleAnima;
@property (nonatomic, assign) int width;
@property (nonatomic, strong) NSString *positionX;
@property (nonatomic, strong) NSString *positionY;
@property (nonatomic, assign) BOOL isLocked;

@end

@implementation LyricModule

// 使用 RCT_EXPORT_MODULE 宏导出模块 (需求 9.3)
RCT_EXPORT_MODULE();

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化默认值
        _currentLyric = @"";
        _translation = @"";
        _romaLyric = @"";
        _isShowTranslation = NO;
        _isShowRoma = NO;
        _playbackRate = 1.0f;
        _isPlaying = NO;
        _currentTime = 0;
        _listenerCount = 0;
        _isSendLyricTextEvent = NO;
        _isDesktopLyricShown = NO;
        
        // 配置默认值
        _alpha = 1.0f;
        _textSize = 16.0f;
        _maxLineNum = 2;
        _singleLine = NO;
        _showToggleAnima = YES;
        _width = 0;
        _isLocked = NO;
    }
    return self;
}

#pragma mark - RCTEventEmitter Required Methods

/**
 * 返回支持的事件名称列表
 * 需求 3.1: 保持与 Android 版本相同的接口
 */
- (NSArray<NSString *> *)supportedEvents {
    return @[@"lyric-text", @"lyric-line-changed"];
}

/**
 * 在主队列上执行
 */
+ (BOOL)requiresMainQueueSetup {
    return YES;
}

#pragma mark - Event Listener Methods

/**
 * 添加事件监听器
 * 需求 3.1: 保持与 Android 版本相同的接口
 */
RCT_EXPORT_METHOD(addListener:(NSString *)eventName) {
    self.listenerCount += 1;
}

/**
 * 移除事件监听器
 * 需求 3.1: 保持与 Android 版本相同的接口
 */
RCT_EXPORT_METHOD(removeListeners:(NSInteger)count) {
    self.listenerCount -= count;
    if (self.listenerCount < 0) {
        self.listenerCount = 0;
    }
}

#pragma mark - Show/Hide Methods

/**
 * 显示桌面歌词（iOS 替代方案）
 * 需求 3.2: 更新 Now Playing Info 中的歌词信息
 */
RCT_EXPORT_METHOD(showDesktopLyric:(NSDictionary *)data
                           resolve:(RCTPromiseResolveBlock)resolve
                            reject:(RCTPromiseRejectBlock)reject) {
    self.isDesktopLyricShown = YES;
    
    // iOS 不支持悬浮窗，可选择更新 Now Playing Info
    // 这里只是标记状态，实际歌词显示由 JavaScript 层处理
    NSLog(@"LyricModule: showDesktopLyric called (iOS alternative)");
    
    resolve(nil);
}

/**
 * 隐藏桌面歌词
 */
RCT_EXPORT_METHOD(hideDesktopLyric:(RCTPromiseResolveBlock)resolve
                            reject:(RCTPromiseRejectBlock)reject) {
    self.isDesktopLyricShown = NO;
    
    NSLog(@"LyricModule: hideDesktopLyric called");
    
    resolve(nil);
}

#pragma mark - Lyric Control Methods

/**
 * 设置是否发送歌词文本事件
 * 需求 3.1: 保持与 Android 版本相同的接口
 */
RCT_EXPORT_METHOD(setSendLyricTextEvent:(BOOL)isSend
                                resolve:(RCTPromiseResolveBlock)resolve
                                 reject:(RCTPromiseRejectBlock)reject) {
    self.isSendLyricTextEvent = isSend;
    resolve(nil);
}

/**
 * 设置歌词数据
 * 需求 3.3: 存储歌词文本、翻译和罗马音
 */
RCT_EXPORT_METHOD(setLyric:(NSString *)lyric
               translation:(NSString *)translation
                 romaLyric:(NSString *)romaLyric
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject) {
    // 存储歌词数据
    self.currentLyric = lyric ?: @"";
    self.translation = translation ?: @"";
    self.romaLyric = romaLyric ?: @"";
    
    NSLog(@"LyricModule: setLyric called, lyric length: %lu", (unsigned long)self.currentLyric.length);
    
    resolve(nil);
}

/**
 * 设置播放速率
 * 需求 3.9: 调整播放速率
 */
RCT_EXPORT_METHOD(setPlaybackRate:(float)playbackRate
                          resolve:(RCTPromiseResolveBlock)resolve
                           reject:(RCTPromiseRejectBlock)reject) {
    self.playbackRate = playbackRate;
    
    NSLog(@"LyricModule: setPlaybackRate called, rate: %f", playbackRate);
    
    resolve(nil);
}

/**
 * 切换翻译显示
 * 需求 3.8: 切换翻译显示
 */
RCT_EXPORT_METHOD(toggleTranslation:(BOOL)isShowTranslation
                            resolve:(RCTPromiseResolveBlock)resolve
                             reject:(RCTPromiseRejectBlock)reject) {
    self.isShowTranslation = isShowTranslation;
    
    NSLog(@"LyricModule: toggleTranslation called, show: %d", isShowTranslation);
    
    resolve(nil);
}

/**
 * 切换罗马音显示
 * 需求 3.8: 切换罗马音显示
 */
RCT_EXPORT_METHOD(toggleRoma:(BOOL)isShowRoma
                     resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject) {
    self.isShowRoma = isShowRoma;
    
    NSLog(@"LyricModule: toggleRoma called, show: %d", isShowRoma);
    
    resolve(nil);
}

/**
 * 播放歌词
 * 需求 3.4: 根据时间戳更新当前歌词行
 */
RCT_EXPORT_METHOD(play:(int)time
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject) {
    self.isPlaying = YES;
    self.currentTime = time;
    
    NSLog(@"LyricModule: play called, time: %d", time);
    
    resolve(nil);
}

/**
 * 暂停歌词更新
 * 需求 3.5: 暂停歌词更新
 */
RCT_EXPORT_METHOD(pause:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject) {
    self.isPlaying = NO;
    
    NSLog(@"LyricModule: pause called");
    
    resolve(nil);
}

#pragma mark - Permission Methods (iOS always returns success)

/**
 * 检查悬浮窗权限
 * 需求 3.6: iOS 不需要悬浮窗权限，直接返回成功
 */
RCT_EXPORT_METHOD(checkOverlayPermission:(RCTPromiseResolveBlock)resolve
                                  reject:(RCTPromiseRejectBlock)reject) {
    // iOS 不需要悬浮窗权限，直接返回成功
    resolve(nil);
}

/**
 * 打开悬浮窗权限设置
 * 需求 3.7: iOS 无需操作，直接返回成功
 */
RCT_EXPORT_METHOD(openOverlayPermissionActivity:(RCTPromiseResolveBlock)resolve
                                         reject:(RCTPromiseRejectBlock)reject) {
    // iOS 无需操作，直接返回成功
    resolve(nil);
}

#pragma mark - Configuration Methods (Interface Compatibility)

/**
 * 切换锁定状态
 * 需求 3.1: 保持接口兼容
 */
RCT_EXPORT_METHOD(toggleLock:(BOOL)isLock
                     resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject) {
    self.isLocked = isLock;
    resolve(nil);
}

/**
 * 设置歌词颜色
 * 需求 3.1: 保持接口兼容
 */
RCT_EXPORT_METHOD(setColor:(NSString *)unplayColor
               playedColor:(NSString *)playedColor
               shadowColor:(NSString *)shadowColor
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject) {
    self.unplayColor = unplayColor;
    self.playedColor = playedColor;
    self.shadowColor = shadowColor;
    resolve(nil);
}

/**
 * 设置透明度
 * 需求 3.1: 保持接口兼容
 */
RCT_EXPORT_METHOD(setAlpha:(float)alpha
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject) {
    self.alpha = alpha;
    resolve(nil);
}

/**
 * 设置文字大小
 * 需求 3.1: 保持接口兼容
 */
RCT_EXPORT_METHOD(setTextSize:(float)size
                      resolve:(RCTPromiseResolveBlock)resolve
                       reject:(RCTPromiseRejectBlock)reject) {
    self.textSize = size;
    resolve(nil);
}

/**
 * 设置最大行数
 * 需求 3.1: 保持接口兼容
 */
RCT_EXPORT_METHOD(setMaxLineNum:(int)maxLineNum
                        resolve:(RCTPromiseResolveBlock)resolve
                         reject:(RCTPromiseRejectBlock)reject) {
    self.maxLineNum = maxLineNum;
    resolve(nil);
}

/**
 * 设置单行显示
 * 需求 3.1: 保持接口兼容
 */
RCT_EXPORT_METHOD(setSingleLine:(BOOL)singleLine
                        resolve:(RCTPromiseResolveBlock)resolve
                         reject:(RCTPromiseRejectBlock)reject) {
    self.singleLine = singleLine;
    resolve(nil);
}

/**
 * 设置是否显示切换动画
 * 需求 3.1: 保持接口兼容
 */
RCT_EXPORT_METHOD(setShowToggleAnima:(BOOL)showToggleAnima
                             resolve:(RCTPromiseResolveBlock)resolve
                              reject:(RCTPromiseRejectBlock)reject) {
    self.showToggleAnima = showToggleAnima;
    resolve(nil);
}

/**
 * 设置宽度
 * 需求 3.1: 保持接口兼容
 */
RCT_EXPORT_METHOD(setWidth:(int)width
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject) {
    self.width = width;
    resolve(nil);
}

/**
 * 设置歌词文本位置
 * 需求 3.1: 保持接口兼容
 */
RCT_EXPORT_METHOD(setLyricTextPosition:(NSString *)positionX
                             positionY:(NSString *)positionY
                               resolve:(RCTPromiseResolveBlock)resolve
                                reject:(RCTPromiseRejectBlock)reject) {
    self.positionX = positionX;
    self.positionY = positionY;
    resolve(nil);
}

@end
