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
                    
                    Text(\n                      _currentStatus,\n                      style: AppTypography.bodySmallStyle(isDark: false).copyWith(\n                        color: _isListening \n                            ? AppColors.error \n                            : AppColors.textSecondary,\n                      ),\n                    ),\n                  ],\n                ),\n              ),\n              \n              // 关闭按钮\n              GestureDetector(\n                onTap: () => Navigator.of(context).pop(),\n                child: Container(\n                  width: 32,\n                  height: 32,\n                  decoration: BoxDecoration(\n                    color: AppColors.backgroundSecondary,\n                    shape: BoxShape.circle,\n                  ),\n                  child: const Icon(\n                    Icons.close,\n                    size: 16,\n                    color: AppColors.textSecondary,\n                  ),\n                ),\n              ),\n            ],\n          ),\n          \n          Space.h32,\n          \n          // 识别文本显示\n          if (_recognizedText.isNotEmpty) ...[\n            Container(\n              width: double.infinity,\n              padding: const EdgeInsets.all(AppSpacing.md),\n              decoration: BoxDecoration(\n                color: AppColors.backgroundSecondary,\n                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),\n              ),\n              child: Text(\n                _recognizedText,\n                style: AppTypography.bodyMediumStyle(isDark: false),\n              ),\n            ),\n            \n            Space.h24,\n          ],\n          \n          // 语音按钮\n          Center(\n            child: VoiceInteractionWidget(\n              isListening: _isListening,\n              onStartListening: _startListening,\n              onStopListening: _stopListening,\n            ),\n          ),\n          \n          Space.h32,\n          \n          // 建议指令\n          Column(\n            crossAxisAlignment: CrossAxisAlignment.start,\n            children: [\n              Text(\n                '试试这些指令',\n                style: AppTypography.bodySmallStyle(isDark: false),\n              ),\n              \n              Space.h12,\n              \n              Wrap(\n                spacing: 8,\n                runSpacing: 8,\n                children: _suggestions.map((suggestion) {\n                  return GestureDetector(\n                    onTap: () => _handleSuggestionTap(suggestion),\n                    child: Container(\n                      padding: const EdgeInsets.symmetric(\n                        horizontal: AppSpacing.md,\n                        vertical: AppSpacing.xs,\n                      ),\n                      decoration: BoxDecoration(\n                        color: AppColors.backgroundSecondary,\n                        borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),\n                      ),\n                      child: Text(\n                        suggestion,\n                        style: AppTypography.captionStyle(isDark: false),\n                      ),\n                    ),\n                  );\n                }).toList(),\n              ),\n            ],\n          ),\n        ],\n      ),\n    );\n  }\n  \n  void _startListening() {\n    setState(() {\n      _isListening = true;\n      _currentStatus = '正在监听...';\n      _recognizedText = '';\n    });\n    \n    // 模拟语音识别过程\n    Future.delayed(const Duration(seconds: 3), () {\n      if (_isListening) {\n        _stopListening();\n        _simulateRecognition();\n      }\n    });\n  }\n  \n  void _stopListening() {\n    setState(() {\n      _isListening = false;\n      _currentStatus = '处理中...';\n    });\n  }\n  \n  void _simulateRecognition() {\n    // 模拟语音识别结果\n    final simulatedResults = [\n      '我想吃银耳莲子羹',\n      '今天想做什么菜呢',\n      '推荐一道简单的菜',\n      '查看菜谱',\n    ];\n    \n    final result = simulatedResults[math.Random().nextInt(simulatedResults.length)];\n    \n    setState(() {\n      _recognizedText = result;\n      _currentStatus = '识别完成';\n    });\n    \n    // 处理识别结果\n    Future.delayed(const Duration(milliseconds: 1500), () {\n      widget.onVoiceCommand?.call(result);\n      Navigator.of(context).pop();\n    });\n  }\n  \n  void _handleSuggestionTap(String suggestion) {\n    setState(() {\n      _recognizedText = suggestion;\n      _currentStatus = '执行指令...';\n    });\n    \n    Future.delayed(const Duration(milliseconds: 1000), () {\n      widget.onVoiceCommand?.call(suggestion);\n      Navigator.of(context).pop();\n    });\n  }\n}