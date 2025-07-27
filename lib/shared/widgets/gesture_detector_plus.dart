import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../../core/gestures/gesture_recognizer.dart';
import '../../core/gestures/gesture_visualizer.dart';
import '../../core/gestures/haptic_feedback.dart';
import '../../core/utils/performance_monitor.dart';

/// 增强手势检测器
/// 整合手势识别、轨迹可视化、触觉反馈的完整解决方案
class GestureDetectorPlus extends StatefulWidget {
  /// 子组件
  final Widget child;
  
  /// 垂直滑动回调
  final Function(GestureDetails)? onVerticalSwipe;
  
  /// 水平滑动回调
  final Function(GestureDetails)? onHorizontalSwipe;
  
  /// 点击回调
  final Function(Offset)? onTap;
  
  /// 长按回调
  final Function(Offset)? onLongPress;
  
  /// 双击回调
  final Function(Offset)? onDoubleTap;
  
  /// 手势配置
  final GestureConfiguration configuration;
  
  /// 是否启用手势学习模式
  final bool enableLearningMode;
  
  /// 学习模式目标手势
  final GestureType? learningTarget;
  
  /// 学习完成回调
  final VoidCallback? onLearningComplete;
  
  const GestureDetectorPlus({
    super.key,
    required this.child,
    this.onVerticalSwipe,
    this.onHorizontalSwipe,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.configuration = const GestureConfiguration(),
    this.enableLearningMode = false,
    this.learningTarget,
    this.onLearningComplete,
  });

  @override
  State<GestureDetectorPlus> createState() => _GestureDetectorPlusState();
}

class _GestureDetectorPlusState extends State<GestureDetectorPlus>
    with TickerProviderStateMixin {
  
  final List<Offset> _trailPoints = [];
  GestureType _currentGesture = GestureType.none;
  bool _showTrail = false;
  bool _gestureInProgress = false;
  
  late AnimationController _successController;
  late AnimationController _trailController;
  
  // 双击检测
  DateTime? _lastTapTime;
  Offset? _lastTapPosition;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeHapticFeedback();
  }
  
  @override
  void dispose() {
    _successController.dispose();
    _trailController.dispose();
    super.dispose();
  }
  
  void _initializeAnimations() {
    _successController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _trailController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }
  
  void _initializeHapticFeedback() {
    HapticFeedbackManager.setConfig(widget.configuration.hapticConfig);
  }
  
  // ==================== 手势处理 ====================
  
  void _handleVerticalSwipe(GestureDetails details) {
    PerformanceMonitor.monitorGesture('VerticalSwipe', () {
      // 触觉反馈
      HapticFeedbackManager.triggerGesture('swipe');
      
      // 显示成功反馈
      _showSuccessFeedback();
      
      // 回调
      widget.onVerticalSwipe?.call(details);
      
      if (kDebugMode) {
        debugPrint('✨ Vertical swipe: ${details.gestureType}');
      }
    });
  }
  
  void _handleHorizontalSwipe(GestureDetails details) {
    PerformanceMonitor.monitorGesture('HorizontalSwipe', () {
      // 触觉反馈
      HapticFeedbackManager.triggerGesture('swipe');
      
      // 显示成功反馈
      _showSuccessFeedback();
      
      // 回调
      widget.onHorizontalSwipe?.call(details);
      
      if (kDebugMode) {
        debugPrint('✨ Horizontal swipe: ${details.gestureType}');
      }
    });
  }
  
  void _handleTap(Offset position) {
    final now = DateTime.now();
    
    // 双击检测
    if (_lastTapTime != null && 
        now.difference(_lastTapTime!).inMilliseconds < 500 &&
        _lastTapPosition != null &&
        (position - _lastTapPosition!).distance < 50) {
      
      // 双击
      _handleDoubleTap(position);
      _lastTapTime = null;
      _lastTapPosition = null;
      return;
    }
    
    // 单击
    _lastTapTime = now;
    _lastTapPosition = position;
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_lastTapTime == now) {
        // 确认是单击
        HapticFeedbackManager.triggerGesture('tap');
        widget.onTap?.call(position);
        
        if (kDebugMode) {
          debugPrint('👆 Tap at $position');
        }
      }
    });
  }
  
  void _handleDoubleTap(Offset position) {
    PerformanceMonitor.monitorGesture('DoubleTap', () {
      AdvancedHapticFeedback.doubleTap();
      widget.onDoubleTap?.call(position);
      
      if (kDebugMode) {
        debugPrint('👆👆 Double tap at $position');
      }
    });
  }
  
  void _handleLongPress(Offset position) {
    PerformanceMonitor.monitorGesture('LongPress', () {
      AdvancedHapticFeedback.longPressPattern();
      widget.onLongPress?.call(position);
      
      if (kDebugMode) {
        debugPrint('👆⏱️ Long press at $position');
      }
    });
  }
  
  // ==================== 视觉反馈 ====================
  
  void _showSuccessFeedback() {
    if (!widget.configuration.enableSuccessFeedback) return;
    
    _successController.forward().then((_) {
      _successController.reset();
    });
  }
  
  void _updateTrail(List<Offset> points) {
    if (!widget.configuration.enableTrailVisualization) return;
    
    setState(() {
      _trailPoints.clear();
      _trailPoints.addAll(points);
      _showTrail = points.isNotEmpty;
    });
    
    if (_showTrail) {
      _trailController.forward().then((_) {
        setState(() {
          _showTrail = false;
          _trailPoints.clear();
        });
        _trailController.reset();
      });
    }
  }
  
  // ==================== 学习模式 ====================
  
  void _handleLearningModeGesture(GestureDetails details) {
    if (!widget.enableLearningMode || widget.learningTarget == null) return;
    
    if (details.gestureType == widget.learningTarget) {
      AdvancedHapticFeedback.successSequence();
      
      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('手势学习成功！'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      widget.onLearningComplete?.call();
      
      if (kDebugMode) {
        debugPrint('🎓 Gesture learning completed: ${details.gestureType}');
      }
    }
  }
  
  // ==================== 界面构建 ====================
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 主要内容
        CustomGestureRecognizer(
          enableTrailVisualization: false, // 我们自己处理
          enableHapticFeedback: false, // 我们自己处理
          gestureThreshold: widget.configuration.gestureThreshold,
          onVerticalDragEnd: (details) {
            _handleVerticalSwipe(details);
            _handleLearningModeGesture(details);
            _updateTrail(details.trailPoints);
          },
          onHorizontalDragEnd: (details) {
            _handleHorizontalSwipe(details);
            _handleLearningModeGesture(details);
            _updateTrail(details.trailPoints);
          },
          onTap: _handleTap,
          onLongPress: _handleLongPress,
          child: widget.child,
        ),
        
        // 轨迹可视化
        if (_showTrail && widget.configuration.enableTrailVisualization)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: GestureTrailPainter(
                  points: _trailPoints,
                  animation: _trailController,
                  gestureType: _currentGesture,
                  isSuccess: _successController.isAnimating,
                ),
              ),
            ),
          ),
        
        // 成功反馈覆层
        if (_successController.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _successController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(
                        0.1 * (1 - _successController.value),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        
        // 学习模式指导
        if (widget.enableLearningMode && widget.learningTarget != null)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: GestureHint(
                gestureType: widget.learningTarget!,
                hintText: _getLearningHintText(),
                icon: _getLearningHintIcon(),
              ),
            ),
          ),
      ],
    );
  }
  
  String _getLearningHintText() {
    switch (widget.learningTarget) {
      case GestureType.swipeUp:
        return '向上滑动';
      case GestureType.swipeDown:
        return '向下滑动';
      case GestureType.swipeLeft:
        return '向左滑动';
      case GestureType.swipeRight:
        return '向右滑动';
      default:
        return '执行手势';
    }
  }
  
  IconData _getLearningHintIcon() {
    switch (widget.learningTarget) {
      case GestureType.swipeUp:
        return Icons.keyboard_arrow_up;
      case GestureType.swipeDown:
        return Icons.keyboard_arrow_down;
      case GestureType.swipeLeft:
        return Icons.keyboard_arrow_left;
      case GestureType.swipeRight:
        return Icons.keyboard_arrow_right;
      default:
        return Icons.touch_app;
    }
  }
}

/// 手势配置类
class GestureConfiguration {
  /// 手势触发阈值
  final double gestureThreshold;
  
  /// 是否启用轨迹可视化
  final bool enableTrailVisualization;
  
  /// 是否启用成功反馈
  final bool enableSuccessFeedback;
  
  /// 触觉反馈配置
  final HapticConfig hapticConfig;
  
  /// 是否启用边缘手势
  final bool enableEdgeGestures;
  
  /// 边缘手势宽度
  final double edgeGestureWidth;
  
  /// 手势识别灵敏度
  final GestureSensitivity sensitivity;
  
  const GestureConfiguration({
    this.gestureThreshold = 50.0,
    this.enableTrailVisualization = true,
    this.enableSuccessFeedback = true,
    this.hapticConfig = HapticConfig.standard,
    this.enableEdgeGestures = false,
    this.edgeGestureWidth = 20.0,
    this.sensitivity = GestureSensitivity.normal,
  });
  
  /// 预设配置 - 微妙模式
  static const GestureConfiguration subtle = GestureConfiguration(
    gestureThreshold: 30.0,
    enableTrailVisualization: false,
    enableSuccessFeedback: false,
    hapticConfig: HapticConfig.subtle,
    sensitivity: GestureSensitivity.high,
  );
  
  /// 预设配置 - 标准模式
  static const GestureConfiguration standard = GestureConfiguration();
  
  /// 预设配置 - 学习模式
  static const GestureConfiguration learning = GestureConfiguration(
    gestureThreshold: 40.0,
    enableTrailVisualization: true,
    enableSuccessFeedback: true,
    hapticConfig: HapticConfig.intense,
    sensitivity: GestureSensitivity.normal,
  );
  
  /// 预设配置 - 无障碍模式
  static const GestureConfiguration accessibility = GestureConfiguration(
    gestureThreshold: 60.0,
    enableTrailVisualization: true,
    enableSuccessFeedback: true,
    hapticConfig: HapticConfig.intense,
    sensitivity: GestureSensitivity.low,
  );
}

/// 手势灵敏度枚举
enum GestureSensitivity {
  low,    // 低灵敏度 - 需要更明确的手势
  normal, // 正常灵敏度
  high,   // 高灵敏度 - 较小的动作也能触发
}

/// 手势统计信息
class GestureStats {
  int totalGestures = 0;
  int successfulGestures = 0;
  Map<GestureType, int> gestureCount = {};
  
  double get successRate => 
      totalGestures > 0 ? successfulGestures / totalGestures : 0.0;
  
  void recordGesture(GestureType type, bool success) {
    totalGestures++;
    if (success) successfulGestures++;
    
    gestureCount[type] = (gestureCount[type] ?? 0) + 1;
  }
  
  void reset() {
    totalGestures = 0;
    successfulGestures = 0;
    gestureCount.clear();
  }
  
  Map<String, dynamic> toJson() {
    return {
      'totalGestures': totalGestures,
      'successfulGestures': successfulGestures,
      'successRate': successRate,
      'gestureCount': gestureCount.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    };
  }
}

/// 全局手势管理器
class GlobalGestureManager {
  static final GestureStats _stats = GestureStats();
  static GestureConfiguration _globalConfig = GestureConfiguration.standard;
  
  /// 设置全局配置
  static void setGlobalConfiguration(GestureConfiguration config) {
    _globalConfig = config;
  }
  
  /// 获取全局配置
  static GestureConfiguration get globalConfiguration => _globalConfig;
  
  /// 获取统计信息
  static GestureStats get stats => _stats;
  
  /// 记录手势
  static void recordGesture(GestureType type, bool success) {
    _stats.recordGesture(type, success);
  }
  
  /// 重置统计
  static void resetStats() {
    _stats.reset();
  }
  
  /// 初始化手势系统
  static Future<void> initialize() async {
    await HapticFeedbackManager.initialize();
    
    if (kDebugMode) {
      debugPrint('🎮 GlobalGestureManager initialized');
    }
  }
}