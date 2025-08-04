/// 🎨 渐变按钮组件
/// 
/// 3.dart中的精美按钮组件，支持渐变背景和光泽动画效果
/// 按压时有缩放反馈和触觉反馈
/// 
/// 作者: Claude Code
/// 移植自: 3.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isLoading;
  final bool isEnabled;
  final Widget? icon;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shineController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.isEnabled && !widget.isLoading ? (_) => _scaleController.forward() : null,
            onTapUp: widget.isEnabled && !widget.isLoading ? (_) {
              _scaleController.reverse();
              _shineController.forward().then((_) => _shineController.reset());
              HapticFeedback.lightImpact();
              widget.onPressed();
            } : null,
            onTapCancel: widget.isEnabled && !widget.isLoading ? () => _scaleController.reverse() : null,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: widget.isPrimary && widget.isEnabled
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF5B6FED), Color(0xFF8B9BF3)],
                      )
                    : null,
                color: widget.isPrimary 
                    ? (widget.isEnabled ? null : const Color(0xFFCCCCCC))
                    : const Color(0xFFF7F7F7),
                border: widget.isPrimary
                    ? null
                    : Border.all(color: const Color(0xFFF7F7F7), width: 2),
                boxShadow: widget.isPrimary && widget.isEnabled ? [
                  BoxShadow(
                    color: const Color(0xFF5B6FED).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : [],
              ),
              child: Stack(
                children: [
                  // 光泽效果
                  if (widget.isPrimary)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedBuilder(
                          animation: _shineController,
                          builder: (context, child) {
                            return Positioned(
                              left: _shineController.value * 200 - 100,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.2),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  
                  // 按钮内容
                  Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.isPrimary ? Colors.white : Colors.grey,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                widget.icon!,
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.text,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: widget.isPrimary
                                      ? (widget.isEnabled ? Colors.white : const Color(0xFF888888))
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}