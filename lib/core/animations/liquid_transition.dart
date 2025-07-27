import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../themes/colors.dart';

/// 液态过渡动画系统
/// 贝塞尔曲线控制，cubic-bezier(0.45,0,0.55,1)，800ms时长
class LiquidTransition extends StatefulWidget {
  final Widget child;
  final Widget? nextChild;
  final Duration duration;
  final Curve curve;
  final LiquidTransitionType type;
  final bool isActive;
  final VoidCallback? onComplete;
  
  const LiquidTransition({
    super.key,
    required this.child,
    this.nextChild,
    this.duration = const Duration(milliseconds: 800),
    this.curve = const Cubic(0.45, 0, 0.55, 1), // 专业贝塞尔曲线
    this.type = LiquidTransitionType.wave,
    this.isActive = false,
    this.onComplete,
  });

  @override
  State<LiquidTransition> createState() => _LiquidTransitionState();
}

class _LiquidTransitionState extends State<LiquidTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _waveAnimation;
  late Animation<double> _morphAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    // 主动画 - 使用专业贝塞尔曲线
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    
    // 波浪动画 - 更快的频率
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    
    // 形变动画 - 弹性效果
    _morphAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }
  
  @override
  void didUpdateWidget(LiquidTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive && !oldWidget.isActive) {
      _startTransition();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reset();
    }
  }
  
  void _startTransition() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipPath(
          clipper: LiquidClipper(
            animation: _animation,
            waveAnimation: _waveAnimation,
            morphAnimation: _morphAnimation,
            transitionType: widget.type,
          ),
          child: Stack(
            children: [
              // 当前内容
              if (_animation.value < 0.5)
                widget.child,
              
              // 下一个内容
              if (_animation.value >= 0.5 && widget.nextChild != null)
                widget.nextChild!,
              
              // 液态效果遮罩
              if (widget.isActive)
                _buildLiquidOverlay(),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildLiquidOverlay() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryLight.withOpacity(0.3 * _animation.value),
                AppColors.primary.withOpacity(0.2 * _animation.value),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 液态裁剪器
class LiquidClipper extends CustomClipper<Path> {
  final Animation<double> animation;
  final Animation<double> waveAnimation;
  final Animation<double> morphAnimation;
  final LiquidTransitionType transitionType;
  
  LiquidClipper({
    required this.animation,
    required this.waveAnimation,
    required this.morphAnimation,
    required this.transitionType,
  });

  @override
  Path getClip(Size size) {
    switch (transitionType) {
      case LiquidTransitionType.wave:
        return _createWavePath(size);
      case LiquidTransitionType.blob:
        return _createBlobPath(size);
      case LiquidTransitionType.ripple:
        return _createRipplePath(size);
      case LiquidTransitionType.morph:
        return _createMorphPath(size);
    }
  }
  
  Path _createWavePath(Size size) {
    final path = Path();
    final progress = animation.value;
    final waveOffset = waveAnimation.value;
    
    // 波浪参数
    final amplitude = 40.0 * (1 - progress); // 振幅随进度减小
    final frequency = 2.0; // 频率
    final baseHeight = size.height * progress; // 基础高度
    
    path.moveTo(0, size.height);
    
    // 创建波浪曲线
    for (double x = 0; x <= size.width; x += 2) {
      final normalizedX = x / size.width;
      final waveValue = math.sin((normalizedX * frequency + waveOffset) * 2 * math.pi);
      final y = baseHeight + (amplitude * waveValue);
      
      path.lineTo(x, size.height - y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    return path;
  }
  
  Path _createBlobPath(Size size) {
    final path = Path();
    final progress = animation.value;
    final morphValue = morphAnimation.value;
    
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    final radius = math.min(size.width, size.height) * 0.5 * progress;
    
    // 创建有机形状的blob
    final points = <Offset>[];
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final variation = 1 + (0.3 * math.sin(angle * 3 + morphValue * 2 * math.pi));
      final x = centerX + radius * variation * math.cos(angle);
      final y = centerY + radius * variation * math.sin(angle);
      points.add(Offset(x, y));
    }
    
    // 使用贝塞尔曲线连接点
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      
      for (int i = 0; i < points.length; i++) {
        final current = points[i];
        final next = points[(i + 1) % points.length];
        final control1 = Offset(
          current.dx + (next.dx - current.dx) * 0.3,
          current.dy + (next.dy - current.dy) * 0.3,
        );
        final control2 = Offset(
          next.dx - (next.dx - current.dx) * 0.3,
          next.dy - (next.dy - current.dy) * 0.3,
        );
        
        path.cubicTo(
          control1.dx, control1.dy,
          control2.dx, control2.dy,
          next.dx, next.dy,
        );
      }
      
      path.close();
    }
    
    return path;
  }
  
  Path _createRipplePath(Size size) {
    final path = Path();
    final progress = animation.value;
    
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) * 0.5;
    final currentRadius = maxRadius * progress;
    
    // 创建多重涟漪效果
    for (int i = 0; i < 3; i++) {
      final rippleProgress = (progress - (i * 0.1)).clamp(0.0, 1.0);
      final rippleRadius = maxRadius * rippleProgress;
      
      if (rippleRadius > 0) {
        path.addOval(Rect.fromCircle(
          center: Offset(centerX, centerY),
          radius: rippleRadius,
        ));
      }
    }
    
    return path;
  }
  
  Path _createMorphPath(Size size) {
    final path = Path();
    final progress = animation.value;
    final morphValue = morphAnimation.value;
    
    // 从矩形变形到圆形
    final cornerRadius = (size.width * 0.5) * morphValue;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * progress);
    
    path.addRRect(RRect.fromRectAndRadius(
      rect,
      Radius.circular(cornerRadius),
    ));
    
    return path;
  }

  @override
  bool shouldReclip(LiquidClipper oldClipper) {
    return animation.value != oldClipper.animation.value ||
           waveAnimation.value != oldClipper.waveAnimation.value ||
           morphAnimation.value != oldClipper.morphAnimation.value;
  }
}

/// 液态过渡页面路由
class LiquidPageRoute<T> extends PageRoute<T> {
  final Widget child;
  final LiquidTransitionType transitionType;
  final Duration transitionDuration;
  
  LiquidPageRoute({
    required this.child,
    this.transitionType = LiquidTransitionType.wave,
    this.transitionDuration = const Duration(milliseconds: 800),
    RouteSettings? settings,
  }) : super(settings: settings);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get animationDuration => transitionDuration;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return LiquidTransitionBuilder(
      animation: animation,
      child: child,
      transitionType: transitionType,
    );
  }
}

/// 液态过渡构建器
class LiquidTransitionBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final LiquidTransitionType transitionType;
  
  const LiquidTransitionBuilder({
    super.key,
    required this.animation,
    required this.child,
    required this.transitionType,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipPath(
          clipper: LiquidClipper(
            animation: animation,
            waveAnimation: animation,
            morphAnimation: animation,
            transitionType: transitionType,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// 液态效果粒子系统
class LiquidParticleSystem extends StatefulWidget {
  final int particleCount;
  final double maxSize;
  final Color color;
  final Duration duration;
  
  const LiquidParticleSystem({
    super.key,
    this.particleCount = 30,
    this.maxSize = 8.0,
    this.color = AppColors.primary,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<LiquidParticleSystem> createState() => _LiquidParticleSystemState();
}

class _LiquidParticleSystemState extends State<LiquidParticleSystem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<LiquidParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    
    _initializeParticles();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _initializeParticles() {
    _particles = List.generate(widget.particleCount, (index) {
      return LiquidParticle(
        position: Offset(
          math.Random().nextDouble(),
          math.Random().nextDouble(),
        ),
        velocity: Offset(
          (math.Random().nextDouble() - 0.5) * 2,
          (math.Random().nextDouble() - 0.5) * 2,
        ),
        size: math.Random().nextDouble() * widget.maxSize,
        life: math.Random().nextDouble(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: LiquidParticlePainter(
            particles: _particles,
            animation: _controller.value,
            color: widget.color,
          ),
          child: child,
        );
      },
    );
  }
}

/// 液态粒子模型
class LiquidParticle {
  Offset position;
  Offset velocity;
  double size;
  double life;
  
  LiquidParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.life,
  });
  
  void update(double dt) {
    position += velocity * dt;
    life -= dt * 0.5;
    
    // 边界反弹
    if (position.dx < 0 || position.dx > 1) {
      velocity = Offset(-velocity.dx, velocity.dy);
    }
    if (position.dy < 0 || position.dy > 1) {
      velocity = Offset(velocity.dx, -velocity.dy);
    }
    
    // 重生粒子
    if (life <= 0) {
      position = Offset(
        math.Random().nextDouble(),
        math.Random().nextDouble(),
      );
      life = 1.0;
    }
  }
}

/// 液态粒子绘制器
class LiquidParticlePainter extends CustomPainter {
  final List<LiquidParticle> particles;
  final double animation;
  final Color color;
  
  LiquidParticlePainter({
    required this.particles,
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      particle.update(0.016); // 60 FPS
      
      final x = particle.position.dx * size.width;
      final y = particle.position.dy * size.height;
      final radius = particle.size * particle.life;
      
      paint.color = color.withOpacity(particle.life * 0.6);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
      
      // 连接相近的粒子
      for (final other in particles) {
        final distance = (particle.position - other.position).distance;
        if (distance < 0.1 && distance > 0) {
          final otherX = other.position.dx * size.width;
          final otherY = other.position.dy * size.height;
          
          paint
            ..color = color.withOpacity(0.3 * particle.life * other.life)
            ..strokeWidth = 1;
          
          canvas.drawLine(Offset(x, y), Offset(otherX, otherY), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(LiquidParticlePainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

/// 液态过渡类型
enum LiquidTransitionType {
  wave,    // 波浪效果
  blob,    // 有机形状
  ripple,  // 涟漪效果
  morph,   // 形变效果
}