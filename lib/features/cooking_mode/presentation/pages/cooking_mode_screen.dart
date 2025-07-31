import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;

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
  
  // 🔧 修复：动态菜谱步骤，根据recipeId加载
  late List<CookingStep> _steps;
  
  @override
  void initState() {
    super.initState();
    _steps = _getCookingStepsByRecipeId(widget.recipeId ?? 'recipe_1');
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
    // 网络图片
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
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
  
  /// 🔧 根据菜谱ID获取对应的烹饪步骤
  List<CookingStep> _getCookingStepsByRecipeId(String recipeId) {
    final cookingStepsData = {
      'recipe_1': [ // 银耳莲子羹
        CookingStep(
          title: '准备食材', 
          description: '洗净银耳，撕成小朵\n莲子去心，红枣去核', 
          duration: 300, 
          icon: '🥄',
          imagePath: 'https://images.unsplash.com/photo-1606787366850-de6330128bfc?w=800&h=600&fit=crop',
          tips: ['银耳选择颜色偏白、朵形完整的', '莲子去心可以减少苦味', '红枣去核防止上火'],
        ),
        CookingStep(
          title: '银耳处理', 
          description: '银耳用温水泡发30分钟\n撕成小块备用', 
          duration: 600, 
          icon: '💧',
          imagePath: 'https://images.unsplash.com/photo-1594736797933-d0e3b5e8181a?w=800&h=600&fit=crop',
          tips: ['泡发时间不宜过长', '撕成小块更容易出胶质'],
        ),
        CookingStep(
          title: '开始煮制', 
          description: '锅中加水，放入银耳\n大火煮开转小火', 
          duration: 300, 
          icon: '🔥',
          imagePath: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=600&fit=crop',
          tips: ['水量要足够，避免干锅', '大火煮开后立即转小火'],
        ),
        CookingStep(
          title: '添加配料', 
          description: '加入莲子和红枣\n继续煮15分钟', 
          duration: 900, 
          icon: '🥄',
          tips: ['先加莲子，后加红枣', '保持小火慢炖'],
        ),
        CookingStep(
          title: '调味收汁', 
          description: '加入冰糖调味\n煮至银耳软糯', 
          duration: 600, 
          icon: '✨',
          tips: ['冰糖用量根据个人喜好', '银耳出胶质即可'],
        ),
      ],
      'recipe_2': [ // 番茄鸡蛋面
        CookingStep(title: '准备食材', description: '面条100g，鸡蛋2个\n番茄2个，葱花适量', duration: 180, icon: '🥄'),
        CookingStep(title: '处理番茄', description: '番茄去皮切块\n先炒出汁水', duration: 300, icon: '🍅'),
        CookingStep(title: '炒制鸡蛋', description: '鸡蛋打散炒熟\n盛起备用', duration: 120, icon: '🍳'),
        CookingStep(title: '下面条', description: '水开后下面条\n煮至8分熟', duration: 180, icon: '🍜'),
        CookingStep(title: '汇合调味', description: '将面条、鸡蛋、番茄汇合\n最后撒上葱花', duration: 120, icon: '✨'),
      ],
      'recipe_3': [ // 红烧排骨
        CookingStep(title: '准备食材', description: '排骨500g，生抽、老抽\n料酒、冰糖适量', duration: 300, icon: '🥩'),
        CookingStep(title: '焯水处理', description: '排骨冷水下锅\n焯水去血沫', duration: 480, icon: '💧'),
        CookingStep(title: '炒糖色', description: '热锅下冰糖\n炒出焦糖色', duration: 300, icon: '🍯'),
        CookingStep(title: '下排骨炒色', description: '下排骨翻炒\n每面都裹上糖色', duration: 300, icon: '🔥'),
        CookingStep(title: '加调料炖煮', description: '加生抽老抽料酒和水\n大火煮开转小火25分钟', duration: 1500, icon: '🍲'),
      ],
      'recipe_4': [ // 蒸蛋羹
        CookingStep(title: '打蛋液', description: '鸡蛋2个打散\n加温水搅匀', duration: 180, icon: '🥚'),
        CookingStep(title: '过筛去泡', description: '蛋液过筛\n去除泡沫', duration: 120, icon: '⏳'),
        CookingStep(title: '蒸制', description: '盖保鲜膜扎孔\n水开后蒸8分钟', duration: 480, icon: '🔥'),
      ],
      'recipe_5': [ // 青椒肉丝
        CookingStep(title: '切丝备料', description: '肉丝切细\n青椒切丝', duration: 480, icon: '🔪'),
        CookingStep(title: '肉丝腌制', description: '肉丝加生抽、淀粉\n腌制10分钟', duration: 600, icon: '🥄'),
        CookingStep(title: '炒制', description: '先炒肉丝至变色\n再下青椒丝大火快炒', duration: 420, icon: '🔥'),
      ],
      'recipe_6': [ // 爱心早餐
        CookingStep(title: '准备食材', description: '面包、鸡蛋、牛奶\n新鲜水果', duration: 300, icon: '🍞'),
        CookingStep(title: '制作煎蛋', description: '热锅煎制\n爱心形状的鸡蛋', duration: 480, icon: '💝'),
        CookingStep(title: '搭配摆盘', description: '面包、煎蛋、水果\n艺术摆盘', duration: 720, icon: '🎨'),
        CookingStep(title: '温牛奶', description: '加热牛奶\n至适温', duration: 300, icon: '🥛'),
      ],
      'recipe_7': [ // 宫保鸡丁
        CookingStep(title: '鸡肉切丁', description: '鸡胸肉切丁\n用料酒腌制', duration: 480, icon: '🐔'),
        CookingStep(title: '炸花生米', description: '花生米过油\n炸酥脆', duration: 300, icon: '🥜'),
        CookingStep(title: '炒制调味', description: '下鸡丁炒熟\n加调料炒匀，撒花生米', duration: 420, icon: '🔥'),
      ],
      'recipe_8': [ // 麻婆豆腐
        CookingStep(title: '豆腐处理', description: '嫩豆腐切块\n用盐水浸泡', duration: 300, icon: '⚪'),
        CookingStep(title: '炒制肉末', description: '热锅炒肉末\n至变色', duration: 180, icon: '🥩'),
        CookingStep(title: '下豆腐调味', description: '加豆瓣酱和豆腐块\n轻柔翻炒', duration: 420, icon: '🌶️'),
      ],
      'recipe_9': [ // 糖醋里脊
        CookingStep(title: '里脊处理', description: '里脊肉切条\n用蛋液淀粉裹匀', duration: 600, icon: '🥩'),
        CookingStep(title: '油炸定型', description: '热油炸至金黄酥脆\n二次复炸', duration: 900, icon: '🔥'),
        CookingStep(title: '调糖醋汁', description: '糖醋汁炒至粘稠\n裹里脊', duration: 600, icon: '🍯'),
      ],
      'recipe_10': [ // 酸菜鱼
        CookingStep(title: '鱼片处理', description: '草鱼切片\n用蛋清淀粉腌制', duration: 900, icon: '🐟'),
        CookingStep(title: '炒酸菜底', description: '炒酸菜出香味\n加水煮开', duration: 600, icon: '🌶️'),
        CookingStep(title: '煮鱼片', description: '下鱼片煮熟\n淋辣椒油', duration: 900, icon: '🔥'),
      ],
      'recipe_11': [ // 口水鸡
        CookingStep(title: '煮鸡肉', description: '整鸡煮熟晾凉\n撕成丝', duration: 1200, icon: '🐔'),
        CookingStep(title: '调制蘸料', description: '生抽、香醋、辣椒油\n调匀', duration: 180, icon: '🥄'),
        CookingStep(title: '拌制装盘', description: '鸡丝淋蘸料\n撒花生碎和香菜', duration: 120, icon: '🥗'),
      ],
      'recipe_12': [ // 蛋花汤
        CookingStep(title: '烧开水', description: '锅中加水烧开\n调味', duration: 180, icon: '💧'),
        CookingStep(title: '淋蛋液', description: '蛋液打散\n慢慢淋入开水中', duration: 60, icon: '🥚'),
        CookingStep(title: '出锅', description: '撒葱花\n即可出锅', duration: 60, icon: '🌿'),
      ],
    };
    
    return cookingStepsData[recipeId] ?? cookingStepsData['recipe_1']!;
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