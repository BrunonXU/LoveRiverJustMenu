import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../core/themes/typography.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../domain/models/story_recommendation.dart';

/// AI智能推荐故事组件
/// 严格遵循95%黑白灰设计原则，故事化推荐呈现
class AIStoryWidget extends StatefulWidget {
  final List<StoryRecommendation> recommendations;
  final Function(StoryRecommendation recommendation)? onRecommendationTap;
  final VoidCallback? onShake;
  
  const AIStoryWidget({
    super.key,
    required this.recommendations,
    this.onRecommendationTap,
    this.onShake,
  });

  @override
  State<AIStoryWidget> createState() => _AIStoryWidgetState();
}

class _AIStoryWidgetState extends State<AIStoryWidget>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _shakeController;
  late Animation<double> _cardAnimation;
  late Animation<double> _shakeAnimation;
  
  int _currentStoryIndex = 0;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor, // 95%白色背景
      ),
      child: SafeArea(
        child: Column(
          children: [
            // AI助手头部 - 极简设计
            _buildMinimalAIHeader(),
            
            Space.h16, // 🔧 优化：减少顶部空白，从32px减少到16px
            
            // 故事卡片 - 🔧 优化：增加内容区域占比
            Expanded(
              flex: 8, // 给内容更多空间
              child: _buildStoryCards(),
            ),
            
            // 🔧 修复132像素溢出：进一步压缩底部空间
            Column(
              children: [
                Space.h8, // 🔧 进一步减少间距从16到8
                
                // 极简摇一摇按钮
                _buildCompactShakeButton(), // 使用紧凑版本
                
                Space.h8, // 🔧 减少底部空间
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMinimalAIHeader() {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Row(
        children: [
          // AI图标 - 移除呼吸动画以提升性能
          RepaintBoundary(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient, // 5%彩色焦点
                borderRadius: BorderRadius.circular(12), // 固定值
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08), // 固定阴影
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          
          Space.w16,
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '智能助手',
                style: AppTypography.titleMediumStyle(
                  isDark: false,
                ).copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w300,
                ),
              ),
              
              Space.h4,
              
              Text(
                '根据你的生活推荐',
                style: AppTypography.bodySmallStyle(
                  isDark: false,
                ).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStoryCards() {
    if (widget.recommendations.isEmpty) {
      return _buildEmptyState();
    }
    
    return PageView.builder(
      itemCount: widget.recommendations.length,
      onPageChanged: (index) {
        setState(() {
          _currentStoryIndex = index;
        });
        _cardAnimationController.forward(from: 0);
        HapticFeedback.lightImpact();
      },
      itemBuilder: (context, index) {
        final story = widget.recommendations[index];
        
        return Padding(
          padding: AppSpacing.pagePadding,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _cardAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - _cardAnimation.value)),
                  child: Opacity(
                    opacity: _cardAnimation.value,
                    child: child!,
                  ),
                );
              },
              child: _buildStoryCard(story),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStoryCard(StoryRecommendation story) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 情境标签 - 5%彩色焦点
              Container(
                decoration: BoxDecoration(
                  gradient: story.gradient, // 5%彩色焦点
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusLarge),
                    topRight: Radius.circular(AppSpacing.radiusLarge),
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                      ),
                      child: Text(
                        story.context,
                        style: AppTypography.bodySmallStyle(
                          isDark: false,
                        ).copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 故事内容 - 使用灵活布局
              Padding(
                padding: AppSpacing.cardContentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 故事文案
                    Text(
                      story.narrative,
                      style: AppTypography.titleMediumStyle(
                        isDark: false,
                      ).copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                      ),
                    ),
                    
                    Space.h24,
                    
                    // 推荐卡片 - 移除固定高度约束
                    GestureDetector(
                      onTap: () {
                        widget.onRecommendationTap?.call(story);
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        ),
                        child: Row(
                          children: [
                            // 菜谱图标
                            Text(
                              story.icon,
                              style: const TextStyle(fontSize: 60), // 调整图标大小
                            ),
                            
                            Space.w16,
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    story.recipe,
                                    style: AppTypography.titleMediumStyle( // 调整字体大小
                                      isDark: false,
                                    ).copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  
                                  Space.h8,
                                  
                                  Text(
                                    story.reason,
                                    style: AppTypography.bodyMediumStyle(
                                      isDark: false,
                                    ).copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  
                                  if (story.cookingTime != null) ...[
                                    Space.h8,
                                    Text(
                                      '预计 ${story.cookingTime} 分钟',
                                      style: AppTypography.bodySmallStyle(
                                        isDark: false,
                                      ).copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    if (story.nutritionTip != null) ...[
                      Space.h16,
                      
                      // 营养提示
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            
                            Space.w8,
                            
                            Expanded(
                              child: Text(
                                story.nutritionTip!,
                                style: AppTypography.captionStyle(
                                  isDark: false,
                                ).copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    Space.h16, // 底部间距
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 🔧 新增紧凑版摇一摇按钮，减少padding防止溢出
  Widget _buildCompactShakeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24), // 🔧 减少padding
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_isShaking ? _shakeAnimation.value : 0, 0),
            child: GestureDetector(
              onTap: _shakeForNewRecommendation,
              child: RepaintBoundary(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20, // 🔧 减少横向padding
                    vertical: 12,   // 🔧 减少纵向padding
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(20), // 🔧 稍微减少圆角
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 18, // 🔧 稍微减少图标大小
                        color: AppColors.textPrimary,
                      ),
                      
                      Space.w4, // 🔧 减少间距
                      
                      Text(
                        '摇一摇换一个',
                        style: AppTypography.captionStyle( // 🔧 使用更小的字体
                          isDark: false,
                        ).copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMinimalShakeButton() {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_isShaking ? _shakeAnimation.value : 0, 0),
            child: GestureDetector(
              onTap: _shakeForNewRecommendation,
              child: RepaintBoundary(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      
                      Space.w8,
                      
                      Text(
                        '摇一摇换一个',
                        style: AppTypography.bodySmallStyle(
                          isDark: false,
                        ).copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          
          Space.h16,
          
          Text(
            '暂无推荐',
            style: AppTypography.titleMediumStyle(
              isDark: false,
            ).copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w300,
            ),
          ),
          
          Space.h8,
          
          Text(
            '稍后会为你生成个性化推荐',
            style: AppTypography.bodySmallStyle(
              isDark: false,
            ).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  void _shakeForNewRecommendation() {
    if (widget.recommendations.isEmpty) return;
    
    setState(() {
      _isShaking = true;
    });
    
    _shakeController.forward().then((_) {
      _shakeController.reverse().then((_) {
        setState(() {
          _isShaking = false;
          _currentStoryIndex = (_currentStoryIndex + 1) % widget.recommendations.length;
        });
        _cardAnimationController.forward(from: 0);
        widget.onShake?.call();
      });
    });
    
    HapticFeedback.mediumImpact();
  }
}