import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../themes/colors.dart';

/// 圣诞雪天特效系统
/// 营造浪漫的雪花飘落效果和点击特效
class ChristmasSnowEffect extends StatefulWidget {
  final Widget child;
  final bool enableClickEffect;
  final int snowflakeCount;
  final Color clickEffectColor;
  
  const ChristmasSnowEffect({
    super.key,
    required this.child,
    this.enableClickEffect = true,
    this.snowflakeCount = 50,
    this.clickEffectColor = const Color(0xFF00BFFF), // 海蓝色默认值
  });

  @override
  State<ChristmasSnowEffect> createState() => _ChristmasSnowEffectState();
}

class _ChristmasSnowEffectState extends State<ChristmasSnowEffect>
    with TickerProviderStateMixin {
  late AnimationController _snowController;
  late List<Snowflake> _snowflakes;
  List<ClickEffect> _clickEffects = [];
  
  @override
  void initState() {
    super.initState();
    _initializeSnowAnimation();
    _generateSnowflakes();
  }

  @override
  void dispose() {
    _snowController.dispose();
    super.dispose();
  }
  
  void _initializeSnowAnimation() {
    _snowController = AnimationController(
      duration: const Duration(days: 1), // 无限循环
      vsync: this,
    );
    
    _snowController.addListener(_updateSnow);
    _snowController.repeat();
  }
  
  void _generateSnowflakes() {
    _snowflakes = List.generate(widget.snowflakeCount, (index) {
      return Snowflake(

      
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble() * -1, // 从屏幕上方开始
        size: 2 + math.Random().nextDouble() * 6, // 2-8px
        speed: 0.1 + math.Random().nextDouble() * 1.5/2, // 不同速度
        opacity: 0.3 + math.Random().nextDouble() * 0.7, // 不同透明度
        drift: (math.Random().nextDouble() - 0.5) * 0.5, // 左右飘动
        rotation: math.Random().nextDouble() * 2 * math.pi,
        rotationSpeed: (math.Random().nextDouble() - 0.5) * 1,
      );
    });
  }
  
  void _updateSnow() {
    if (!mounted) return;
    
    setState(() {
      // 更新雪花位置
      for (final snowflake in _snowflakes) {
        snowflake.update();
        
        // 重置超出屏幕的雪花
        if (snowflake.y > 1.2) {
          snowflake.reset();
        }
      }
      
      // 更新点击特效
      _clickEffects.removeWhere((effect) => !effect.isAlive);
      for (final effect in _clickEffects) {
        effect.update();
      }
    });
  }
  
  void _addClickEffect(Offset position, Size screenSize) {
    if (!widget.enableClickEffect) return;
    
    HapticFeedback.lightImpact();
    
    // 添加点击位置的雪花爆炸效果
    final normalizedX = position.dx / screenSize.width;
    final normalizedY = position.dy / screenSize.height;
    
    setState(() {
      _clickEffects.add(ClickEffect(
        x: normalizedX,
        y: normalizedY,
        maxRadius: 18 + math.Random().nextDouble() * 10,
        duration: 1.5 + math.Random().nextDouble() * 0.5,
      ));
      
      // 生成额外的小雪花
      for (int i = 0; i < 8; i++) {
        _snowflakes.add(Snowflake(
          x: normalizedX + (math.Random().nextDouble() - 0.5) * 0.2,
          y: normalizedY + (math.Random().nextDouble() - 0.5) * 0.1,
          size: 1 + math.Random().nextDouble() * 3,
          speed: 0.1 + math.Random().nextDouble() * 2,
          opacity: 0.8 + math.Random().nextDouble() * 0.2,
          drift: (math.Random().nextDouble() - 0.5) * 1.0,
          rotation: math.Random().nextDouble() * 2 * math.pi,
          rotationSpeed: (math.Random().nextDouble() - 0.5) * 0.2,
          lifespan: 3.0, // 临时雪花，3秒后消失
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 只处理点击，不拦截拖拽手势
      onTapDown: (details) {
        _addClickEffect(details.localPosition, MediaQuery.of(context).size);
      },
      // 关键：不处理拖拽事件，让它们传递给下层
      behavior: HitTestBehavior.deferToChild,
      child: Stack(
        children: [
          // 圣诞背景渐变
          Container(
            decoration: BoxDecoration(
              gradient: _getChristmasGradient(),
            ),
          ),
          
          // 雪花层
          CustomPaint(
            painter: SnowPainter(
              snowflakes: _snowflakes,
              clickEffects: _clickEffects,
              clickEffectColor: widget.clickEffectColor,
            ),
            size: Size.infinite,
          ),
          
          // 原始内容
          widget.child,
        ],
      ),
    );
  }
  
  /// 获取圣诞主题渐变背景
  LinearGradient _getChristmasGradient() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 12) {
      // 早晨 - 温暖的金色圣诞
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFF8E7), // 暖白
          Color(0xFFFFF0DC), // 淡金
          Color(0xFFFAEBD7), // 古董白
        ],
      );
    } else if (hour >= 12 && hour < 17) {
      // 午后 - 明亮圣诞红
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFAF5), // 雪白
          Color(0xFFFFF5F0), // 淡粉
          Color(0xFFFFF0F5), // 薰衣草红
        ],
      );
    } else if (hour >= 17 && hour < 22) {
      // 晚霞 - 浪漫圣诞紫
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF8F8FF), // 幽灵白
          Color(0xFFF0F8FF), // 爱丽丝蓝
          Color(0xFFE6E6FA), // 薰衣草
        ],
      );
    } else {
      // 夜晚 - 神秘圣诞蓝
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0F1419), // 深夜蓝
          Color(0xFF1A1F2E), // 午夜蓝
          Color(0xFF2C3E50), // 湿板岩灰
        ],
      );
    }
  }
}

/// 雪花模型
class Snowflake {
  double x; // 0-1 normalized
  double y; // 0-1 normalized  
  double size;
  double speed;
  double opacity;
  double drift; // 左右飘动
  double rotation;
  double rotationSpeed;
  double? lifespan; // 生命周期（可选）
  double _life; // 当前生命值
  
  Snowflake({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.drift,
    required this.rotation,
    required this.rotationSpeed,
    this.lifespan,
  }) : _life = lifespan ?? double.infinity;
  
  void update() {
    // 更新位置
    y += speed * 0.01; // 向下飘落
    x += drift * 0.005; // 左右飘动
    rotation += rotationSpeed;
    
    // 边界处理
    if (x < -0.1) x = 1.1;
    if (x > 1.1) x = -0.1;
    
    // 生命周期处理
    if (lifespan != null) {
      _life -= 0.016; // 60 FPS
      if (_life <= 0) {
        opacity = 0; // 渐隐
      } else {
        opacity = math.min(opacity, _life / lifespan!);
      }
    }
  }
  
  void reset() {
    x = math.Random().nextDouble();
    y = -0.1 - math.Random().nextDouble() * 0.5;
    size = 2 + math.Random().nextDouble() * 6;
    speed = 0.5 + math.Random().nextDouble() * 1.5;
    opacity = 0.3 + math.Random().nextDouble() * 0.7;
    drift = (math.Random().nextDouble() - 0.5) * 0.5;
    rotation = math.Random().nextDouble() * 2 * math.pi;
    rotationSpeed = (math.Random().nextDouble() - 0.5) * 0.1;
    
    if (lifespan != null) {
      _life = lifespan!;
    }
  }
  
  bool get isAlive => lifespan == null || _life > 0;
}

/// 点击特效模型
class ClickEffect {
  double x;
  double y;
  double currentRadius;
  double maxRadius;
  double opacity;
  double duration;
  double _elapsed;
  
  ClickEffect({
    required this.x,
    required this.y,
    required this.maxRadius,
    required this.duration,
  }) : currentRadius = 0,
       opacity = 1.0,
       _elapsed = 0;
  
  void update() {
    _elapsed += 0.016; // 60 FPS
    
    final progress = _elapsed / duration;
    if (progress >= 1.0) {
      opacity = 0;
      return;
    }
    
    // 扩散动画（easeOut）
    currentRadius = maxRadius * (1 - math.pow(1 - progress, 3));
    
    // 渐隐动画
    opacity = 1.0 - progress;
  }
  
  bool get isAlive => opacity > 0;
}

/// 雪花绘制器
class SnowPainter extends CustomPainter {
  final List<Snowflake> snowflakes;
  final List<ClickEffect> clickEffects;
  final Color clickEffectColor;
  
  SnowPainter({
    required this.snowflakes,
    required this.clickEffects,
    required this.clickEffectColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制雪花
    _drawSnowflakes(canvas, size);
    
    // 绘制点击特效
    _drawClickEffects(canvas, size);
  }
  
  void _drawSnowflakes(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (final snowflake in snowflakes) {
      if (!snowflake.isAlive) continue;
      
      final x = snowflake.x * size.width;
      final y = snowflake.y * size.height;
      
      paint.color = Colors.white.withOpacity(snowflake.opacity);
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(snowflake.rotation);
      
      // 绘制六角形雪花
      _drawSnowflakeShape(canvas, snowflake.size, paint);
      
      canvas.restore();
    }
  }
  
  void _drawSnowflakeShape(Canvas canvas, double size, Paint paint) {
    final path = Path();
    
    // 简化的雪花形状 - 六个点的星形
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final x = math.cos(angle) * size;
      final y = math.sin(angle) * size;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // 添加内部点
      final innerAngle = ((i * 60) + 30) * math.pi / 180;
      final innerX = math.cos(innerAngle) * size * 0.5;
      final innerY = math.sin(innerAngle) * size * 0.5;
      path.lineTo(innerX, innerY);
    }
    
    path.close();
    canvas.drawPath(path, paint);
    
    // 添加中心点
    canvas.drawCircle(Offset.zero, size * 0.2, paint);
  }
  
  void _drawClickEffects(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    for (final effect in clickEffects) {
      if (!effect.isAlive) continue;
      
      final center = Offset(
        effect.x * size.width,
        effect.y * size.height,
      );
      
      // 外圈扩散 - 使用海蓝色
      paint.color = clickEffectColor.withOpacity(effect.opacity * 0.8);
      canvas.drawCircle(center, effect.currentRadius, paint);
      
      // 内圈填充 - 使用稍透明的海蓝色
      paint
        ..style = PaintingStyle.fill
        ..color = clickEffectColor.withOpacity(effect.opacity * 0.3);
      canvas.drawCircle(center, effect.currentRadius * 0.6, paint);
      
      // 恢复描边样式
      paint.style = PaintingStyle.stroke;
      
      // 绘制雪花粒子
      _drawClickSnowflakes(canvas, center, effect);
    }
  }
  
  void _drawClickSnowflakes(Canvas canvas, Offset center, ClickEffect effect) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = clickEffectColor.withOpacity(effect.opacity * 0.9); // 点击雪花也用海蓝色
    
    // 在点击位置周围绘制小雪花
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final distance = effect.currentRadius * 0.8;
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;
      
      canvas.drawCircle(
        Offset(x, y),
        1 + effect.opacity * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SnowPainter oldDelegate) {
    return snowflakes != oldDelegate.snowflakes ||
           clickEffects != oldDelegate.clickEffects ||
           clickEffectColor != oldDelegate.clickEffectColor;
  }
}