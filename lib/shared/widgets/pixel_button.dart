/// 🎮 像素风按钮组件
/// 
/// 专为像素风主题设计的按钮组件
/// 具有8位风格的外观和按下效果
/// 
/// 作者: Claude Code
/// 创建时间: 2025-08-08

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final double width;
  final double height;
  
  const PixelButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.width = double.infinity,
    this.height = 48,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                // 像素风边框效果
                border: Border.all(
                  color: widget.isPrimary 
                    ? const Color(0xFF2D4A3E)
                    : const Color(0xFF6B4423),
                  width: 2,
                ),
                // 8位游戏风格颜色
                color: _isPressed 
                  ? (widget.isPrimary 
                      ? const Color(0xFF4A6B3A).withOpacity(0.8)
                      : const Color(0xFF8B6F47).withOpacity(0.8))
                  : (widget.isPrimary 
                      ? const Color(0xFF4A6B3A)
                      : const Color(0xFF8B6F47)),
                // 像素风不使用圆角
                borderRadius: BorderRadius.zero,
                // 像素阴影效果
                boxShadow: _isPressed 
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(2, 2),
                        blurRadius: 0, // 像素风格无模糊
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 12,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}