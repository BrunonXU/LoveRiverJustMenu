import 'package:flutter/material.dart';

import '../../core/themes/colors.dart';
import '../../core/themes/spacing.dart';

/// 极简卡片组件
/// 严格遵循设计规范：24px圆角，48px内边距，阴影 0 8px 32px rgba(0,0,0,0.08)
class MinimalCard extends StatelessWidget {
  /// 卡片宽度
  final double? width;
  
  /// 卡片高度
  final double? height;
  
  /// 子组件
  final Widget child;
  
  /// 内边距（默认48px）
  final EdgeInsets padding;
  
  /// 外边距
  final EdgeInsets margin;
  
  /// 背景色（自动适配深色模式）
  final Color? backgroundColor;
  
  /// 是否启用阴影
  final bool enableShadow;
  
  /// 自定义阴影
  final List<BoxShadow>? customShadow;
  
  /// 圆角大小（默认24px）
  final double borderRadius;
  
  /// 渐变背景
  final Gradient? gradient;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 长按回调
  final VoidCallback? onLongPress;
  
  /// 悬停效果
  final bool enableHover;
  
  /// 边框
  final Border? border;
  
  const MinimalCard({
    super.key,
    this.width,
    this.height,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl), // 48px
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.enableShadow = true,
    this.customShadow,
    this.borderRadius = AppSpacing.radiusLarge, // 24px
    this.gradient,
    this.onTap,
    this.onLongPress,
    this.enableHover = false,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBackgroundColor = backgroundColor ?? 
        AppColors.getBackgroundColor(isDark);
    
    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: _buildDecoration(isDark, effectiveBackgroundColor),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
    
    // 添加交互效果
    if (onTap != null || onLongPress != null) {
      card = _buildInteractiveCard(card, isDark);
    }
    
    // 添加悬停效果
    if (enableHover) {
      card = _HoverCard(child: card);
    }
    
    return card;
  }
  
  /// 构建装饰器
  BoxDecoration _buildDecoration(bool isDark, Color bgColor) {
    return BoxDecoration(
      color: gradient == null ? bgColor : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: _buildShadow(isDark),
    );
  }
  
  /// 构建阴影
  List<BoxShadow>? _buildShadow(bool isDark) {
    if (!enableShadow) return null;
    
    if (customShadow != null) return customShadow;
    
    return [
      BoxShadow(
        color: AppColors.getShadowColor(isDark),
        blurRadius: AppSpacing.shadowBlurRadius, // 32px
        offset: AppSpacing.shadowOffset, // (0, 8)
        spreadRadius: AppSpacing.shadowSpreadRadius, // 0
      ),
    ];
  }
  
  /// 构建交互式卡片
  Widget _buildInteractiveCard(Widget card, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: AppColors.primary.withOpacity(0.05),
        child: card,
      ),
    );
  }
}

/// 渐变卡片组件
class GradientCard extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Gradient gradient;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool enableShadow;
  
  const GradientCard({
    super.key,
    this.width,
    this.height,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.margin = EdgeInsets.zero,
    required this.gradient,
    this.borderRadius = AppSpacing.radiusLarge,
    this.onTap,
    this.enableShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return MinimalCard(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      gradient: gradient,
      borderRadius: borderRadius,
      onTap: onTap,
      enableShadow: enableShadow,
      child: child,
    );
  }
}

/// 图标卡片组件
class IconCard extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final double iconSize;
  final Gradient? iconGradient;
  
  const IconCard({
    super.key,
    required this.icon,
    this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.iconSize = 60.0,
    this.iconGradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MinimalCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标容器
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: iconGradient ?? AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? Colors.white,
            ),
          ),
          
          if (title != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.getTextPrimaryColor(isDark),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// 悬浮卡片组件
class FloatingCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final VoidCallback? onTap;
  
  const FloatingCard({
    super.key,
    required this.child,
    this.elevation = 8.0,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin = EdgeInsets.zero,
    this.borderRadius = AppSpacing.radiusLarge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MinimalCard(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      customShadow: [
        BoxShadow(
          color: AppColors.getShadowColor(isDark),
          blurRadius: elevation * 4,
          offset: Offset(0, elevation),
          spreadRadius: 0,
        ),
      ],
      child: child,
    );
  }
}

/// 可展开卡片组件
class ExpandableCard extends StatefulWidget {
  final Widget header;
  final Widget content;
  final bool initiallyExpanded;
  final Duration animationDuration;
  final EdgeInsets padding;
  
  const ExpandableCard({
    super.key,
    required this.header,
    required this.content,
    this.initiallyExpanded = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late bool _isExpanded;
  
  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MinimalCard(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _toggleExpanded,
            child: Row(
              children: [
                Expanded(child: widget.header),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: widget.animationDuration,
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ),
          
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: widget.content,
            ),
          ),
        ],
      ),
    );
  }
}

/// 悬停效果组件
class _HoverCard extends StatefulWidget {
  final Widget child;
  
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(_isHovered ? 1.02 : 1.0),
        child: widget.child,
      ),
    );
  }
}

/// 卡片构建器
class MinimalCardBuilder {
  double? _width;
  double? _height;
  EdgeInsets _padding = const EdgeInsets.all(AppSpacing.xl);
  EdgeInsets _margin = EdgeInsets.zero;
  Color? _backgroundColor;
  bool _enableShadow = true;
  double _borderRadius = AppSpacing.radiusLarge;
  Gradient? _gradient;
  VoidCallback? _onTap;
  bool _enableHover = false;
  
  MinimalCardBuilder setSize(double? width, double? height) {
    _width = width;
    _height = height;
    return this;
  }
  
  MinimalCardBuilder setPadding(EdgeInsets padding) {
    _padding = padding;
    return this;
  }
  
  MinimalCardBuilder setMargin(EdgeInsets margin) {
    _margin = margin;
    return this;
  }
  
  MinimalCardBuilder setBackgroundColor(Color color) {
    _backgroundColor = color;
    return this;
  }
  
  MinimalCardBuilder setGradient(Gradient gradient) {
    _gradient = gradient;
    return this;
  }
  
  MinimalCardBuilder setShadow(bool enable) {
    _enableShadow = enable;
    return this;
  }
  
  MinimalCardBuilder setBorderRadius(double radius) {
    _borderRadius = radius;
    return this;
  }
  
  MinimalCardBuilder setOnTap(VoidCallback onTap) {
    _onTap = onTap;
    return this;
  }
  
  MinimalCardBuilder setHover(bool enable) {
    _enableHover = enable;
    return this;
  }
  
  MinimalCard build(Widget child) {
    return MinimalCard(
      width: _width,
      height: _height,
      padding: _padding,
      margin: _margin,
      backgroundColor: _backgroundColor,
      enableShadow: _enableShadow,
      borderRadius: _borderRadius,
      gradient: _gradient,
      onTap: _onTap,
      enableHover: _enableHover,
      child: child,
    );
  }
}