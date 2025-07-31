import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:io';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../../../shared/widgets/app_icon_3d.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../domain/models/recipe.dart';
import '../../data/repositories/recipe_repository.dart';

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
  
  // 🎨 新增：封面图片管理
  String? _coverImagePath;
  
  // 页面状态
  bool _isBasicInfoComplete = false;
  int _currentStepIndex = 0;
  final PageController _stepPageController = PageController();
  
  // 🔥 步骤控制器管理 - 为每个步骤创建独立的文本控制器
  final List<Map<String, TextEditingController>> _stepControllers = [];
  
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
    _stepPageController.dispose();
    for (var controllers in _stepControllers) {
      controllers['title']?.dispose();
      controllers['description']?.dispose();
    }
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
    
    // 🔥 修复：同时创建对应的文本控制器
    _stepControllers.add({
      'title': TextEditingController(),
      'description': TextEditingController(),
    });
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
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(
          top: 80, // AppBar高度
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: 0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔧 优化布局：左侧基本信息区域（占50%宽度）- 扩大基本信息区域
            Expanded(
              flex: 5,
              child: _buildBasicInfoPanel(isDark),
            ),
            
            Space.w16, // 左右间距
            
            // 🔧 优化布局：右侧步骤编辑区域（占50%宽度）- 缩小步骤区域
            Expanded(
              flex: 5,
              child: _buildStepsPanel(isDark),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 🔧 新增：左侧基本信息面板
  Widget _buildBasicInfoPanel(bool isDark) {
    return BreathingWidget(
      child: MinimalCard(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 面板标题
            Text(
              '基本信息',
              style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                fontWeight: AppTypography.medium,
              ),
            ),
            
            Space.h24,
            
            // 内容区域 - 可滚动
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 食谱图标选择 - 🔧 增强版：更大图标，更好的用户体验
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '选择食谱图标',
                            style: AppTypography.titleMediumStyle(isDark: isDark).copyWith( // 更大标题
                              fontWeight: AppTypography.light,
                              color: AppColors.getTextPrimaryColor(isDark),
                            ),
                          ),
                          Space.h16, // 增加间距
                          _buildEnhancedIconSelector(isDark), // 使用增强版图标选择器
                        ],
                      ),
                    ),
                    
                    Space.h24,
                    
                    // 🎨 新增：封面图片上传区域 - 200px高度
                    _buildCoverImageUpload(isDark),
                    
                    Space.h24,
                    
                    // 食谱名称 - 🔧 增强版：更大字体，更好的视觉效果
                    _buildEnhancedTextField(
                      label: '菜谱名称',
                      controller: _nameController,
                      hintText: '比如：蜜汁红烧肉、爱心蛋挞...',
                      isDark: isDark,
                      isLarge: true, // 更大的输入框
                    ),
                    
                    Space.h24, // 增加间距
                    
                    // 食谱描述 - 🔧 增强版：更大文本区域
                    _buildEnhancedTextField(
                      label: '菜谱描述',  
                      controller: _descriptionController,
                      hintText: '描述这道菜的特色和故事...',
                      maxLines: 4, // 增加行数
                      isDark: isDark,
                    ),
                    
                    Space.h16,
                    
                    // 份数和难度
                    Row(
                      children: [
                        Expanded(
                          child: _buildCompactTextField(
                            label: '份数',
                            controller: _servingsController,
                            hintText: '几人份',
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                        ),
                        Space.w12,
                        Expanded(
                          child: _buildCompactDifficultySelector(isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 🔥 完全重构：与烹饪模式对齐的步骤编辑面板
  /// 一次只显示一个步骤，占满整个页面，格式与烹饪模式完全一致
  Widget _buildStepsPanel(bool isDark) {
    return BreathingWidget(
      child: MinimalCard(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔧 缩小标题区域，优化空间利用
            _buildStepsHeader(isDark),
            
            Space.h12, // 减少间距
            
            // 🔥 全屏步骤编辑界面 - 与烹饪模式格式完全一致
            Expanded(
              child: _steps.isEmpty
                  ? _buildFirstStepCreator(isDark)
                  : _buildCookingModeStepEditor(isDark),
            ),
          ],
        ),
      ),
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
      height: 120, // 🎨 从80px调整为120px，符合1.html设计
      child: Row(
        children: [
          // 添加图片按钮 - 🎨 调整为120px高度
          GestureDetector(
            onTap: () => _addImageToStep(step),
            child: Container(
              width: 120, // 🎨 从80px调整为120px
              height: 120, // 🎨 从80px调整为120px
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
                            width: 120, // 🎨 从80px调整为120px
                            height: 120, // 🎨 从80px调整为120px
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
  
  void _addNewStep() {
    HapticFeedback.lightImpact();
    setState(() {
      // 添加新步骤
      _steps.add(CreateRecipeStep(
        title: '',
        description: '',
        duration: 5,
        tips: '',
      ));
      
      // 🔥 为新步骤创建控制器
      _stepControllers.add({
        'title': TextEditingController(),
        'description': TextEditingController(),
      });
      
      _currentStepIndex = _steps.length - 1;
    });
    
    // 🔥 自动导航到新步骤（延迟执行避免构建冲突）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stepPageController.hasClients) {
        _stepPageController.animateToPage(
          _currentStepIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
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
  
  void _removeStep(int index) {
    HapticFeedback.lightImpact();
    
    if (index < 0 || index >= _steps.length) return;
    
    setState(() {
      // 🔥 移除步骤和对应的控制器
      _steps.removeAt(index);
      
      // 销毁对应的控制器
      if (index < _stepControllers.length) {
        _stepControllers[index]['title']?.dispose();
        _stepControllers[index]['description']?.dispose();
        _stepControllers.removeAt(index);
      }
      
      // 调整当前步骤索引
      if (_currentStepIndex >= _steps.length && _steps.isNotEmpty) {
        _currentStepIndex = _steps.length - 1;
      } else if (_steps.isEmpty) {
        _currentStepIndex = 0;
      }
    });
    
    // 🔥 导航到正确的步骤页面
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stepPageController.hasClients && _steps.isNotEmpty) {
        _stepPageController.animateToPage(
          _currentStepIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }
  
  // ==================== 新的横向布局辅助方法 ====================
  
  /// 紧凑的图标选择器
  /// 🔧 增强版图标选择器 - 更大图标，更好用户体验
  Widget _buildEnhancedIconSelector(bool isDark) {
    return Wrap(
      spacing: 12, // 增加间距
      runSpacing: 12,
      children: AppIcon3DType.values.map((iconType) {
        final isSelected = _selectedIconType == iconType;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedIconType = iconType;
            });
          },
          child: Container(
            width: 60, // 更大图标容器
            height: 60,
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.primaryGradient : null,
              color: isSelected ? null : AppColors.getBackgroundSecondaryColor(isDark),
              borderRadius: BorderRadius.circular(30),
              border: isSelected 
                ? null 
                : Border.all(color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.3)),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: AppIcon3D(
              type: iconType,
              size: 36, // 更大图标
              isAnimated: false,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompactIconSelector(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppIcon3DType.values.map((iconType) {
        final isSelected = _selectedIconType == iconType;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedIconType = iconType;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.primaryGradient : null,
              color: isSelected ? null : AppColors.getBackgroundSecondaryColor(isDark),
              borderRadius: BorderRadius.circular(20),
              border: isSelected 
                ? null 
                : Border.all(color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.3)),
            ),
            child: AppIcon3D(
              type: iconType,
              size: 24,
              isAnimated: false,
            ),
          ),
        );
      }).toList(),
    );
  }
  
  /// 🔧 增强版文本输入框 - 更大字体，更好视觉效果
  Widget _buildEnhancedTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isLarge = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith( // 更大标签
            color: AppColors.getTextPrimaryColor(isDark),
            fontWeight: AppTypography.medium,
          ),
        ),
        Space.h12, // 更大间距
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.bodyMediumStyle(isDark: isDark).copyWith( // 更大提示文字
              color: AppColors.getTextSecondaryColor(isDark),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge), // 更大圆角
              borderSide: BorderSide(
                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2, // 更粗的聚焦边框
              ),
            ),
            contentPadding: EdgeInsets.all(isLarge ? AppSpacing.lg : AppSpacing.md), // 动态内边距
            filled: true,
            fillColor: AppColors.getBackgroundSecondaryColor(isDark),
          ),
          style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith( // 更大输入文字
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// 紧凑的文本输入框
  Widget _buildCompactTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
            fontWeight: AppTypography.medium,
          ),
        ),
        Space.h8,
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
              color: AppColors.getTextSecondaryColor(isDark),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide: BorderSide(
                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: EdgeInsets.all(AppSpacing.md),
            filled: true,
            fillColor: AppColors.getBackgroundSecondaryColor(isDark),
          ),
          style: AppTypography.bodySmallStyle(isDark: isDark),
        ),
      ],
    );
  }
  
  /// 紧凑的难度选择器
  Widget _buildCompactDifficultySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '难度',
          style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
            fontWeight: AppTypography.medium,
          ),
        ),
        Space.h8,
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.getBackgroundSecondaryColor(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(
              color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDifficulty,
              isExpanded: true,
              style: AppTypography.bodySmallStyle(isDark: isDark),
              items: _difficultyLevels.map((String difficulty) {
                return DropdownMenuItem<String>(
                  value: difficulty,
                  child: Text(difficulty),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedDifficulty = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
  
  /// 空步骤状态
  Widget _buildEmptyStepsState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 48,
            color: AppColors.getTextSecondaryColor(isDark),
          ),
          Space.h12,
          Text(
            '还没有添加步骤',
            style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
              color: AppColors.getTextSecondaryColor(isDark),
            ),
          ),
          Space.h8,
          Text(
            '点击上方"添加步骤"开始创建',
            style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
              color: AppColors.getTextSecondaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 紧凑的步骤卡片
  Widget _buildCompactStepCard(
    CreateRecipeStep step,
    int stepNumber,
    bool isActive,
    bool isDark, {
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive 
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.getBackgroundSecondaryColor(isDark),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          border: isActive 
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
            : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              // 步骤编号
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: isActive ? AppColors.primaryGradient : null,
                  color: isActive ? null : AppColors.getTextSecondaryColor(isDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    stepNumber.toString(),
                    style: AppTypography.captionStyle(isDark: false).copyWith(
                      color: Colors.white,
                      fontWeight: AppTypography.medium,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              
              Space.w8,
              
              // 步骤内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (step.title.isNotEmpty) ...[
                      Text(
                        step.title,
                        style: AppTypography.captionStyle(isDark: isDark).copyWith(
                          fontWeight: AppTypography.medium,
                          color: AppColors.getTextPrimaryColor(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    Text(
                      step.description.isEmpty ? '空步骤' : step.description,
                      style: AppTypography.captionStyle(isDark: isDark).copyWith(
                        color: AppColors.getTextSecondaryColor(isDark),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // 删除按钮
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveRecipe() async {
    HapticFeedback.mediumImpact();
    
    try {
      // 🔧 修复bug：使用异步初始化的Repository确保数据库已准备好
      final repository = await ref.read(initializedRecipeRepositoryProvider.future);
      
      // 生成唯一ID
      final recipeId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // 转换步骤数据
      final List<RecipeStep> recipeSteps = [];
      for (int i = 0; i < _steps.length; i++) {
        final createStep = _steps[i];
        
        // 处理步骤图片
        String? stepImagePath;
        if (createStep.imageUrls.isNotEmpty) {
          // 假设imageUrls[0]是文件路径，需要保存到应用目录
          final imageFile = File(createStep.imageUrls[0]);
          if (await imageFile.exists()) {
            stepImagePath = await repository.saveImageFile(
              imageFile, 
              recipeId, 
              stepId: i.toString()
            );
          }
        }
        
        recipeSteps.add(RecipeStep(
          title: createStep.title,
          description: createStep.description,
          duration: createStep.duration,
          tips: createStep.tips.isEmpty ? null : createStep.tips,
          imagePath: stepImagePath,
          ingredients: [], // TODO: 后续版本可以添加食材输入
        ));
      }
      
      // 🎨 处理封面图片保存
      String? savedCoverImagePath;
      if (_coverImagePath != null) {
        final coverImageFile = File(_coverImagePath!);
        if (await coverImageFile.exists()) {
          savedCoverImagePath = await repository.saveImageFile(
            coverImageFile, 
            recipeId,
            // 不传stepId，将保存为主图片（cover）
          );
        }
      }
      
      // 计算总时长
      final totalTime = recipeSteps.fold(0, (sum, step) => sum + step.duration);
      
      // 创建Recipe对象
      final recipe = Recipe(
        id: recipeId,
        name: _nameController.text,
        description: _descriptionController.text,
        iconType: _selectedIconType.toString(), // 转换为字符串存储
        totalTime: totalTime,
        difficulty: _selectedDifficulty,
        servings: int.tryParse(_servingsController.text) ?? 2,
        steps: recipeSteps,
        imagePath: savedCoverImagePath, // 🎨 保存封面图片路径
        createdBy: 'current_user', // TODO: 集成用户系统后使用真实用户ID
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPublic: true,
        rating: 0.0,
        cookCount: 0,
      );
      
      // 保存到数据库
      await repository.saveRecipe(recipe);
      
      // 🔧 修复bug：保存成功后跳转到菜谱详情页，而不是直接退出
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('食谱 "${recipe.name}" 创建成功！'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: '查看',
              textColor: Colors.white,
              onPressed: () {
                context.go('/recipe/${recipe.id}');
              },
            ),
          ),
        );
        
        // 短暂延迟后自动跳转到详情页
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            context.go('/recipe/${recipe.id}');
          }
        });
      }
      
    } catch (e) {
      // 错误处理
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败：$e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
      print('保存菜谱失败: $e');
    }
  }
  
  // ==================== 🔥 新的烹饪模式风格步骤编辑方法 ====================
  
  /// 🔧 缩小的步骤标题区域
  /// 🔧 紧凑化步骤头部 - 减少垂直空间占用，优化布局
  Widget _buildStepsHeader(bool isDark) {
    return Container(
      height: 40, // 限制头部高度
      child: Row(
        children: [
          Text(
            '制作步骤',
            style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith( // 进一步减小字体
              fontWeight: AppTypography.medium,
            ),
          ),
          const Spacer(),
          if (_steps.isNotEmpty) ...[ 
            // 步骤导航指示器 - 更紧凑
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs, // 减少内边距
                vertical: 4, // 减少垂直内边距
              ),
              decoration: BoxDecoration(
                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Text(
                '${_currentStepIndex + 1}/${_steps.length}',
                style: AppTypography.captionStyle(isDark: isDark).copyWith(
                  color: AppColors.getTextSecondaryColor(isDark),
                  fontWeight: AppTypography.medium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// 🔥 首次创建步骤界面 - 引导用户创建第一个步骤
  Widget _buildFirstStepCreator(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 大号图标，模拟烹饪模式样式
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '🍳',
                style: const TextStyle(fontSize: 60), // 与烹饪模式一致的大图标
              ),
            ),
          ),
          
          Space.h24,
          
          Text(
            '开始创建第一个步骤',
            style: AppTypography.customStyle(
              fontSize: 32, // 接近烹饪模式的48px，但适合创建界面
              fontWeight: AppTypography.light,
              isDark: isDark,
            ),
          ),
          
          Space.h12,
          
          Text(
            '每个步骤都会以全屏形式呈现\n就像烹饪模式一样清晰易懂',
            style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
              color: AppColors.getTextSecondaryColor(isDark),
              height: 1.8, // 与烹饪模式一致的行高
            ),
            textAlign: TextAlign.center,
          ),
          
          Space.h32,
          
          // 开始创建按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _addNewStep();
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  Space.w8,
                  Text(
                    '创建第一步',
                    style: AppTypography.bodyLargeStyle(isDark: false).copyWith(
                      color: Colors.white,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 🔥 烹饪模式风格的步骤编辑器 - 完全对齐格式
  Widget _buildCookingModeStepEditor(bool isDark) {
    // 🔥 修复：添加安全检查
    if (_steps.isEmpty || _stepControllers.isEmpty) {
      return Center(
        child: Text(
          '暂无步骤',
          style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
          ),
        ),
      );
    }
    
    return PageView.builder(
      controller: _stepPageController,
      onPageChanged: (index) {
        setState(() {
          _currentStepIndex = index;
        });
      },
      itemCount: _steps.length,
      itemBuilder: (context, index) {
        return _buildSingleStepEditor(index, isDark);
      },
    );
  }
  
  /// 🔥 单个步骤编辑器 - 完全模拟烹饪模式布局
  Widget _buildSingleStepEditor(int stepIndex, bool isDark) {
    // 🔥 修复：添加边界检查
    if (stepIndex >= _stepControllers.length) {
      return Center(
        child: Text(
          '步骤数据错误',
          style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            color: Colors.red,
          ),
        ),
      );
    }
    
    final stepControllers = _stepControllers[stepIndex];
    final titleController = stepControllers['title']!;
    final descriptionController = stepControllers['description']!;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 步骤标题区 - 完全模拟烹饪模式
          Row(
            children: [
              // 步骤图标 - 减小尺寸以适应横屏布局
              Container(
                width: 60, // 从80减少到60
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12, // 减小阴影
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getStepIcon(stepIndex),
                    style: const TextStyle(fontSize: 30), // 减小图标
                  ),
                ),
              ),
              
              Space.w12,
              
              // 步骤信息区
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '第${stepIndex + 1}步',
                      style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                        color: AppColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                    
                    Space.h4,
                    
                    // 步骤标题输入框 - 减小字体以适应横屏
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: titleController.text.isEmpty 
                                ? Colors.red.withOpacity(0.3)
                                : AppColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: TextField(
                        controller: titleController,
                        style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                          fontWeight: AppTypography.medium,
                        ),
                        decoration: InputDecoration(
                          hintText: '步骤标题（如：准备食材）',
                          hintStyle: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                            color: AppColors.getTextSecondaryColor(isDark),
                            fontWeight: AppTypography.light,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          // 🔥 修复：同步更新步骤数据
                          if (stepIndex < _steps.length) {
                            _steps[stepIndex].title = value;
                          }
                          setState(() {}); // 更新边框颜色
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          Space.h16,
          
          // 🔥 步骤描述区 - 与烹饪模式布局一致，但更紧凑
          Text(
            '详细描述',
            style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
              color: AppColors.getTextSecondaryColor(isDark),
              fontWeight: AppTypography.medium,
            ),
          ),
          
          Space.h8,
          
          // 🔧 修复溢出：使用Expanded包装输入框确保不溢出
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.getBackgroundSecondaryColor(isDark),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                border: Border.all(
                  color: descriptionController.text.isEmpty 
                      ? Colors.red.withOpacity(0.3)
                      : AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: descriptionController,
                maxLines: null, // 自适应高度
                expands: true, // 填满容器
                textAlignVertical: TextAlignVertical.top,
                style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                  height: 1.4,
                  fontWeight: AppTypography.light,
                ),
                decoration: InputDecoration(
                  hintText: '详细描述操作步骤...',
                  hintStyle: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                    color: AppColors.getTextSecondaryColor(isDark),
                    height: 1.4,
                    fontWeight: AppTypography.light,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(AppSpacing.sm),
                ),
                onChanged: (value) {
                  // 🔥 修复：同步更新步骤数据
                  if (stepIndex < _steps.length) {
                    _steps[stepIndex].description = value;
                  }
                  setState(() {}); // 更新边框颜色
                },
              ),
            ),
          ),
          
          Space.h12,
          
          // 🔧 操作区域 - 紧凑布局
          Row(
            children: [
              // 时长设置
              Expanded(
                child: _buildNewTimeSelector(stepIndex, isDark),
              ),
              
              Space.w12,
              
              // 删除步骤按钮
              if (_steps.length > 1)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _removeStep(stepIndex);
                  },
                  child: Container(
                    width: 36, // 减小尺寸
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
          
          Space.h12,
          
          // 🔥 底部导航区域 - 与烹饪模式风格一致
          _buildStepNavigation(stepIndex, isDark),
        ],
      ),
    );
  }
  
  /// 🔥 步骤导航区域 - 模拟烹饪模式的导航控制
  Widget _buildStepNavigation(int stepIndex, bool isDark) {
    return Row(
      children: [
        // 上一步按钮
        if (stepIndex > 0)
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _stepPageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundSecondaryColor(isDark),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chevron_left,
                      color: AppColors.getTextSecondaryColor(isDark),
                      size: 20,
                    ),
                    Space.w4,
                    Text(
                      '上一步',
                      style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                        color: AppColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        if (stepIndex > 0) Space.w12,
        
        // 主操作按钮
        Expanded(
          flex: stepIndex == _steps.length - 1 ? 2 : 1,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              if (stepIndex == _steps.length - 1) {
                // 最后一步：添加新步骤
                _addNewStep();
              } else {
                // 不是最后一步：下一步
                _stepPageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (stepIndex == _steps.length - 1) ...[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                    Space.w4,
                    Text(
                      '继续添加',
                      style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                        color: Colors.white,
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '下一步',
                      style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                        color: Colors.white,
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                    Space.w4,
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// 获取步骤图标
  String _getStepIcon(int stepIndex) {
    final icons = ['🥄', '🔥', '🍳', '⏰', '✨', '🍽️', '💫', '🎯'];
    return icons[stepIndex % icons.length];
  }
  
  // ==================== 🎨 封面图片上传功能 ====================
  
  /// 🎨 封面图片上传区域 - 200px高度，符合1.html设计
  Widget _buildCoverImageUpload(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '菜谱封面图片',
          style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
            color: AppColors.getTextPrimaryColor(isDark),
            fontWeight: AppTypography.medium,
          ),
        ),
        Space.h12,
        
        GestureDetector(
          onTap: _selectCoverImage,
          child: Container(
            width: double.infinity,
            height: 200, // 🎨 200px高度，符合1.html设计
            decoration: BoxDecoration(
              color: _coverImagePath == null 
                  ? AppColors.getBackgroundSecondaryColor(isDark)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(
                color: _coverImagePath == null
                    ? AppColors.getTextSecondaryColor(isDark).withOpacity(0.3)
                    : AppColors.primary.withOpacity(0.3),
                width: 2,
                style: _coverImagePath == null ? BorderStyle.solid : BorderStyle.solid,
              ),
            ),
            child: _coverImagePath == null
                ? _buildCoverUploadPlaceholder(isDark)
                : _buildCoverImagePreview(isDark),
          ),
        ),
        
        if (_coverImagePath != null) ...[
          Space.h8,
          Text(
            '💡 点击图片可重新选择或编辑',
            style: AppTypography.captionStyle(isDark: isDark).copyWith(
              color: AppColors.getTextSecondaryColor(isDark),
            ),
          ),
        ],
      ],
    );
  }
  
  /// 封面上传占位符
  Widget _buildCoverUploadPlaceholder(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient.scale(0.3),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Icon(
            Icons.add_a_photo,
            size: 32,
            color: AppColors.primary,
          ),
        ),
        
        Space.h16,
        
        Text(
          '点击上传封面图片',
          style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            color: AppColors.getTextPrimaryColor(isDark),
            fontWeight: AppTypography.medium,
          ),
        ),
        
        Space.h4,
        
        Text(
          '建议尺寸 4:3，最大5MB',
          style: AppTypography.captionStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
          ),
        ),
        
        Space.h12,
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildUploadActionButton('📷', '拍照', isDark, () => _selectCoverImage(useCamera: true)),
            Space.w16,
            _buildUploadActionButton('🖼️', '相册', isDark, () => _selectCoverImage(useCamera: false)),
          ],
        ),
      ],
    );
  }
  
  /// 封面图片预览
  Widget _buildCoverImagePreview(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge - 2),
      child: Stack(
        children: [
          // 图片显示
          _coverImagePath!.startsWith('data:') || _coverImagePath!.startsWith('http')
              ? Image.network(
                  _coverImagePath!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 32),
                            Space.h8,
                            Text('图片加载失败', style: AppTypography.captionStyle(isDark: isDark)),
                          ],
                        ),
                      ),
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
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                  child: Center(
                    child: Icon(Icons.image, color: Colors.grey, size: 48),
                  ),
                ),
          
          // 操作按钮浮层
          Positioned(
            top: 12,
            right: 12,
            child: Row(
              children: [
                _buildFloatingActionButton(
                  Icons.edit,
                  '编辑',
                  () => _selectCoverImage(),
                ),
                Space.w8,
                _buildFloatingActionButton(
                  Icons.delete,
                  '删除',
                  _removeCoverImage,
                  isDestructive: true,
                ),
              ],
            ),
          ),
          
          // 图片信息浮层
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                '菜谱封面图片',
                style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                  color: Colors.white,
                  fontWeight: AppTypography.medium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 上传操作按钮
  Widget _buildUploadActionButton(
    String icon, 
    String label, 
    bool isDark, 
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: 16),
            ),
            Space.w4,
            Text(
              label,
              style: AppTypography.captionStyle(isDark: isDark).copyWith(
                color: AppColors.primary,
                fontWeight: AppTypography.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 浮动操作按钮
  Widget _buildFloatingActionButton(
    IconData icon,
    String tooltip,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDestructive 
              ? Colors.red.withOpacity(0.9)
              : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDestructive 
                  ? Colors.red.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
  
  /// 选择封面图片
  void _selectCoverImage({bool? useCamera}) async {
    HapticFeedback.lightImpact();
    
    try {
      String? imageUrl;
      
      if (useCamera == true) {
        // 强制使用相机
        imageUrl = await ImagePickerHelper.takePhotoFromCamera(context);
      } else if (useCamera == false) {
        // 强制使用相册
        imageUrl = await ImagePickerHelper.pickImageFromGallery(context);
      } else {
        // 显示选择对话框
        imageUrl = await ImagePickerHelper.showImagePickerDialog(context);
      }
      
      if (imageUrl != null) {
        setState(() {
          _coverImagePath = imageUrl;
        });
        
        // 显示成功反馈
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                Space.w8,
                Text('封面图片设置成功！'),
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
              Text('图片选择失败，请重试'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  /// 删除封面图片
  void _removeCoverImage() {
    HapticFeedback.lightImpact();
    setState(() {
      _coverImagePath = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white, size: 20),
            Space.w8,
            Text('封面图片已移除'),
          ],
        ),
        backgroundColor: AppColors.getTextSecondaryColor(Theme.of(context).brightness == Brightness.dark),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// 新的时长选择器 - 紧凑化设计
  Widget _buildNewTimeSelector(int stepIndex, bool isDark) {
    final duration = _steps[stepIndex].duration;
    
    return Container(
      height: 36, // 减小高度
      decoration: BoxDecoration(
        color: AppColors.getBackgroundSecondaryColor(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Row(
        children: [
          Space.w8,
          
          GestureDetector(
            onTap: () {
              if (duration > 1) {
                setState(() {
                  _steps[stepIndex].duration = duration - 1;
                });
              }
            },
            child: Container(
              width: 24, // 减小尺寸
              height: 24,
              decoration: BoxDecoration(
                color: duration > 1 
                    ? AppColors.getTextSecondaryColor(isDark).withOpacity(0.1)
                    : AppColors.getTextSecondaryColor(isDark).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.remove,
                size: 14,
                color: duration > 1 
                    ? AppColors.getTextSecondaryColor(isDark)
                    : AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
              ),
            ),
          ),
          
          Expanded(
            child: Center(
              child: Text(
                '$duration分钟',
                style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                  fontWeight: AppTypography.medium,
                ),
              ),
            ),
          ),
          
          GestureDetector(
            onTap: () {
              setState(() {
                _steps[stepIndex].duration = duration + 1;
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add,
                size: 14,
                color: AppColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
          
          Space.w8,
        ],
      ),
    );
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