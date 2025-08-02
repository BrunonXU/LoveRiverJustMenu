import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../domain/models/recipe.dart';
import '../../../recipe/presentation/providers/recipe_providers.dart';
import '../../../../core/firestore/repositories/recipe_repository.dart';

/// 烹饪模式界面
/// 横屏全屏模式，48px超大字体，环形进度条，大触摸区域设计
class CookingModeScreen extends ConsumerStatefulWidget {
  final String? recipeId;
  
  const CookingModeScreen({super.key, this.recipeId});

  @override
  ConsumerState<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends ConsumerState<CookingModeScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _breathingController;
  late Animation<double> _progressAnimation;
  
  int _currentStep = 0;
  bool _isPlaying = false;
  bool _isPaused = false;
  int _totalTime = 0;
  int _currentTime = 0;
  
  // 🔧 修复：动态菜谱步骤，根据recipeId加载
  List<CookingStep> _steps = [];
  Recipe? _currentRecipe;
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setLandscapeMode();
    _loadRecipeData();
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
    if (!kIsWeb) {
      // 只在移动平台设置横屏和全屏
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    // Web平台不强制横屏，让用户自行选择
  }
  
  void _restorePortraitMode() {
    if (!kIsWeb) {
      // 只在移动平台恢复竖屏
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
  
  void _calculateTotalTime() {
    _totalTime = _steps.fold(0, (sum, step) => sum + step.duration);
  }
  
  /// 🔧 加载真实菜谱数据
  Future<void> _loadRecipeData() async {
    if (widget.recipeId == null) {
      setState(() {
        _errorMessage = '菜谱ID为空';
        _isLoading = false;
      });
      return;
    }
    
    try {
      // 从云端仓库加载菜谱
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      final recipe = await repository.getRecipe(widget.recipeId!);
      
      if (recipe == null) {
        setState(() {
          _errorMessage = '未找到菜谱：${widget.recipeId}';
          _isLoading = false;
        });
        return;
      }
      
      // 转换 RecipeStep 为 CookingStep
      final cookingSteps = recipe.steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        
        return CookingStep(
          title: step.title,
          description: step.description,
          duration: step.duration * 60, // 转换为秒
          icon: _getStepIcon(index),
          imagePath: _getStepImagePath(step),
          tips: step.tips != null && step.tips!.isNotEmpty 
              ? [step.tips!] 
              : [],
        );
      }).toList();
      
      setState(() {
        _currentRecipe = recipe;
        _steps = cookingSteps;
        _isLoading = false;
        _calculateTotalTime();
      });
      
    } catch (e) {
      debugPrint('❌ 加载菜谱数据失败: $e');
      setState(() {
        _errorMessage = '加载菜谱失败：$e';
        _isLoading = false;
      });
    }
  }
  
  /// 🎯 根据步骤索引获取合适的图标
  String _getStepIcon(int index) {
    const icons = ['🥄', '🔪', '🔥', '💧', '🍳', '🥢', '✨', '🍽️'];
    return icons[index % icons.length];
  }
  
  /// 🖼️ 获取步骤图片路径
  String? _getStepImagePath(RecipeStep step) {
    // 优先使用 base64 图片
    if (step.imageBase64 != null && step.imageBase64!.isNotEmpty) {
      return 'data:image/jpeg;base64,${step.imageBase64}';
    }
    
    // 其次使用图片路径
    if (step.imagePath != null && step.imagePath!.isNotEmpty) {
      return step.imagePath;
    }
    
    return null;
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingScreen(isDark)
            : _errorMessage != null
                ? _buildErrorScreen(isDark)
                : _steps.isEmpty
                    ? _buildEmptyScreen(isDark)
                    : Padding(
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
  
  /// 🔄 构建加载屏幕
  Widget _buildLoadingScreen(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            '正在加载菜谱...',
            style: AppTypography.titleMediumStyle(isDark: isDark),
          ),
        ],
      ),
    );
  }
  
  /// ❌ 构建错误屏幕
  Widget _buildErrorScreen(bool isDark) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              '加载失败',
              style: AppTypography.titleLargeStyle(isDark: isDark),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? '未知错误',
              style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadRecipeData();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '重试',
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                '返回',
                style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                  color: AppColors.getTextSecondaryColor(isDark),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 📭 构建空内容屏幕
  Widget _buildEmptyScreen(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: AppColors.getTextSecondaryColor(isDark),
          ),
          const SizedBox(height: 24),
          Text(
            '这个菜谱还没有烹饪步骤',
            style: AppTypography.titleMediumStyle(isDark: isDark),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '返回',
                style: AppTypography.bodyMediumStyle(isDark: isDark),
              ),
            ),
          ),
        ],
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
        
        // 🔧 横向布局：步骤描述（左）+ 烹饪小贴士（右）
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧：步骤描述
            Expanded(
              flex: 3,
              child: Text(
                currentStepData.description,
                style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                  height: 1.8,
                  fontWeight: AppTypography.light,
                ),
              ),
            ),
            
            // 右侧：烹饪小贴士
            if (currentStepData.tips.isNotEmpty) ...[
              Space.w24,
              Expanded(
                flex: 2,
                child: _buildStepTips(currentStepData.tips, isDark),
              ),
            ],
          ],
        ),
        
        Space.h32,
        
        // 🖼️ 步骤图片展示区（占用剩余空间）
        Expanded(
          child: Column(
            children: [
              // 图片区域（如果有图片）
              if (currentStepData.imagePath != null) ...[
                Expanded(
                  child: _buildStepImage(currentStepData.imagePath!, isDark),
                ),
                Space.h24,
              ],
              
              // 底部固定的步骤进度
              _buildStepProgress(isDark),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 🖼️ 构建步骤图片展示区 - 横屏优化布局，自适应高度
  Widget _buildStepImage(String imagePath, bool isDark) {
    return BreathingWidget(
      child: Container(
        width: double.infinity,
        // 移除固定高度，让容器自适应Expanded空间
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          child: Stack(
            children: [
              // 主图片
              Container(
                width: double.infinity,
                height: double.infinity,
                child: _buildImageWidget(imagePath),
              ),
              
              // 渐变遮罩（增强文字可读性）
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 图片标签
              Positioned(
                bottom: 12,
                left: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Text(
                    '步骤参考图',
                    style: AppTypography.captionStyle(isDark: false).copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔧 智能图片组件 - 支持多种图片源
  Widget _buildImageWidget(String imagePath) {
    // Base64 图片
    if (imagePath.startsWith('data:image/')) {
      try {
        final base64String = imagePath.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('❌ Base64图片解析失败: $error');
            return _buildImageError();
          },
        );
      } catch (e) {
        debugPrint('❌ Base64图片处理异常: $e');
        return _buildImageError();
      }
    }
    
    // 网络图片
    else if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.backgroundSecondary,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    }
    
    // 本地文件图片
    else if (imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    }
    
    // 默认占位符
    else {
      return _buildImageError();
    }
  }

  /// 🖼️ 图片加载错误占位符
  Widget _buildImageError() {
    return Container(
      color: AppColors.backgroundSecondary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 48,
            color: AppColors.textSecondary,
          ),
          Space.h8,
          Text(
            '图片加载失败',
            style: AppTypography.bodySmallStyle(isDark: false).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 💡 构建烹饪小贴士区域
  Widget _buildStepTips(List<String> tips, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.emotionGradient.colors.first.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: AppColors.emotionGradient.colors.first.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                size: 20,
                color: AppColors.emotionGradient.colors.first,
              ),
              Space.w8,
              Text(
                '烹饪小贴士',
                style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.emotionGradient.colors.first,
                ),
              ),
            ],
          ),
          
          Space.h8,
          
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                    color: AppColors.emotionGradient.colors.first,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
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
  
  /// 🔄 重新加载菜谱数据
  Future<void> _reloadRecipeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _loadRecipeData();
  }
}

/// 烹饪步骤数据模型
class CookingStep {
  final String title;
  final String description;
  final int duration; // 秒
  final String icon;
  final String? imagePath; // 🖼️ 新增：步骤图片路径
  final List<String> tips; // 🔧 新增：烹饪小贴士
  
  const CookingStep({
    required this.title,
    required this.description,
    required this.duration,
    required this.icon,
    this.imagePath,
    this.tips = const [],
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