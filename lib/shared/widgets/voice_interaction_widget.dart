import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../core/themes/colors.dart';
import '../../core/themes/typography.dart';
import '../../core/themes/spacing.dart';
import 'breathing_widget.dart';

/// 语音交互组件
/// 56x56px纯黑圆形按钮，脉冲动画监听状态，自然语音识别
class VoiceInteractionWidget extends StatefulWidget {
  final VoidCallback? onStartListening;
  final VoidCallback? onStopListening;
  final Function(String)? onVoiceResult;
  final bool isListening;
  
  const VoiceInteractionWidget({
    super.key,
    this.onStartListening,
    this.onStopListening,
    this.onVoiceResult,
    this.isListening = false,
  });

  @override
  State<VoiceInteractionWidget> createState() => _VoiceInteractionWidgetState();
}

class _VoiceInteractionWidgetState extends State<VoiceInteractionWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }
  
  void _initializeAnimations() {
    // 脉冲动画控制器
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // 声波动画控制器
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void didUpdateWidget(VoiceInteractionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _startListeningAnimation();
      } else {
        _stopListeningAnimation();
      }
    }
  }
  
  void _startListeningAnimation() {
    _pulseController.repeat(reverse: true);
    _waveController.repeat(reverse: true);
    HapticFeedback.mediumImpact();
  }
  
  void _stopListeningAnimation() {
    _pulseController.stop();
    _waveController.stop();
    _pulseController.reset();
    _waveController.reset();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 声波效果
        if (widget.isListening) ..._buildWaveEffects(),
        
        // 主按钮
        _buildMainButton(),
      ],
    );
  }
  
  List<Widget> _buildWaveEffects() {
    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          final delay = index * 0.3;
          final animationValue = (_waveAnimation.value + delay) % 1.0;
          
          return Container(
            width: 56 + (animationValue * 40), // 从56px扩展到96px
            height: 56 + (animationValue * 40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textPrimary.withOpacity(0.3 - (animationValue * 0.3)),
                width: 2,
              ),
            ),
          );
        },
      );
    });
  }
  
  Widget _buildMainButton() {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _handleVoiceButtonTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = widget.isListening 
              ? _pulseAnimation.value 
              : (_isPressed ? 0.95 : 1.0);
              
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: widget.isListening 
                    ? AppColors.error // 监听时红色
                    : AppColors.textPrimary, // 默认纯黑
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.isListening
                        ? AppColors.error.withOpacity(0.4)
                        : AppColors.getShadowColor(false),
                    blurRadius: widget.isListening ? 20 : 16,
                    offset: const Offset(0, 4),
                    spreadRadius: widget.isListening ? 2 : 0,
                  ),
                ],
              ),
              child: Icon(
                widget.isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _handleVoiceButtonTap() {
    if (widget.isListening) {
      widget.onStopListening?.call();
    } else {
      widget.onStartListening?.call();
    }
  }
}

/// 语音交互对话框
class VoiceInteractionDialog extends StatefulWidget {
  final Function(String)? onVoiceCommand;
  
  const VoiceInteractionDialog({
    super.key,
    this.onVoiceCommand,
  });

  @override
  State<VoiceInteractionDialog> createState() => _VoiceInteractionDialogState();
}

class _VoiceInteractionDialogState extends State<VoiceInteractionDialog>
    with TickerProviderStateMixin {
  late AnimationController _dialogController;
  late Animation<double> _dialogAnimation;
  
  bool _isListening = false;
  String _recognizedText = '';
  String _currentStatus = '轻触开始说话';
  
  final List<String> _suggestions = [
    '我想吃银耳莲子羹',
    '今天适合做什么菜',
    '推荐一道简单的菜',
    '制作番茄鸡蛋面',
    '查看烹饪历史',
  ];

  @override
  void initState() {
    super.initState();
    _initializeDialogAnimation();
  }

  @override
  void dispose() {
    _dialogController.dispose();
    super.dispose();
  }
  
  void _initializeDialogAnimation() {
    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _dialogAnimation = CurvedAnimation(
      parent: _dialogController,
      curve: Curves.easeOutCubic,
    );
    
    _dialogController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dialogAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _dialogAnimation.value,
          child: Opacity(
            opacity: _dialogAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: _buildDialogContent(),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildDialogContent() {
    return Container(
      padding: AppSpacing.cardContentPadding,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(false),
            blurRadius: AppSpacing.shadowBlurRadius,
            offset: AppSpacing.shadowOffset,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Row(
            children: [
              BreathingWidget(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assistant,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              Space.w16,
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '语音助手',
                      style: AppTypography.titleMediumStyle(isDark: false),
                    ),
                    
                    Space.h4,
                    
                    Text(
                      _currentStatus,
                      style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                        color: _isListening 
                            ? AppColors.error 
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 关闭按钮
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          Space.h32,
          
          // 识别文本显示
          if (_recognizedText.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Text(
                _recognizedText,
                style: AppTypography.bodyMediumStyle(isDark: false),
              ),
            ),
            
            Space.h24,
          ],
          
          // 语音按钮
          Center(
            child: VoiceInteractionWidget(
              isListening: _isListening,
              onStartListening: _startListening,
              onStopListening: _stopListening,
            ),
          ),
          
          Space.h32,
          
          // 建议指令
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '试试这些指令',
                style: AppTypography.bodySmallStyle(isDark: false),
              ),
              
              Space.h8,
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestions.map((suggestion) {
                  return GestureDetector(
                    onTap: () => _handleSuggestionTap(suggestion),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                      ),
                      child: Text(
                        suggestion,
                        style: AppTypography.captionStyle(isDark: false),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _startListening() {
    setState(() {
      _isListening = true;
      _currentStatus = '正在监听...';
      _recognizedText = '';
    });
    
    // 模拟语音识别过程
    Future.delayed(const Duration(seconds: 3), () {
      if (_isListening) {
        _stopListening();
        _simulateRecognition();
      }
    });
  }
  
  void _stopListening() {
    setState(() {
      _isListening = false;
      _currentStatus = '处理中...';
    });
  }
  
  void _simulateRecognition() {
    // 模拟语音识别结果
    final simulatedResults = [
      '我想吃银耳莲子羹',
      '今天想做什么菜呢',
      '推荐一道简单的菜',
      '查看菜谱',
    ];
    
    final result = simulatedResults[math.Random().nextInt(simulatedResults.length)];
    
    setState(() {
      _recognizedText = result;
      _currentStatus = '识别完成';
    });
    
    // 处理识别结果
    Future.delayed(const Duration(milliseconds: 1500), () {
      widget.onVoiceCommand?.call(result);
      Navigator.of(context).pop();
    });
  }
  
  void _handleSuggestionTap(String suggestion) {
    setState(() {
      _recognizedText = suggestion;
      _currentStatus = '执行指令...';
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      widget.onVoiceCommand?.call(suggestion);
      Navigator.of(context).pop();
    });
  }
}