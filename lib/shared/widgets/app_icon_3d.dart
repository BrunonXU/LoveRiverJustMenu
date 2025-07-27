import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../core/themes/colors.dart';
import '../../core/themes/spacing.dart';
import 'breathing_widget.dart';

/// 3D扁平化图标系统
/// 120x120px，蓝紫渐变(#5B6FED→#8B9BF3)，类似碗勺参考图标
class AppIcon3D extends StatefulWidget {
  final AppIcon3DType type;
  final double size;
  final bool isAnimated;
  final VoidCallback? onTap;
  
  const AppIcon3D({
    super.key,
    required this.type,
    this.size = 120,
    this.isAnimated = true,
    this.onTap,
  });

  @override
  State<AppIcon3D> createState() => _AppIcon3DState();
}

class _AppIcon3DState extends State<AppIcon3D>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _shadowController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _shadowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _shadowAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _shadowController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isAnimated) {
      _rotationController.repeat();
      _shadowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _shadowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = widget.isAnimated
        ? BreathingWidget(child: _buildIcon())
        : _buildIcon();
    
    if (widget.onTap != null) {
      iconWidget = GestureDetector(
        onTap: widget.onTap,
        child: iconWidget,
      );
    }
    
    return iconWidget;
  }
  
  Widget _buildIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _shadowAnimation]),
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // 透视效果
            ..rotateY(_rotationAnimation.value * 0.1) // 轻微旋转
            ..scale(_shadowAnimation.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: _getIconGradient(),
              borderRadius: BorderRadius.circular(widget.size * 0.25), // 圆角
              boxShadow: [
                BoxShadow(
                  color: AppColors.getShadowColor(false).withOpacity(0.3),
                  blurRadius: widget.size * 0.2,
                  offset: Offset(0, widget.size * 0.1),
                  spreadRadius: widget.size * 0.02,
                ),
                // 3D效果阴影
                BoxShadow(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  blurRadius: widget.size * 0.1,
                  offset: Offset(widget.size * 0.05, widget.size * 0.05),
                ),
              ],
            ),
            child: _buildIconContent(),
          ),
        );
      },
    );
  }
  
  Widget _buildIconContent() {
    return Container(
      padding: EdgeInsets.all(widget.size * 0.2),
      child: CustomPaint(
        size: Size(widget.size * 0.6, widget.size * 0.6),
        painter: _getIconPainter(),
      ),
    );
  }
  
  LinearGradient _getIconGradient() {
    switch (widget.type) {
      case AppIcon3DType.bowl:
        return AppColors.primaryGradient;
      case AppIcon3DType.spoon:
        return const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppIcon3DType.chef:
        return const LinearGradient(
          colors: [Color(0xFFB794F6), Color(0xFFF687B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppIcon3DType.timer:
        return const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppIcon3DType.recipe:
        return const LinearGradient(
          colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppIcon3DType.heart:
        return const LinearGradient(
          colors: [Color(0xFFEC407A), Color(0xFFAB47BC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
  
  CustomPainter _getIconPainter() {
    switch (widget.type) {
      case AppIcon3DType.bowl:
        return BowlIconPainter();
      case AppIcon3DType.spoon:
        return SpoonIconPainter();
      case AppIcon3DType.chef:
        return ChefIconPainter();
      case AppIcon3DType.timer:
        return TimerIconPainter();
      case AppIcon3DType.recipe:
        return RecipeIconPainter();
      case AppIcon3DType.heart:
        return HeartIconPainter();
    }
  }
}

/// 3D图标类型枚举
enum AppIcon3DType {
  bowl,    // 碗
  spoon,   // 勺子
  chef,    // 厨师帽
  timer,   // 计时器
  recipe,  // 菜谱
  heart,   // 爱心
}

/// 碗图标绘制器
class BowlIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    
    // 绘制碗的外形
    final bowlPath = Path();
    bowlPath.moveTo(center.dx - radius, center.dy);
    bowlPath.quadraticBezierTo(
      center.dx, center.dy + radius * 0.8,
      center.dx + radius, center.dy,
    );
    
    canvas.drawPath(bowlPath, paint);
    
    // 绘制碗口
    canvas.drawArc(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 0.6),
      0,
      math.pi,
      false,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 勺子图标绘制器
class SpoonIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // 勺子柄
    canvas.drawLine(
      Offset(center.dx, center.dy + size.height * 0.3),
      Offset(center.dx, center.dy - size.height * 0.1),
      paint,
    );
    
    // 勺子头
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.height * 0.25),
      size.width * 0.15,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 厨师帽图标绘制器
class ChefIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // 帽子底部
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.2),
        width: size.width * 0.6,
        height: size.height * 0.15,
      ),
      paint,
    );
    
    // 帽子顶部
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - size.height * 0.1),
        width: size.width * 0.5,
        height: size.height * 0.4,
      ),
      0,
      math.pi,
      false,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 计时器图标绘制器
class TimerIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;
    
    // 时钟外圈
    canvas.drawCircle(center, radius, paint);
    
    // 时钟指针
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - radius * 0.6),
      paint,
    );
    
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.4, center.dy),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 菜谱图标绘制器
class RecipeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // 书本外形
    final bookRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.6,
      height: size.height * 0.7,
    );
    
    canvas.drawRect(bookRect, paint);
    
    // 书本内容线条
    for (int i = 0; i < 3; i++) {
      final y = center.dy - size.height * 0.15 + (i * size.height * 0.15);
      canvas.drawLine(
        Offset(center.dx - size.width * 0.2, y),
        Offset(center.dx + size.width * 0.2, y),
        paint..strokeWidth = size.width * 0.04,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 爱心图标绘制器
class HeartIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    final heartPath = Path();
    heartPath.moveTo(center.dx, center.dy + size.height * 0.2);
    
    // 左半心
    heartPath.cubicTo(
      center.dx - size.width * 0.3, center.dy - size.height * 0.1,
      center.dx - size.width * 0.3, center.dy - size.height * 0.3,
      center.dx, center.dy - size.height * 0.15,
    );
    
    // 右半心
    heartPath.cubicTo(
      center.dx + size.width * 0.3, center.dy - size.height * 0.3,
      center.dx + size.width * 0.3, center.dy - size.height * 0.1,
      center.dx, center.dy + size.height * 0.2,
    );
    
    canvas.drawPath(heartPath, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}