import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 平台自适应工具类
/// 为Web端提供鼠标悬停、键盘导航、响应式布局支持
class PlatformAdaptive {
  /// 是否为Web平台
  static bool get isWeb => kIsWeb;
  
  /// 是否为移动平台
  static bool get isMobile => !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || 
                                          defaultTargetPlatform == TargetPlatform.android);
  
  /// 是否为桌面平台
  static bool get isDesktop => !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || 
                                           defaultTargetPlatform == TargetPlatform.macOS || 
                                           defaultTargetPlatform == TargetPlatform.linux);
  
  /// 获取设备类型
  static DeviceType getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      return DeviceType.phone;
    } else if (screenWidth < 1200) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  /// 获取响应式列数
  static int getResponsiveColumns(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.phone:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
    }
  }
  
  /// 获取响应式边距
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.phone:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(32);
      case DeviceType.desktop:
        return const EdgeInsets.all(48);
    }
  }
  
  /// 设置Web端鼠标样式
  static SystemMouseCursor getMouseCursor(bool isHovering) {
    if (!isWeb) return SystemMouseCursors.basic;
    return isHovering ? SystemMouseCursors.click : SystemMouseCursors.basic;
  }
}

/// 设备类型枚举
enum DeviceType {
  phone,
  tablet,
  desktop,
}

/// Web端自适应包装器
class WebAdaptiveWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onHover;
  final bool enableHover;
  final bool enableKeyboard;
  
  const WebAdaptiveWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.onHover,
    this.enableHover = true,
    this.enableKeyboard = true,
  });

  @override
  State<WebAdaptiveWrapper> createState() => _WebAdaptiveWrapperState();
}

class _WebAdaptiveWrapperState extends State<WebAdaptiveWrapper> {
  bool _isHovering = false;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }
  
  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }
  
  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }
  
  void _handleKeyEvent(KeyEvent event) {
    if (!widget.enableKeyboard || !PlatformAdaptive.isWeb) return;
    
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        widget.onTap?.call();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    Widget result = widget.child;
    
    // Web端悬停效果
    if (PlatformAdaptive.isWeb && widget.enableHover) {
      result = MouseRegion(
        cursor: PlatformAdaptive.getMouseCursor(_isHovering),
        onEnter: (_) {
          setState(() => _isHovering = true);
          widget.onHover?.call();
        },
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isHovering ? 1.02 : 1.0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isHovering ? 0.9 : 1.0,
            child: result,
          ),
        ),
      );
    }
    
    // Web端键盘导航
    if (PlatformAdaptive.isWeb && widget.enableKeyboard) {
      result = KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
            widget.onTap?.call();
          },
          child: Container(
            decoration: BoxDecoration(
              border: _isFocused 
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: result,
          ),
        ),
      );
    } else if (widget.onTap != null) {
      result = GestureDetector(
        onTap: widget.onTap,
        child: result,
      );
    }
    
    return result;
  }
}

/// 响应式布局构建器
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, DeviceType) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = PlatformAdaptive.getDeviceType(context);
        return builder(context, deviceType);
      },
    );
  }
}

/// 响应式网格
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsets padding;
  
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final columns = PlatformAdaptive.getResponsiveColumns(context);
    
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - (columns - 1) * spacing) / columns;
          
          return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: children.map((child) {
              return SizedBox(
                width: itemWidth,
                child: child,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

/// Web端滚动行为
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

/// 平台自适应图标按钮
class AdaptiveIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double size;
  
  const AdaptiveIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(icon, size: size),
      color: color,
      onPressed: onPressed,
      tooltip: tooltip,
    );
    
    if (PlatformAdaptive.isWeb) {
      return WebAdaptiveWrapper(
        onTap: onPressed,
        child: button,
      );
    }
    
    return button;
  }
}

/// 自适应手势检测器
class AdaptiveGestureDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final GestureDragUpdateCallback? onVerticalDragUpdate;
  final GestureDragEndCallback? onVerticalDragEnd;
  final GestureDragUpdateCallback? onHorizontalDragUpdate;
  final GestureDragEndCallback? onHorizontalDragEnd;
  
  const AdaptiveGestureDetector({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    // Web端使用点击而非滑动
    if (PlatformAdaptive.isWeb) {
      return WebAdaptiveWrapper(
        onTap: onTap,
        child: child,
      );
    }
    
    // 移动端使用完整手势
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      child: child,
    );
  }
}