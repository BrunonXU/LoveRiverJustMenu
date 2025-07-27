import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';

/// 烹饪模式界面
/// 横屏全屏模式，48px超大字体，环形进度条，大触摸区域设计
class CookingModeScreen extends StatefulWidget {
  final String? recipeId;
  
  const CookingModeScreen({super.key, this.recipeId});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _breathingController;
  late Animation<double> _progressAnimation;
  
  int _currentStep = 0;
  bool _isPlaying = false;
  bool _isPaused = false;
  int _totalTime = 0;
  int _currentTime = 0;
  
  // 示例菜谱步骤
  final List<CookingStep> _steps = [
    CookingStep(
      title: '准备食材',
      description: '洗净银耳，撕成小朵\n莲子去心，红枣去核',
      duration: 300, // 5分钟
      icon: '🥄',
    ),
    CookingStep(
      title: '银耳处理',
      description: '银耳用温水泡发30分钟\n撕成小块备用',
      duration: 600, // 10分钟
      icon: '💧',
    ),
    CookingStep(
      title: '开始煮制',
      description: '锅中加水，放入银耳\n大火煮开转小火',
      duration: 300, // 5分钟
      icon: '🔥',
    ),
    CookingStep(
      title: '添加配料',
      description: '加入莲子和红枣\n继续煮15分钟',
      duration: 900, // 15分钟
      icon: '🥄',
    ),
    CookingStep(
      title: '调味收汁',
      description: '加入冰糖调味\n煮至银耳软糯',
      duration: 600, // 10分钟
      icon: '✨',
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setLandscapeMode();
    _calculateTotalTime();
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _breathingController.dispose();
    _restorePortraitMode();
    super.dispose();
  }
  
  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  void _setLandscapeMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  
  void _restorePortraitMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  
  void _calculateTotalTime() {
    _totalTime = _steps.fold(0, (sum, step) => sum + step.duration);
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Row(
            children: [
              // 左侧步骤信息区
              Expanded(
                flex: 2,
                child: _buildStepInfo(isDark),
              ),
              
              Space.w48,
              
              // 右侧控制区
              Expanded(
                flex: 1,
                child: _buildControlArea(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStepInfo(bool isDark) {
    final currentStepData = _currentStep < _steps.length 
        ? _steps[_currentStep] 
        : _steps.last;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 步骤标题
        Row(
          children: [
            Text(
              currentStepData.icon,
              style: const TextStyle(fontSize: 60),
            ),
            
            Space.w16,
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '第${_currentStep + 1}步',
                    style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                      color: AppColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                  
                  Space.h8,
                  
                  Text(
                    currentStepData.title,
                    style: AppTypography.customStyle(
                      fontSize: 48, // 48px超大字体
                      fontWeight: AppTypography.light,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        Space.h32,
        
        // 步骤描述
        Text(
          currentStepData.description,
          style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
            height: 1.8,
            fontWeight: AppTypography.light,
          ),
        ),
        
        Space.h48,
        
        // 步骤进度
        _buildStepProgress(isDark),
      ],
    );
  }
  
  Widget _buildStepProgress(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '烹饪进度',
          style: AppTypography.bodyLargeStyle(isDark: isDark),
        ),
        
        Space.h16,
        
        // 步骤指示器
        Row(
          children: _steps.asMap().entries.map((entry) {
            final index = entry.key;
            final isCompleted = index < _currentStep;
            final isCurrent = index == _currentStep;
            
            return Expanded(
              child: Container(
                height: 8,
                margin: EdgeInsets.only(right: index < _steps.length - 1 ? 8 : 0),
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent
                      ? AppColors.getTextPrimaryColor(isDark)
                      : AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildControlArea(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 环形进度条
        _buildCircularProgress(isDark),
        
        Space.h48,
        
        // 控制按钮
        _buildControlButtons(isDark),
        
        Space.h32,
        
        // 退出按钮
        _buildExitButton(isDark),
      ],
    );
  }
  
  Widget _buildCircularProgress(bool isDark) {
    final progress = _currentStep / _steps.length;
    
    return BreathingWidget(
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 背景圆环
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                  width: 8,
                ),
              ),
            ),
            
            // 进度圆环
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(200, 200),
                  painter: CircularProgressPainter(
                    progress: progress * _progressAnimation.value,
                    color: AppColors.getTextPrimaryColor(isDark),
                    strokeWidth: 8,
                  ),
                );
              },
            ),
            
            // 中心文字
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(_currentStep + 1)}/${_steps.length}',
                  style: AppTypography.customStyle(
                    fontSize: 36,
                    fontWeight: AppTypography.light,
                    isDark: isDark,
                  ),
                ),
                
                Space.h8,
                
                Text(
                  '${_formatTime(_currentTime)}',
                  style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                    color: AppColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControlButtons(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 上一步按钮
        _buildControlButton(
          icon: Icons.skip_previous,
          onTap: _currentStep > 0 ? _previousStep : null,
          isDark: isDark,
        ),
        
        // 播放/暂停按钮
        _buildControlButton(
          icon: _isPlaying ? Icons.pause : Icons.play_arrow,
          onTap: _togglePlayPause,
          isDark: isDark,
          isLarge: true,
        ),
        
        // 下一步按钮
        _buildControlButton(
          icon: Icons.skip_next,
          onTap: _currentStep < _steps.length - 1 ? _nextStep : null,
          isDark: isDark,
        ),
      ],
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isDark,
    bool isLarge = false,
  }) {
    final size = isLarge ? 80.0 : 60.0;
    final iconSize = isLarge ? 40.0 : 30.0;
    
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.mediumImpact();
          onTap();
        }
      },
      child: BreathingWidget(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: onTap != null 
                ? AppColors.getTextPrimaryColor(isDark)
                : AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
            shape: BoxShape.circle,
            boxShadow: onTap != null ? [
              BoxShadow(
                color: AppColors.getShadowColor(isDark),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Widget _buildExitButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.close,
              size: 20,
              color: AppColors.getTextSecondaryColor(isDark),
            ),
            
            Space.w8,
            
            Text(
              '退出烹饪',
              style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _progressController.forward(from: 0);
    }
  }
  
  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _progressController.forward(from: 0);
    }
  }
  
  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // TODO: 实现计时器逻辑
  }
}

/// 烹饪步骤数据模型
class CookingStep {
  final String title;
  final String description;
  final int duration; // 秒
  final String icon;
  
  const CookingStep({
    required this.title,
    required this.description,
    required this.duration,
    required this.icon,
  });
}

/// 环形进度条绘制器
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  
  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}