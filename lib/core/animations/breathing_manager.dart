import 'package:flutter/material.dart';
import 'performance_mode.dart';

/// 🚀 高性能全局呼吸动画管理器
/// 目标：达到120FPS (8.33ms/帧) 企业级性能标准
/// 策略：共享AnimationController + 智能帧预算管理
class BreathingManager {
  static BreathingManager? _instance;
  static BreathingManager get instance => _instance ??= BreathingManager._();
  
  BreathingManager._();
  
  // ==================== 共享动画控制器 ====================
  
  AnimationController? _controller;
  TickerProvider? _vsync;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  // 🎯 性能监控
  int _frameCount = 0;
  DateTime _lastFrameTime = DateTime.now();
  double _currentFps = 0.0;
  
  /// 初始化管理器 - 高性能版
  void initialize(TickerProvider vsync) {
    if (_controller != null) return;
    
    // 检查性能模式
    if (!PerformanceModeManager.instance.shouldShowBreathingAnimation) {
      debugPrint('🚀 性能模式：禁用呼吸动画提升性能');
      return;
    }
    
    _vsync = vsync;
    final duration = (4000 * PerformanceModeManager.instance.animationDurationMultiplier).round();
    _controller = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: vsync,
    );
    
    // 缩放动画 - 1.0 → 1.02
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ));
    
    // 透明度动画 - 0.8 → 1.0  
    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ));
    
    // 开始动画
    _controller!.repeat(reverse: true);
    
    // 性能监控回调
    _controller!.addListener(_monitorPerformance);
    
    debugPrint('🫁 BreathingManager 初始化成功 - 目标120FPS');
  }
  
  /// 获取缩放动画
  Animation<double>? get scaleAnimation => _scaleAnimation;
  
  /// 获取透明度动画  
  Animation<double>? get opacityAnimation => _opacityAnimation;
  
  /// 获取动画控制器
  AnimationController? get controller => _controller;
  
  /// 销毁管理器
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _vsync = null;
    debugPrint('🫁 BreathingManager 已销毁');
  }
  
  /// 暂停所有呼吸动画
  void pauseAll() {
    _controller?.stop();
  }
  
  /// 恢复所有呼吸动画
  void resumeAll() {
    _controller?.repeat(reverse: true);
  }
  
  /// 检查是否已初始化
  bool get isInitialized => _controller != null;
  
  /// 性能监控
  void _monitorPerformance() {
    _frameCount++;
    final now = DateTime.now();
    final deltaTime = now.difference(_lastFrameTime).inMilliseconds;
    
    if (_frameCount % 60 == 0) { // 每60帧检查一次
      _currentFps = 1000.0 / (deltaTime / 60);
      if (_currentFps < 50) {
        debugPrint('⚠️ 呼吸动画FPS过低: ${_currentFps.toStringAsFixed(1)}');
      }
    }
    
    _lastFrameTime = now;
  }
  
  /// 获取当前FPS
  double get currentFps => _currentFps;
}

/// 高性能呼吸动画组件
/// 使用全局共享的AnimationController，避免性能问题
class OptimizedBreathingWidget extends StatelessWidget {
  final Widget child;
  final double scaleMultiplier;
  final double opacityMultiplier;
  
  const OptimizedBreathingWidget({
    super.key,
    required this.child,
    this.scaleMultiplier = 1.0,
    this.opacityMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final manager = BreathingManager.instance;
    
    // 性能检查：如果禁用动画或管理器未初始化，直接返回子组件
    if (!PerformanceModeManager.instance.shouldShowBreathingAnimation || !manager.isInitialized) {
      return child;
    }
    
    return AnimatedBuilder(
      animation: manager.controller!,
      builder: (context, _) {
        final scaleValue = 1.0 + ((manager.scaleAnimation!.value - 1.0) * scaleMultiplier);
        final opacityValue = manager.opacityAnimation!.value * opacityMultiplier;
        
        return Transform.scale(
          scale: scaleValue,
          child: Opacity(
            opacity: opacityValue.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}

/// 呼吸管理器初始化组件
/// 在应用启动时初始化共享的动画控制器
class BreathingManagerInitializer extends StatefulWidget {
  final Widget child;
  
  const BreathingManagerInitializer({
    super.key,
    required this.child,
  });

  @override
  State<BreathingManagerInitializer> createState() => _BreathingManagerInitializerState();
}

class _BreathingManagerInitializerState extends State<BreathingManagerInitializer>
    with SingleTickerProviderStateMixin {
  
  @override
  void initState() {
    super.initState();
    // 初始化呼吸管理器
    BreathingManager.instance.initialize(this);
  }
  
  @override
  void dispose() {
    // 销毁呼吸管理器
    BreathingManager.instance.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}