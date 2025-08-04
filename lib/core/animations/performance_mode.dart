import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 📊 性能模式管理器
/// 根据设备性能动态调整动画密度，确保流畅体验
// 性能模式枚举
enum PerformanceMode {
  highPerformance,  // 120FPS - 旗舰设备
  balanced,         // 60FPS - 主流设备
  powerSaver,       // 30FPS - 低端设备
}

class PerformanceModeManager {
  static PerformanceModeManager? _instance;
  static PerformanceModeManager get instance => _instance ??= PerformanceModeManager._();
  
  PerformanceModeManager._();
  
  PerformanceMode _currentMode = PerformanceMode.balanced;
  bool _animationsEnabled = true;
  
  /// 当前性能模式
  PerformanceMode get currentMode => _currentMode;
  
  /// 动画是否启用
  bool get animationsEnabled => _animationsEnabled;
  
  /// 根据设备性能自动设置模式
  void autoDetectPerformanceMode() {
    // 基于设备信息自动检测
    // 这里简化处理，实际可以通过设备信息API获取
    if (kDebugMode) {
      _currentMode = PerformanceMode.highPerformance;
    } else {
      _currentMode = PerformanceMode.balanced;
    }
    
    // 🚨 紧急修复：确保动画在所有模式下都启用
    _animationsEnabled = true;
    
    debugPrint('🎯 性能模式已设置: $_currentMode, 动画启用: $_animationsEnabled');
  }
  
  /// 手动设置性能模式
  void setPerformanceMode(PerformanceMode mode) {
    _currentMode = mode;
    
    switch (mode) {
      case PerformanceMode.highPerformance:
        _animationsEnabled = true;
        break;
      case PerformanceMode.balanced:
        _animationsEnabled = true;
        break;
      case PerformanceMode.powerSaver:
        _animationsEnabled = false; // 禁用所有非必要动画
        break;
    }
    
    debugPrint('🎯 手动设置性能模式: $mode, 动画启用: $_animationsEnabled');
  }
  
  /// 获取动画持续时间倍数
  double get animationDurationMultiplier {
    switch (_currentMode) {
      case PerformanceMode.highPerformance:
        return 1.0;
      case PerformanceMode.balanced:
        return 1.2;
      case PerformanceMode.powerSaver:
        return 0.0; // 无动画
    }
  }
  
  /// 获取推荐的动画帧率
  int get targetFps {
    switch (_currentMode) {
      case PerformanceMode.highPerformance:
        return 120;
      case PerformanceMode.balanced:
        return 60;
      case PerformanceMode.powerSaver:
        return 30;
    }
  }
  
  /// 是否应该显示复杂动画
  bool get shouldShowComplexAnimations {
    return _currentMode != PerformanceMode.powerSaver; // balanced模式也显示动画
  }
  
  /// 是否应该显示呼吸动画
  bool get shouldShowBreathingAnimation {
    return true; // 暂时全部开启，保证生产环境正常
  }
}

/// 高性能Widget包装器
/// 根据性能模式动态决定是否显示动画
class PerformanceAwareWidget extends StatelessWidget {
  final Widget child;
  final Widget? highPerformanceChild;
  final Widget? balancedChild;
  final Widget? powerSaverChild;
  
  const PerformanceAwareWidget({
    super.key,
    required this.child,
    this.highPerformanceChild,
    this.balancedChild,
    this.powerSaverChild,
  });

  @override
  Widget build(BuildContext context) {
    final mode = PerformanceModeManager.instance.currentMode;
    
    switch (mode) {
      case PerformanceMode.highPerformance:
        return highPerformanceChild ?? child;
      case PerformanceMode.balanced:
        return balancedChild ?? child;
      case PerformanceMode.powerSaver:
        return powerSaverChild ?? child;
    }
  }
}