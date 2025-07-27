import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../themes/colors.dart';
import 'gesture_recognizer.dart';

/// 手势轨迹绘制器
/// 实现渐变透明度轨迹，压力感应可视化，成功反馈金色效果
class GestureTrailPainter extends CustomPainter {
  final List<Offset> points;
  final Animation<double>? animation;
  final GestureType gestureType;
  final bool showPressure;
  final bool isSuccess;
  
  GestureTrailPainter({
    required this.points,
    this.animation,
    this.gestureType = GestureType.none,
    this.showPressure = false,
    this.isSuccess = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    
    // 绘制主轨迹
    _drawMainTrail(canvas);
    
    // 绘制方向指示器
    if (points.length > 5) {
      _drawDirectionIndicator(canvas);
    }
    
    // 绘制手势类型提示
    if (gestureType != GestureType.none) {
      _drawGestureTypeHint(canvas, size);
    }
  }
  
  /// 绘制主轨迹
  void _drawMainTrail(Canvas canvas) {
    final baseColor = isSuccess ? Colors.amber : _getGestureColor();
    final fadeValue = animation?.value ?? 0.0;
    
    for (int i = 1; i < points.length; i++) {
      final startPoint = points[i - 1];
      final endPoint = points[i];
      
      // 计算透明度（越新的点越不透明）
      final opacity = (i / points.length) * (1.0 - fadeValue);
      if (opacity <= 0) continue;
      
      // 计算线宽（基于位置和压力）
      final progress = i / points.length;
      final baseWidth = 3.0;
      final dynamicWidth = baseWidth * (0.5 + progress * 0.5);
      
      // 创建渐变着色器
      final gradient = ui.Gradient.linear(
        startPoint,
        endPoint,
        [
          baseColor.withOpacity(opacity * 0.3),
          baseColor.withOpacity(opacity),
        ],
        [0.0, 1.0],
      );
      
      final paint = Paint()
        ..shader = gradient
        ..strokeWidth = dynamicWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(startPoint, endPoint, paint);
      
      // 绘制光晕效果
      if (i > points.length - 5) {
        _drawGlowEffect(canvas, endPoint, baseColor, opacity);
      }
    }
  }
  
  /// 绘制光晕效果
  void _drawGlowEffect(Canvas canvas, Offset center, Color color, double opacity) {
    final glowPaint = Paint()
      ..color = color.withOpacity(opacity * 0.1)
      ..style = PaintingStyle.fill;
    
    for (double radius = 15.0; radius > 0; radius -= 3.0) {
      glowPaint.color = color.withOpacity(opacity * 0.1 * (radius / 15.0));
      canvas.drawCircle(center, radius, glowPaint);
    }
  }
  
  /// 绘制方向指示器
  void _drawDirectionIndicator(Canvas canvas) {
    if (points.length < 2) return;
    
    final startPoint = points[0];
    final endPoint = points.last;
    final direction = endPoint - startPoint;
    
    if (direction.distance < 20) return;
    
    // 计算箭头位置和角度
    final arrowLength = 15.0;
    final arrowAngle = math.atan2(direction.dy, direction.dx);
    
    // 箭头端点
    final arrowTip = endPoint;
    final arrowBase1 = Offset(
      arrowTip.dx - arrowLength * math.cos(arrowAngle - 0.5),
      arrowTip.dy - arrowLength * math.sin(arrowAngle - 0.5),
    );
    final arrowBase2 = Offset(
      arrowTip.dx - arrowLength * math.cos(arrowAngle + 0.5),
      arrowTip.dy - arrowLength * math.sin(arrowAngle + 0.5),
    );
    
    // 绘制箭头
    final arrowPaint = Paint()
      ..color = _getGestureColor().withOpacity(0.8)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final arrowPath = Path()
      ..moveTo(arrowBase1.dx, arrowBase1.dy)
      ..lineTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowBase2.dx, arrowBase2.dy);
    
    canvas.drawPath(arrowPath, arrowPaint);
  }
  
  /// 绘制手势类型提示
  void _drawGestureTypeHint(Canvas canvas, Size size) {
    final hintText = _getGestureTypeText();
    if (hintText.isEmpty) return;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: hintText,
        style: TextStyle(
          color: _getGestureColor(),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // 计算文字位置（轨迹中心附近）
    final centerPoint = _calculateTrailCenter();
    final textOffset = Offset(
      centerPoint.dx - textPainter.width / 2,
      centerPoint.dy - textPainter.height / 2 - 30,
    );
    
    // 绘制背景
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        textOffset.dx - 8,
        textOffset.dy - 4,
        textPainter.width + 16,
        textPainter.height + 8,
      ),
      const Radius.circular(8),
    );
    
    canvas.drawRRect(backgroundRect, backgroundPaint);
    
    // 绘制文字
    textPainter.paint(canvas, textOffset);
  }
  
  /// 计算轨迹中心点
  Offset _calculateTrailCenter() {
    if (points.isEmpty) return Offset.zero;
    
    double totalX = 0;
    double totalY = 0;
    
    for (final point in points) {
      totalX += point.dx;
      totalY += point.dy;
    }
    
    return Offset(totalX / points.length, totalY / points.length);
  }
  
  /// 获取手势颜色
  Color _getGestureColor() {
    switch (gestureType) {
      case GestureType.swipeUp:
        return const Color(0xFF4CAF50); // 绿色
      case GestureType.swipeDown:
        return const Color(0xFF2196F3); // 蓝色
      case GestureType.swipeLeft:
        return const Color(0xFFFF9800); // 橙色
      case GestureType.swipeRight:
        return const Color(0xFF9C27B0); // 紫色
      case GestureType.pinch:
        return const Color(0xFFF44336); // 红色
      case GestureType.zoom:
        return const Color(0xFF00BCD4); // 青色
      default:
        return AppColors.primary;
    }
  }
  
  /// 获取手势类型文字
  String _getGestureTypeText() {
    switch (gestureType) {
      case GestureType.swipeUp:
        return '上滑';
      case GestureType.swipeDown:
        return '下滑';
      case GestureType.swipeLeft:
        return '左滑';
      case GestureType.swipeRight:
        return '右滑';
      case GestureType.pinch:
        return '捏合';
      case GestureType.zoom:
        return '放大';
      default:
        return '';
    }
  }

  @override
  bool shouldRepaint(GestureTrailPainter oldDelegate) {
    return points != oldDelegate.points ||
           animation?.value != oldDelegate.animation?.value ||
           gestureType != oldDelegate.gestureType ||
           isSuccess != oldDelegate.isSuccess;
  }
}

/// 手势提示组件
class GestureHint extends StatefulWidget {
  final GestureType gestureType;
  final String hintText;
  final IconData? icon;
  final Duration showDuration;
  
  const GestureHint({
    super.key,
    required this.gestureType,
    required this.hintText,
    this.icon,
    this.showDuration = const Duration(seconds: 2),
  });

  @override
  State<GestureHint> createState() => _GestureHintState();
}

class _GestureHintState extends State<GestureHint>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _controller.forward();
    
    // 自动隐藏
    Future.delayed(widget.showDuration, () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.hintText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 压力感应可视化组件
class PressureVisualizer extends StatelessWidget {
  final double pressure;
  final Offset position;
  final double maxRadius;
  
  const PressureVisualizer({
    super.key,
    required this.pressure,
    required this.position,
    this.maxRadius = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - maxRadius,
      top: position.dy - maxRadius,
      child: Container(
        width: maxRadius * 2,
        height: maxRadius * 2,
        child: CustomPaint(
          painter: _PressurePainter(pressure: pressure, maxRadius: maxRadius),
        ),
      ),
    );
  }
}

/// 压力绘制器
class _PressurePainter extends CustomPainter {
  final double pressure;
  final double maxRadius;
  
  _PressurePainter({
    required this.pressure,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = maxRadius * pressure.clamp(0.1, 1.0);
    
    // 外圈 - 透明度较低
    final outerPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, outerPaint);
    
    // 内圈 - 透明度较高
    final innerPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.6, innerPaint);
    
    // 中心点
    final centerPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 3, centerPaint);
  }

  @override
  bool shouldRepaint(_PressurePainter oldDelegate) {
    return pressure != oldDelegate.pressure;
  }
}

/// 手势学习组件
class GestureLearningWidget extends StatefulWidget {
  final GestureType targetGesture;
  final String instruction;
  final VoidCallback? onSuccess;
  final VoidCallback? onSkip;
  
  const GestureLearningWidget({
    super.key,
    required this.targetGesture,
    required this.instruction,
    this.onSuccess,
    this.onSkip,
  });

  @override
  State<GestureLearningWidget> createState() => _GestureLearningWidgetState();
}

class _GestureLearningWidgetState extends State<GestureLearningWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _gestureDetected = false;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  
  void _handleGestureDetected(GestureDetails details) {
    if (details.gestureType == widget.targetGesture && !_gestureDetected) {
      setState(() {
        _gestureDetected = true;
      });
      
      _pulseController.stop();
      
      // 成功反馈
      HapticFeedback.notificationImpact(NotificationFeedbackType.success);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onSuccess?.call();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 动画指示器
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _gestureDetected ? 1.0 : _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gestureDetected 
                        ? Colors.green.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.2),
                    border: Border.all(
                      color: _gestureDetected ? Colors.green : AppColors.primary,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    _getGestureIcon(),
                    size: 60,
                    color: _gestureDetected ? Colors.green : AppColors.primary,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // 指导文字
          Text(
            _gestureDetected ? '很好！手势识别成功' : widget.instruction,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // 跳过按钮
          if (!_gestureDetected)
            TextButton(
              onPressed: widget.onSkip,
              child: const Text('跳过'),
            ),
        ],
      ),
    );
  }
  
  IconData _getGestureIcon() {
    switch (widget.targetGesture) {
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