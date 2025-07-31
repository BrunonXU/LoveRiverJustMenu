/// 🎨 自定义文本输入框组件
/// 
/// 3.dart中的精美输入框组件，支持聚焦动画和错误状态显示
/// 聚焦时有上浮动画和阴影效果
/// 
/// 作者: Claude Code
/// 移植自: 3.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final Function(String)? onSubmitted;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
    this.onSubmitted,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()
            ..translate(0.0, _isFocused ? -2.0 : 0.0),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: widget.errorText != null
                    ? const Color(0xFFF56565)
                    : _isFocused
                        ? const Color(0xFF5B6FED)
                        : const Color(0xFFF7F7F7),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: const Color(0xFF5B6FED).withOpacity(0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: widget.prefixIcon,
                  ),
                ],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    keyboardType: widget.keyboardType,
                    inputFormatters: widget.inputFormatters,
                    obscureText: widget.obscureText,
                    onSubmitted: widget.onSubmitted,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: const TextStyle(
                        color: Color(0xFF999999),
                        fontWeight: FontWeight.w300,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: widget.prefixIcon != null ? 8 : 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                if (widget.suffixIcon != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 16),
                    child: widget.suffixIcon,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFF56565),
              ),
            ),
          ),
      ],
    );
  }
}