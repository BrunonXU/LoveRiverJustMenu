import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// 高级触觉反馈系统
/// 提供丰富的触觉反馈体验，增强手势操作感知
class AdvancedHapticFeedback {
  static bool _isEnabled = true;
  static double _intensity = 1.0;
  
  /// 设置触觉反馈开关
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }
  
  /// 设置触觉反馈强度 (0.0 - 1.0)
  static void setIntensity(double intensity) {
    _intensity = intensity.clamp(0.0, 1.0);
  }
  
  /// 获取当前状态
  static bool get isEnabled => _isEnabled;
  static double get intensity => _intensity;
  
  // ==================== 基础触觉反馈 ====================
  
  /// 轻触反馈 - 用于UI元素点击
  static Future<void> lightTap() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.lightImpact();
      if (kDebugMode) {
        debugPrint('🔸 Haptic: Light tap');
      }
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }
  
  /// 中等反馈 - 用于重要操作确认
  static Future<void> mediumTap() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.mediumImpact();
      if (kDebugMode) {
        debugPrint('🔹 Haptic: Medium tap');
      }
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }
  
  /// 重触反馈 - 用于关键操作或错误
  static Future<void> heavyTap() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.heavyImpact();
      if (kDebugMode) {
        debugPrint('🔸 Haptic: Heavy tap');
      }
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }
  
  // ==================== 通知类型反馈 ====================
  
  /// 成功反馈 - 操作成功完成
  static Future<void> success() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.notificationImpact(NotificationFeedbackType.success);
      if (kDebugMode) {
        debugPrint('✅ Haptic: Success');
      }
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }
  
  /// 警告反馈 - 需要用户注意
  static Future<void> warning() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.notificationImpact(NotificationFeedbackType.warning);
      if (kDebugMode) {
        debugPrint('⚠️ Haptic: Warning');
      }
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }
  
  /// 错误反馈 - 操作失败或错误
  static Future<void> error() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.notificationImpact(NotificationFeedbackType.error);
      if (kDebugMode) {
        debugPrint('❌ Haptic: Error');
      }
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }
  
  // ==================== 手势专用反馈 ====================
  
  /// 手势开始反馈
  static Future<void> gestureStart() async {
    if (!_isEnabled) return;
    await lightTap();
  }
  
  /// 手势进行中反馈
  static Future<void> gestureProgress() async {
    if (!_isEnabled) return;
    
    // 使用选择反馈模拟连续触感
    try {
      await HapticFeedback.selectionClick();
      if (kDebugMode) {
        debugPrint('🔄 Haptic: Gesture progress');
      }
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }
  
  /// 手势识别成功反馈
  static Future<void> gestureRecognized() async {
    if (!_isEnabled) return;
    await mediumTap();
  }
  
  /// 手势完成反馈
  static Future<void> gestureCompleted() async {
    if (!_isEnabled) return;
    await success();
  }
  
  /// 手势取消反馈
  static Future<void> gestureCancelled() async {
    if (!_isEnabled) return;
    await warning();
  }
  
  // ==================== 组合反馈模式 ====================
  
  /// 双击反馈模式
  static Future<void> doubleTap() async {
    if (!_isEnabled) return;
    
    await lightTap();
    await Future.delayed(const Duration(milliseconds: 50));
    await lightTap();
  }
  
  /// 长按反馈模式
  static Future<void> longPressPattern() async {
    if (!_isEnabled) return;
    
    await lightTap();
    await Future.delayed(const Duration(milliseconds: 100));
    await mediumTap();
  }
  
  /// 成功序列反馈
  static Future<void> successSequence() async {
    if (!_isEnabled) return;
    
    await lightTap();
    await Future.delayed(const Duration(milliseconds: 100));
    await mediumTap();
    await Future.delayed(const Duration(milliseconds: 100));
    await success();
  }
  
  /// 错误序列反馈
  static Future<void> errorSequence() async {
    if (!_isEnabled) return;
    
    await heavyTap();
    await Future.delayed(const Duration(milliseconds: 150));
    await heavyTap();
  }
  
  // ==================== 界面导航反馈 ====================
  
  /// 页面切换反馈
  static Future<void> pageTransition() async {
    if (!_isEnabled) return;
    await lightTap();
  }
  
  /// 卡片滑动反馈
  static Future<void> cardSwipe() async {
    if (!_isEnabled) return;
    await gestureProgress();
  }
  
  /// 弹窗显示反馈
  static Future<void> modalPresent() async {
    if (!_isEnabled) return;
    await mediumTap();
  }
  
  /// 弹窗关闭反馈
  static Future<void> modalDismiss() async {
    if (!_isEnabled) return;
    await lightTap();
  }
  
  // ==================== 状态反馈 ====================
  
  /// 加载开始反馈
  static Future<void> loadingStart() async {
    if (!_isEnabled) return;
    await lightTap();
  }
  
  /// 加载完成反馈
  static Future<void> loadingComplete() async {
    if (!_isEnabled) return;
    await success();
  }
  
  /// 刷新反馈
  static Future<void> refresh() async {
    if (!_isEnabled) return;
    await mediumTap();
  }
  
  /// 边界反馈 - 到达滚动边界
  static Future<void> boundary() async {
    if (!_isEnabled) return;
    await warning();
  }
  
  // ==================== 音频配合反馈 ====================
  
  /// 配合音效的反馈
  static Future<void> withSound({
    required HapticType hapticType,
    String? soundAsset,
  }) async {
    if (!_isEnabled) return;
    
    // 触觉反馈
    switch (hapticType) {
      case HapticType.light:
        await lightTap();
        break;
      case HapticType.medium:
        await mediumTap();
        break;
      case HapticType.heavy:
        await heavyTap();
        break;
      case HapticType.success:
        await success();
        break;
      case HapticType.warning:
        await warning();
        break;
      case HapticType.error:
        await error();
        break;
    }
    
    // TODO: 添加音效播放逻辑
    if (soundAsset != null && kDebugMode) {
      debugPrint('🔊 Sound: $soundAsset');
    }
  }
  
  // ==================== 自定义反馈模式 ====================
  
  /// 自定义振动模式 (Android)
  static Future<void> customPattern({
    required List<int> pattern,
    int repeat = -1,
  }) async {
    if (!_isEnabled) return;
    
    try {
      // 注意：这个API在Flutter中可能不直接可用
      // 实际项目中需要使用platform channel或第三方插件
      if (kDebugMode) {
        debugPrint('📳 Haptic: Custom pattern $pattern');
      }
    } catch (e) {
      debugPrint('Custom haptic pattern error: $e');
    }
  }
  
  /// 渐强反馈序列
  static Future<void> crescendoSequence() async {
    if (!_isEnabled) return;
    
    await lightTap();
    await Future.delayed(const Duration(milliseconds: 200));
    await mediumTap();
    await Future.delayed(const Duration(milliseconds: 200));
    await heavyTap();
  }
  
  /// 心跳反馈模式
  static Future<void> heartbeatPattern() async {
    if (!_isEnabled) return;
    
    await mediumTap();
    await Future.delayed(const Duration(milliseconds: 100));
    await lightTap();
    await Future.delayed(const Duration(milliseconds: 600));
    await mediumTap();
    await Future.delayed(const Duration(milliseconds: 100));
    await lightTap();
  }
  
  // ==================== 工具方法 ====================
  
  /// 检查设备是否支持触觉反馈
  static Future<bool> isSupported() async {
    try {
      await HapticFeedback.lightImpact();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 预热触觉反馈系统
  static Future<void> warmup() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.lightImpact();
      if (kDebugMode) {
        debugPrint('🔥 Haptic system warmed up');
      }
    } catch (e) {
      debugPrint('Haptic warmup error: $e');
    }
  }
  
  /// 获取触觉反馈统计信息
  static Map<String, dynamic> getStats() {
    return {
      'enabled': _isEnabled,
      'intensity': _intensity,
      'supported': true, // 实际项目中应该异步检查
    };
  }
}

/// 触觉反馈类型枚举
enum HapticType {
  light,
  medium,
  heavy,
  success,
  warning,
  error,
}

/// 触觉反馈配置类
class HapticConfig {
  final bool enabled;
  final double intensity;
  final Map<String, HapticType> gestureMapping;
  
  const HapticConfig({
    this.enabled = true,
    this.intensity = 1.0,
    this.gestureMapping = const {
      'tap': HapticType.light,
      'longPress': HapticType.medium,
      'swipe': HapticType.light,
      'success': HapticType.success,
      'error': HapticType.error,
    },
  });
  
  /// 预设配置 - 微妙模式
  static const HapticConfig subtle = HapticConfig(
    intensity: 0.3,
    gestureMapping: {
      'tap': HapticType.light,
      'longPress': HapticType.light,
      'swipe': HapticType.light,
      'success': HapticType.light,
      'error': HapticType.medium,
    },
  );
  
  /// 预设配置 - 标准模式
  static const HapticConfig standard = HapticConfig(
    intensity: 1.0,
  );
  
  /// 预设配置 - 强烈模式
  static const HapticConfig intense = HapticConfig(
    intensity: 1.0,
    gestureMapping: {
      'tap': HapticType.medium,
      'longPress': HapticType.heavy,
      'swipe': HapticType.medium,
      'success': HapticType.success,
      'error': HapticType.heavy,
    },
  );
  
  /// 应用配置
  void apply() {
    AdvancedHapticFeedback.setEnabled(enabled);
    AdvancedHapticFeedback.setIntensity(intensity);
  }
}

/// 触觉反馈管理器
class HapticFeedbackManager {
  static HapticConfig _currentConfig = HapticConfig.standard;
  
  /// 设置配置
  static void setConfig(HapticConfig config) {
    _currentConfig = config;
    config.apply();
  }
  
  /// 获取当前配置
  static HapticConfig get currentConfig => _currentConfig;
  
  /// 根据配置触发手势反馈
  static Future<void> triggerGesture(String gestureType) async {
    final hapticType = _currentConfig.gestureMapping[gestureType];
    if (hapticType == null) return;
    
    switch (hapticType) {
      case HapticType.light:
        await AdvancedHapticFeedback.lightTap();
        break;
      case HapticType.medium:
        await AdvancedHapticFeedback.mediumTap();
        break;
      case HapticType.heavy:
        await AdvancedHapticFeedback.heavyTap();
        break;
      case HapticType.success:
        await AdvancedHapticFeedback.success();
        break;
      case HapticType.warning:
        await AdvancedHapticFeedback.warning();
        break;
      case HapticType.error:
        await AdvancedHapticFeedback.error();
        break;
    }
  }
  
  /// 初始化触觉反馈系统
  static Future<void> initialize() async {
    await AdvancedHapticFeedback.warmup();
    _currentConfig.apply();
    
    if (kDebugMode) {
      debugPrint('🎮 HapticFeedbackManager initialized');
    }
  }
}