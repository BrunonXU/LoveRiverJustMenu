import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../performance/frame_budget_manager.dart';

/// 🚀 超轻量级动画系统
/// 专为120FPS设计，最小化性能开销
class LightweightAnimationController {
  static LightweightAnimationController? _instance;
  static LightweightAnimationController get instance => _instance ??= LightweightAnimationController._();
  
  LightweightAnimationController._();
  
  late Ticker _ticker;
  bool _isRunning = false;
  int _startTime = 0;
  
  final Map<String, LightweightAnimation> _animations = {};
  
  /// 获取动画实例（只读）
  LightweightAnimation? getAnimation(String id) => _animations[id];
  
  /// 初始化动画系统
  void initialize(TickerProvider vsync) {
    _ticker = vsync.createTicker(_onTick);
    FrameBudgetManager.instance.setTargetFps(120); // 设置120FPS目标
  }
  
  /// 添加动画
  void addAnimation(String id, LightweightAnimation animation) {
    _animations[id] = animation;
    if (!_isRunning) {
      _start();
    }
  }
  
  /// 移除动画
  void removeAnimation(String id) {
    _animations.remove(id);
    if (_animations.isEmpty) {
      _stop();
    }
  }
  
  /// 开始动画循环
  void _start() {
    if (_isRunning) return;
    _isRunning = true;
    _startTime = DateTime.now().millisecondsSinceEpoch;
    _ticker.start();
  }
  
  /// 停止动画循环
  void _stop() {
    if (!_isRunning) return;
    _isRunning = false;
    _ticker.stop();
  }
  
  /// 动画tick回调
  void _onTick(Duration elapsed) {
    // 检查帧预算
    if (!FrameBudgetManager.instance.hasFrameBudget()) {
      // 如果当前帧预算不足，跳过这次更新
      return;
    }
    
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    
    // 更新所有活跃动画
    final toRemove = <String>[];
    for (final entry in _animations.entries) {
      final animation = entry.value;
      if (!animation.update(currentTime)) {
        toRemove.add(entry.key);
      }
    }
    
    // 清理完成的动画
    for (final id in toRemove) {
      _animations.remove(id);
    }
    
    // 如果没有动画了，停止ticker
    if (_animations.isEmpty) {
      _stop();
    }
  }
  
  /// 销毁动画系统
  void dispose() {
    _ticker.dispose();
    _animations.clear();
  }
}

/// 轻量级动画接口
abstract class LightweightAnimation {
  /// 更新动画状态
  /// 返回false表示动画已完成
  bool update(int currentTime);
}

/// 轻量级缩放动画
class LightweightScaleAnimation extends LightweightAnimation {
  final double fromScale;
  final double toScale;
  final int duration;
  final int startTime;
  final VoidCallback? onUpdate;
  
  double _currentScale;
  
  LightweightScaleAnimation({
    required this.fromScale,
    required this.toScale,
    required this.duration,
    required this.startTime,
    this.onUpdate,
  }) : _currentScale = fromScale;
  
  double get currentScale => _currentScale;
  
  @override
  bool update(int currentTime) {
    final elapsed = currentTime - startTime;
    if (elapsed >= duration) {
      _currentScale = toScale;
      onUpdate?.call();
      return false; // 动画完成
    }
    
    final progress = elapsed / duration;
    // 使用简单的easeInOut曲线
    final easedProgress = progress < 0.5 
        ? 2 * progress * progress 
        : 1 - 2 * (1 - progress) * (1 - progress);
    
    _currentScale = fromScale + (toScale - fromScale) * easedProgress;
    onUpdate?.call();
    return true; // 动画继续
  }
}

/// 超轻量级呼吸Widget
/// 使用最小化的Transform操作
class UltraLightBreathingWidget extends StatefulWidget {
  final Widget child;
  final double scaleRange;
  final int period; // 毫秒
  
  const UltraLightBreathingWidget({
    super.key,
    required this.child,
    this.scaleRange = 0.02,
    this.period = 4000,
  });

  @override
  State<UltraLightBreathingWidget> createState() => _UltraLightBreathingWidgetState();
}

class _UltraLightBreathingWidgetState extends State<UltraLightBreathingWidget>
    with SingleTickerProviderStateMixin {
  
  double _scale = 1.0;
  String? _animationId;
  
  @override
  void initState() {
    super.initState();
    _startAnimation();
  }
  
  void _startAnimation() {
    if (!mounted) return;
    
    _animationId = 'breathing_${DateTime.now().millisecondsSinceEpoch}';
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    
    final animation = LightweightScaleAnimation(
      fromScale: 1.0,
      toScale: 1.0 + widget.scaleRange,
      duration: widget.period ~/ 2,
      startTime: currentTime,
      onUpdate: () {
        if (mounted) {
          setState(() {
            final anim = LightweightAnimationController.instance.getAnimation(_animationId!) as LightweightScaleAnimation?;
            _scale = anim?.currentScale ?? 1.0;
          });
        }
      },
    );
    
    LightweightAnimationController.instance.addAnimation(_animationId!, animation);
    
    // 安排反向动画
    Future.delayed(Duration(milliseconds: widget.period ~/ 2), () {
      if (mounted && _animationId != null) {
        _startReverseAnimation();
      }
    });
  }
  
  void _startReverseAnimation() {
    if (!mounted || _animationId == null) return;
    
    LightweightAnimationController.instance.removeAnimation(_animationId!);
    
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final animation = LightweightScaleAnimation(
      fromScale: 1.0 + widget.scaleRange,
      toScale: 1.0,
      duration: widget.period ~/ 2,
      startTime: currentTime,
      onUpdate: () {
        if (mounted) {
          setState(() {
            final anim = LightweightAnimationController.instance.getAnimation(_animationId!) as LightweightScaleAnimation?;
            _scale = anim?.currentScale ?? 1.0;
          });
        }
      },
    );
    
    LightweightAnimationController.instance.addAnimation(_animationId!, animation);
    
    // 循环动画
    Future.delayed(Duration(milliseconds: widget.period ~/ 2), () {
      if (mounted) {
        _startAnimation();
      }
    });
  }
  
  @override
  void dispose() {
    if (_animationId != null) {
      LightweightAnimationController.instance.removeAnimation(_animationId!);
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _scale,
      child: widget.child,
    );
  }
}