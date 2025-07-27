import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../../../shared/widgets/app_icon_3d.dart';
import '../../../../core/utils/image_picker_helper.dart';

/// 创建食谱页面
/// 支持添加步骤、设置时长、上传图片的完整创建流程
class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  // 表单控制器
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servingsController = TextEditingController(text: '2');
  final _scrollController = ScrollController(); // 步骤列表滚动控制器
  
  // 选择的图标类型
  AppIcon3DType _selectedIconType = AppIcon3DType.heart;
  
  // 难度等级
  String _selectedDifficulty = '简单';
  final List<String> _difficultyLevels = ['简单', '中等', '困难'];
  
  // 步骤列表
  List<CreateRecipeStep> _steps = [];
  
  // 页面状态
  bool _isBasicInfoComplete = false;
  int _currentStepIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _addFirstStep();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.forward();
  }
  
  void _addFirstStep() {
    _steps.add(CreateRecipeStep(
      title: '',
      description: '',
      duration: 5,
      tips: '',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true, // 全屏布局
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: _buildAppBar(isDark),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getTimeBasedGradient(),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // 主要内容 - 占据全屏
              Expanded(
                child: _buildMainContent(isDark),
              ),
              
              // 底部操作栏 - 悬浮式
              _buildBottomActions(isDark),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8, // 状态栏高度 + 8px
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent, // 透明背景
        border: Border(
          bottom: BorderSide(
            color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 返回按钮 - 极简设计
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.getBackgroundColor(isDark).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.getTextPrimaryColor(isDark),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          
          const Spacer(),
          
          // 标题 - 更小更优雅
          Text(
            '创建食谱',
            style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
              fontWeight: AppTypography.light,
            ),
          ),
          
          const Spacer(),
          
          // 保存按钮（替代进度指示器）
          GestureDetector(
            onTap: _canSave() ? _saveRecipe : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _canSave() ? AppColors.primaryGradient : null,
                    color: _canSave() ? null : AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '保存',
                    style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                      color: _canSave() ? Colors.white : AppColors.getTextSecondaryColor(isDark),
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent(bool isDark) {
    return Container(
      margin: EdgeInsets.only(
        top: 80, // AppBar高度
        left: AppSpacing.md, // 减少边距
        right: AppSpacing.md,
        bottom: 0,
      ),
      child: !_isBasicInfoComplete 
          ? _buildBasicInfoStep(isDark)
          : _buildStepsEditingMode(isDark),
    );
  }
  
  Widget _buildBasicInfoStep(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 100), // 底部留空避免被操作栏遮挡
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部空间
          Space.h24,
          
          // 主要内容 - 无卡片，直接全屏展示
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 食谱图标选择 - 更突出
              Center(
                child: Column(
                  children: [
                    Text(
                      '选择你的食谱图标',
                      style: AppTypography.titleLargeStyle(isDark: isDark).copyWith(
                        fontWeight: AppTypography.light,
                      ),
                    ),
                    
                    Space.h24,
                    
                    _buildIconSelector(isDark),
                  ],
                ),
              ),
              
              Space.h48,
              
              // 食谱名称 - 全宽输入
              _buildSectionTitle('给你的食谱起个名字', isDark),
              Space.h16,
              _buildFullWidthTextField(
                controller: _nameController,
                hintText: '比如：爱心红烧肉',
                isDark: isDark,
                isLarge: true,
              ),
              
              Space.h32,
              
              // 食谱描述
              _buildSectionTitle('简单介绍一下这道菜', isDark),
              Space.h16,
              _buildFullWidthTextField(
                controller: _descriptionController,
                hintText: '告诉TA这道菜的特别之处...',
                isDark: isDark,
                maxLines: 4,
              ),
              
              Space.h32,
              
              // 难度和份量 - 并排布局
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('制作难度', isDark),
                        Space.h12,
                        _buildDifficultySelector(isDark),
                      ],
                    ),
                  ),
                  
                  Space.w24,
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('几人份', isDark),
                        Space.h12,
                        _buildFullWidthTextField(
                          controller: _servingsController,
                          hintText: '2',
                          isDark: isDark,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepsEditingMode(bool isDark) {
    return Column(
      children: [
        // 步骤列表
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _steps.length,
            padding: EdgeInsets.only(bottom: AppSpacing.lg), // 底部留白
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _buildStepEditCard(_steps[index], index + 1, isDark),
              );
            },
          ),
        ),
        
        Space.h16,
        
        // 添加步骤按钮
        GestureDetector(
          onTap: _addStep,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(
                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: AppColors.getTextSecondaryColor(isDark),
                  size: 20,
                ),
                
                Space.w8,
                
                Text(
                  '添加步骤',
                  style: AppTypography.bodyMediumStyle(isDark: isDark),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildIconSelector(bool isDark) {
    final icons = [
      AppIcon3DType.heart,
      AppIcon3DType.bowl,
      AppIcon3DType.spoon,
      AppIcon3DType.chef,
      AppIcon3DType.timer,
      AppIcon3DType.recipe,
    ];
    
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: icons.map((iconType) {
        final isSelected = _selectedIconType == iconType;
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedIconType = iconType;
            });
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.getTextSecondaryColor(isDark).withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(
                color: isSelected 
                    ? AppColors.primary
                    : AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: AppIcon3D(
                type: iconType,
                size: 40,
                isAnimated: isSelected,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildDifficultySelector(bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.getBackgroundSecondaryColor(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: Row(
        children: _difficultyLevels.map((difficulty) {
          final isSelected = _selectedDifficulty == difficulty;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedDifficulty = difficulty;
                });
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                ),
                child: Center(
                  child: Text(
                    difficulty,
                    style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                      color: isSelected ? Colors.white : AppColors.getTextSecondaryColor(isDark),
                      fontWeight: isSelected ? AppTypography.medium : AppTypography.light,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackgroundSecondaryColor(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: AppTypography.bodyMediumStyle(isDark: isDark),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.lg),
        ),
        onChanged: (value) {
          setState(() {}); // 触发重建检查完成状态
        },
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
        fontWeight: AppTypography.light,
        letterSpacing: 0.5,
      ),
    );
  }
  
  Widget _buildFullWidthTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isLarge = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.getBackgroundColor(isDark).withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(isDark).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: isLarge 
            ? AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                fontWeight: AppTypography.light,
              )
            : AppTypography.bodyMediumStyle(isDark: isDark),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: (isLarge 
              ? AppTypography.titleMediumStyle(isDark: isDark) 
              : AppTypography.bodyMediumStyle(isDark: isDark)).copyWith(
            color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.6),
            fontWeight: AppTypography.light,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(isLarge ? AppSpacing.xl : AppSpacing.lg),
        ),
        onChanged: (value) {
          setState(() {}); // 触发重建检查完成状态
        },
      ),
    );
  }
  
  Widget _buildStepEditCard(CreateRecipeStep step, int stepNumber, bool isDark) {
    return MinimalCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 步骤标题行
          Row(
            children: [
              // 步骤编号
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                ),
                child: Center(
                  child: Text(
                    stepNumber.toString(),
                    style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                      color: Colors.white,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ),
              ),
              
              Space.w12,
              
              // 步骤标题输入
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '步骤标题',
                    hintStyle: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                      color: AppColors.getTextSecondaryColor(isDark),
                    ),
                    border: InputBorder.none,
                  ),
                  style: AppTypography.titleMediumStyle(isDark: isDark),
                  onChanged: (value) {
                    step.title = value;
                  },
                ),
              ),
              
              // 时长设置
              _buildTimeSelector(step, isDark),
              
              // 删除按钮
              if (_steps.length > 1)
                GestureDetector(
                  onTap: () => _removeStep(stepNumber - 1),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          
          Space.h12,
          
          // 步骤描述
          TextField(
            decoration: InputDecoration(
              hintText: '详细描述这个步骤的操作',
              hintStyle: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
              ),
              border: InputBorder.none,
            ),
            style: AppTypography.bodyMediumStyle(isDark: isDark),
            maxLines: 3,
            onChanged: (value) {
              step.description = value;
            },
          ),
          
          Space.h12,
          
          // 小贴士
          TextField(
            decoration: InputDecoration(
              hintText: '小贴士（可选）',
              hintStyle: AppTypography.captionStyle(isDark: isDark).copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: AppColors.getTimeBasedAccent(),
              ),
            ),
            style: AppTypography.captionStyle(isDark: isDark),
            onChanged: (value) {
              step.tips = value;
            },
          ),
          
          Space.h12,
          
          // 图片上传区域
          _buildImageUploadArea(step, isDark),
        ],
      ),
    );
  }
  
  Widget _buildTimeSelector(CreateRecipeStep step, bool isDark) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (step.duration > 1) {
              setState(() {
                step.duration--;
              });
            }
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Icon(
              Icons.remove,
              size: 16,
              color: AppColors.getTextSecondaryColor(isDark),
            ),
          ),
        ),
        
        Space.w8,
        
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.getTimeBasedAccent().withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          child: Text(
            '${step.duration}分钟',
            style: AppTypography.captionStyle(isDark: isDark),
          ),
        ),
        
        Space.w8,
        
        GestureDetector(
          onTap: () {
            setState(() {
              step.duration++;
            });
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Icon(
              Icons.add,
              size: 16,
              color: AppColors.getTextSecondaryColor(isDark),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildImageUploadArea(CreateRecipeStep step, bool isDark) {
    return Container(
      height: 80,
      child: Row(
        children: [
          // 添加图片按钮
          GestureDetector(
            onTap: () => _addImageToStep(step),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                border: Border.all(
                  color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
                  style: BorderStyle.solid,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.add_a_photo,
                color: AppColors.getTextSecondaryColor(isDark),
                size: 24,
              ),
            ),
          ),
          
          Space.w8,
          
          // 已添加的图片预览
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: step.imageUrls.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: AppSpacing.sm),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // 点击查看大图
                          ImagePickerHelper.showImagePreview(context, step.imageUrls[index]);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                            ),
                            child: step.imageUrls[index].startsWith('data:') || step.imageUrls[index].startsWith('http')
                                ? Image.network(
                                    step.imageUrls[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                                        child: Icon(Icons.error, color: Colors.red, size: 24),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / 
                                                  loadingProgress.expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                                    child: const Icon(Icons.image, color: Colors.grey, size: 24),
                                  ),
                          ),
                        ),
                      ),
                      
                      // 删除按钮
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImageFromStep(step, index),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomActions(bool isDark) {
    if (!_isBasicInfoComplete) {
      return _buildBasicInfoActions(isDark);
    }
    
    // 步骤编辑模式隐藏底部操作栏，使用AppBar中的保存按钮
    return const SizedBox.shrink();
  }
  
  Widget _buildBasicInfoActions(bool isDark) {
    final isComplete = _nameController.text.isNotEmpty && 
                      _descriptionController.text.isNotEmpty;
    
    return Container(
      margin: EdgeInsets.all(AppSpacing.lg),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.getBackgroundColor(isDark).withOpacity(0.9),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getShadowColor(isDark).withOpacity(0.1),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: GestureDetector(
                onTap: isComplete ? _proceedToSteps : null,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isComplete 
                        ? AppColors.primaryGradient
                        : LinearGradient(colors: [
                            AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
                            AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
                          ]),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    boxShadow: isComplete ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      '继续添加步骤 →',
                      style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                        color: Colors.white,
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStepsActions(bool isDark) {
    final canSave = _steps.isNotEmpty && 
                   _steps.every((step) => step.title.isNotEmpty && step.description.isNotEmpty);
    
    return Row(
      children: [
        // 返回基本信息
        GestureDetector(
          onTap: () {
            setState(() {
              _isBasicInfoComplete = false;
            });
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.getBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getShadowColor(isDark),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.getTextSecondaryColor(isDark),
              size: 24,
            ),
          ),
        ),
        
        Space.w16,
        
        // 保存食谱
        Expanded(
          child: GestureDetector(
            onTap: canSave ? _saveRecipe : null,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: canSave 
                    ? AppColors.primaryGradient
                    : LinearGradient(colors: [
                        AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
                        AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
                      ]),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                boxShadow: canSave ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Center(
                child: Text(
                  '保存食谱',
                  style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                    color: Colors.white,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // ==================== 交互方法 ====================
  
  int _getCurrentProgress() {
    if (!_isBasicInfoComplete) {
      return _nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty ? 30 : 10;
    }
    
    final completedSteps = _steps.where((step) => 
        step.title.isNotEmpty && step.description.isNotEmpty).length;
    
    return 30 + ((completedSteps / _steps.length) * 70).round();
  }
  
  bool _canSave() {
    if (!_isBasicInfoComplete) {
      return _nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty;
    }
    
    return _steps.isNotEmpty && 
           _steps.every((step) => step.title.isNotEmpty && step.description.isNotEmpty);
  }
  
  void _proceedToSteps() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isBasicInfoComplete = true;
    });
  }
  
  void _addStep() {
    HapticFeedback.lightImpact();
    setState(() {
      _steps.add(CreateRecipeStep(
        title: '',
        description: '',
        duration: 5,
        tips: '',
      ));
    });
    
    // 自动滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _removeStep(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _steps.removeAt(index);
    });
  }
  
  void _addImageToStep(CreateRecipeStep step) async {
    HapticFeedback.lightImpact();
    
    try {
      final imageUrl = await ImagePickerHelper.showImagePickerDialog(context);
      
      if (imageUrl != null) {
        setState(() {
          step.imageUrls.add(imageUrl);
        });
        
        // 显示成功反馈
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                Space.w8,
                Text('图片添加成功！'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // 显示错误反馈
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              Space.w8,
              Text('图片添加失败，请重试'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  void _removeImageFromStep(CreateRecipeStep step, int index) {
    HapticFeedback.lightImpact();
    setState(() {
      step.imageUrls.removeAt(index);
    });
  }
  
  void _saveRecipe() {
    HapticFeedback.mediumImpact();
    
    // TODO: 实现保存到数据库
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('食谱 "${_nameController.text}" 创建成功！'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: '查看',
          onPressed: () {
            // 导航到食谱详情页面
            context.pop();
          },
        ),
      ),
    );
    
    // 延迟返回主页
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.pop();
      }
    });
  }
}

// ==================== 数据模型 ====================

class CreateRecipeStep {
  String title;
  String description;
  int duration;
  String tips;
  List<String> imageUrls;
  
  CreateRecipeStep({
    required this.title,
    required this.description,
    required this.duration,
    this.tips = '',
    List<String>? imageUrls,
  }) : imageUrls = imageUrls ?? [];
}