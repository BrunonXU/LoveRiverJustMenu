import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../themes/spacing.dart';
import '../utils/performance_monitor.dart';

/// 手势识别器
/// 严格遵循设计规范：50px触发阈值，轨迹可视化，触觉反馈
class CustomGestureRecognizer extends StatefulWidget {
  /// 子组件
  final Widget child;
  
  /// 垂直滑动回调
  final Function(GestureDetails)? onVerticalDrag;
  final Function(GestureDetails)? onVerticalDragEnd;
  
  /// 水平滑动回调
  final Function(GestureDetails)? onHorizontalDrag;
  final Function(GestureDetails)? onHorizontalDragEnd;
  
  /// 点击回调
  final Function(Offset)? onTap;
  final Function(Offset)? onLongPress;
  
  /// 缩放手势回调
  final Function(ScaleDetails)? onScale;
  
  /// 旋转手势回调
  final Function(double)? onRotation;
  
  /// 是否启用轨迹可视化
  final bool enableTrailVisualization;
  
  /// 是否启用触觉反馈
  final bool enableHapticFeedback;
  
  /// 手势触发阈值
  final double gestureThreshold;
  
  /// 是否启用边缘手势
  final bool enableEdgeGestures;
  
  /// 边缘手势宽度
  final double edgeGestureWidth;
  
  const CustomGestureRecognizer({
    super.key,
    required this.child,
    this.onVerticalDrag,
    this.onVerticalDragEnd,
    this.onHorizontalDrag,
    this.onHorizontalDragEnd,
    this.onTap,
    this.onLongPress,
    this.onScale,
    this.onRotation,
    this.enableTrailVisualization = true,
    this.enableHapticFeedback = true,
    this.gestureThreshold = AppSpacing.gestureThreshold, // 50px
    this.enableEdgeGestures = false,
    this.edgeGestureWidth = 20.0,
  });

  @override
  State<CustomGestureRecognizer> createState() => _CustomGestureRecognizerState();
}

class _CustomGestureRecognizerState extends State<CustomGestureRecognizer>
    with TickerProviderStateMixin {
  
  // ==================== 手势状态 ====================
  
  final List<Offset> _trailPoints = [];
  Offset? _startPoint;
  Offset? _currentPoint;
  GestureType _currentGesture = GestureType.none;
  DateTime? _gestureStartTime;
  
  late AnimationController _trailController;
  late AnimationController _feedbackController;
  
  bool _isGestureActive = false;
  bool _isLongPressActive = false;
  
  // ==================== 初始化 ====================
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  @override
  void dispose() {
    _trailController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }
  
  void _initializeAnimations() {
    // 轨迹消失动画
    _trailController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // 反馈动画
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }
  
  // ==================== 手势处理 ====================
  
  void _onPanStart(DragStartDetails details) {
    PerformanceMonitor.monitorGesture('PanStart', () {
      _startPoint = details.localPosition;
      _currentPoint = details.localPosition;
      _gestureStartTime = DateTime.now();
      _isGestureActive = true;
      
      setState(() {
        _trailPoints.clear();
        _trailPoints.add(details.localPosition);
      });
      
      _triggerHapticFeedback(HapticType.light);
    });
  }
  
  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isGestureActive || _startPoint == null) return;
    
    _currentPoint = details.localPosition;
    
    setState(() {
      _trailPoints.add(details.localPosition);
      
      // 限制轨迹点数量（性能优化）
      if (_trailPoints.length > 50) {
        _trailPoints.removeAt(0);
      }
    });
    
    // 计算手势方向和距离
    final delta = details.localPosition - _startPoint!;
    final distance = delta.distance;
    
    if (distance > widget.gestureThreshold) {
      final gestureType = _detectGestureType(delta);
      
      if (gestureType != _currentGesture) {
        _currentGesture = gestureType;
        _triggerHapticFeedback(HapticType.medium);
        
        // 触发相应的手势回调
        _handleGestureCallback(gestureType, details);
      }
    }
  }
  
  void _onPanEnd(DragEndDetails details) {
    if (!_isGestureActive || _startPoint == null || _currentPoint == null) return;
    
    PerformanceMonitor.monitorGesture('PanEnd', () {
      final delta = _currentPoint! - _startPoint!;
      final velocity = details.velocity.pixelsPerSecond;
      final duration = DateTime.now().difference(_gestureStartTime!);
      
      final gestureDetails = GestureDetails(
        startPosition: _startPoint!,
        endPosition: _currentPoint!,
        delta: delta,
        velocity: velocity,
        duration: duration,
        distance: delta.distance,
        gestureType: _currentGesture,
        trailPoints: List.from(_trailPoints),
      );
      
      // 触发结束回调
      _handleGestureEndCallback(_currentGesture, gestureDetails);
      
      // 成功手势反馈
      if (_currentGesture != GestureType.none) {
        _triggerHapticFeedback(HapticType.success);
        _showSuccessFeedback();
      }
      
      // 清理状态
      _resetGestureState();
    });
  }
  
  void _onTap(TapUpDetails details) {
    PerformanceMonitor.monitorGesture('Tap', () {
      _triggerHapticFeedback(HapticType.light);
      widget.onTap?.call(details.localPosition);
    });
  }
  
  void _onLongPressStart(LongPressStartDetails details) {
    _isLongPressActive = true;
    _triggerHapticFeedback(HapticType.heavy);
    widget.onLongPress?.call(details.localPosition);
  }
  
  void _onLongPressEnd(LongPressEndDetails details) {
    _isLongPressActive = false;
  }
  
  // ==================== 手势识别逻辑 ====================
  
  GestureType _detectGestureType(Offset delta) {
    final dx = delta.dx.abs();
    final dy = delta.dy.abs();
    
    // 判断主要方向
    if (dy > dx * 1.5) {
      // 垂直手势
      return delta.dy > 0 ? GestureType.swipeDown : GestureType.swipeUp;
    } else if (dx > dy * 1.5) {
      // 水平手势
      return delta.dx > 0 ? GestureType.swipeRight : GestureType.swipeLeft;
    }
    
    return GestureType.none;
  }
  
  void _handleGestureCallback(GestureType type, DragUpdateDetails details) {
    final gestureDetails = GestureDetails(
      startPosition: _startPoint!,
      endPosition: details.localPosition,
      delta: details.localPosition - _startPoint!,
      velocity: Offset.zero, // 更新时暂无速度信息
      duration: DateTime.now().difference(_gestureStartTime!),
      distance: (details.localPosition - _startPoint!).distance,
      gestureType: type,
      trailPoints: List.from(_trailPoints),
    );
    
    switch (type) {
      case GestureType.swipeUp:
      case GestureType.swipeDown:
        widget.onVerticalDrag?.call(gestureDetails);
        break;
      case GestureType.swipeLeft:
      case GestureType.swipeRight:
        widget.onHorizontalDrag?.call(gestureDetails);
        break;
      default:
        break;
    }
  }
  
  void _handleGestureEndCallback(GestureType type, GestureDetails details) {
    switch (type) {
      case GestureType.swipeUp:
      case GestureType.swipeDown:
        widget.onVerticalDragEnd?.call(details);
        break;
      case GestureType.swipeLeft:
      case GestureType.swipeRight:
        widget.onHorizontalDragEnd?.call(details);
        break;
      default:
        break;
    }
  }
  
  // ==================== 反馈系统 ====================
  
  void _triggerHapticFeedback(HapticType type) {
    if (!widget.enableHapticFeedback) return;
    
    switch (type) {
      case HapticType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticType.success:
        HapticFeedback.notificationImpact(NotificationFeedbackType.success);
        break;
      case HapticType.warning:
        HapticFeedback.notificationImpact(NotificationFeedbackType.warning);
        break;
      case HapticType.error:
        HapticFeedback.notificationImpact(NotificationFeedbackType.error);
        break;
    }
  }
  
  void _showSuccessFeedback() {
    _feedbackController.forward().then((_) {
      _feedbackController.reset();
    });
  }
  
  // ==================== 状态重置 ====================
  
  void _resetGestureState() {
    setState(() {
      _isGestureActive = false;
      _currentGesture = GestureType.none;
      _startPoint = null;
      _currentPoint = null;
      _gestureStartTime = null;
    });
    
    // 启动轨迹消失动画
    _trailController.forward().then((_) {
      setState(() {
        _trailPoints.clear();
      });
      _trailController.reset();
    });
  }
  
  // ==================== 边缘手势检测 ====================
  
  bool _isEdgeGesture(Offset position) {
    if (!widget.enableEdgeGestures) return false;
    
    final screenSize = MediaQuery.of(context).size;
    return position.dx < widget.edgeGestureWidth ||
           position.dx > screenSize.width - widget.edgeGestureWidth ||
           position.dy < widget.edgeGestureWidth ||
           position.dy > screenSize.height - widget.edgeGestureWidth;
  }
  
  // ==================== 界面构建 ====================
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 主要内容
        GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onTapUp: widget.onTap != null ? _onTap : null,
          onLongPressStart: widget.onLongPress != null ? _onLongPressStart : null,
          onLongPressEnd: widget.onLongPress != null ? _onLongPressEnd : null,
          child: widget.child,
        ),
        
        // 轨迹可视化
        if (widget.enableTrailVisualization && _trailPoints.isNotEmpty)
          Positioned.fill(
            child: CustomPaint(
              painter: GestureTrailPainter(
                points: _trailPoints,
                animation: _trailController,
                gestureType: _currentGesture,
              ),
            ),
          ),
        
        // 成功反馈效果
        if (_feedbackController.isAnimating)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _feedbackController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(
                      0.2 * (1 - _feedbackController.value),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// 手势类型枚举
enum GestureType {
  none,
  swipeUp,
  swipeDown,
  swipeLeft,
  swipeRight,
  pinch,
  zoom,
  rotate,
}

/// 触觉反馈类型
enum HapticType {
  light,
  medium,
  heavy,
  success,
  warning,
  error,
}

/// 手势详情
class GestureDetails {
  final Offset startPosition;
  final Offset endPosition;
  final Offset delta;
  final Offset velocity;
  final Duration duration;
  final double distance;
  final GestureType gestureType;
  final List<Offset> trailPoints;
  
  const GestureDetails({
    required this.startPosition,
    required this.endPosition,
    required this.delta,
    required this.velocity,
    required this.duration,
    required this.distance,
    required this.gestureType,
    required this.trailPoints,
  });
  
  /// 手势速度 (px/s)
  double get speed => distance / (duration.inMilliseconds / 1000);
  
  /// 是否为快速手势
  bool get isFastGesture => speed > 300;
  
  /// 手势角度 (弧度)
  double get angle => math.atan2(delta.dy, delta.dx);
  
  /// 手势角度 (度)
  double get angleDegrees => angle * 180 / math.pi;
}

/// 缩放手势详情
class ScaleDetails {
  final Offset focalPoint;
  final double scale;
  final double rotation;
  
  const ScaleDetails({
    required this.focalPoint,
    required this.scale,
    required this.rotation,
  });
}