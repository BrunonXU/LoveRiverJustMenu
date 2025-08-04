import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../core/utils/performance_monitor.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../../../shared/widgets/app_icon_3d.dart';
import '../../../../shared/widgets/voice_interaction_widget.dart';
import '../../../../shared/widgets/side_drawer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/animations/physics_engine.dart';
import '../../../../core/animations/christmas_snow_effect.dart';
import '../../../../core/firestore/repositories/recipe_repository.dart';
import '../../../../core/auth/providers/auth_providers.dart';
import '../../../recipe/domain/models/recipe.dart';

/// 主界面 - 时间驱动的卡片流
/// 严格遵循极简设计原则：95%黑白灰，5%彩色焦点
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  
  // ==================== 动画控制器 ====================
  
  late AnimationController _breathingController;
  late AnimationController _cardController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _cardAnimation;
  
  // ==================== 状态变量 ====================
  
  int _currentIndex = 0;
  bool _isLoading = true;
  List<Recipe> _allRecipes = []; // 🔧 从数据库加载的所有菜谱
  
  // ==================== 公共方法 ====================
  
  /// 🔄 刷新菜谱数据
  void refreshRecipes() {
    debugPrint('🔄 手动刷新菜谱数据');
    setState(() {
      _isLoading = true;
    });
    _loadInitialData();
  }
  
  // ==================== 生命周期 ====================
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
  }
  
  @override
  void dispose() {
    _breathingController.dispose();
    _cardController.dispose();
    super.dispose();
  }
  
  // ==================== 初始化方法 ====================
  
  /// 初始化动画
  void _initializeAnimations() {
    // 呼吸动画控制器 - 4s循环
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02, // 严格按照设计规范
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    // 卡片动画控制器
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );
    
    // 启动动画
    _cardController.forward();
  }
  
  /// 加载初始数据
  void _loadInitialData() async {
    final stopwatch = PerformanceMonitor.startOperation('LoadInitialData');
    
    try {
      // 获取当前用户ID
      final currentUser = ref.read(currentUserProvider);
      debugPrint('🔍 首页加载数据 - 当前用户: ${currentUser?.uid ?? "null"}');
      
      if (currentUser == null) {
        debugPrint('❌ 用户未登录，使用默认数据');
        if (mounted) {
          setState(() {
            _allRecipes = [];
            _isLoading = false;
          });
        }
        return;
      }
      
      debugPrint('🔍 开始查询用户菜谱: ${currentUser.uid}');
      
      // 🔧 从云端数据库加载所有可用菜谱数据
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      debugPrint('✅ 获取Repository成功');
      
      // 🔧 同时加载用户菜谱和公共预设菜谱
      final Future<List<Recipe>> userRecipesFuture = repository.getUserRecipes(currentUser.uid);
      final Future<List<Recipe>> presetRecipesFuture = repository.getPresetRecipes();
      
      final results = await Future.wait([userRecipesFuture, presetRecipesFuture]);
      final userRecipes = results[0];
      final presetRecipes = results[1];
      
      debugPrint('📊 用户菜谱: ${userRecipes.length} 个');
      debugPrint('📊 预设菜谱: ${presetRecipes.length} 个');
      
      // 🔧 合并所有菜谱（用户菜谱 + 预设菜谱）
      final List<Recipe> allAvailableRecipes = [];
      
      // 添加预设菜谱（显示在前面，因为这些是精选菜谱）
      allAvailableRecipes.addAll(presetRecipes);
      
      // 添加用户自己创建的菜谱
      allAvailableRecipes.addAll(userRecipes);
      
      debugPrint('📊 总计可用菜谱: ${allAvailableRecipes.length} 个');
      
      // 打印菜谱详情便于调试
      for (int i = 0; i < allAvailableRecipes.length; i++) {
        final recipe = allAvailableRecipes[i];
        final type = recipe.isPreset ? '预设' : '用户';
        debugPrint('📖 菜谱$i: ${recipe.name} (类型: $type, ID: ${recipe.id})');
      }
      
      if (mounted) {
        setState(() {
          _allRecipes = allAvailableRecipes;
          _isLoading = false;
        });
        debugPrint('✅ 首页数据加载完成: ${_allRecipes.length} 个菜谱');
      }
    } catch (e) {
      debugPrint('❌ 加载菜谱数据失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    
    PerformanceMonitor.endOperation(stopwatch, 'LoadInitialData');
  }
  
  // ==================== 界面构建 ====================
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      // 添加侧边栏
      drawer: const SideDrawer(),
      
      body: ChristmasSnowEffect(
        enableClickEffect: true,
        snowflakeCount: 8, // 稍微增加雪花数量
        clickEffectColor: const Color(0xFF00BFFF), // 海蓝色点击特效
        child: SafeArea(
          child: _isLoading 
              ? _buildLoadingState() 
              : _buildSimplifiedMainContent(isDark),
        ),
      ),
      
      // 只保留语音助手按钮
      floatingActionButton: _buildVoiceButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  
  /// 构建加载状态
  Widget _buildLoadingState() {
    return Center(
      child: BreathingWidget(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
  
  /// 构建简化的主要内容
  Widget _buildSimplifiedMainContent(bool isDark) {
    return Column(
      children: [
        // 简化的顶部区域：汉堡菜单 + 时间 + 天气 + 搜索
        _buildSimplifiedHeader(isDark),
        
        // 智能推荐文案区域
        _buildRecommendationText(isDark),
        
        // 单个菜谱卡片区域
        Expanded(
          child: _buildSingleRecipeCard(isDark),
        ),
        
        // 操作提示
        _buildSimplifiedHint(isDark),
      ],
    );
  }

  /// 构建原主要内容（保留作为备用）
  Widget _buildMainContent(bool isDark) {
    return Column(
      children: [
        // 时间感知顶部区域
        _buildTimeAwareHeader(isDark),
        
        // 主卡片区域
        Expanded(
          child: _buildCardArea(isDark),
        ),
        
        // 按钮操作提示
        _buildButtonHint(isDark),
      ],
    );
  }

  /// 构建简化的顶部区域
  Widget _buildSimplifiedHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧：汉堡菜单 + 时间
          Flexible(
            child: Row(
              children: [
              // 汉堡菜单按钮
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Scaffold.of(context).openDrawer();
                  },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.getBackgroundSecondaryColor(isDark),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getShadowColor(isDark).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.menu,
                    size: 24,
                    color: AppColors.getTextPrimaryColor(isDark),
                  ),
                ),
                ),
              ),
              const SizedBox(width: 16),
              // 时间显示
              Text(
                _getCurrentTime(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w100,
                  color: AppColors.getTextPrimaryColor(isDark),
                ),
              ),
              ],
            ),
          ),
          
          // 右侧：天气 + 搜索按钮
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 天气信息
              _buildWeatherInfo(isDark),
              const SizedBox(width: 8),
              // 搜索按钮（从原顶部栏迁移）
              _buildSearchButton(isDark),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建天气信息
  Widget _buildWeatherInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.getBackgroundSecondaryColor(isDark),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌤️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            'Melody',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondaryColor(isDark),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '24°C',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextPrimaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建搜索按钮
  Widget _buildSearchButton(bool isDark) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _navigateToSearch();
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.getBackgroundSecondaryColor(isDark),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadowColor(isDark).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.search,
            size: 20,
            color: AppColors.getTextSecondaryColor(isDark),
          ),
        ),
      ),
    );
  }

  /// 构建智能推荐文案
  Widget _buildRecommendationText(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16), // 减少垂直间距
      child: Column(
        children: [
          Text(
            _getGreetingData()['text'],
            style: TextStyle(
              fontSize: 26, // 稍微减小字体
              fontWeight: FontWeight.w100,
              color: AppColors.getTextPrimaryColor(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8), // 减少间距
          Text(
            _getSmartSuggestion(),
            style: TextStyle(
              fontSize: 15, // 稍微减小字体
              color: AppColors.getTextSecondaryColor(isDark),
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建单个菜谱卡片
  Widget _buildSingleRecipeCard(bool isDark) {
    final recipe = _getCurrentRecipe();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // 添加外边距
      child: Stack(
        children: [
          // 菜谱卡片 - 增大尺寸
          Center(
            child: BreathingWidget(
              child: GestureDetector(
                onTap: () => _navigateToRecipeDetail(recipe['id']),
                child: Container(
                  width: 320, // 增大宽度
                  height: 240, // 增大高度
                  decoration: BoxDecoration(
                    color: AppColors.getBackgroundSecondaryColor(isDark),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getShadowColor(isDark).withOpacity(0.15),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 菜谱图标或emoji - 增大尺寸
                      if (recipe['emojiIcon'] != null)
                        Text(
                          recipe['emojiIcon'],
                          style: const TextStyle(fontSize: 60), // 增大emoji
                        )
                      else
                        AppIcon3D(
                          type: recipe['iconType'] ?? AppIcon3DType.heart,
                          size: 60, // 增大图标
                        ),
                      const SizedBox(height: 20),
                      // 菜谱名称
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          recipe['name'] ?? '暂无菜谱',
                          style: TextStyle(
                            fontSize: 22, // 增大字体
                            fontWeight: FontWeight.w300,
                            color: AppColors.getTextPrimaryColor(isDark),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2, // 允许换行
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 烹饪时间
                      if (recipe['time'] != null && recipe['time'] > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 18, // 稍微增大图标
                              color: AppColors.getTextSecondaryColor(isDark),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${recipe['time']}分钟',
                              style: TextStyle(
                                fontSize: 16, // 增大字体
                                color: AppColors.getTextSecondaryColor(isDark),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // 上箭头按钮 - 调整位置
          Positioned(
            top: 10, // 稍微上移
            left: 0,
            right: 0,
            child: Center(
              child: _buildArrowButton(Icons.keyboard_arrow_up, _previousCard, isDark),
            ),
          ),
          // 下箭头按钮 - 往下移动更多空间
          Positioned(
            bottom: 10, // 往下移动，给卡片留更多空间
            left: 0,
            right: 0,
            child: Center(
              child: _buildArrowButton(Icons.keyboard_arrow_down, _nextCard, isDark),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建箭头按钮
  Widget _buildArrowButton(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.getBackgroundSecondaryColor(isDark).withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadowColor(isDark).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 24,
          color: AppColors.getTextSecondaryColor(isDark),
        ),
      ),
    );
  }

  /// 构建简化操作提示
  Widget _buildSimplifiedHint(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: Text(
        '左侧滑入查看更多',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.getTextSecondaryColor(isDark),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  /// 构建时间感知头部
  Widget _buildTimeAwareHeader(bool isDark) {
    final greetingData = _getGreetingData();
    
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧问候区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      greetingData['icon'],
                      size: 24,
                      color: AppColors.getTextPrimaryColor(true),
                    ),
                    Space.w8,
                    Text(
                      greetingData['text'],
                      style: AppTypography.greetingStyle(isDark: true),
                    ),
                  ],
                ),
                Space.h4,
                Text(
                  _getSmartSuggestion(),
                  style: AppTypography.bodySmallStyle(isDark: isDark),
                ),
              ],
            ),
          ),
          
          // 挑战按钮 ⭐ 新功能入口
          BreathingWidget(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _navigateToChallenge();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundSecondaryColor(isDark),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getShadowColor(isDark).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  // 特殊标识 - 新功能
                  border: Border.all(
                    color: Color(0xFF5B6FED).withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.sports_martial_arts,
                        color: Color(0xFF5B6FED),
                        size: 20,
                      ),
                    ),
                    // 新功能标识点
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Space.w8,
          
          // 情侣按钮
          BreathingWidget(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _navigateToCoupleProfile();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundSecondaryColor(isDark),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getShadowColor(isDark).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
          
          Space.w8,
          
          // 亲密度按钮 ⭐ 新功能
          BreathingWidget(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _navigateToIntimacy();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundSecondaryColor(isDark),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getShadowColor(isDark).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  // 特殊标识 - 新功能
                  border: Border.all(
                    color: Color(0xFFFF6B6B).withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: const Text(
                        '💕',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    // 新功能小红点
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Space.w8,
          
          // 搜索按钮
          BreathingWidget(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _navigateToSearch();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundSecondaryColor(isDark),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getShadowColor(isDark).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.search,
                  color: AppColors.getTextSecondaryColor(isDark),
                  size: 20,
                ),
              ),
            ),
          ),
          
          Space.w8,
          
          // 我的按钮 - 个人中心入口
          BreathingWidget(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _navigateToPersonalCenter();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '我',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          Space.w16,
          
          // 右侧时间区域
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getCurrentTime(),
                style: AppTypography.displayLargeStyle(isDark: true),
              ),
              Text(
                '24°C 适合热饮',
                style: AppTypography.captionStyle(isDark: isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 构建卡片区域 - 移除手势，使用按钮
  Widget _buildCardArea(bool isDark) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height - 200,
      ),
      child: Stack(
        children: [
          // 主卡片
          Center(
            child: _buildRecipeCard(isDark),
          ),
          
          // 方向按钮
          _buildDirectionButtons(isDark),
        ],
      ),
    );
  }
  
  /// 构建菜谱卡片
  Widget _buildRecipeCard(bool isDark) {
    final recipe = _getCurrentRecipe();
    
    return BreathingWidget(
      child: GestureDetector(
        onTap: () {
          final recipe = _getCurrentRecipe();
          final recipeId = recipe['id'];
          
          // 🔧 修复：如果没有真实菜谱，引导用户导入菜谱
          if (recipeId == 'empty' || _allRecipes.isEmpty) {
            _showImportRecipeDialog();
            return;
          }
          
          // 进入食谱详情
          _navigateToRecipeDetail(recipeId);
        },
        child: MinimalCard(
          width: MediaQuery.of(context).size.width * 0.51, // 屏幕宽度51% (64%再缩小20%)
          height: MediaQuery.of(context).size.height * 0.82, // 屏幕高度82% (66%延长25%)
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🎨 智能图标显示：预设菜谱用emoji，用户菜谱优先显示上传图片
              if (recipe['isPreset'] == true && recipe['emojiIcon'] != null && recipe['emojiIcon'].toString().isNotEmpty)
                // 预设菜谱：显示emoji图标
                _buildEmojiIcon(recipe, isDark)
              else if (recipe['isPreset'] != true && _hasUserUploadedImage(recipe))
                // 用户菜谱且有上传图片：显示用户上传的图片
                _buildUserRecipeImage(recipe, isDark)
              else
                // 其他情况：显示3D图标
                _buildDefault3DIcon(recipe),
              
              Space.h32,
              
              // 菜名
              Text(
                recipe['name'],
                style: AppTypography.titleMediumStyle(isDark: isDark),
                textAlign: TextAlign.center,
              ),
              
              Space.h16,
              
              // 时间信息
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: AppColors.getTextSecondaryColor(isDark),
                  ),
                  Space.w4,
                  Text(
                    '${recipe['time']}分钟',
                    style: AppTypography.timeStyle(isDark: isDark),
                  ),
                ],
              ),
              
              Space.h16,
              
              // // 点击提示
              // Text(
              //   '点击查看详情',
              //   style: AppTypography.hintStyle(isDark: isDark),
              // ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建方向按钮
  Widget _buildDirectionButtons(bool isDark) {
    return Stack(
      children: [
        // 上方按钮 - 上一个菜谱
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: _buildDirectionButton(
              icon: Icons.keyboard_arrow_up,
              onTap: _previousCard,
              isDark: isDark,
            ),
          ),
        ),
        
        // 下方按钮 - 下一个菜谱
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: _buildDirectionButton(
              icon: Icons.keyboard_arrow_down,
              onTap: _nextCard,
              isDark: isDark,
            ),
          ),
        ),
        
        // 左方按钮 - 时光机
        Positioned(
          left: 30,
          top: 0,
          bottom: 0,
          child: Center(
            child: _buildDirectionButton(
              icon: Icons.timeline,
              onTap: _navigateToTimeline,
              isDark: isDark,
              isSpecial: true, // 使用微妙彩色
            ),
          ),
        ),
        
        // 右方按钮 - AI推荐
        Positioned(
          right: 30,
          top: 0,
          bottom: 0,
          child: Center(
            child: _buildDirectionButton(
              icon: Icons.psychology,
              onTap: _navigateToAIRecommendation,
              isDark: isDark,
              isSpecial: true, // 使用微妙彩色
            ),
          ),
        ),
        
        // 右下角按钮 - 美食地图 ⭐ 新功能
        Positioned(
          right: 80,
          bottom: 80,
          child: _buildDirectionButton(
            icon: Icons.map,
            onTap: _navigateToFoodMap,
            isDark: isDark,
            isSpecial: true, // 使用微妙彩色
          ),
        ),
      ],
    );
  }
  
  /// 构建单个方向按钮
  Widget _buildDirectionButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    bool isSpecial = false,
  }) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSpecial 
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.getBackgroundColor(isDark).withOpacity(0.9),
            shape: BoxShape.circle,
            border: Border.all(
              color: isSpecial 
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadowColor(isDark).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSpecial 
                ? AppColors.primary
                : AppColors.getTextSecondaryColor(isDark),
          ),
        ),
      ),
    );
  }
  
  /// 构建按钮提示
  Widget _buildButtonHint(bool isDark) {
    return Container(
      //padding: EdgeInsets.only(bottom: AppSpacing.xl),
      height: 60,
      padding: const EdgeInsets.only(top: 16.0), // ✅ 整体下移一些
      child: Text(
        '🎯点击挑战按钮开始厨房对决 • 上下切换菜谱 • 左右探索功能',
        style: AppTypography.hintStyle(isDark: isDark),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  /// 构建新建菜谱按钮
  Widget _buildCreateRecipeButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BreathingWidget(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _navigateToCreateRecipe();
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  /// 构建语音按钮
    Widget _buildVoiceButton() {
      return Padding(
        padding: const EdgeInsets.only(left: 122.0), // 👉 向左边靠 12 像素
        child: VoiceInteractionWidget(
          onStartListening: () {
            HapticFeedback.lightImpact();
            PerformanceMonitor.monitorGesture('VoiceStart', () {
              _showVoiceInterface();
            });
          },
        ),
      );
    }
  
  // ==================== 数据获取方法 ====================
  
  /// 获取当前时间
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
  
  /// 获取问候语数据
  Map<String, dynamic> _getGreetingData() {
    final hour = DateTime.now().hour;
    final greetings = {
      'morning': {'text': '早上好呀Melody', 'icon': Icons.wb_sunny},
      'afternoon': {'text': '午后好呀Melody', 'icon': Icons.coffee},
      'evening': {'text': '晚上好呀Melody', 'icon': Icons.dinner_dining},
      'night': {'text': '早点休息吧Melody', 'icon': Icons.bedtime},
    };
    
    String timeOfDay;
    if (hour >= 6 && hour < 12) {
      timeOfDay = 'morning';
    } else if (hour >= 12 && hour < 17) {
      timeOfDay = 'afternoon';
    } else if (hour >= 17 && hour < 22) {
      timeOfDay = 'evening';
    } else {
      timeOfDay = 'night';
    }
    
    return greetings[timeOfDay]!;
  }
  
  /// 获取智能建议
  String _getSmartSuggestion() {
    final hour = DateTime.now().hour;
    final suggestions = {
      'morning': '来份营养早餐开启美好一天',
      'afternoon': '下午茶时间，来点轻食吧',
      'evening': '今晚想为她做点什么呢',
      'night': '要不要来点夜宵',
    };
    
    String timeOfDay;
    if (hour >= 6 && hour < 12) {
      timeOfDay = 'morning';
    } else if (hour >= 12 && hour < 17) {
      timeOfDay = 'afternoon';
    } else if (hour >= 17 && hour < 22) {
      timeOfDay = 'evening';
    } else {
      timeOfDay = 'night';
    }
    
    return suggestions[timeOfDay] ?? '探索更多美味';
  }
  
  /// 获取当前菜谱 - 🔧 优先使用数据库数据，fallback到示例数据
  Map<String, dynamic> _getCurrentRecipe() {
    // 如果有数据库中的菜谱，优先使用
    if (_allRecipes.isNotEmpty) {
      final validIndex = _currentIndex % _allRecipes.length;
      final recipe = _allRecipes[validIndex];
      
      // 解析图标类型
      AppIcon3DType iconType;
      try {
        iconType = AppIcon3DType.values.firstWhere(
          (type) => type.toString() == recipe.iconType,
          orElse: () => AppIcon3DType.heart,
        );
      } catch (e) {
        iconType = AppIcon3DType.heart;
      }
      
      return {
        'name': recipe.name,
        'time': recipe.totalTime,
        'iconType': iconType,
        'id': recipe.id,
        'emojiIcon': recipe.emojiIcon, // 🔧 新增：传递emoji图标
        'isPreset': recipe.isPreset,   // 🔧 新增：标记是否为预设菜谱
      };
    }
    
    // 如果数据库中没有菜谱，显示提示信息
    if (_allRecipes.isEmpty) {
      return {
        'name': '暂无菜谱',
        'time': 0,
        'iconType': AppIcon3DType.heart,
        'id': 'empty',
        'description': '点击右上角设置按钮导入示例菜谱开始体验',
      };
    }
    
    // 循环显示真实菜谱数据
    final validIndex = _currentIndex % _allRecipes.length;
    final recipe = _allRecipes[validIndex];
    return {
      'name': recipe.name,
      'time': recipe.totalTime,
      'iconType': _parseIconType(recipe.iconType),
      'id': recipe.id,
      'description': recipe.description,
    };
  }
  
  /// 解析图标类型字符串为枚举
  AppIcon3DType _parseIconType(String iconTypeString) {
    switch (iconTypeString) {
      case 'AppIcon3DType.bowl':
        return AppIcon3DType.bowl;
      case 'AppIcon3DType.spoon':
        return AppIcon3DType.spoon;
      case 'AppIcon3DType.chef':
        return AppIcon3DType.chef;
      case 'AppIcon3DType.timer':
        return AppIcon3DType.timer;
      case 'AppIcon3DType.recipe':
        return AppIcon3DType.recipe;
      case 'AppIcon3DType.heart':
        return AppIcon3DType.heart;
      default:
        return AppIcon3DType.heart;
    }
  }
  
  // ==================== 交互处理方法 ====================
  
  /// 下一张卡片
  void _nextCard() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex++;
    });
  }
  
  /// 上一张卡片
  void _previousCard() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_currentIndex > 0) _currentIndex--;
    });
  }
  
  
  /// 显示语音界面
  void _showVoiceInterface() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => VoiceInteractionDialog(
        onVoiceCommand: _handleVoiceCommand,
      ),
    );
  }
  
  /// 处理语音指令
  void _handleVoiceCommand(String command) {
    HapticFeedback.mediumImpact();
    
    // 动态菜谱识别逻辑
    bool recipeFound = false;
    for (int i = 0; i < _allRecipes.length; i++) {
      if (command.contains(_allRecipes[i].name)) {
        setState(() {
          _currentIndex = i;
        });
        _cardController.forward(from: 0);
        recipeFound = true;
        break;
      }
    }
    
    if (!recipeFound) {
      // 功能指令识别
      if (command.contains('烹饪') || command.contains('制作')) {
        _navigateToCookingMode();
      } else if (command.contains('推荐') || command.contains('AI')) {
        _navigateToAIRecommendation();
      } else if (command.contains('时光机') || command.contains('历史')) {
        _navigateToTimeline();
      } else if (command.contains('挑战') || command.contains('对决')) {
        _navigateToChallenge();
      } else {
        // 默认显示提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已识别："$command"'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  // ==================== 导航方法 ====================
  
  /// 导航到AI推荐页面
  void _navigateToAIRecommendation() {
    HapticFeedback.mediumImpact();
    context.push(AppRouter.aiRecommendation);
  }
  
  /// 导航到3D时光机页面
  void _navigateToTimeline() {
    HapticFeedback.mediumImpact();
    context.push(AppRouter.timeline);
  }
  
  /// 导航到烹饪模式
  void _navigateToCookingMode({String? recipeId}) {
    HapticFeedback.mediumImpact();
    
    final targetRecipeId = recipeId ?? _getCurrentRecipe()['id'];
    
    // 🔧 修复：如果没有真实菜谱，引导用户导入菜谱
    if (targetRecipeId == 'empty' || _allRecipes.isEmpty) {
      _showImportRecipeDialog();
      return;
    }
    
    context.push('${AppRouter.cookingMode}?recipeId=$targetRecipeId');
  }
  
  /// 导航到创建食谱页面
  void _navigateToCreateRecipe() {
    HapticFeedback.mediumImpact();
    context.push(AppRouter.createRecipe);
  }
  
  /// 导航到搜索页面
  void _navigateToSearch() {
    HapticFeedback.mediumImpact();
    context.push(AppRouter.search);
  }
  
  /// 导航到个人中心页面
  void _navigateToPersonalCenter() {
    HapticFeedback.mediumImpact();
    context.push(AppRouter.personalCenter);
  }
  
  /// 导航到食谱详情页面
  void _navigateToRecipeDetail(String recipeId) {
    HapticFeedback.mediumImpact();
    // 🔧 修复路由错误：正确替换路径参数
    context.push(AppRouter.recipeDetail.replaceAll(':id', recipeId));
  }
  
  /// 显示导入菜谱引导对话框
  void _showImportRecipeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🍳 开始你的美食之旅'),
        content: const Text(
          '看起来你还没有菜谱呢！\n\n'
          '点击右上角设置按钮，导入示例菜谱开始体验，'
          '或者创建你的第一个菜谱吧～'
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('稍后再说'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/profile/settings');
            },
            child: const Text('去导入菜谱'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToCreateRecipe();
            },
            child: const Text('创建菜谱'),
          ),
        ],
      ),
    );
  }

  /// 导航到挑战页面 ⭐ 新功能
  void _navigateToChallenge() {
    HapticFeedback.mediumImpact();
    context.push(AppRouter.challenge);
  }
  
  /// 导航到情侣档案页面
  void _navigateToCoupleProfile() {
    HapticFeedback.mediumImpact();
    context.push(AppRouter.coupleProfile);
  }
  
  /// 导航到美食地图页面 ⭐ 新功能
  void _navigateToFoodMap() {
    HapticFeedback.mediumImpact();
    context.push(AppRouter.foodMap);
  }
  
  /// 导航到亲密度系统页面 ⭐ 新功能
  void _navigateToIntimacy() {
    HapticFeedback.mediumImpact();
    context.push(AppRouter.intimacy);
  }
  
  // ==================== 图标构建方法 ====================
  
  /// 检查用户是否上传了图片
  bool _hasUserUploadedImage(Map<String, dynamic> recipe) {
    return (recipe['imageUrl'] != null && recipe['imageUrl'].toString().isNotEmpty) ||
           (recipe['imageBase64'] != null && recipe['imageBase64'].toString().isNotEmpty) ||
           (recipe['imagePath'] != null && recipe['imagePath'].toString().isNotEmpty);
  }
  
  /// 构建emoji图标（预设菜谱专用）
  Widget _buildEmojiIcon(Map<String, dynamic> recipe, bool isDark) {
    return GestureDetector(
      onTap: () {
        final currentRecipe = _getCurrentRecipe();
        final recipeId = currentRecipe['id'];
        
        if (recipeId == 'empty' || _allRecipes.isEmpty) {
          _showImportRecipeDialog();
          return;
        }
        
        _navigateToRecipeDetail(recipeId);
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGradient.colors[0].withOpacity(0.1),
              AppColors.primaryGradient.colors[1].withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            recipe['emojiIcon'] ?? '🍳',
            style: const TextStyle(fontSize: 80),
          ),
        ),
      ),
    );
  }
  
  /// 构建用户上传的菜谱图片（用户菜谱专用）
  Widget _buildUserRecipeImage(Map<String, dynamic> recipe, bool isDark) {
    return GestureDetector(
      onTap: () {
        final currentRecipe = _getCurrentRecipe();
        final recipeId = currentRecipe['id'];
        
        if (recipeId == 'empty' || _allRecipes.isEmpty) {
          _showImportRecipeDialog();
          return;
        }
        
        _navigateToRecipeDetail(recipeId);
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadowColor(isDark).withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // 主图片
              _buildImageWidget(recipe),
              
              // 渐变遮罩（增强对比度，确保与emoji视觉一致）
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建图片组件 - 支持多种图片源
  Widget _buildImageWidget(Map<String, dynamic> recipe) {
    // 优先级：imageUrl > imageBase64 > imagePath
    final imageUrl = recipe['imageUrl'];
    final imageBase64 = recipe['imageBase64'];
    final imagePath = recipe['imagePath'];
    
    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      // Firebase Storage URL
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: 150,
        height: 150,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 150,
            height: 150,
            color: AppColors.backgroundSecondary,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
      );
    }
    
    if (imageBase64 != null && imageBase64.toString().isNotEmpty) {
      // Base64图片
      try {
        // 处理data URL格式
        String base64String = imageBase64.toString();
        if (base64String.startsWith('data:image/')) {
          base64String = base64String.split(',')[1];
        }
        
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: 150,
          height: 150,
          errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
        );
      } catch (e) {
        debugPrint('❌ Base64图片解析失败: $e');
        return _buildImageFallback();
      }
    }
    
    if (imagePath != null && imagePath.toString().isNotEmpty) {
      // 本地图片路径
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: 150,
        height: 150,
        errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
      );
    }
    
    return _buildImageFallback();
  }
  
  /// 图片加载失败时的fallback
  Widget _buildImageFallback() {
    return Container(
      width: 150,
      height: 150,
      color: AppColors.backgroundSecondary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 40,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              '图片加载失败',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建默认3D图标（fallback）
  Widget _buildDefault3DIcon(Map<String, dynamic> recipe) {
    return AppIcon3D(
      type: recipe['iconType'] ?? 'cooking',
      size: 150,
      isAnimated: true,
      onTap: () {
        final currentRecipe = _getCurrentRecipe();
        final recipeId = currentRecipe['id'];
        
        if (recipeId == 'empty' || _allRecipes.isEmpty) {
          _showImportRecipeDialog();
          return;
        }
        
        _navigateToRecipeDetail(recipeId);
      },
    );
  }
}