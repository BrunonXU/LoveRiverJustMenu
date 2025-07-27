import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 爱心食谱动画系统
/// 提供呼吸动画、液态过渡、磁性吸附、粒子系统等核心动画
class AnimationSystem {
  /// 呼吸动画 - 核心设计元素（4s循环）
  static Widget breathingWidget({
    required Widget child,
    Duration duration = const Duration(seconds: 4),
    double scaleRange = 0.02, // 默认1.0 -> 1.02
  }) {
    return _BreathingWidget(
      duration: duration,
      scaleRange: scaleRange,
      child: child,
    );
  }
  
  /// 液态过渡动画 - 800ms贝塞尔曲线
  static Widget liquidTransition({
    required Widget child,
    required Animation<double> animation,
    Curve curve = const Cubic(0.45, 0, 0.55, 1), // cubic-bezier(0.45,0,0.55,1)
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return ClipPath(
          clipper: _LiquidClipper(animation.value),
          child: child,
        );
      },
    );
  }
  
  /// 磁性吸附效果 - 150px半径
  static Widget magneticField({
    required Widget child,
    required Offset targetPosition,
    double strength = 100,
    double radius = 150, // 设计规范：150px磁性半径
  }) {
    return _MagneticWidget(
      targetPosition: targetPosition,
      strength: strength,
      radius: radius,
      child: child,
    );
  }
  
  /// 粒子系统 - 20-50个粒子
  static Widget particleSystem({
    required Widget child,
    required List<Particle> particles,
  }) {
    return Stack(
      children: [
        child,
        ..._buildParticles(particles),
      ],
    );
  }
  
  /// 物理动画 - 重力9.8，弹性0.6
  static Widget physicsAnimation({
    required Widget child,
    required AnimationController controller,
    double gravity = 9.8,
    double elasticity = 0.6,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final progress = controller.value;
        final bounce = math.sin(progress * math.pi * 2) * elasticity;
        
        return Transform.translate(
          offset: Offset(0, bounce * gravity),
          child: child,
        );
      },
    );
  }
  
  /// 构建粒子组件
  static List<Widget> _buildParticles(List<Particle> particles) {
    return particles.map((particle) {
      return AnimatedPositioned(
        duration: particle.lifespan,
        left: particle.position.dx,
        top: particle.position.dy,
        child: AnimatedOpacity(
          duration: particle.lifespan,
          opacity: particle.opacity,
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              color: particle.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }).toList();
  }
  
  /// 生成粒子系统（20-50个粒子）
  static List<Particle> generateParticles({
    required Size containerSize,
    int count = 30,
    Duration lifespan = const Duration(seconds: 2),
  }) {
    final particles = <Particle>[];
    final random = math.Random();
    
    for (int i = 0; i < count; i++) {
      particles.add(
        Particle(
          position: Offset(
            random.nextDouble() * containerSize.width,
            random.nextDouble() * containerSize.height,
          ),
          size: 2.0 + random.nextDouble() * 4.0,
          color: Colors.white.withOpacity(0.3 + random.nextDouble() * 0.4),
          lifespan: lifespan,
          opacity: 0.3 + random.nextDouble() * 0.7,
        ),
      );
    }
    
    return particles;
  }
}

/// 呼吸动画组件 - 严格按设计规范实现
class _BreathingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scaleRange;
  
  const _BreathingWidget({
    required this.child,
    required this.duration,
    required this.scaleRange,
  });

  @override
  State<_BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<_BreathingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    
    // 缩放动画：1.0 -> 1.0 + scaleRange
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0 + widget.scaleRange,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // 透明度动画：轻微变化
    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// 液态裁剪器 - 贝塞尔曲线实现
class _LiquidClipper extends CustomClipper<Path> {
  final double progress;
  
  _LiquidClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveHeight = 30.0 * (1 - progress);
    
    path.moveTo(0, size.height);
    
    // 创建波浪效果 - 使用贝塞尔曲线
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * (1 - progress) +
          math.sin((x / size.width) * 2 * math.pi) * waveHeight;
      
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(_LiquidClipper oldClipper) => progress != oldClipper.progress;
}

/// 磁性吸附组件 - 150px半径
class _MagneticWidget extends StatefulWidget {
  final Widget child;
  final Offset targetPosition;
  final double strength;
  final double radius;
  
  const _MagneticWidget({
    required this.child,
    required this.targetPosition,
    required this.strength,
    required this.radius,
  });

  @override
  State<_MagneticWidget> createState() => _MagneticWidgetState();
}

class _MagneticWidgetState extends State<_MagneticWidget> {
  Offset _currentPosition = Offset.zero;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final distance = (details.localPosition - widget.targetPosition).distance;
        
        if (distance < widget.radius) {
          // 磁性吸附力计算
          final force = 1 - (distance / widget.radius);
          final deltaX = (widget.targetPosition.dx - details.localPosition.dx) * force * 0.2;
          final deltaY = (widget.targetPosition.dy - details.localPosition.dy) * force * 0.2;
          
          setState(() {
            _currentPosition = Offset(deltaX, deltaY);
          });
        } else {
          setState(() {
            _currentPosition = Offset.zero;
          });
        }
      },
      onPanEnd: (_) {
        setState(() {
          _currentPosition = Offset.zero;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(
          _currentPosition.dx,
          _currentPosition.dy,
          0,
        ),
        child: widget.child,
      ),
    );
  }
}

/// 粒子数据模型
class Particle {
  final Offset position;
  final double size;
  final Color color;
  final Duration lifespan;
  final double opacity;
  
  const Particle({
    required this.position,
    required this.size,
    required this.color,
    required this.lifespan,
    this.opacity = 1.0,
  });
}