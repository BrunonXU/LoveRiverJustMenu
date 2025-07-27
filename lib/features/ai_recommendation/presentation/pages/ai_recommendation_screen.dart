import 'package:flutter/material.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../widgets/ai_story_widget.dart';
import '../../domain/models/story_recommendation.dart';

/// AI智能推荐页面
/// 已集成完整的故事化推荐系统，支持摇一摇和呼吸动画
class AiRecommendationScreen extends StatelessWidget {
  const AiRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取示例推荐数据
    final recommendations = RecommendationData.getSampleRecommendations();
    
    return Scaffold(
      body: AIStoryWidget(
        recommendations: recommendations,
        onRecommendationTap: (recommendation) {
          // 处理推荐点击
          _handleRecommendationTap(context, recommendation);
        },
        onShake: () {
          // 处理摇一摇
          _handleShake(context);
        },
      ),
    );
  }
  
  void _handleRecommendationTap(BuildContext context, StoryRecommendation recommendation) {
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
              color: AppColors.backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLarge),
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
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // 内容区域
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: AppSpacing.pagePadding,
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
                            
                            Space.w16,
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recommendation.recipe,
                                    style: AppTypography.titleLargeStyle(
                                      isDark: false,
                                    ).copyWith(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  
                                  Space.h8,
                                  
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: recommendation.gradient,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusCircle,
                                      ),
                                    ),
                                    child: Text(
                                      recommendation.context,
                                      style: AppTypography.captionStyle(
                                        isDark: false,
                                      ).copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        Space.h32,
                        
                        // 故事描述
                        Text(
                          recommendation.narrative,
                          style: AppTypography.titleMediumStyle(
                            isDark: false,
                          ).copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w300,
                            height: 1.6,
                          ),
                        ),
                        
                        Space.h24,
                        
                        // 推荐理由
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSecondary,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMedium,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              
                              Space.w8,
                              
                              Expanded(
                                child: Text(
                                  recommendation.reason,
                                  style: AppTypography.bodySmallStyle(
                                    isDark: false,
                                  ).copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        if (recommendation.nutritionTip != null) ...[
                          Space.h16,
                          
                          // 营养提示
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMedium,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                
                                Space.w8,
                                
                                Expanded(
                                  child: Text(
                                    recommendation.nutritionTip!,
                                    style: AppTypography.bodySmallStyle(
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
                        
                        Space.h24,
                        
                        // 菜谱信息
                        if (recommendation.cookingTime != null || 
                            recommendation.difficulty != null) ...[
                          Row(
                            children: [
                              if (recommendation.cookingTime != null) ...[
                                _buildInfoChip(
                                  icon: Icons.timer_outlined,
                                  label: '${recommendation.cookingTime} 分钟',
                                ),
                                
                                Space.w8,
                              ],
                              
                              if (recommendation.difficulty != null) ...[
                                _buildInfoChip(
                                  icon: Icons.star_outline,
                                  label: _getDifficultyText(recommendation.difficulty!),
                                ),
                              ],
                            ],
                          ),
                          
                          Space.h32,
                        ],
                        
                        // 开始烹饪按钮
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _startCooking(context, recommendation);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLarge,
                                ),
                              ),
                            ),
                            child: Text(
                              '开始烹饪',
                              style: AppTypography.titleMediumStyle(
                                isDark: false,
                              ).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
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
  
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          
          Space.w4,
          
          Text(
            label,
            style: AppTypography.captionStyle(
              isDark: false,
            ).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return '简单';
      case 2:
        return '容易';
      case 3:
        return '中等';
      case 4:
        return '困难';
      case 5:
        return '专业';
      default:
        return '未知';
    }
  }
  
  void _handleShake(BuildContext context) {
    // 显示摇一摇提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '已为你更换推荐！',
          style: AppTypography.bodyMediumStyle(
            isDark: false,
          ).copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _startCooking(BuildContext context, StoryRecommendation recommendation) {
    // 跳转到烹饪模式（或显示提示）
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '准备开始制作${recommendation.recipe}',
          style: AppTypography.bodyMediumStyle(
            isDark: false,
          ).copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
      ),
    );
  }
}