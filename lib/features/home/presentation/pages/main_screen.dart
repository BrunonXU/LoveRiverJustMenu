import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../core/utils/performance_monitor.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';

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
  double _dragOffset = 0;
  bool _isLoading = true;
  
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
    
    // 模拟数据加载
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    
    PerformanceMonitor.endOperation(stopwatch, 'LoadInitialData');
  }
  
  // ==================== 界面构建 ====================
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppColors.getTimeBasedBackground(),
      body: SafeArea(
        child: _isLoading 
            ? _buildLoadingState() 
            : _buildMainContent(isDark),
      ),
      
      // 语音按钮 - 56x56px纯黑圆形
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
        
        // 隐形导航提示
        _buildNavigationHint(isDark),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    greetingData['icon'],
                    size: 24,
                    color: AppColors.getTextPrimaryColor(isDark),
                  ),
                  Space.w8,
                  Text(
                    greetingData['text'],
                    style: AppTypography.greetingStyle(isDark: isDark),
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
          
          // 右侧时间区域
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getCurrentTime(),
                style: AppTypography.displayLargeStyle(isDark: isDark),
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
  
  /// 构建卡片区域
  Widget _buildCardArea(bool isDark) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        PerformanceMonitor.monitorGesture('VerticalDrag', () {
          setState(() {
            _dragOffset = details.delta.dy;
          });
        });
      },
      onVerticalDragEnd: (details) {
        PerformanceMonitor.monitorGesture('VerticalDragEnd', () {
          if (details.velocity.pixelsPerSecond.dy < -300) {
            // 上滑 - 下一个
            _nextCard();
          } else if (details.velocity.pixelsPerSecond.dy > 300) {
            // 下滑 - 上一个或创建
            if (_currentIndex == 0) {
              _showCreateMode();
            } else {
              _previousCard();
            }
          }
          setState(() {
            _dragOffset = 0;
          });
        });
      },
      child: Center(
        child: _buildRecipeCard(isDark),
      ),
    );
  }
  
  /// 构建菜谱卡片
  Widget _buildRecipeCard(bool isDark) {
    final recipe = _getCurrentRecipe();
    
    return BreathingWidget(
      child: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: MinimalCard(
          width: 320,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3D扁平图标 - 120x120px
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  recipe['icon'],
                  size: 60,
                  color: Colors.white,
                ),
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
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建导航提示
  Widget _buildNavigationHint(bool isDark) {
    return Container(
      padding: EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.keyboard_arrow_up,
            color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
            size: 20,
          ),
          Space.h4,
          Text(
            '滑动探索',
            style: AppTypography.hintStyle(isDark: isDark),
          ),
        ],
      ),
    );
  }
  
  /// 构建语音按钮
  Widget _buildVoiceButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.textPrimary, // 纯黑
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            PerformanceMonitor.monitorGesture('VoiceTap', () {
              _showVoiceInterface();
            });
          },
          child: const Icon(
            Icons.mic,
            color: Colors.white,
            size: 24,
          ),
        ),
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
      'morning': {'text': '早安', 'icon': Icons.wb_sunny},
      'afternoon': {'text': '午后好', 'icon': Icons.coffee},
      'evening': {'text': '晚上好', 'icon': Icons.dinner_dining},
      'night': {'text': '夜深了', 'icon': Icons.bedtime},
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
  
  /// 获取当前菜谱
  Map<String, dynamic> _getCurrentRecipe() {
    final recipes = [
      {'name': '银耳莲子羹', 'time': 20, 'icon': Icons.local_cafe},
      {'name': '番茄鸡蛋面', 'time': 15, 'icon': Icons.ramen_dining},
      {'name': '红烧排骨', 'time': 45, 'icon': Icons.dinner_dining},
      {'name': '蒸蛋羹', 'time': 10, 'icon': Icons.egg_alt},
      {'name': '青椒肉丝', 'time': 25, 'icon': Icons.restaurant},
    ];
    return recipes[_currentIndex % recipes.length];
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
  
  /// 显示创建模式
  void _showCreateMode() {
    HapticFeedback.mediumImpact();
    // TODO: 实现创建模式
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('创建模式开发中...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// 显示语音界面
  void _showVoiceInterface() {
    HapticFeedback.lightImpact();
    // TODO: 实现语音界面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('语音功能开发中...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}