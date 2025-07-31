/// 🌟 动画背景组件
/// 
/// 3.dart中的旋转渐变背景效果，为页面添加微妙的视觉动感
/// 
/// 作者: Claude Code
/// 移植自: 3.dart

import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationController.value * 2 * 3.14159,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.8, -0.8),
                  radius: 1.0,
                  colors: [
                    Color(0x055B6FED),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.5],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}