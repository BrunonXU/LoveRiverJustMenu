import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/voice_interaction_widget.dart';
import '../../domain/models/story_recommendation.dart';

/// 🤖 AI推荐页面V2 - 时间驱动界面+情境卡片+语音交互
/// 根据不同时间段自动调整UI风格和推荐内容
class AiRecommendationScreenV2 extends ConsumerStatefulWidget {
  const AiRecommendationScreenV2({super.key});

  @override
  ConsumerState<AiRecommendationScreenV2> createState() => _AiRecommendationScreenV2State();
}

class _AiRecommendationScreenV2State extends ConsumerState<AiRecommendationScreenV2>
    with TickerProviderStateMixin {
  
  // ==================== 动画控制器 ====================
  
  late AnimationController _backgroundController;
  late AnimationController _cardController;
  late AnimationController _voiceController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _voiceAnimation;
  
  // ==================== 状态变量 ====================
  
  int _currentCardIndex = 0;
  bool _isVoiceActive = false;
  List<StoryRecommendation> _recommendations = [];
  TimeOfDay _currentTimeOfDay = TimeOfDay.morning;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTimeBasedRecommendations();
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    _cardController.dispose();
    _voiceController.dispose();
    super.dispose();
  }
  
  /// 初始化动画
  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _voiceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );
    
    _voiceAnimation = CurvedAnimation(
      parent: _voiceController,
      curve: Curves.elasticOut,
    );
    
    _cardController.forward();
  }
  
  /// 根据时间加载推荐内容
  void _loadTimeBasedRecommendations() {
    _currentTimeOfDay = _getCurrentTimeOfDay();
    _recommendations = _getTimeBasedRecommendations(_currentTimeOfDay);
  }
  
  /// 获取当前时间段
  TimeOfDay _getCurrentTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return TimeOfDay.morning;
    if (hour >= 12 && hour < 17) return TimeOfDay.afternoon;
    if (hour >= 17 && hour < 22) return TimeOfDay.evening;
    return TimeOfDay.night;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🎨 时间驱动的动态背景
          _buildTimeDrivenBackground(),
          
          // 🎨 主要内容区域
          SafeArea(
            child: Column(
              children: [
                // 🎨 时间感知头部
                _buildTimeAwareHeader(),
                
                // 🎨 情境卡片区域
                Expanded(
                  child: _buildContextualCards(),
                ),
                
                // 🎨 语音交互区域
                _buildVoiceInteractionArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 🎨 时间驱动的动态背景
  Widget _buildTimeDrivenBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: _getTimeBasedGradient(_currentTimeOfDay, _backgroundAnimation.value),
          ),
        );
      },
    );
  }
  
  /// 获取基于时间的渐变背景
  LinearGradient _getTimeBasedGradient(TimeOfDay timeOfDay, double animationValue) {
    Color baseColor, accentColor;
    
    switch (timeOfDay) {
      case TimeOfDay.morning:
        baseColor = Color.lerp(const Color(0xFFFFF5E6), const Color(0xFFFFE4B5), animationValue)!;
        accentColor = Color.lerp(const Color(0xFFFFE4B5), const Color(0xFFFFF5E6), animationValue)!;
        break;
      case TimeOfDay.afternoon:
        baseColor = Color.lerp(const Color(0xFFFFFFF8), const Color(0xFFFFF8DC), animationValue)!;
        accentColor = Color.lerp(const Color(0xFFFFF8DC), const Color(0xFFFFFFF8), animationValue)!;
        break;
      case TimeOfDay.evening:
        baseColor = Color.lerp(const Color(0xFFFFE4E1), const Color(0xFFFFC0CB), animationValue)!;
        accentColor = Color.lerp(const Color(0xFFFFC0CB), const Color(0xFFFFE4E1), animationValue)!;
        break;
      case TimeOfDay.night:
        baseColor = Color.lerp(const Color(0xFF191970), const Color(0xFF2F2F4F), animationValue)!;
        accentColor = Color.lerp(const Color(0xFF2F2F4F), const Color(0xFF191970), animationValue)!;
        break;
    }
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [baseColor, accentColor],
    );
  }
  
  /// 🎨 时间感知头部
  Widget _buildTimeAwareHeader() {
    final greeting = _getTimeBasedGreeting(_currentTimeOfDay);
    final isDark = _currentTimeOfDay == TimeOfDay.night;
    
    return Padding(
      padding: const EdgeInsets.all(24),
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
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.arrow_back,
                size: 20,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 时间问候
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      greeting['icon'] ?? '🤖',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      greeting['text'] ?? 'AI推荐',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  greeting['subtitle'] ?? '为你推荐美食',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          
          // AI状态指示器
          BreathingWidget(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF5B6FED),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B6FED).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 🎨 情境卡片区域
  Widget _buildContextualCards() {
    if (_recommendations.isEmpty) {
      return _buildEmptyState();
    }
    
    return PageView.builder(
      onPageChanged: (index) {
        setState(() {
          _currentCardIndex = index;
        });
        _cardController.forward(from: 0);
        HapticFeedback.lightImpact();
      },
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AnimatedBuilder(
            animation: _cardAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - _cardAnimation.value)),
                child: Opacity(
                  opacity: _cardAnimation.value,
                  child: _buildContextualCard(_recommendations[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  /// 🎨 单个情境卡片
  Widget _buildContextualCard(StoryRecommendation recommendation) {
    final isDark = _currentTimeOfDay == TimeOfDay.night;
    
    return GestureDetector(
      onTap: () => _handleRecommendationTap(recommendation),
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // 情境标签头部
            Container(
              decoration: BoxDecoration(
                gradient: recommendation.gradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getContextIcon(recommendation.type),
                          size: 16,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          recommendation.context,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 卡片内容
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI对话文案
                    Text(
                      '"${recommendation.narrative}"',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.6,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 推荐菜谱
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // 菜谱图标
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                recommendation.icon,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // 菜谱信息
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recommendation.recipe,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  recommendation.reason,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                                if (recommendation.cookingTime != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${recommendation.cookingTime}分钟',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          // 箭头指示
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // 营养提示
                    if (recommendation.nutritionTip != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              size: 18,
                              color: Color(0xFFFF9800),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                recommendation.nutritionTip!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                            ),
                          ],
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
  
  /// 🎨 语音交互区域
  Widget _buildVoiceInteractionArea() {
    final isDark = _currentTimeOfDay == TimeOfDay.night;
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 页面指示器
          if (_recommendations.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_recommendations.length, (index) {
                final isActive = index == _currentCardIndex;
                return Container(
                  width: isActive ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? const Color(0xFF5B6FED)
                        : (isDark ? Colors.white30 : Colors.black26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          
          const SizedBox(height: 16),
          
          // 语音交互按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 换一个推荐
              _buildActionButton(
                icon: Icons.refresh,
                label: '换一个',
                onTap: _refreshRecommendations,
                isDark: isDark,
              ),
              
              // 语音交互
              AnimatedBuilder(
                animation: _voiceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isVoiceActive ? (1.0 + _voiceAnimation.value * 0.1) : 1.0,
                    child: _buildVoiceButton(isDark),
                  );
                },
              ),
              
              // 开始烹饪
              _buildActionButton(
                icon: Icons.play_arrow,
                label: '开始烹饪',
                onTap: _startCooking,
                isDark: isDark,
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 🎨 语音按钮
  Widget _buildVoiceButton(bool isDark) {
    return GestureDetector(
      onTap: _toggleVoiceInteraction,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: _isVoiceActive
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                )
              : LinearGradient(
                  colors: [
                    isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                    isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                  ],
                ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _isVoiceActive
                  ? const Color(0xFFFF6B6B).withOpacity(0.4)
                  : Colors.black.withOpacity(0.1),
              blurRadius: _isVoiceActive ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          _isVoiceActive ? Icons.mic : Icons.mic_none,
          size: 28,
          color: _isVoiceActive
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.black54),
        ),
      ),
    );
  }
  
  /// 🎨 操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFF5B6FED), Color(0xFF8B9BF3)],
                )
              : null,
          color: isPrimary
              ? null
              : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 🎨 空状态
  Widget _buildEmptyState() {
    final isDark = _currentTimeOfDay == TimeOfDay.night;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BreathingWidget(
            child: Icon(
              Icons.auto_awesome_outlined,
              size: 64,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI正在思考中...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '稍等片刻，为你生成专属推荐',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
  
  // ==================== 数据获取方法 ====================
  
  /// 获取基于时间的问候语
  Map<String, String> _getTimeBasedGreeting(TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return {
          'icon': '🌅',
          'text': '早安推荐',
          'subtitle': '美好的一天从营养早餐开始',
        };
      case TimeOfDay.afternoon:
        return {
          'icon': '☀️',
          'text': '午后时光',
          'subtitle': '为你推荐清爽的午后美食',
        };
      case TimeOfDay.evening:
        return {
          'icon': '🌆',
          'text': '晚餐时分',
          'subtitle': '今晚想为她做点什么特别的',
        };
      case TimeOfDay.night:
        return {
          'icon': '🌙',
          'text': '夜宵时光',
          'subtitle': '深夜治愈系美食陪伴你',
        };
    }
  }
  
  /// 获取基于时间的推荐
  List<StoryRecommendation> _getTimeBasedRecommendations(TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return _getMorningRecommendations();
      case TimeOfDay.afternoon:
        return _getAfternoonRecommendations();
      case TimeOfDay.evening:
        return _getEveningRecommendations();
      case TimeOfDay.night:
        return _getNightRecommendations();
    }
  }
  
  /// 早上推荐
  List<StoryRecommendation> _getMorningRecommendations() {
    return [
      const StoryRecommendation(
        context: '清晨唤醒',
        narrative: '新的一天开始了，来一份营养丰富的早餐为身体充电吧',
        recipe: '牛油果吐司',
        reason: '富含健康脂肪，为一天提供持续能量',
        icon: '🥑',
        type: RecommendationType.nutrition,
        nutritionTip: '牛油果含有丰富的不饱和脂肪酸，有助于心血管健康',
        cookingTime: 10,
        difficulty: 1,
      ),
      const StoryRecommendation(
        context: '温馨晨光',
        narrative: '窗外阳光正好，来一杯温暖的饮品开启美好心情',
        recipe: '蜂蜜柠檬茶',
        reason: '维生素C助力免疫，温暖身心',
        icon: '🍯',
        type: RecommendationType.mood,
        nutritionTip: '柠檬富含维生素C，蜂蜜具有抗菌消炎的作用',
        cookingTime: 5,
        difficulty: 1,
      ),
    ];
  }
  
  /// 下午推荐
  List<StoryRecommendation> _getAfternoonRecommendations() {
    return [
      const StoryRecommendation(
        context: '午后小憩',
        narrative: '下午茶时间到了，来点清爽的小食为下午加油',
        recipe: '水果沙拉',
        reason: '天然糖分补充能量，纤维助消化',
        icon: '🥗',
        type: RecommendationType.nutrition,
        nutritionTip: '多种水果组合提供全面维生素',
        cookingTime: 15,
        difficulty: 1,
      ),
      const StoryRecommendation(
        context: '阳光正好',
        narrative: '趁着好天气，来一份清香的茶点享受悠闲时光',
        recipe: '抹茶玛德琳',
        reason: '抹茶的清香搭配小点心的甜蜜',
        icon: '🍵',
        type: RecommendationType.mood,
        nutritionTip: '抹茶含有茶多酚，具有抗氧化作用',
        cookingTime: 45,
        difficulty: 3,
      ),
    ];
  }
  
  /// 晚上推荐
  List<StoryRecommendation> _getEveningRecommendations() {
    return [
      const StoryRecommendation(
        context: '浪漫晚餐',
        narrative: '夜幕降临，为心爱的人准备一顿浪漫的晚餐',
        recipe: '红酒炖牛肉',
        reason: '浓郁醇香，营造温馨氛围',
        icon: '🍷',
        type: RecommendationType.special,
        nutritionTip: '牛肉富含蛋白质和铁质，红酒适量饮用有益心血管',
        cookingTime: 120,
        difficulty: 4,
      ),
      const StoryRecommendation(
        context: '家常温暖',
        narrative: '简单的家常菜，承载着最真挚的爱意',
        recipe: '番茄鸡蛋面',
        reason: '经典搭配，温暖人心',
        icon: '🍜',
        type: RecommendationType.mood,
        nutritionTip: '番茄富含番茄红素，鸡蛋提供优质蛋白',
        cookingTime: 20,
        difficulty: 2,
      ),
    ];
  }
  
  /// 夜间推荐
  List<StoryRecommendation> _getNightRecommendations() {
    return [
      const StoryRecommendation(
        context: '深夜治愈',
        narrative: '深夜时分，来一份温暖的夜宵慰藉疲惫的心',
        recipe: '银耳莲子汤',
        reason: '滋润养颜，助眠安神',
        icon: '🌙',
        type: RecommendationType.mood,
        nutritionTip: '银耳富含胶原蛋白，莲子有安神的功效',
        cookingTime: 60,
        difficulty: 2,
      ),
      const StoryRecommendation(
        context: '夜宵小食',
        narrative: '工作到深夜，来点简单的小食补充能量',
        recipe: '小馄饨',
        reason: '暖胃暖心，不给肠胃造成负担',
        icon: '🥟',
        type: RecommendationType.nutrition,
        nutritionTip: '馄饨皮薄馅嫩，易消化吸收',
        cookingTime: 25,
        difficulty: 2,
      ),
    ];
  }
  
  /// 获取情境图标
  IconData _getContextIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.weather:
        return Icons.wb_sunny;
      case RecommendationType.nutrition:
        return Icons.favorite;
      case RecommendationType.special:
        return Icons.celebration;
      case RecommendationType.mood:
        return Icons.sentiment_satisfied;
    }
  }
  
  // ==================== 交互处理方法 ====================
  
  /// 处理推荐点击
  void _handleRecommendationTap(StoryRecommendation recommendation) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: _currentTimeOfDay == TimeOfDay.night
                  ? const Color(0xFF1A1A1A)
                  : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // 拖拽指示器
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentTimeOfDay == TimeOfDay.night
                        ? Colors.white30
                        : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // 内容区域
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 推荐标题
                        Row(
                          children: [
                            Text(
                              recommendation.icon,
                              style: const TextStyle(fontSize: 60),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recommendation.recipe,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w300,
                                      color: _currentTimeOfDay == TimeOfDay.night
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: recommendation.gradient,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      recommendation.context,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // 故事描述
                        Text(
                          recommendation.narrative,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: _currentTimeOfDay == TimeOfDay.night
                                ? Colors.white
                                : Colors.black87,
                            height: 1.6,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 推荐理由
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _currentTimeOfDay == TimeOfDay.night
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 20,
                                color: _currentTimeOfDay == TimeOfDay.night
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  recommendation.reason,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _currentTimeOfDay == TimeOfDay.night
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        if (recommendation.nutritionTip != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4E6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline,
                                  size: 20,
                                  color: Color(0xFFFF9800),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    recommendation.nutritionTip!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFE65100),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // 菜谱信息
                        if (recommendation.cookingTime != null || recommendation.difficulty != null) ...[
                          Row(
                            children: [
                              if (recommendation.cookingTime != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _currentTimeOfDay == TimeOfDay.night
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 16,
                                        color: _currentTimeOfDay == TimeOfDay.night
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${recommendation.cookingTime} 分钟',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _currentTimeOfDay == TimeOfDay.night
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (recommendation.difficulty != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _currentTimeOfDay == TimeOfDay.night
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_outline,
                                        size: 16,
                                        color: _currentTimeOfDay == TimeOfDay.night
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _getDifficultyText(recommendation.difficulty!),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _currentTimeOfDay == TimeOfDay.night
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                        
                        // 开始烹饪按钮
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _startCooking();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B6FED),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '开始烹饪',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  /// 获取难度文本
  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1: return '简单';
      case 2: return '容易';
      case 3: return '中等';
      case 4: return '困难';
      case 5: return '专业';
      default: return '未知';
    }
  }
  
  /// 刷新推荐
  void _refreshRecommendations() {
    HapticFeedback.mediumImpact();
    _loadTimeBasedRecommendations();
    setState(() {
      _currentCardIndex = 0;
    });
    _cardController.forward(from: 0);
  }
  
  /// 切换语音交互
  void _toggleVoiceInteraction() {
    HapticFeedback.lightImpact();
    setState(() {
      _isVoiceActive = !_isVoiceActive;
    });
    
    if (_isVoiceActive) {
      _voiceController.repeat(reverse: true);
      _showVoiceDialog();
    } else {
      _voiceController.stop();
      _voiceController.reset();
    }
  }
  
  /// 显示语音对话
  void _showVoiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: _currentTimeOfDay == TimeOfDay.night
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BreathingWidget(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '正在聆听...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: _currentTimeOfDay == TimeOfDay.night
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '试试说"推荐一个简单的菜"',
              style: TextStyle(
                fontSize: 14,
                color: _currentTimeOfDay == TimeOfDay.night
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isVoiceActive = false;
              });
              _voiceController.stop();
              _voiceController.reset();
              _handleVoiceCommand('推荐一个简单的菜');
            },
            child: Text(
              '完成',
              style: TextStyle(
                color: _currentTimeOfDay == TimeOfDay.night
                    ? Colors.white
                    : const Color(0xFF5B6FED),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 处理语音指令
  void _handleVoiceCommand(String command) {
    // 模拟语音识别结果
    if (command.contains('简单') || command.contains('容易')) {
      // 筛选简单的菜谱
      final simpleRecipes = _recommendations.where((r) => 
        r.difficulty != null && r.difficulty! <= 2
      ).toList();
      
      if (simpleRecipes.isNotEmpty) {
        final randomIndex = math.Random().nextInt(simpleRecipes.length);
        _handleRecommendationTap(simpleRecipes[randomIndex]);
      }
    } else if (command.contains('快手') || command.contains('快速')) {
      // 筛选快手菜
      final quickRecipes = _recommendations.where((r) => 
        r.cookingTime != null && r.cookingTime! <= 20
      ).toList();
      
      if (quickRecipes.isNotEmpty) {
        final randomIndex = math.Random().nextInt(quickRecipes.length);
        _handleRecommendationTap(quickRecipes[randomIndex]);
      }
    } else {
      // 随机推荐
      _refreshRecommendations();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已识别语音指令："$command"'),
        backgroundColor: const Color(0xFF5B6FED),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// 开始烹饪
  void _startCooking() {
    HapticFeedback.mediumImpact();
    if (_recommendations.isNotEmpty) {
      final currentRecommendation = _recommendations[_currentCardIndex];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('准备开始制作${currentRecommendation.recipe}'),
          backgroundColor: const Color(0xFF5B6FED),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      
      // TODO: 导航到烹饪模式
      // context.push('/cooking-mode?recipeId=${currentRecommendation.recipeId}');
    }
  }
}

/// 时间段枚举
enum TimeOfDay {
  morning,
  afternoon,
  evening,
  night,
}