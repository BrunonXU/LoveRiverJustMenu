import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../core/utils/performance_monitor.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../../../shared/widgets/app_icon_3d.dart';
import '../../../../shared/widgets/voice_interaction_widget.dart';
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
      if (currentUser == null) {
        print('用户未登录，使用默认数据');
        if (mounted) {
          setState(() {
            _allRecipes = [];
            _isLoading = false;
          });
        }
        return;
      }
      
      // 🔧 从云端数据库加载用户菜谱数据
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      final userRecipes = await repository.getUserRecipes(currentUser.uid);
      
      if (mounted) {
        setState(() {
          _allRecipes = userRecipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('加载菜谱数据失败: $e');
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
      body: ChristmasSnowEffect(
        enableClickEffect: true,
        snowflakeCount: 5, // 最少雪花数量保证60FPS
        clickEffectColor: const Color(0xFF00BFFF), // 海蓝色点击特效
        child: SafeArea(
          child: _isLoading 
              ? _buildLoadingState() 
              : _buildMainContent(isDark),
        ),
      ),
      
      // 浫动按钮移到最外层，避免手势冲突
      floatingActionButton: Stack(
        children: [
          Positioned(
            left: 30,
            bottom: 30,
            child: _buildCreateRecipeButton(),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _buildVoiceButton(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
  
  /// 构建主要内容
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
          // 进入食谱详情
          _navigateToRecipeDetail(recipe['id'] ?? 'recipe_1');
        },
        child: MinimalCard(
          width: MediaQuery.of(context).size.width * 0.51, // 屏幕宽度51% (64%再缩小20%)
          height: MediaQuery.of(context).size.height * 0.82, // 屏幕高度82% (66%延长25%)
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3D扁平图标 - 100x100px (适配更窄卡片)
              AppIcon3D(
                type: recipe['iconType'],
                size: 150,
                isAnimated: true,
                onTap: () {
                  // 🔧 修复：点击图标进入对应菜谱详情
                  final currentRecipe = _getCurrentRecipe();
                  _navigateToRecipeDetail(currentRecipe['id'] ?? 'recipe_1');
                },
              ),
              
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
      };
    }
    
    // 如果数据库中没有菜谱，使用示例数据作为fallback
    final fallbackRecipes = [
      {'name': '银耳莲子羹', 'time': 20, 'iconType': AppIcon3DType.bowl, 'id': 'recipe_1'},
      {'name': '番茄鸡蛋面', 'time': 15, 'iconType': AppIcon3DType.spoon, 'id': 'recipe_2'},
      {'name': '红烧排骨', 'time': 45, 'iconType': AppIcon3DType.chef, 'id': 'recipe_3'},
      {'name': '蒸蛋羹', 'time': 10, 'iconType': AppIcon3DType.timer, 'id': 'recipe_4'},
      {'name': '青椒肉丝', 'time': 25, 'iconType': AppIcon3DType.recipe, 'id': 'recipe_5'},
      {'name': '爱心早餐', 'time': 30, 'iconType': AppIcon3DType.heart, 'id': 'recipe_6'},
      {'name': '宫保鸡丁', 'time': 20, 'iconType': AppIcon3DType.chef, 'id': 'recipe_7'},
      {'name': '麻婆豆腐', 'time': 15, 'iconType': AppIcon3DType.bowl, 'id': 'recipe_8'},
      {'name': '糖醋里脊', 'time': 35, 'iconType': AppIcon3DType.recipe, 'id': 'recipe_9'},
      {'name': '酸菜鱼', 'time': 40, 'iconType': AppIcon3DType.spoon, 'id': 'recipe_10'},
      {'name': '口水鸡', 'time': 25, 'iconType': AppIcon3DType.chef, 'id': 'recipe_11'},
      {'name': '蛋花汤', 'time': 5, 'iconType': AppIcon3DType.bowl, 'id': 'recipe_12'},
    ];
    
    final validIndex = _currentIndex % fallbackRecipes.length;
    return fallbackRecipes[validIndex];
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
    
    // 简单的指令识别逻辑
    if (command.contains('银耳莲子羹')) {
      setState(() {
        _currentIndex = 0; // 银耳莲子羹对应的索引
      });
      _cardController.forward(from: 0);
    } else if (command.contains('番茄鸡蛋面')) {
      setState(() {
        _currentIndex = 1;
      });
      _cardController.forward(from: 0);
    } else if (command.contains('烹饪') || command.contains('制作')) {
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
}