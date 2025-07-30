import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/pages/image_gallery_screen.dart';
import '../../../../shared/widgets/base64_image_widget.dart';
import '../../domain/models/recipe.dart';
import '../../data/repositories/recipe_repository.dart';

/// 🎨 极简菜谱详情页面 - 垂直滚动设计 V2.1
/// 所有步骤在同一页面展示，通过垂直滚动浏览
/// UI规格：
/// - 封面图片：300px 高度
/// - 步骤图片：200px 高度
/// - 间距系统：使用 8 的倍数
class RecipeDetailScreenV2 extends ConsumerStatefulWidget {
  final String recipeId;
  
  const RecipeDetailScreenV2({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailScreenV2> createState() => _RecipeDetailScreenV2State();
}

class _RecipeDetailScreenV2State extends ConsumerState<RecipeDetailScreenV2> 
    with TickerProviderStateMixin {
  Recipe? _recipe;
  late ScrollController _scrollController; // 改用 ScrollController 实现垂直滚动
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  String? _errorMessage;
  
  // UI 尺寸常量定义
  static const double _coverImageHeight = 300.0; // 封面图片高度
  static const double _stepImageHeight = 200.0;  // 步骤图片高度
  static const double _pageHorizontalPadding = 24.0; // 页面水平内边距
  static const double _sectionSpacing = 32.0; // 区块间距
  static const double _itemSpacing = 16.0; // 项目间距
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(); // 初始化滚动控制器
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
    _scrollController.dispose(); // 释放滚动控制器
    _fadeController.dispose();
    super.dispose();
  }
  
  void _loadRecipeData() async {
    print('🔍 开始加载菜谱数据，ID: ${widget.recipeId}');
    
    try {
      final repository = await ref.read(initializedRecipeRepositoryProvider.future);
      print('✅ RecipeRepository 获取成功');
      
      final recipe = repository.getRecipe(widget.recipeId);
      print('🔍 查找菜谱结果: ${recipe != null ? '找到' : '未找到'}');
      
      if (mounted) {
        setState(() {
          // 如果找不到菜谱，创建一个示例菜谱
          _recipe = recipe ?? _createFallbackRecipe(widget.recipeId);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ 加载菜谱数据失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '加载失败: $e';
        });
      }
    }
  }
  
  /// 创建fallback菜谱数据
  Recipe _createFallbackRecipe(String recipeId) {
    print('🛠️ 创建fallback菜谱，ID: $recipeId');
    
    // 根据ID选择不同的示例菜谱
    final fallbackData = _getFallbackDataByid(recipeId);
    
    return Recipe(
      id: recipeId,
      name: fallbackData['name'],
      description: fallbackData['description'],
      iconType: 'AppIcon3DType.${fallbackData['iconType']}',
      totalTime: fallbackData['totalTime'],
      difficulty: '简单',
      servings: 2,
      steps: (fallbackData['steps'] as List<Map<String, dynamic>>).map((stepData) => 
        RecipeStep(
          title: stepData['title'],
          description: stepData['description'],
          duration: stepData['duration'],
          imagePath: stepData['imagePath'],
          tips: stepData['tips'],
        )
      ).toList(),
      imagePath: fallbackData['imagePath'],
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPublic: true,
      rating: 4.5,
      cookCount: 100,
    );
  }
  
  /// 根据ID获取fallback数据
  Map<String, dynamic> _getFallbackDataByid(String recipeId) {
    final fallbackRecipes = {
      'recipe_1': {
        'name': '银耳莲子羹',
        'description': '滋润养颜的经典甜品，口感清香甜美',
        'iconType': 'bowl',
        'totalTime': 45,
        'imagePath': null,
        'steps': [
          {
            'title': '准备食材',
            'description': '银耳一朵，莲子50g，冰糖适量。将银耳提前泡发，莲子去芯。',
            'duration': 15,
            'imagePath': null,
            'tips': '银耳要充分泡发，这样煮出来才粘稠',
          },
          {
            'title': '炖煮过程',
            'description': '将银耳撕成小朵，与莲子一起放入锅中，加水炖煮30分钟。',
            'duration': 30,
            'imagePath': null,
            'tips': '小火慢炖，保持水开状态即可',
          },
        ],
      },
      'recipe_2': {
        'name': '番茄鸡蛋面',
        'description': '家常经典面条，酸甜可口，营养丰富',
        'iconType': 'spoon',
        'totalTime': 15,
        'imagePath': null,
        'steps': [
          {
            'title': '准备配菜',
            'description': '番茄2个切块，鸡蛋2个打散，葱花少许。',
            'duration': 5,
            'imagePath': null,
            'tips': '番茄要选熟透的，这样更容易出汁',
          },
          {
            'title': '炒制面条',
            'description': '先炒鸡蛋盛起，再炒番茄出汁，加入面条和鸡蛋翻炒。',
            'duration': 10,
            'imagePath': null,
            'tips': '面条要煮到8分熟，这样炒制时不会太软',
          },
        ],
      },
    };
    
    return fallbackRecipes[recipeId] ?? fallbackRecipes['recipe_1']!;
  }
  
  @override
  Widget build(BuildContext context) {
    // 🔄 正在加载状态
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // 简单的顶部导航
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.pop();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          '加载中...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              
              // 加载指示器
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF5B6FED),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '正在加载菜谱详情...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
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
    
    // ❌ 错误状态
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // 简单的顶部导航
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.pop();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          '出错了',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              
              // 错误信息
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '菜谱加载失败',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // 重新加载
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _loadRecipeData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B6FED),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('重新加载'),
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
    
    // ✅ 成功加载，显示菜谱内容
    if (_recipe == null) {
      return const Scaffold(
        body: Center(
          child: Text('数据异常'),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _buildCookingModeButton(), // 🍳 开始烹饪浮动按钮
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 🎨 顶部导航栏 + 封面图片（使用 SliverAppBar 实现沉浸式效果）
          SliverAppBar(
            pinned: true, // 固定在顶部
            expandedHeight: _coverImageHeight + 56, // 封面图片高度 + 导航栏高度
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
                icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
              ),
            ),
            // ✏️ 添加编辑按钮
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _navigateToEditRecipe();
                  },
                  icon: const Icon(Icons.edit, color: Colors.black87, size: 20),
                  tooltip: '编辑菜谱',
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 封面图片
                  _buildCoverImage(),
                  // 渐变遮罩，确保顶部文字可读
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 🎨 主要内容区域
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(_pageHorizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📝 菜谱基本信息区域
                        _buildRecipeHeader(),
                        
                        const SizedBox(height: _sectionSpacing),
                        
                        // 📊 菜谱元数据（时间、难度、份量）
                        _buildRecipeMetadata(),
                        
                        const SizedBox(height: _sectionSpacing),
                        
                        // 📋 所有步骤列表（垂直展示）
                        _buildAllSteps(),
                        
                        // 底部安全区域
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // 注意：以下方法已被新的垂直滚动设计取代，保留供参考
  
  /// 🎨 极简顶部导航栏 (已废弃)
  Widget _buildMinimalAppBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                color: const Color(0xFFF5F5F5),
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
          Text(
            _recipe!.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          
          // 菜单按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // TODO: 显示更多选项
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.more_horiz,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 🎨 单个步骤页面 - 极简设计
  Widget _buildStepPage(RecipeStep step, int stepNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 1),
          
          // 🎨 步骤过程标题（可选）
          if (true) // 在垂直滚动设计中总是显示过程标题
            Container(
              margin: const EdgeInsets.only(bottom: 32),
              child: Text(
                '${_recipe!.name}过程',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
            ),
          
          // 🎨 步骤图形展示区域
          Container(
            height: 280,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 48),
            child: Stack(
              children: [
                // 极简图形背景
                Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      shape: BoxShape.circle,
                    ),
                    child: _buildStepVisual(step, stepNumber),
                  ),
                ),
                
                // 步骤编号
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        stepNumber.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 🎨 步骤标题
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Text(
              step.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 🎨 步骤描述
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Text(
              step.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 🎨 时间和技巧标签
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 时间标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${step.duration}分钟',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              if (step.tips?.isNotEmpty == true) ...[
                const SizedBox(width: 12),
                // 技巧标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '技巧',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          const Spacer(flex: 2),
          
          // 🎨 贴士详情（如果有）
          if (step.tips?.isNotEmpty == true)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 18,
                        color: Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '小贴士',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.tips!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  /// 🎨 步骤可视化展示（极简图形）
  Widget _buildStepVisual(RecipeStep step, int stepNumber) {
    // 如果有图片，显示图片（支持点击打开画廊）
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
            heroTag: 'step_image_${stepNumber}',
          );
        },
        child: Hero(
          tag: 'step_image_${stepNumber}',
          child: ClipOval(
            child: step.imagePath!.startsWith('http')
                ? Image.network(
                    step.imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultVisual(step.title);
                    },
                  )
                : kIsWeb
                    ? Image.asset(
                        step.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultVisual(step.title);
                        },
                      )
                    : Image.asset(
                        step.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultVisual(step.title);
                        },
                      ),
          ),
        ),
      );
    }
    
    // 否则显示默认图形
    return _buildDefaultVisual(step.title);
  }
  
  /// 🎨 默认的极简图形展示
  Widget _buildDefaultVisual(String title) {
    IconData iconData = Icons.restaurant;
    
    // 根据标题关键词选择图标
    if (title.contains('准备') || title.contains('食材')) {
      iconData = Icons.kitchen;
    } else if (title.contains('切') || title.contains('处理')) {
      iconData = Icons.content_cut;
    } else if (title.contains('煮') || title.contains('炖') || title.contains('烧')) {
      iconData = Icons.local_fire_department;
    } else if (title.contains('炒') || title.contains('煎')) {
      iconData = Icons.whatshot;
    } else if (title.contains('蒸')) {
      iconData = Icons.water_drop;
    } else if (title.contains('调味') || title.contains('完成')) {
      iconData = Icons.done_all;
    }
    
    return Icon(
      iconData,
      size: 80,
      color: Colors.grey[400],
    );
  }
  
  /// 🎨 底部进度指示器
  Widget _buildProgressIndicator() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 页面指示点
          ...List.generate(_recipe!.steps.length, (index) {
            final isActive = true; // 在垂直滚动设计中所有步骤都是激活状态
            return Container(
              width: isActive ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.black87 : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  /// 📷 构建封面图片 - 300px高度，支持Base64图片
  Widget _buildCoverImage() {
    // 优先使用Base64数据，对于旧数据保留imagePath兼容性
    final imageBase64 = _recipe!.imageBase64;
    final imagePath = _recipe!.imagePath;
    
    // 如果有Base64数据，优先使用
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      return Base64ImageWidget(
        base64Data: imageBase64,
        width: double.infinity,
        height: _coverImageHeight,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.zero,
        errorWidget: _buildDefaultCoverImage(),
      );
    }
    
    // 兼容旧数据：如果有imagePath，使用传统方式显示
    if (imagePath != null && imagePath.isNotEmpty) {
      return imagePath.startsWith('http')
          ? Image.network(
              imagePath,
              height: _coverImageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultCoverImage();
              },
            )
          : Image.asset(
              imagePath,
              height: _coverImageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultCoverImage();
              },
            );
    }
    
    return _buildDefaultCoverImage();
  }
  
  /// 🎨 默认封面图片
  Widget _buildDefaultCoverImage() {
    return Container(
      height: _coverImageHeight,
      width: double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 80,
          color: Colors.grey[400],
        ),
      ),
    );
  }
  
  /// 🎨 构建菜谱头部信息
  Widget _buildRecipeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 菜谱名称 - 大标题
        Text(
          _recipe!.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 分隔线
        Container(
          height: 1,
          width: 60,
          color: Colors.grey[300],
        ),
        
        const SizedBox(height: 12),
        
        // 菜谱描述
        if (_recipe!.description.isNotEmpty)
          Text(
            _recipe!.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
      ],
    );
  }
  
  /// 🎨 构建菜谱元数据（时间、难度、份量）
  Widget _buildRecipeMetadata() {
    return Row(
      children: [
        // 制作时间
        _buildMetadataItem(
          icon: Icons.access_time,
          label: '${_recipe!.totalTime}分钟',
        ),
        
        const SizedBox(width: 24),
        
        // 难度
        _buildMetadataItem(
          icon: Icons.signal_cellular_alt,
          label: _recipe!.difficulty,
        ),
        
        const SizedBox(width: 24),
        
        // 份量
        _buildMetadataItem(
          icon: Icons.people_outline,
          label: '${_recipe!.servings}人份',
        ),
      ],
    );
  }
  
  /// 🎨 单个元数据项
  Widget _buildMetadataItem({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  /// 🎨 构建所有步骤列表 - 垂直展示
  Widget _buildAllSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 步骤标题
        const Text(
          '制作步骤',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 步骤列表
        ...List.generate(_recipe!.steps.length, (index) {
          final step = _recipe!.steps[index];
          final stepNumber = index + 1;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: _buildStepItem(step, stepNumber),
          );
        }),
      ],
    );
  }
  
  /// 🎨 单个步骤项 - 垂直布局设计
  Widget _buildStepItem(RecipeStep step, int stepNumber) {
    return Column(
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
                color: const Color(0xFF5B6FED),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 步骤标题
            Expanded(
              child: Text(
                step.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 步骤图片 - 200px高度（支持Base64和imagePath）
        if ((step.imageBase64 != null && step.imageBase64!.isNotEmpty) || 
            (step.imagePath != null && step.imagePath!.isNotEmpty))
          _buildStepImage(step, stepNumber),
        
        // 步骤描述
        if (step.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            step.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }
  
  /// 📷 构建步骤图片 - 支持Base64图片和点击查看大图
  Widget _buildStepImage(RecipeStep step, int stepNumber) {
    // 收集所有步骤的图片数据（优先Base64，然后路径）
    final allStepImages = _recipe!.steps
        .where((s) => (s.imageBase64 != null && s.imageBase64!.isNotEmpty) || 
                     (s.imagePath != null && s.imagePath!.isNotEmpty))
        .map((s) => s.imageBase64 ?? s.imagePath!)
        .toList();
    
    final currentImage = step.imageBase64 ?? step.imagePath!;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // 打开图片画廊（如果支持Base64数据）
        if (allStepImages.isNotEmpty) {
          // TODO: 更新ImageGalleryScreen以支持Base64数据
          // 目前先显示提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('图片放大功能开发中...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Hero(
        tag: 'step_image_v2_${stepNumber}',
        child: Container(
          height: _stepImageHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildStepImageContent(step),
          ),
        ),
      ),
    );
  }
  
  /// 📷 构建步骤图片内容（支持Base64和传统路径）
  Widget _buildStepImageContent(RecipeStep step) {
    // 优先使用Base64数据
    if (step.imageBase64 != null && step.imageBase64!.isNotEmpty) {
      return Base64ImageWidget(
        base64Data: step.imageBase64,
        width: double.infinity,
        height: _stepImageHeight,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.zero, // 已经在父容器中应用了圆角
        errorWidget: _buildDefaultStepImage(),
      );
    }
    
    // 兼容旧数据：使用imagePath
    if (step.imagePath != null && step.imagePath!.isNotEmpty) {
      return step.imagePath!.startsWith('http')
          ? Image.network(
              step.imagePath!,
              height: _stepImageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultStepImage();
              },
            )
          : Image.asset(
              step.imagePath!,
              height: _stepImageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultStepImage();
              },
            );
    }
    
    return _buildDefaultStepImage();
  }
  
  /// 🎨 默认步骤图片
  Widget _buildDefaultStepImage() {
    return Container(
      height: _stepImageHeight,
      width: double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image,
          size: 60,
          color: Colors.grey[400],
        ),
      ),
    );
  }
  
  /// 🎨 烹饪模式浮动按钮
  Widget _buildCookingModeButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _navigateToCookingMode();
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B6FED), Color(0xFF8B9BF3)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B6FED).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
  
  /// 导航到烹饪模式
  void _navigateToCookingMode() {
    context.push('/cooking-mode?recipeId=${widget.recipeId}');
  }
  
  /// ✏️ 导航到编辑菜谱页面
  void _navigateToEditRecipe() {
    context.push('/create-recipe?editId=${widget.recipeId}');
  }
}