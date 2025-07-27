import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;

/// 呼吸动画组件
/// 严格遵循设计规范：4s循环，scale 1.0→1.02，赋予界面生命力
class BreathingWidget extends StatefulWidget {
  /// 子组件
  final Widget child;
  
  /// 动画持续时间（默认4秒）
  final Duration duration;
  
  /// 缩放范围（默认1.0-1.02）
  final double scaleRange;
  
  /// 透明度范围（默认0.8-1.0）
  final double opacityRange;
  
  /// 是否启用模糊效果
  final bool enableBlur;
  
  /// 是否自动播放
  final bool autoPlay;
  
  const BreathingWidget({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 4),
    this.scaleRange = 0.02,
    this.opacityRange = 0.2,
    this.enableBlur = false,
    this.autoPlay = true,
  });

  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    if (widget.autoPlay) {
      _startBreathing();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  /// 初始化动画
  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    // 缩放动画 - 1.0 → 1.0+scaleRange
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0 + widget.scaleRange,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // 透明度动画 - (1.0-opacityRange) → 1.0
    _opacityAnimation = Tween<double>(
      begin: 1.0 - widget.opacityRange,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // 模糊动画 - 0px → 0.5px
    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  /// 开始呼吸动画
  void _startBreathing() {
    _controller.repeat(reverse: true);
  }
  
  /// 停止呼吸动画
  void _stopBreathing() {
    _controller.stop();
  }
  
  /// 暂停呼吸动画
  void pauseBreathing() {
    _controller.stop();
  }
  
  /// 恢复呼吸动画
  void resumeBreathing() {
    _startBreathing();
  }
  
  /// 重置动画
  void resetBreathing() {
    _controller.reset();
    if (widget.autoPlay) {
      _startBreathing();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget animatedChild = Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
        
        // 可选的模糊效果
        if (widget.enableBlur) {
          animatedChild = _BlurFilter(
            blur: _blurAnimation.value,
            child: animatedChild,
          );
        }
        
        return animatedChild;
      },
    );
  }
}

/// 多层呼吸动画组件
/// 支持不同层级的呼吸效果叠加
class MultiLayerBreathingWidget extends StatelessWidget {
  final Widget child;
  final List<BreathingConfig> layers;
  
  const MultiLayerBreathingWidget({
    super.key,
    required this.child,
    required this.layers,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;
    
    // 从内到外应用呼吸动画层
    for (int i = layers.length - 1; i >= 0; i--) {
      final config = layers[i];
      result = BreathingWidget(
        duration: config.duration,
        scaleRange: config.scaleRange,
        opacityRange: config.opacityRange,
        enableBlur: config.enableBlur,
        autoPlay: config.autoPlay,
        child: result,
      );
    }
    
    return result;
  }
}

/// 呼吸动画配置
class BreathingConfig {
  final Duration duration;
  final double scaleRange;
  final double opacityRange;
  final bool enableBlur;
  final bool autoPlay;
  
  const BreathingConfig({
    this.duration = const Duration(seconds: 4),
    this.scaleRange = 0.02,
    this.opacityRange = 0.2,
    this.enableBlur = false,
    this.autoPlay = true,
  });
  
  /// 预设配置 - 微妙呼吸
  static const BreathingConfig subtle = BreathingConfig(
    duration: Duration(seconds: 4),
    scaleRange: 0.01,
    opacityRange: 0.1,
  );
  
  /// 预设配置 - 标准呼吸
  static const BreathingConfig standard = BreathingConfig(
    duration: Duration(seconds: 4),
    scaleRange: 0.02,
    opacityRange: 0.2,
  );
  
  /// 预设配置 - 强烈呼吸
  static const BreathingConfig intense = BreathingConfig(
    duration: Duration(seconds: 3),
    scaleRange: 0.05,
    opacityRange: 0.3,
  );
  
  /// 预设配置 - 慢呼吸
  static const BreathingConfig slow = BreathingConfig(
    duration: Duration(seconds: 6),
    scaleRange: 0.02,
    opacityRange: 0.2,
  );
}

/// 脉冲呼吸组件
/// 用于特殊状态（如语音监听）
class PulseBreathingWidget extends StatefulWidget {
  final Widget child;
  final Duration pulseDuration;
  final double pulseScale;
  final bool isActive;
  
  const PulseBreathingWidget({
    super.key,
    required this.child,
    this.pulseDuration = const Duration(seconds: 1),
    this.pulseScale = 0.1,
    this.isActive = true,
  });

  @override
  State<PulseBreathingWidget> createState() => _PulseBreathingWidgetState();
}

class _PulseBreathingWidgetState extends State<PulseBreathingWidget>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.pulseDuration,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0 + widget.pulseScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    if (widget.isActive) {
      _controller.repeat();
    }
  }
  
  @override
  void didUpdateWidget(PulseBreathingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// 模糊滤镜组件
class _BlurFilter extends StatelessWidget {
  final double blur;
  final Widget child;
  
  const _BlurFilter({
    required this.blur,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    if (blur == 0.0) return child;
    
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: child,
    );
  }
}