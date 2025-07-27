import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../themes/colors.dart';

/// 物理动画引擎
/// 重力9.8，弹性0.6，磁性吸附150px半径，粒子系统20-50个
class PhysicsEngine {
  // 物理常量
  static const double gravity = 9.8;
  static const double elasticity = 0.6;
  static const double magneticRadius = 150.0;
  static const double friction = 0.98;
  static const double airResistance = 0.995;
  
  // 计算重力影响
  static Offset applyGravity(Offset velocity, double deltaTime) {
    return Offset(
      velocity.dx, 
      velocity.dy + (gravity * deltaTime * 100), // 转换为像素/秒
    );
  }
  
  // 计算弹性碰撞
  static Offset applyElasticity(Offset velocity, {bool reverseX = false, bool reverseY = false}) {
    return Offset(
      reverseX ? -velocity.dx * elasticity : velocity.dx,
      reverseY ? -velocity.dy * elasticity : velocity.dy,
    );
  }
  
  // 计算磁性吸附
  static Offset applyMagneticForce(Offset position, Offset targetPosition, Offset velocity) {
    final distance = (targetPosition - position).distance;
    
    if (distance < magneticRadius) {
      final force = (magneticRadius - distance) / magneticRadius;
      final direction = (targetPosition - position) / distance;
      
      // 磁性加速度
      final magneticAcceleration = direction * force * 500;
      
      return velocity + magneticAcceleration * 0.016; // 60 FPS
    }
    
    return velocity;
  }
  
  // 应用摩擦力
  static Offset applyFriction(Offset velocity) {
    return velocity * friction;
  }
  
  // 应用空气阻力
  static Offset applyAirResistance(Offset velocity) {
    return velocity * airResistance;
  }
}

/// 物理粒子
class PhysicsParticle {
  Offset position;
  Offset velocity;
  double mass;
  double radius;
  Color color;
  double life;
  double maxLife;
  bool isAlive;
  
  // 物理属性
  bool affectedByGravity;
  bool affectedByMagnetic;
  bool canCollide;
  
  PhysicsParticle({
    required this.position,
    this.velocity = Offset.zero,
    this.mass = 1.0,
    this.radius = 5.0,
    this.color = AppColors.primary,
    this.maxLife = 5.0,
    this.affectedByGravity = true,
    this.affectedByMagnetic = true,
    this.canCollide = true,
  }) : life = maxLife, isAlive = true;
  
  /// 更新粒子物理状态
  void update(Size bounds, {List<Offset>? magneticPoints, double deltaTime = 0.016}) {
    if (!isAlive) return;
    
    // 应用重力
    if (affectedByGravity) {
      velocity = PhysicsEngine.applyGravity(velocity, deltaTime);
    }
    
    // 应用磁性吸附
    if (affectedByMagnetic && magneticPoints != null) {
      for (final magneticPoint in magneticPoints) {
        velocity = PhysicsEngine.applyMagneticForce(position, magneticPoint, velocity);
      }
    }
    
    // 应用空气阻力和摩擦
    velocity = PhysicsEngine.applyAirResistance(velocity);
    velocity = PhysicsEngine.applyFriction(velocity);
    
    // 更新位置
    position += velocity * deltaTime;
    
    // 边界碰撞检测
    _handleBoundaryCollision(bounds);
    
    // 更新生命周期
    life -= deltaTime;
    if (life <= 0) {
      isAlive = false;
    }
  }
  
  /// 边界碰撞处理
  void _handleBoundaryCollision(Size bounds) {
    if (!canCollide) return;
    
    // 左右边界
    if (position.dx - radius <= 0) {
      position = Offset(radius, position.dy);
      velocity = PhysicsEngine.applyElasticity(velocity, reverseX: true);
      HapticFeedback.selectionClick();
    } else if (position.dx + radius >= bounds.width) {
      position = Offset(bounds.width - radius, position.dy);
      velocity = PhysicsEngine.applyElasticity(velocity, reverseX: true);
      HapticFeedback.selectionClick();
    }
    
    // 上下边界
    if (position.dy - radius <= 0) {
      position = Offset(position.dx, radius);
      velocity = PhysicsEngine.applyElasticity(velocity, reverseY: true);
      HapticFeedback.selectionClick();
    } else if (position.dy + radius >= bounds.height) {
      position = Offset(position.dx, bounds.height - radius);
      velocity = PhysicsEngine.applyElasticity(velocity, reverseY: true);
      HapticFeedback.selectionClick();
    }
  }
  
  /// 粒子间碰撞检测
  bool checkCollision(PhysicsParticle other) {
    if (!canCollide || !other.canCollide) return false;
    
    final distance = (position - other.position).distance;
    return distance < (radius + other.radius);
  }
  
  /// 处理粒子间碰撞
  void handleCollision(PhysicsParticle other) {
    if (!checkCollision(other)) return;
    
    // 分离重叠的粒子
    final direction = (other.position - position).normalized;
    final overlap = (radius + other.radius) - (position - other.position).distance;
    
    position -= direction * (overlap * 0.5);
    other.position += direction * (overlap * 0.5);
    
    // 弹性碰撞计算（简化版）
    final relativeVelocity = velocity - other.velocity;
    final velocityAlongDirection = relativeVelocity.dot(direction);
    
    if (velocityAlongDirection > 0) return; // 粒子已在分离
    
    // 动量守恒
    final restitution = PhysicsEngine.elasticity;
    final impulse = 2 * velocityAlongDirection / (mass + other.mass);
    
    velocity -= direction * (impulse * other.mass * restitution);
    other.velocity += direction * (impulse * mass * restitution);
    
    HapticFeedback.lightImpact();
  }
}

/// 物理粒子系统组件
class PhysicsParticleSystem extends StatefulWidget {
  final int minParticles;
  final int maxParticles;
  final Size? systemSize;
  final List<Offset>? magneticPoints;
  final bool enableGravity;
  final bool enableMagnetic;
  final bool enableCollisions;
  final Function(List<PhysicsParticle>)? onParticleUpdate;
  
  const PhysicsParticleSystem({
    super.key,
    this.minParticles = 20,
    this.maxParticles = 50,
    this.systemSize,
    this.magneticPoints,
    this.enableGravity = true,
    this.enableMagnetic = true,
    this.enableCollisions = true,
    this.onParticleUpdate,
  });

  @override
  State<PhysicsParticleSystem> createState() => _PhysicsParticleSystemState();
}

class _PhysicsParticleSystemState extends State<PhysicsParticleSystem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<PhysicsParticle> _particles = [];
  DateTime _lastFrameTime = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializeParticles();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _initializeController() {
    _controller = AnimationController(
      duration: const Duration(days: 1), // 无限循环
      vsync: this,
    );
    
    _controller.addListener(_updatePhysics);
    _controller.repeat();
  }
  
  void _initializeParticles() {
    final particleCount = widget.minParticles + 
        math.Random().nextInt(widget.maxParticles - widget.minParticles);
    
    _particles = List.generate(particleCount, (index) => _createRandomParticle());
  }
  
  PhysicsParticle _createRandomParticle() {
    final random = math.Random();
    final size = widget.systemSize ?? const Size(400, 600);
    
    return PhysicsParticle(
      position: Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height * 0.3, // 从顶部开始
      ),
      velocity: Offset(
        (random.nextDouble() - 0.5) * 200, // -100 到 100
        random.nextDouble() * 100, // 0 到 100 向下
      ),
      mass: 0.5 + random.nextDouble() * 1.5, // 0.5 到 2.0
      radius: 2 + random.nextDouble() * 8, // 2 到 10
      color: _getRandomColor(),
      maxLife: 3 + random.nextDouble() * 7, // 3 到 10 秒
      affectedByGravity: widget.enableGravity,
      affectedByMagnetic: widget.enableMagnetic,
      canCollide: widget.enableCollisions,
    );
  }
  
  Color _getRandomColor() {
    final colors = [
      AppColors.primary,
      AppColors.primaryLight,
      AppColors.getTimeBasedAccent(),
    ];
    
    return colors[math.Random().nextInt(colors.length)];
  }
  
  void _updatePhysics() {
    final currentTime = DateTime.now();
    final deltaTime = currentTime.difference(_lastFrameTime).inMicroseconds / 1000000.0;
    _lastFrameTime = currentTime;
    
    // 限制 deltaTime 避免大跳跃
    final clampedDeltaTime = math.min(deltaTime, 0.033); // 最大 30 FPS
    
    final size = widget.systemSize ?? const Size(400, 600);
    
    // 更新所有粒子
    for (final particle in _particles) {
      particle.update(
        size,
        magneticPoints: widget.magneticPoints,
        deltaTime: clampedDeltaTime,
      );
    }
    
    // 处理粒子间碰撞
    if (widget.enableCollisions) {
      _handleParticleCollisions();
    }
    
    // 移除死亡粒子并添加新粒子
    _manageParticleLifecycle();
    
    // 通知更新
    widget.onParticleUpdate?.call(_particles);
    
    if (mounted) {
      setState(() {});
    }
  }
  
  void _handleParticleCollisions() {
    for (int i = 0; i < _particles.length; i++) {
      for (int j = i + 1; j < _particles.length; j++) {
        _particles[i].handleCollision(_particles[j]);
      }
    }
  }
  
  void _manageParticleLifecycle() {
    // 移除死亡粒子
    _particles.removeWhere((particle) => !particle.isAlive);
    
    // 添加新粒子保持数量
    while (_particles.length < widget.minParticles) {
      _particles.add(_createRandomParticle());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PhysicsParticlePainter(
        particles: _particles,
        magneticPoints: widget.magneticPoints ?? [],
      ),
      size: widget.systemSize ?? Size.infinite,
    );
  }
}

/// 物理粒子绘制器
class PhysicsParticlePainter extends CustomPainter {
  final List<PhysicsParticle> particles;
  final List<Offset> magneticPoints;
  
  PhysicsParticlePainter({
    required this.particles,
    required this.magneticPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制磁性区域
    _drawMagneticFields(canvas, size);
    
    // 绘制粒子连接线
    _drawParticleConnections(canvas);
    
    // 绘制粒子
    _drawParticles(canvas);
  }
  
  void _drawMagneticFields(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.primary.withOpacity(0.1);
    
    for (final point in magneticPoints) {
      // 绘制磁性影响圈
      canvas.drawCircle(point, PhysicsEngine.magneticRadius, paint);
      
      // 绘制磁性中心点
      paint
        ..style = PaintingStyle.fill
        ..color = AppColors.primary.withOpacity(0.3);
      canvas.drawCircle(point, 5, paint);
      
      paint.style = PaintingStyle.stroke;
    }
  }
  
  void _drawParticleConnections(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final particle1 = particles[i];
        final particle2 = particles[j];
        
        final distance = (particle1.position - particle2.position).distance;
        
        // 只连接足够近的粒子
        if (distance < 80) {
          final opacity = (1 - distance / 80) * 0.3;
          paint.color = AppColors.primary.withOpacity(opacity);
          
          canvas.drawLine(particle1.position, particle2.position, paint);
        }
      }
    }
  }
  
  void _drawParticles(Canvas canvas) {
    for (final particle in particles) {
      if (!particle.isAlive) continue;
      
      final lifeRatio = particle.life / particle.maxLife;
      final alpha = lifeRatio.clamp(0.0, 1.0);
      
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = particle.color.withOpacity(alpha * 0.8);
      
      // 绘制粒子主体
      canvas.drawCircle(particle.position, particle.radius, paint);
      
      // 绘制粒子光晕
      paint
        ..color = particle.color.withOpacity(alpha * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawCircle(particle.position, particle.radius * 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(PhysicsParticlePainter oldDelegate) {
    return particles != oldDelegate.particles ||
           magneticPoints != oldDelegate.magneticPoints;
  }
}

/// 物理动画组件
class PhysicsAnimatedWidget extends StatefulWidget {
  final Widget child;
  final bool enablePhysics;
  final Duration duration;
  final List<Offset>? magneticPoints;
  
  const PhysicsAnimatedWidget({
    super.key,
    required this.child,
    this.enablePhysics = true,
    this.duration = const Duration(seconds: 2),
    this.magneticPoints,
  });

  @override
  State<PhysicsAnimatedWidget> createState() => _PhysicsAnimatedWidgetState();
}

class _PhysicsAnimatedWidgetState extends State<PhysicsAnimatedWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  Offset _position = Offset.zero;
  Offset _velocity = Offset.zero;
  bool _isDragging = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _initializeAnimation() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: const ElasticOutCurve(0.6), // 使用弹性曲线
    );
    
    if (widget.enablePhysics) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: _position,
            child: Transform.scale(
              scale: 1.0 + (_animation.value * 0.1),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
  
  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _controller.stop();
    HapticFeedback.lightImpact();
  }
  
  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    setState(() {
      _position += details.delta;
      _velocity = details.delta / 0.016; // 转换为速度
    });
  }
  
  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    
    // 应用物理效果
    if (widget.enablePhysics) {
      _simulatePhysics();
    }
    
    HapticFeedback.mediumImpact();
  }
  
  void _simulatePhysics() {
    // 启动物理模拟动画
    _controller.reset();
    _controller.forward().then((_) {
      // 物理模拟完成后重置位置
      setState(() {
        _position = Offset.zero;
        _velocity = Offset.zero;
      });
      
      if (widget.enablePhysics) {
        _controller.repeat(reverse: true);
      }
    });
  }
}

/// 扩展方法
extension OffsetExtensions on Offset {
  /// 获取标准化向量
  Offset get normalized {
    final length = distance;
    if (length == 0) return Offset.zero;
    return this / length;
  }
  
  /// 点积运算
  double dot(Offset other) {
    return dx * other.dx + dy * other.dy;
  }
}

/// 弹性曲线
class ElasticOutCurve extends Curve {
  final double elasticity;
  
  const ElasticOutCurve(this.elasticity);
  
  @override
  double transformInternal(double t) {
    final s = elasticity / 4.0;
    return math.pow(2.0, -10 * t) * math.sin((t - s) * (math.pi * 2.0) / elasticity) + 1.0;
  }
}