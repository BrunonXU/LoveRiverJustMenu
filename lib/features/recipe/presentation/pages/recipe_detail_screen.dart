import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../../../shared/widgets/app_icon_3d.dart';

/// 食谱详情页面
/// 支持修改步骤、时长记录、每步骤图片上传
class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;
  
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  bool _isEditing = false;
  int _currentStepIndex = 0;
  
  // 示例食谱数据
  late RecipeData _recipeData;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadRecipeData();
  }

  @override
  void dispose() {
    _controller.dispose();
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
  
  void _loadRecipeData() {
    // 根据ID加载对应食谱数据
    _recipeData = _getRecipeDataById(widget.recipeId);
  }
  
  RecipeData _getRecipeDataById(String recipeId) {
    final recipes = {
      'recipe_1': RecipeData(
        id: 'recipe_1',
        name: '银耳莲子羹',
        description: '滋补养颜，润燥清热的经典甜品',
        iconType: AppIcon3DType.bowl,
        totalTime: 45,
        difficulty: '简单',
        servings: 2,
        steps: [
          RecipeStep(
            title: '准备食材',
            description: '银耳15g，莲子20g，红枣6颗，冰糖适量',
            duration: 5,
            tips: '银耳要提前泡发，去除黄根部分',
          ),
          RecipeStep(
            title: '银耳处理',
            description: '将泡发的银耳撕成小朵，莲子去芯',
            duration: 10,
            tips: '银耳撕得越小，煮出来越粘稠',
          ),
          RecipeStep(
            title: '开始炖煮',
            description: '锅中加水，放入银耳大火煮开转小火',
            duration: 20,
            tips: '水要一次性加够，中途不要加水',
          ),
          RecipeStep(
            title: '加入配料',
            description: '加入莲子和红枣继续炖煮',
            duration: 15,
            tips: '莲子不要过早放入，容易煮烂',
          ),
          RecipeStep(
            title: '调味完成',
            description: '最后加入冰糖调味即可',
            duration: 2,
            tips: '冰糖的用量根据个人喜好调整',
          ),
        ],
      ),
      'recipe_2': RecipeData(
        id: 'recipe_2',
        name: '番茄鸡蛋面',
        description: '家常美味，营养丰富的经典面条',
        iconType: AppIcon3DType.spoon,
        totalTime: 15,
        difficulty: '简单',
        servings: 1,
        steps: [
          RecipeStep(
            title: '准备食材',
            description: '面条100g，鸡蛋2个，番茄2个，葱花适量',
            duration: 3,
            tips: '番茄要选择熟透的，口感更好',
          ),
          RecipeStep(
            title: '处理番茄',
            description: '番茄切块，先炒出汁水',
            duration: 5,
            tips: '番茄皮可以先用开水烫一下再去皮',
          ),
          RecipeStep(
            title: '炒制鸡蛋',
            description: '鸡蛋打散炒熟盛起备用',
            duration: 2,
            tips: '鸡蛋要炒得嫩一些，口感更好',
          ),
          RecipeStep(
            title: '下面条',
            description: '水开后下面条煮至8分熟',
            duration: 3,
            tips: '面条不要煮得太软，有嚼劲更好',
          ),
          RecipeStep(
            title: '汇合调味',
            description: '将面条、鸡蛋、番茄汇合调味',
            duration: 2,
            tips: '最后撒上葱花提味',
          ),
        ],
      ),
    };
    
    return recipes[recipeId] ?? recipes['recipe_1']!;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getTimeBasedGradient(),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // 顶部导航栏
                _buildAppBar(isDark),
                
                // 主要内容
                Expanded(
                  child: _buildMainContent(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.getBackgroundColor(isDark).withOpacity(0.9),
                borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getShadowColor(isDark),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.getTextPrimaryColor(isDark),
                size: 20,
              ),
            ),
          ),
          
          const Spacer(),
          
          // 标题
          Text(
            _recipeData.name,
            style: AppTypography.titleLargeStyle(isDark: isDark),
          ),
          
          const Spacer(),
          
          // 编辑按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isEditing 
                    ? AppColors.primary 
                    : AppColors.getBackgroundColor(isDark).withOpacity(0.9),
                borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getShadowColor(isDark),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _isEditing ? Icons.check : Icons.edit,
                color: _isEditing 
                    ? Colors.white 
                    : AppColors.getTextPrimaryColor(isDark),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent(bool isDark) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          // 食谱信息卡片
          _buildRecipeInfo(isDark),
          
          Space.h24,
          
          // 步骤列表
          Expanded(
            child: _buildStepsList(isDark),
          ),
          
          Space.h24,
          
          // 底部操作栏
          _buildBottomActions(isDark),
        ],
      ),
    );
  }
  
  Widget _buildRecipeInfo(bool isDark) {
    return BreathingWidget(
      child: MinimalCard(
        child: Column(
          children: [
            // 3D图标
            AppIcon3D(
              type: _recipeData.iconType,
              size: 80,
              isAnimated: true,
            ),
            
            Space.h16,
            
            // 食谱信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoItem(
                  icon: Icons.access_time,
                  label: '总时长',
                  value: '${_recipeData.totalTime}分钟',
                  isDark: isDark,
                ),
                _buildInfoItem(
                  icon: Icons.signal_cellular_alt,
                  label: '难度',
                  value: _recipeData.difficulty,
                  isDark: isDark,
                ),
                _buildInfoItem(
                  icon: Icons.people,
                  label: '份量',
                  value: '${_recipeData.servings}人份',
                  isDark: isDark,
                ),
              ],
            ),
            
            Space.h16,
            
            // 描述
            Text(
              _recipeData.description,
              style: AppTypography.bodyMediumStyle(isDark: isDark),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.getTextSecondaryColor(isDark),
        ),
        
        Space.h4,
        
        Text(
          label,
          style: AppTypography.captionStyle(isDark: isDark),
        ),
        
        Space.h2,
        
        Text(
          value,
          style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
            fontWeight: AppTypography.medium,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStepsList(bool isDark) {
    return ListView.builder(
      itemCount: _recipeData.steps.length,
      itemBuilder: (context, index) {
        final step = _recipeData.steps[index];
        final isActive = index == _currentStepIndex;
        
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _buildStepCard(step, index + 1, isActive, isDark),
        );
      },
    );
  }
  
  Widget _buildStepCard(RecipeStep step, int stepNumber, bool isActive, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentStepIndex = stepNumber - 1;
        });
      },
      child: MinimalCard(
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
                    color: isActive 
                        ? AppColors.primary 
                        : AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                  ),
                  child: Center(
                    child: Text(
                      stepNumber.toString(),
                      style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                        color: isActive ? Colors.white : AppColors.getTextSecondaryColor(isDark),
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                  ),
                ),
                
                Space.w12,
                
                // 步骤标题
                Expanded(
                  child: Text(
                    step.title,
                    style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                      fontWeight: isActive ? AppTypography.medium : AppTypography.light,
                    ),
                  ),
                ),
                
                // 时长
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
                
                // 编辑模式下的操作按钮
                if (_isEditing) ...[
                  Space.w8,
                  _buildStepAction(Icons.camera_alt, () => _addStepImage(stepNumber - 1), isDark),
                  Space.w4,
                  _buildStepAction(Icons.edit, () => _editStep(stepNumber - 1), isDark),
                ],
              ],
            ),
            
            Space.h12,
            
            // 步骤描述
            Text(
              step.description,
              style: AppTypography.bodyMediumStyle(isDark: isDark),
            ),
            
            if (step.tips.isNotEmpty) ...[
              Space.h8,
              
              // 小贴士
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.getTimeBasedAccent().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: AppColors.getTimeBasedAccent(),
                    ),
                    
                    Space.w8,
                    
                    Expanded(
                      child: Text(
                        step.tips,
                        style: AppTypography.captionStyle(isDark: isDark).copyWith(
                          color: AppColors.getTimeBasedAccent(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // 步骤图片
            if (step.images.isNotEmpty) ...[
              Space.h12,
              _buildStepImages(step.images, isDark),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStepAction(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        child: Icon(
          icon,
          size: 16,
          color: AppColors.getTextSecondaryColor(isDark),
        ),
      ),
    );
  }
  
  Widget _buildStepImages(List<String> images, bool isDark) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + (_isEditing ? 1 : 0),
        itemBuilder: (context, index) {
          if (_isEditing && index == images.length) {
            // 添加图片按钮
            return Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => _addStepImage(_currentStepIndex),
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
            );
          }
          
          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              child: Container(
                width: 80,
                height: 80,
                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildBottomActions(bool isDark) {
    return Row(
      children: [
        // 开始烹饪按钮
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _startCooking();
            },
            child: Container(
              height: 56,
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
              child: Center(
                child: Text(
                  '开始烹饪',
                  style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                    color: Colors.white,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        Space.w16,
        
        // 收藏按钮
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _toggleFavorite();
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
              Icons.favorite_outline,
              color: AppColors.getTextSecondaryColor(isDark),
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
  
  // ==================== 交互方法 ====================
  
  void _addStepImage(int stepIndex) {
    HapticFeedback.lightImpact();
    
    // 模拟图片上传成功
    setState(() {
      _recipeData.steps[stepIndex].images.add('image_${DateTime.now().millisecondsSinceEpoch}');
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('图片添加成功！'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  void _editStep(int stepIndex) {
    HapticFeedback.lightImpact();
    
    final step = _recipeData.steps[stepIndex];
    
    // 显示编辑对话框
    showDialog(
      context: context,
      builder: (context) => EditStepDialog(
        step: step,
        stepNumber: stepIndex + 1,
        onSave: (updatedStep) {
          setState(() {
            _recipeData.steps[stepIndex] = updatedStep;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('步骤更新成功！'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
  
  void _startCooking() {
    // 导航到烹饪模式
    context.push('/cooking-mode');
  }
  
  void _toggleFavorite() {
    // TODO: 实现收藏功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('收藏功能开发中...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ==================== 数据模型 ====================

class RecipeData {
  final String id;
  final String name;
  final String description;
  final AppIcon3DType iconType;
  final int totalTime;
  final String difficulty;
  final int servings;
  final List<RecipeStep> steps;
  
  RecipeData({
    required this.id,
    required this.name,
    required this.description,
    required this.iconType,
    required this.totalTime,
    required this.difficulty,
    required this.servings,
    required this.steps,
  });
}

class RecipeStep {
  String title;
  String description;
  int duration;
  String tips;
  List<String> images;
  
  RecipeStep({
    required this.title,
    required this.description,
    required this.duration,
    this.tips = '',
    List<String>? images,
  }) : images = images ?? [];
  
  RecipeStep copyWith({
    String? title,
    String? description,
    int? duration,
    String? tips,
    List<String>? images,
  }) {
    return RecipeStep(
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      tips: tips ?? this.tips,
      images: images ?? this.images,
    );
  }
}

/// 编辑步骤对话框
class EditStepDialog extends StatefulWidget {
  final RecipeStep step;
  final int stepNumber;
  final Function(RecipeStep) onSave;
  
  const EditStepDialog({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.onSave,
  });

  @override
  State<EditStepDialog> createState() => _EditStepDialogState();
}

class _EditStepDialogState extends State<EditStepDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tipsController;
  late int _duration;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.step.title);
    _descriptionController = TextEditingController(text: widget.step.description);
    _tipsController = TextEditingController(text: widget.step.tips);
    _duration = widget.step.duration;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: AppColors.getBackgroundColor(isDark),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadowColor(isDark),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                    ),
                    child: Center(
                      child: Text(
                        widget.stepNumber.toString(),
                        style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                          color: Colors.white,
                          fontWeight: AppTypography.medium,
                        ),
                      ),
                    ),
                  ),
                  
                  Space.w12,
                  
                  Expanded(
                    child: Text(
                      '编辑步骤',
                      style: AppTypography.titleMediumStyle(isDark: isDark),
                    ),
                  ),
                  
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 内容区域
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 步骤标题
                  Text(
                    '步骤标题',
                    style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                  
                  Space.h8,
                  
                  _buildTextField(
                    controller: _titleController,
                    hintText: '输入步骤标题',
                    isDark: isDark,
                  ),
                  
                  Space.h16,
                  
                  // 步骤描述
                  Text(
                    '步骤描述',
                    style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                  
                  Space.h8,
                  
                  _buildTextField(
                    controller: _descriptionController,
                    hintText: '详细描述操作步骤',
                    isDark: isDark,
                    maxLines: 3,
                  ),
                  
                  Space.h16,
                  
                  // 时长设置
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '预计时长',
                              style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                                fontWeight: AppTypography.medium,
                              ),
                            ),
                            
                            Space.h8,
                            
                            _buildTimeSelector(isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  Space.h16,
                  
                  // 小贴士
                  Text(
                    '小贴士（可选）',
                    style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                  
                  Space.h8,
                  
                  _buildTextField(
                    controller: _tipsController,
                    hintText: '添加一些有用的小贴士',
                    isDark: isDark,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            
            Space.h24,
            
            // 底部按钮
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        ),
                        child: Center(
                          child: Text(
                            '取消',
                            style: AppTypography.bodyMediumStyle(isDark: isDark),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  Space.w12,
                  
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _saveStep,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        ),
                        child: Center(
                          child: Text(
                            '保存',
                            style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                              color: Colors.white,
                              fontWeight: AppTypography.medium,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackgroundSecondaryColor(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTypography.bodyMediumStyle(isDark: isDark),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }
  
  Widget _buildTimeSelector(bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.getBackgroundSecondaryColor(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: Row(
        children: [
          Space.w16,
          
          GestureDetector(
            onTap: () {
              if (_duration > 1) {
                setState(() {
                  _duration--;
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
          
          Expanded(
            child: Center(
              child: Text(
                '$_duration 分钟',
                style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                  fontWeight: AppTypography.medium,
                ),
              ),
            ),
          ),
          
          GestureDetector(
            onTap: () {
              setState(() {
                _duration++;
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
          
          Space.w16,
        ],
      ),
    );
  }
  
  void _saveStep() {
    final updatedStep = widget.step.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      duration: _duration,
      tips: _tipsController.text,
    );
    
    widget.onSave(updatedStep);
    Navigator.of(context).pop();
  }
}