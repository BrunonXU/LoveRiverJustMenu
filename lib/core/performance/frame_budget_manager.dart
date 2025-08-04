import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

/// 🎯 帧预算管理器
/// 确保每帧处理时间不超过8ms (120FPS) 或 16ms (60FPS)
class FrameBudgetManager {
  static FrameBudgetManager? _instance;
  static FrameBudgetManager get instance => _instance ??= FrameBudgetManager._();
  
  FrameBudgetManager._();
  
  // 帧预算配置 (微秒)
  static const int targetFps120 = 8333; // 8.33ms for 120FPS
  static const int targetFps60 = 16666;  // 16.66ms for 60FPS
  static const int targetFps30 = 33333;  // 33.33ms for 30FPS
  
  int _currentBudgetMicros = targetFps60;
  int _frameStartTime = 0;
  int _frameCount = 0;
  int _droppedFrames = 0;
  
  List<double> _frameTimes = [];
  
  /// 设置目标帧率
  void setTargetFps(int fps) {
    switch (fps) {
      case 120:
        _currentBudgetMicros = targetFps120;
        break;
      case 60:
        _currentBudgetMicros = targetFps60;
        break;
      case 30:
        _currentBudgetMicros = targetFps30;
        break;
      default:
        _currentBudgetMicros = (1000000 / fps).round();
    }
    
    debugPrint('🎯 设置目标帧率: ${fps}FPS (${_currentBudgetMicros / 1000}ms/帧)');
  }
  
  /// 开始帧预算监控
  void startFrame() {
    _frameStartTime = DateTime.now().microsecondsSinceEpoch;
  }
  
  /// 结束帧预算监控
  void endFrame() {
    final endTime = DateTime.now().microsecondsSinceEpoch;
    final frameTime = endTime - _frameStartTime;
    
    _frameCount++;
    _frameTimes.add(frameTime / 1000.0); // 转换为毫秒
    
    // 检查是否超出预算
    if (frameTime > _currentBudgetMicros) {
      _droppedFrames++;
      if (kDebugMode) {
        debugPrint('⚠️ 帧超时: ${(frameTime / 1000).toStringAsFixed(2)}ms (预算: ${(_currentBudgetMicros / 1000).toStringAsFixed(2)}ms)');
      }
    }
    
    // 保持最近100帧的记录
    if (_frameTimes.length > 100) {
      _frameTimes.removeAt(0);
    }
    
    // 每秒报告一次性能
    if (_frameCount % 60 == 0) {
      _reportPerformance();
    }
  }
  
  /// 检查当前帧是否还有预算
  bool hasFrameBudget() {
    final currentTime = DateTime.now().microsecondsSinceEpoch;
    final elapsed = currentTime - _frameStartTime;
    return elapsed < (_currentBudgetMicros * 0.8); // 保留20%缓冲
  }
  
  /// 获取剩余帧预算 (毫秒)
  double getRemainingBudgetMs() {
    final currentTime = DateTime.now().microsecondsSinceEpoch;
    final elapsed = currentTime - _frameStartTime;
    final remaining = _currentBudgetMicros - elapsed;
    return remaining / 1000.0;
  }
  
  /// 报告性能统计
  void _reportPerformance() {
    if (_frameTimes.isEmpty) return;
    
    final avgFrameTime = _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    final maxFrameTime = _frameTimes.reduce((a, b) => a > b ? a : b);
    final dropRate = (_droppedFrames / _frameCount * 100);
    
    if (kDebugMode) {
      debugPrint('''
📊 帧预算报告:
├── 平均帧时间: ${avgFrameTime.toStringAsFixed(2)}ms
├── 最大帧时间: ${maxFrameTime.toStringAsFixed(2)}ms
├── 掉帧率: ${dropRate.toStringAsFixed(1)}%
├── 目标: ${(_currentBudgetMicros / 1000).toStringAsFixed(2)}ms
└── 状态: ${dropRate < 5 ? '✅ 优秀' : dropRate < 15 ? '⚠️ 一般' : '🚨 需优化'}
''');
    }
  }
  
  /// 获取当前FPS
  double getCurrentFps() {
    if (_frameTimes.isEmpty) return 0.0;
    final avgFrameTime = _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    return 1000.0 / avgFrameTime;
  }
  
  /// 重置统计
  void reset() {
    _frameCount = 0;
    _droppedFrames = 0;
    _frameTimes.clear();
  }
}

/// 帧预算监控Widget
/// 自动为子Widget添加帧预算监控
class FrameBudgetMonitor extends StatefulWidget {
  final Widget child;
  final String? debugLabel;
  
  const FrameBudgetMonitor({
    super.key,
    required this.child,
    this.debugLabel,
  });

  @override
  State<FrameBudgetMonitor> createState() => _FrameBudgetMonitorState();
}

class _FrameBudgetMonitorState extends State<FrameBudgetMonitor>
    with SingleTickerProviderStateMixin {
  
  @override
  void initState() {
    super.initState();
    
    // 设置帧回调监控
    SchedulerBinding.instance.addPostFrameCallback((_) {
      FrameBudgetManager.instance.startFrame();
    });
    
    SchedulerBinding.instance.addPersistentFrameCallback((_) {
      FrameBudgetManager.instance.endFrame();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        FrameBudgetManager.instance.startFrame();
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}