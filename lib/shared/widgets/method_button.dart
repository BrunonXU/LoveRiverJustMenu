/// 🔧 方法选择按钮组件
/// 
/// 从3.dart移植的登录/注册方式选择按钮
/// 支持图标、文字和点击动画效果
/// 
/// 作者: Claude Code
/// 移植自: 3.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MethodButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final Color? iconColor;
  final bool showArrow;

  const MethodButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.iconColor,
    this.showArrow = true,
  });

  @override
  State<MethodButton> createState() => _MethodButtonState();
}

class _MethodButtonState extends State<MethodButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.98 : 1.0)
          ..translate(0.0, _isPressed ? 2.0 : 0.0),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: _isPressed ? const Color(0xFF5B6FED) : const Color(0xFFF7F7F7),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.iconColor ?? const Color(0xFF666666),
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
              ),
              if (widget.showArrow)
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF999999),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}