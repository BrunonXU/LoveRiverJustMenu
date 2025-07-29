import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/pages/image_gallery_screen.dart';
import '../../../recipe/domain/models/recipe.dart';
import '../../../recipe/data/repositories/recipe_repository.dart';

/// 🎨 极简烹饪模式 - 大图指导设计
/// 上半屏显示步骤大图，下半屏显示文字说明
class CookingModeScreenV2 extends ConsumerStatefulWidget {
  final String recipeId;
  
  const CookingModeScreenV2({
    super.key, 
    required this.recipeId,
  });

  @override
  ConsumerState<CookingModeScreenV2> createState() => _CookingModeScreenV2State();
}

class _CookingModeScreenV2State extends ConsumerState<CookingModeScreenV2> 
    with TickerProviderStateMixin {
  Recipe? _recipe;
  int _currentStepIndex = 0;
  Timer? _stepTimer;
  int _currentStepTime = 0;
  bool _isPlaying = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    _loadRecipeData();
  }
  
  @override
  void dispose() {
    _stepTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }
  
  void _loadRecipeData() async {
    try {
      final repository = await ref.read(initializedRecipeRepositoryProvider.future);
      final recipe = repository.getRecipe(widget.recipeId);
      
      if (recipe != null) {
        setState(() {
          _recipe = recipe;
          if (_recipe!.steps.isNotEmpty) {
            _currentStepTime = _recipe!.steps[0].duration * 60; // 转换为秒
          }
        });
      }
    } catch (e) {
      print('❌ 加载菜谱数据失败: $e');
    }
  }
  
  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    
    if (_isPlaying) {
      _startTimer();
    } else {
      _pauseTimer();
    }
    
    HapticFeedback.lightImpact();
  }
  
  void _startTimer() {
    _stepTimer?.cancel();
    _stepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentStepTime > 0) {
          _currentStepTime--;
        } else {
          // 自动进入下一步
          if (_currentStepIndex < _recipe!.steps.length - 1) {
            _nextStep();
          } else {
            _isPlaying = false;
            timer.cancel();
          }
        }
      });
    });
  }
  
  void _pauseTimer() {
    _stepTimer?.cancel();
  }
  
  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _currentStepTime = _recipe!.steps[_currentStepIndex].duration * 60;
        _isPlaying = false;
      });
      _pauseTimer();
      HapticFeedback.mediumImpact();
    }
  }
  
  void _nextStep() {
    if (_currentStepIndex < _recipe!.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _currentStepTime = _recipe!.steps[_currentStepIndex].duration * 60;
        _isPlaying = false;
      });
      _pauseTimer();
      HapticFeedback.mediumImpact();
    }
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    if (_recipe == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final currentStep = _recipe!.steps[_currentStepIndex];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // 🎨 极简顶部导航
            _buildMinimalHeader(),
            
            // 🎨 上半部分 - 大图展示区
            Expanded(
              flex: 5,
              child: _buildImageSection(currentStep),
            ),
            
            // 🎨 下半部分 - 说明文字区
            Expanded(
              flex: 4,
              child: _buildInstructionSection(currentStep),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 🎨 极简顶部导航
  Widget _buildMinimalHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
          
          // 标题
          Expanded(
            child: Center(
              child: Text(
                _recipe!.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          
          // 占位
          const SizedBox(width: 40),
        ],
      ),
    );
  }
  
  /// 🎨 上半部分 - 图片和控制区域
  Widget _buildImageSection(RecipeStep step) {
    return Container(
      color: const Color(0xFFE8E8E8),
      child: Stack(
        children: [
          // 步骤图片或占位图
          Center(
            child: _buildStepImage(step),
          ),
          
          // 步骤标题（顶部）
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          
          // 播放控制按钮（底部）
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: _buildPlaybackControls(),
          ),
        ],
      ),
    );
  }
  
  /// 🎨 步骤图片展示
  Widget _buildStepImage(RecipeStep step) {
    if (step.imagePath != null && step.imagePath!.isNotEmpty) {
      // 收集所有步骤的图片路径
      final allStepImages = _recipe!.steps
          .where((s) => s.imagePath != null && s.imagePath!.isNotEmpty)
          .map((s) => s.imagePath!)
          .toList();
      
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          // 打开图片画廊
          ImageGalleryScreen.show(
            context,
            imagePaths: allStepImages,
            initialIndex: allStepImages.indexOf(step.imagePath!),
            heroTag: 'cooking_step_image_${_currentStepIndex}',
          );
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(48),
          child: Hero(
            tag: 'cooking_step_image_${_currentStepIndex}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: step.imagePath!.startsWith('http')
                  ? Image.network(
                      step.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultStepVisual(step.title);
                      },
                    )
                  : kIsWeb
                      ? Image.asset(
                          step.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultStepVisual(step.title);
                          },
                        )
                      : Image.asset(
                          step.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultStepVisual(step.title);
                          },
                        ),
            ),
          ),
        ),
      );
    }
    
    return _buildDefaultStepVisual(step.title);
  }
  
  /// 🎨 默认步骤图形
  Widget _buildDefaultStepVisual(String title) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          _getIconForStep(title),
          size: 100,
          color: Colors.grey[400],
        ),
      ),
    );
  }
  
  IconData _getIconForStep(String title) {
    if (title.contains('准备') || title.contains('食材')) {
      return Icons.kitchen;
    } else if (title.contains('切') || title.contains('处理')) {
      return Icons.content_cut;
    } else if (title.contains('煮') || title.contains('炖') || title.contains('烧')) {
      return Icons.local_fire_department;
    } else if (title.contains('炒') || title.contains('煎')) {
      return Icons.whatshot;
    } else if (title.contains('蒸')) {
      return Icons.water_drop;
    } else if (title.contains('调味') || title.contains('完成')) {
      return Icons.done_all;
    }
    return Icons.restaurant;
  }
  
  /// 🎨 播放控制按钮
  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 上一步按钮
        GestureDetector(
          onTap: _currentStepIndex > 0 ? _previousStep : null,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _currentStepIndex > 0 
                  ? Colors.white.withOpacity(0.9)
                  : Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.skip_previous,
              size: 24,
              color: _currentStepIndex > 0 
                  ? Colors.black87
                  : Colors.grey[400],
            ),
          ),
        ),
        
        const SizedBox(width: 24),
        
        // 播放/暂停按钮
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 32,
              color: Colors.black87,
            ),
          ),
        ),
        
        const SizedBox(width: 24),
        
        // 下一步按钮
        GestureDetector(
          onTap: _currentStepIndex < _recipe!.steps.length - 1 
              ? _nextStep 
              : null,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _currentStepIndex < _recipe!.steps.length - 1
                  ? Colors.white.withOpacity(0.9)
                  : Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.skip_next,
              size: 24,
              color: _currentStepIndex < _recipe!.steps.length - 1
                  ? Colors.black87
                  : Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }
  
  /// 🎨 下半部分 - 说明文字区域
  Widget _buildInstructionSection(RecipeStep step) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 操作说明标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '操作说明',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              // 计时器
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isPlaying 
                      ? const Color(0xFFFFE0B2)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: _isPlaying 
                          ? Colors.orange[700]
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_currentStepTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _isPlaying 
                            ? Colors.orange[700]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 步骤描述
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.8,
                    ),
                  ),
                  
                  // 专业贴士（如果有）
                  if (step.tips?.isNotEmpty == true) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: Color(0xFFFF9800),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '专业贴士',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 贴士内容（带项目符号）
                    ...step.tips!.split('，').map((tip) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 8, right: 12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF9800),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tip.trim(),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).toList(),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 底部提示
          Center(
            child: Text(
              '烹饪模式 - 大图指导',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }
}