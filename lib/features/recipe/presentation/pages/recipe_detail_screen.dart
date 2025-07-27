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
      // 🔥 添加红烧排骨数据 - 修复用户问题
      'recipe_3': RecipeData(
        id: 'recipe_3',
        name: '红烧排骨',
        description: '软糯香甜，肥而不腻的经典家常菜',
        iconType: AppIcon3DType.chef,
        totalTime: 45,
        difficulty: '中等',
        servings: 3,
        steps: [
          RecipeStep(
            title: '准备食材',
            description: '排骨500g，生抽、老抽、料酒、冰糖适量',
            duration: 5,
            tips: '排骨要选择带点肥肉的，口感更好',
          ),
          RecipeStep(
            title: '焯水处理',
            description: '排骨冷水下锅焯水去血沫',
            duration: 8,
            tips: '焯水时加几片姜去腥效果更好',
          ),
          RecipeStep(
            title: '炒糖色',
            description: '热锅下冰糖炒出焦糖色',
            duration: 5,
            tips: '小火慢炒，糖色不要炒过头变苦',
          ),
          RecipeStep(
            title: '下排骨炒色',
            description: '下排骨翻炒至每面都裹上糖色',
            duration: 5,
            tips: '炒匀后排骨会呈现诱人的红亮色泽',
          ),
          RecipeStep(
            title: '加调料炖煮',
            description: '加生抽老抽料酒和水，大火煮开转小火',
            duration: 25,
            tips: '水量要没过排骨，最后大火收汁',
          ),
        ],
      ),
      'recipe_4': RecipeData(
        id: 'recipe_4',
        name: '蒸蛋羹',
        description: '嫩滑如豆腐的营养蒸蛋',
        iconType: AppIcon3DType.timer,
        totalTime: 10,
        difficulty: '简单',
        servings: 1,
        steps: [
          RecipeStep(
            title: '打蛋液',
            description: '鸡蛋2个打散，加温水搅匀',
            duration: 3,
            tips: '蛋液和水的比例1:1.5最嫩滑',
          ),
          RecipeStep(
            title: '过筛去泡',
            description: '蛋液过筛去除泡沫',
            duration: 2,
            tips: '也可以用勺子撇去表面泡沫',
          ),
          RecipeStep(
            title: '蒸制',
            description: '盖保鲜膜扎孔，水开后蒸8分钟',
            duration: 8,
            tips: '中火蒸制，避免蜂窝状',
          ),
        ],
      ),
      'recipe_5': RecipeData(
        id: 'recipe_5',
        name: '青椒肉丝',
        description: '色彩搭配完美的经典炒菜',
        iconType: AppIcon3DType.recipe,
        totalTime: 25,
        difficulty: '中等',
        servings: 2,
        steps: [
          RecipeStep(
            title: '切丝备料',
            description: '肉丝切细，青椒切丝',
            duration: 8,
            tips: '肉丝要顺着纹理切，更嫩',
          ),
          RecipeStep(
            title: '肉丝腌制',
            description: '肉丝加生抽、淀粉腌制',
            duration: 10,
            tips: '腌制时间不要太长',
          ),
          RecipeStep(
            title: '炒制',
            description: '先炒肉丝至变色，再下青椒丝',
            duration: 7,
            tips: '大火快炒保持青椒脆嫩',
          ),
        ],
      ),
      'recipe_6': RecipeData(
        id: 'recipe_6',
        name: '爱心早餐',
        description: '营养搭配的温馨早餐',
        iconType: AppIcon3DType.heart,
        totalTime: 30,
        difficulty: '简单',
        servings: 2,
        steps: [
          RecipeStep(
            title: '准备食材',
            description: '面包、鸡蛋、牛奶、水果',
            duration: 5,
            tips: '选择新鲜食材，营养更丰富',
          ),
          RecipeStep(
            title: '制作煎蛋',
            description: '热锅煎制爱心形状的鸡蛋',
            duration: 8,
            tips: '用心形模具更容易成型',
          ),
          RecipeStep(
            title: '搭配摆盘',
            description: '面包、煎蛋、水果艺术摆盘',
            duration: 12,
            tips: '用心摆盘，爱意满满',
          ),
          RecipeStep(
            title: '温牛奶',
            description: '加热牛奶至适温',
            duration: 5,
            tips: '温度刚好，暖胃暖心',
          ),
        ],
      ),
      'recipe_7': RecipeData(
        id: 'recipe_7',
        name: '宫保鸡丁',
        description: '酸甜微辣的经典川菜',
        iconType: AppIcon3DType.chef,
        totalTime: 20,
        difficulty: '中等',
        servings: 2,
        steps: [
          RecipeStep(
            title: '鸡肉切丁',
            description: '鸡胸肉切丁，用料酒腌制',
            duration: 8,
            tips: '鸡丁大小要均匀',
          ),
          RecipeStep(
            title: '炸花生米',
            description: '花生米过油炸酥脆',
            duration: 5,
            tips: '小火慢炸，避免糊掉',
          ),
          RecipeStep(
            title: '炒制调味',
            description: '下鸡丁炒熟，加调料炒匀',
            duration: 7,
            tips: '最后撒花生米增加口感',
          ),
        ],
      ),
      'recipe_8': RecipeData(
        id: 'recipe_8',
        name: '麻婆豆腐',
        description: '麻辣鲜香的经典川菜',
        iconType: AppIcon3DType.bowl,
        totalTime: 15,
        difficulty: '中等',
        servings: 2,
        steps: [
          RecipeStep(
            title: '豆腐处理',
            description: '嫩豆腐切块，用盐水浸泡',
            duration: 5,
            tips: '盐水浸泡可以去豆腥味',
          ),
          RecipeStep(
            title: '炒制肉末',
            description: '热锅炒肉末至变色',
            duration: 3,
            tips: '用猪肉末味道更香',
          ),
          RecipeStep(
            title: '下豆腐调味',
            description: '加豆瓣酱和豆腐块翻炒',
            duration: 7,
            tips: '轻柔翻炒，避免豆腐碎',
          ),
        ],
      ),
      'recipe_9': RecipeData(
        id: 'recipe_9',
        name: '糖醋里脊',
        description: '酸甜可口的经典菜品',
        iconType: AppIcon3DType.recipe,
        totalTime: 35,
        difficulty: '中等',
        servings: 2,
        steps: [
          RecipeStep(
            title: '里脊处理',
            description: '里脊肉切条，用蛋液淀粉裹匀',
            duration: 10,
            tips: '裹粉要均匀，炸出来更酥脆',
          ),
          RecipeStep(
            title: '油炸定型',
            description: '热油炸至金黄酥脆',
            duration: 15,
            tips: '二次复炸口感更好',
          ),
          RecipeStep(
            title: '调糖醋汁',
            description: '糖醋汁炒至粘稠，裹里脊',
            duration: 10,
            tips: '糖醋比例2:1最佳',
          ),
        ],
      ),
      'recipe_10': RecipeData(
        id: 'recipe_10',
        name: '酸菜鱼',
        description: '麻辣鲜香的经典川菜',
        iconType: AppIcon3DType.spoon,
        totalTime: 40,
        difficulty: '困难',
        servings: 3,
        steps: [
          RecipeStep(
            title: '鱼片处理',
            description: '草鱼切片，用蛋清淀粉腌制',
            duration: 15,
            tips: '鱼片要薄厚均匀',
          ),
          RecipeStep(
            title: '炒酸菜底',
            description: '炒酸菜出香味，加水煮开',
            duration: 10,
            tips: '酸菜要先挤干水分',
          ),
          RecipeStep(
            title: '煮鱼片',
            description: '下鱼片煮熟，淋辣椒油',
            duration: 15,
            tips: '鱼片不要煮太久',
          ),
        ],
      ),
      'recipe_11': RecipeData(
        id: 'recipe_11',
        name: '口水鸡',
        description: '麻辣爽口的经典凉菜',
        iconType: AppIcon3DType.chef,
        totalTime: 25,
        difficulty: '中等',
        servings: 2,
        steps: [
          RecipeStep(
            title: '煮鸡肉',
            description: '整鸡煮熟晾凉，撕成丝',
            duration: 20,
            tips: '煮鸡时加姜片去腥',
          ),
          RecipeStep(
            title: '调制蘸料',
            description: '生抽、香醋、辣椒油调匀',
            duration: 3,
            tips: '蘸料要提前调好入味',
          ),
          RecipeStep(
            title: '拌制装盘',
            description: '鸡丝淋蘸料，撒花生碎',
            duration: 2,
            tips: '最后撒香菜增加香味',
          ),
        ],
      ),
      'recipe_12': RecipeData(
        id: 'recipe_12',
        name: '蛋花汤',
        description: '清淡鲜美的家常汤品',
        iconType: AppIcon3DType.bowl,
        totalTime: 5,
        difficulty: '简单',
        servings: 2,
        steps: [
          RecipeStep(
            title: '烧开水',
            description: '锅中加水烧开，调味',
            duration: 3,
            tips: '可以加点鸡精提鲜',
          ),
          RecipeStep(
            title: '淋蛋液',
            description: '蛋液打散，慢慢淋入开水中',
            duration: 1,
            tips: '边淋边搅拌形成蛋花',
          ),
          RecipeStep(
            title: '出锅',
            description: '撒葱花即可出锅',
            duration: 1,
            tips: '不要煮太久保持鲜嫩',
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