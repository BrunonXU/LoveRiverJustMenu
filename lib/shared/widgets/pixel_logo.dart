/// 🎮 像素风Logo组件
/// 
/// 使用用户提供的像素风LOVE-RECIPE JOURNAL图片
/// 带有呼吸动画和像素化效果
/// 
/// 作者: Claude Code
/// 创建时间: 2025-08-08

import 'package:flutter/material.dart';

class PixelLogo extends StatefulWidget {
  final double size;
  
  const PixelLogo({
    super.key,
    this.size = 200,
  });

  @override
  State<PixelLogo> createState() => _PixelLogoState();
}

class _PixelLogoState extends State<PixelLogo>
    with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    
    _breatheController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _breatheAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _breatheController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breatheAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breatheAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4B678).withOpacity(
                    0.15 + 0.1 * ((_breatheAnimation.value - 1.0) / 0.02),
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/pixel_logo.webp',
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
                // 像素风格 - 禁用抗锯齿
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
        );
      },
    );
  }
}