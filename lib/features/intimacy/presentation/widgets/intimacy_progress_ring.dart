import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';

/// 🥰 亲密度环形进度指示器
class IntimacyProgressRing extends StatefulWidget {
  final double progress;
  final Color color;
  final double size;
  final double strokeWidth;
  final Widget? child;
  final bool showPercentage;

  const IntimacyProgressRing({
    super.key,
    required this.progress,
    required this.color,
    this.size = 60,
    this.strokeWidth = 6,
    this.child,
    this.showPercentage = false,
  });

  @override
  State<IntimacyProgressRing> createState() => _IntimacyProgressRingState();
}

class _IntimacyProgressRingState extends State<IntimacyProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // 启动动画
    _animationController.forward();
  }

  @override
  void didUpdateWidget(IntimacyProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 进度环
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _ProgressRingPainter(
                    progress: _progressAnimation.value,
                    color: widget.color,
                    strokeWidth: widget.strokeWidth,
                  ),
                );
              },
            ),
          ),
          
          // 中心内容
          if (widget.child != null)
            widget.child!
          else if (widget.showPercentage)
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final percentage = (_progressAnimation.value * 100).round();
                return Text(
                  '$percentage%',
                  style: AppTypography.captionStyle(isDark: false).copyWith(
                    fontWeight: FontWeight.w500,
                    color: widget.color,
                    fontSize: widget.size * 0.2,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// 环形进度画笔
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 背景圆环
    final backgroundPaint = Paint()
      ..color = AppColors.backgroundSecondary
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 进度圆环
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // 绘制进度弧
      const startAngle = -math.pi / 2; // 从顶部开始
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );

      // 在进度端点添加一个小圆点
      if (progress < 1.0) {
        final endAngle = startAngle + sweepAngle;
        final endPoint = Offset(
          center.dx + radius * math.cos(endAngle),
          center.dy + radius * math.sin(endAngle),
        );

        final dotPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.drawCircle(endPoint, strokeWidth / 2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}

/// 🥰 带数值显示的进度环
class IntimacyProgressRingWithValue extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;
  final String value;
  final String? subtitle;

  const IntimacyProgressRingWithValue({
    super.key,
    required this.progress,
    required this.color,
    required this.value,
    this.size = 80,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return IntimacyProgressRing(
      progress: progress,
      color: color,
      size: size,
      strokeWidth: 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTypography.titleMediumStyle(isDark: false).copyWith(
              fontWeight: FontWeight.w500,
              color: color,
              fontSize: size * 0.25,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTypography.captionStyle(isDark: false).copyWith(
                color: AppColors.textSecondary,
                fontSize: size * 0.12,
              ),
            ),
        ],
      ),
    );
  }
}

/// 🥰 脉动效果的进度环
class PulsingIntimacyProgressRing extends StatefulWidget {
  final double progress;
  final Color color;
  final double size;
  final Widget? child;

  const PulsingIntimacyProgressRing({
    super.key,
    required this.progress,
    required this.color,
    this.size = 60,
    this.child,
  });

  @override
  State<PulsingIntimacyProgressRing> createState() => _PulsingIntimacyProgressRingState();
}

class _PulsingIntimacyProgressRingState extends State<PulsingIntimacyProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: IntimacyProgressRing(
            progress: widget.progress,
            color: widget.color.withValues(alpha: _pulseAnimation.value),
            size: widget.size,
            child: widget.child,
          ),
        );
      },
    );
  }
}