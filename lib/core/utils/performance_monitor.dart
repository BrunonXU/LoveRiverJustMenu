import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 性能监控系统
/// 企业级要求：实时监控FPS、内存使用、响应时间
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._();
  
  PerformanceMonitor._();
  
  // ==================== 性能指标 ====================
  
  /// 目标FPS
  static const double targetFps = 60.0;
  
  /// 目标内存使用量 (MB)
  static const double targetMemoryMB = 150.0;
  
  /// 目标响应时间 (ms)
  static const int targetResponseTimeMs = 100;
  
  /// 动画帧时间阈值 (ms)
  static const int frameTimeThresholdMs = 16;
  
  // ==================== 监控状态 ====================
  
  bool _isMonitoring = false;
  final List<Duration> _frameTimes = [];
  final List<double> _memoryUsage = [];
  final List<int> _responseimes = [];
  
  int _frameCount = 0;
  int _droppedFrames = 0;
  double _currentFps = 0.0;
  double _currentMemoryMB = 0.0;
  
  // ==================== 初始化 ====================
  
  /// 初始化性能监控
  static void init() {
    if (!kDebugMode) return;
    
    instance._startMonitoring();
    _setupFrameMonitoring();
    _setupMemoryMonitoring();
    
    if (kDebugMode) {
      debugPrint('🚀 PerformanceMonitor initialized');
    }
  }
  
  /// 停止监控
  static void dispose() {
    instance._stopMonitoring();
  }
  
  // ==================== FPS监控 ====================
  
  /// 设置帧监控
  static void _setupFrameMonitoring() {
    WidgetsBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      if (!instance._isMonitoring) return;
      
      for (final timing in timings) {
        final frameTime = timing.totalSpan;
        instance._frameTimes.add(frameTime);
        instance._frameCount++;
        
        // 检测掉帧
        if (frameTime.inMilliseconds > frameTimeThresholdMs) {
          instance._droppedFrames++;
          _logPerformanceWarning(
            'Frame drop detected: ${frameTime.inMilliseconds}ms',
            PerformanceLevel.warning,
          );
        }
        
        // 计算当前FPS
        instance._calculateCurrentFps();
        
        // 清理旧数据（保留最近100帧）
        if (instance._frameTimes.length > 100) {
          instance._frameTimes.removeAt(0);
        }
      }
    });
  }
  
  /// 计算当前FPS
  void _calculateCurrentFps() {
    if (_frameTimes.isEmpty) return;
    
    final avgFrameTime = _frameTimes
        .map((duration) => duration.inMicroseconds)
        .reduce((a, b) => a + b) / _frameTimes.length;
    
    _currentFps = 1000000 / avgFrameTime; // 转换为FPS
    
    // FPS警告
    if (_currentFps < 50) {
      _logPerformanceWarning(
        'Low FPS detected: ${_currentFps.toStringAsFixed(1)}',
        PerformanceLevel.critical,
      );
    } else if (_currentFps < 55) {
      _logPerformanceWarning(
        'FPS below target: ${_currentFps.toStringAsFixed(1)}',
        PerformanceLevel.warning,
      );
    }
  }
  
  // ==================== 内存监控 ====================
  
  /// 设置内存监控
  static void _setupMemoryMonitoring() {
    // 每5秒检查一次内存使用
    if (kDebugMode) {
      _scheduleMemoryCheck();
    }
  }
  
  static void _scheduleMemoryCheck() {
    Future.delayed(const Duration(seconds: 5), () {
      if (instance._isMonitoring) {
        _checkMemoryUsage();
        _scheduleMemoryCheck();
      }
    });
  }
  
  static void _checkMemoryUsage() async {
    try {
      // 模拟内存检查（实际项目中需要使用原生插件）
      final memoryInfo = await _getMemoryInfo();
      instance._currentMemoryMB = memoryInfo;
      instance._memoryUsage.add(memoryInfo);
      
      // 内存警告
      if (memoryInfo > 200) {
        _logPerformanceWarning(
          'High memory usage: ${memoryInfo.toStringAsFixed(1)}MB',
          PerformanceLevel.critical,
        );
      } else if (memoryInfo > targetMemoryMB) {
        _logPerformanceWarning(
          'Memory usage above target: ${memoryInfo.toStringAsFixed(1)}MB',
          PerformanceLevel.warning,
        );
      }
      
      // 清理旧数据（保留最近20个记录）
      if (instance._memoryUsage.length > 20) {
        instance._memoryUsage.removeAt(0);
      }
    } catch (e) {
      debugPrint('Memory monitoring error: $e');
    }
  }
  
  /// 获取内存信息（模拟）
  static Future<double> _getMemoryInfo() async {
    // 实际项目中需要使用原生插件获取真实内存信息
    // 这里使用模拟数据
    return 80.0 + (DateTime.now().millisecondsSinceEpoch % 70);
  }
  
  // ==================== 响应时间监控 ====================
  
  /// 记录操作开始时间
  static Stopwatch startOperation(String operation) {
    final stopwatch = Stopwatch()..start();
    if (kDebugMode) {
      debugPrint('🔄 Operation started: $operation');
    }
    return stopwatch;
  }
  
  /// 记录操作结束时间
  static void endOperation(Stopwatch stopwatch, String operation) {
    stopwatch.stop();
    final responseTime = stopwatch.elapsedMilliseconds;
    
    instance._responseimes.add(responseTime);
    
    // 响应时间警告
    if (responseTime > 1000) {
      _logPerformanceWarning(
        'Slow operation: $operation took ${responseTime}ms',
        PerformanceLevel.critical,
      );
    } else if (responseTime > targetResponseTimeMs) {
      _logPerformanceWarning(
        'Operation above target: $operation took ${responseTime}ms',
        PerformanceLevel.warning,
      );
    }
    
    if (kDebugMode) {
      debugPrint('✅ Operation completed: $operation (${responseTime}ms)');
    }
    
    // 清理旧数据
    if (instance._responseimes.length > 50) {
      instance._responseimes.removeAt(0);
    }
  }
  
  // ==================== 动画性能监控 ====================
  
  /// 监控动画性能
  static void monitorAnimation(String animationName, VoidCallback animation) {
    final stopwatch = startOperation('Animation: $animationName');
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      endOperation(stopwatch, 'Animation: $animationName');
    });
    
    animation();
  }
  
  // ==================== 手势性能监控 ====================
  
  /// 监控手势响应时间
  static void monitorGesture(String gestureName, VoidCallback gesture) {
    final stopwatch = startOperation('Gesture: $gestureName');
    
    // 添加触觉反馈
    HapticFeedback.lightImpact();
    
    gesture();
    
    endOperation(stopwatch, 'Gesture: $gestureName');
  }
  
  // ==================== 报告生成 ====================
  
  /// 生成性能报告
  static PerformanceReport getPerformanceReport() {
    return PerformanceReport(
      averageFps: instance._currentFps,
      droppedFramesCount: instance._droppedFrames,
      totalFramesCount: instance._frameCount,
      averageMemoryMB: instance._memoryUsage.isEmpty 
          ? 0.0 
          : instance._memoryUsage.reduce((a, b) => a + b) / instance._memoryUsage.length,
      currentMemoryMB: instance._currentMemoryMB,
      averageResponseTimeMs: instance._responseimes.isEmpty 
          ? 0 
          : instance._responseimes.reduce((a, b) => a + b) ~/ instance._responseimes.length,
      maxResponseTimeMs: instance._responseimes.isEmpty ? 0 : instance._responseimes.reduce((a, b) => a > b ? a : b),
    );
  }
  
  /// 打印性能报告
  static void printPerformanceReport() {
    if (!kDebugMode) return;
    
    final report = getPerformanceReport();
    debugPrint('''
📊 Performance Report:
├── FPS: ${report.averageFps.toStringAsFixed(1)} (Target: $targetFps)
├── Dropped Frames: ${report.droppedFramesCount}/${report.totalFramesCount}
├── Memory: ${report.currentMemoryMB.toStringAsFixed(1)}MB (Avg: ${report.averageMemoryMB.toStringAsFixed(1)}MB)
├── Response Time: ${report.averageResponseTimeMs}ms (Max: ${report.maxResponseTimeMs}ms)
└── Status: ${_getPerformanceStatus(report)}
''');
  }
  
  // ==================== 私有方法 ====================
  
  void _startMonitoring() {
    _isMonitoring = true;
    debugPrint('📈 Performance monitoring started');
  }
  
  void _stopMonitoring() {
    _isMonitoring = false;
    debugPrint('📈 Performance monitoring stopped');
  }
  
  static void _logPerformanceWarning(String message, PerformanceLevel level) {
    if (!kDebugMode) return;
    
    final icon = switch (level) {
      PerformanceLevel.info => 'ℹ️',
      PerformanceLevel.warning => '⚠️',
      PerformanceLevel.critical => '🚨',
    };
    
    debugPrint('$icon Performance: $message');
  }
  
  static String _getPerformanceStatus(PerformanceReport report) {
    if (report.averageFps < 50 || report.currentMemoryMB > 200) {
      return '🚨 Critical';
    } else if (report.averageFps < 55 || report.currentMemoryMB > targetMemoryMB) {
      return '⚠️ Warning';
    } else {
      return '✅ Good';
    }
  }
}

/// 性能级别
enum PerformanceLevel {
  info,
  warning,
  critical,
}

/// 性能报告
class PerformanceReport {
  final double averageFps;
  final int droppedFramesCount;
  final int totalFramesCount;
  final double averageMemoryMB;
  final double currentMemoryMB;
  final int averageResponseTimeMs;
  final int maxResponseTimeMs;
  
  const PerformanceReport({
    required this.averageFps,
    required this.droppedFramesCount,
    required this.totalFramesCount,
    required this.averageMemoryMB,
    required this.currentMemoryMB,
    required this.averageResponseTimeMs,
    required this.maxResponseTimeMs,
  });
  
  /// 性能评分 (0-100)
  int get performanceScore {
    int score = 100;
    
    // FPS评分 (40%)
    if (averageFps < 30) {
      score -= 40;
    } else if (averageFps < 50) {
      score -= 20;
    } else if (averageFps < 55) {
      score -= 10;
    }
    
    // 内存评分 (30%)
    if (currentMemoryMB > 200) {
      score -= 30;
    } else if (currentMemoryMB > PerformanceMonitor.targetMemoryMB) {
      score -= 15;
    }
    
    // 响应时间评分 (30%)
    if (averageResponseTimeMs > 500) {
      score -= 30;
    } else if (averageResponseTimeMs > PerformanceMonitor.targetResponseTimeMs) {
      score -= 15;
    }
    
    return score.clamp(0, 100);
  }
  
  /// 是否健康
  bool get isHealthy => performanceScore >= 70;
}