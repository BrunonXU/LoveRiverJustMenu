/// 💖 呼吸Logo组件
/// 
/// 从3.dart移植的精美Logo组件，具有呼吸动画和光泽效果
/// 支持自定义大小和渐变色彩
/// 
/// 作者: Claude Code
/// 移植自: 3.dart

import 'package:flutter/material.dart';

class BreathingLogo extends StatefulWidget {
  final double size;
  final String emoji;
  final List<Color> gradientColors;
  
  const BreathingLogo({
    super.key,
    this.size = 80,
    this.emoji = '💕',
    this.gradientColors = const [Color(0xFF5B6FED), Color(0xFF8B9BF3)],
  });

  @override
  State<BreathingLogo> createState() => _BreathingLogoState();
}

class _BreathingLogoState extends State<BreathingLogo>
    with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _shineController;
  late Animation<double> _breatheAnimation;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    
    _breatheController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _shineController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _breatheAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breatheController,
      curve: Curves.easeInOut,
    ));
    
    _shineAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shineController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breatheAnimation, _shineAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _breatheAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.size * 0.25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.gradientColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors.first.withOpacity(
                    0.15 + 0.1 * ((_breatheAnimation.value - 1.0) / 0.05),
                  ),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    widget.emoji,
                    style: TextStyle(fontSize: widget.size * 0.4),
                  ),
                ),
                // 光泽效果
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.size * 0.25),
                    child: Stack(
                      children: [
                        AnimatedBuilder(
                          animation: _shineAnimation,
                          builder: (context, child) {
                            return Positioned(
                              left: _shineAnimation.value * (widget.size * 1.5) - (widget.size * 0.75),
                              top: -widget.size * 0.5,
                              child: Transform.rotate(
                                angle: 0.785398, // 45度
                                child: Container(
                                  width: widget.size * 0.5,
                                  height: widget.size * 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.2),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}